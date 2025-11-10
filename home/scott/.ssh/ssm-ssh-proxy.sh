#!/usr/bin/env bash
# Smart AWS-SSM proxy for SSH. Usage: ssm-ssh-proxy.sh <instance-id> <port>
set -Eeuo pipefail
trap 'echo "[proxy] failed on line $LINENO"; exit 1' ERR

TARGET="$1"
PORT="$2"

# Detect login user automatically if not set in ~/.ssh/config
REMOTE_USER="${SSH_REMOTE_USER:-ubuntu}"       # override with User in ssh_config if you like
REMOTE_HOME=$(printf '/home/%s' "$REMOTE_USER")

KEY="$HOME/.ssh/aws"
PUB="$KEY.pub"

# 1. Make sure we have a key
[[ -f $KEY && -f $PUB ]] || ssh-keygen -t ed25519 -N '' -C "ssm-ssh-key" -f "$KEY"

# 2. Ship the key only if it isn’t on the box yet
PUBKEY=$(<"$PUB")
PAYLOAD=$(cat <<JSON
{
  "commands": [
    "mkdir -p ${REMOTE_HOME}/.ssh",
    "touch ${REMOTE_HOME}/.ssh/authorized_keys",
    "chmod 0644 ${REMOTE_HOME}/.ssh/authorized_keys",
    "chown -R ${REMOTE_USER}:${REMOTE_USER} ${REMOTE_HOME}/.ssh",
    "install -d -m 700 -o ${REMOTE_USER} -g ${REMOTE_USER} ${REMOTE_HOME}/.ssh",
    "grep -qxF '${PUBKEY}' ${REMOTE_HOME}/.ssh/authorized_keys || \
     echo '${PUBKEY}' >> ${REMOTE_HOME}/.ssh/authorized_keys",
    "chmod 600 ${REMOTE_HOME}/.ssh/authorized_keys"
  ]
}
JSON
)

aws ssm send-command \
  --instance-ids "$TARGET" \
  --document-name "AWS-RunShellScript" \
  --parameters "$PAYLOAD" \
  --comment "Add local SSH pubkey for Session-Manager login" \
  --output text --query 'Command.CommandId' >/dev/null


aws ssm wait command-executed --instance-id "$TARGET" --command-id "$(aws ssm list-command-invocations --instance-id "$TARGET" --query 'CommandInvocations[0].CommandId' --output text | head -n 1)" >/dev/null

# 3. Hand off to Session Manager
exec aws ssm start-session --target "$TARGET" \
     --document-name AWS-StartSSHSession \
     --parameters "portNumber=${PORT}"

