#!/bin/bash

set -e

GOVERSION=1.25.5
GOLANG_CI_LINT_VERSION=2.7.2

GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
BOLD='\e[1m'
RESET='\e[0m'

repos=(
	debugging-sucks/agent-wrapper
	debugging-sucks/compute-infra
	debugging-sucks/concurrency
	debugging-sucks/ecies
	debugging-sucks/ecr-infra
	debugging-sucks/event-horizon-api-infra
	debugging-sucks/event-horizon-api-service
	debugging-sucks/event-horizon-hub-infra
	debugging-sucks/event-horizon-sdk-go
	debugging-sucks/event-horizon-ui
	debugging-sucks/event-horizon-ui-infra
	debugging-sucks/event-horizon-webhook-service
	debugging-sucks/event-horizon-webhook-service-infra
	debugging-sucks/openid
	debugging-sucks/proxy-service
	debugging-sucks/proxy-service-infra
	debugging-sucks/root-dns-terraform
	debugging-sucks/sigv4util
	debugging-sucks/terraform-account-factory
	debugging-sucks/terraform-manifest-k8s
	scottwis/dotfiles
)

checkout_repo() {
	repo=$1
	echo "===================================="
	if [ -d $(basename $repo) ]; then
		echo -e "${YELLOW}skipping repo $repo: directory already exists${RESET}"
	else
		echo -e "${GREEN}checking out repo $repo...${RESET}"
		git clone git@github.com:$repo
	fi

	echo "===================================="
}

popd() {
	command popd "$@" > /dev/null
}

pushd() {
	command pushd "$@" > /dev/null
}

checkout_repos() {
	mkdir -p ~/code
	for repo in ${repos[@]}
	do
		(cd ~/code && checkout_repo $repo)
	done
}

copy_personal_config() {
	echo "===================================="
	echo -e "${GREEN}copying config files...${RESET}"
	pushd ~/code/dotfiles/home/scott
	cp admin_connect.sh .gitconfig .tmux.conf .zprofile .zshrc .manpath ~
	cd .ssh
	mkdir -p ~/.ssh
	cp config ssm-ssh-proxy.sh ~/.ssh
	popd
	echo "===================================="
}

copy_dgx_spark_config() {
	echo "===================================="
	echo -e "${GREEN}copying dgx spark specific config files...${RESET}"

	rsync -avh ~/code/dotfiles/home/scott/.config ~
	rsync -avh ~/code/dotfiles/home/scott/.local ~
	update-desktop-database ~/.local/share/applications

	sudo mkdir -p /usr/share/backgrounds/scott
	sudo cp ~/code/dotfiles/usr/share/backgrounds/scott/* /usr/share/backgrounds/scott

	sudo mkdir -p /usr/share/icons/hicolor/512x512/apps
	sudo cp ~/code/dotfiles/usr/share/icons/hicolor/512x512/apps/* /usr/share/icons/hicolor/512x512/apps

	sudo cp ~/code/dotfiles/etc/apt/preferences.d/* /etc/apt/preferences.d
	sudo cp ~/code/dotfiles/etc/apt/sources.list.d/* /etc/apt/sources.list.d
	sudo cp ~/code/dotfiles/usr/share/keyrings/* /usr/share/keyrings
	echo "===================================="
}

install_on_dgx_spark() {
	echo "===================================="
	echo -e "${GREEN}installing various ubuntu software packages${RESET}"
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y \
		nvtop \
		cosmic-session \
		zsh \
		curl \
		wget \
		emacs-nox \
		fonts-powerline \
		flatpak \
		power-profiles-daemon \
		terraform \
		packer \
		helm \
		postgresql-client \
		xclip \
		libssl-dev \
		ruby-dev \
		build-essential \
		pipx \
		python3-venv \
		python3-dev


	flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub org.chromium.Chromium -y
	echo "===================================="

	echo "===================================="
		if [ -d /usr/local/go ]; then
		echo -e "${YELLOW}Skipping go install: already installed${RESET}"
	else
		echo -e "${GREEN}Installing go${RESET}"
		curl https://dl.google.com/go/go$GOVERSION.linux-arm64.tar.gz -o ~/Downloads/go$GOVERSION.tgz
		pushd ~/Downloads
		sudo tar -zxvf ~/Downloads/go$GOVERSION.tgz -C /usr/local
		popd
	fi

	if ! echo $PATH | grep /usr/local/go/bin; then
		export PATH="$PATH:/usr/local/go/bin"
	fi
	echo "===================================="

	echo "===================================="
	if [ ! -f /etc/default/grub ]; then
		echo -e "${RED}ERROR: /etc/default/grub not found${RESET}"
		exit -1
	elif grep "nvidia-drm.modeset=1" /etc/default/grub; then
		echo -e "${YELLOW}skipping drm modeset enablement: already enabled${RESET}"
	else
		echo -e "${GREEN}enabling drm modeset in grub config"
		sudo patch --forward /etc/default/grub ~/code/dotfiles/grub.patch
		sudo update-grub
	fi
	echo "===================================="

	echo "===================================="
	if [ -f ~/go/bin/k9s ]; then
		echo -e "${YELLOW}skipping k9s install: alredy installed${RESET}"
	else
		echo -e "${GREEN}installing k9s${RESET}"
		go install github.com/derailed/k9s@latest
	fi
	echo "===================================="

	echo "===================================="
	if which kubectl; then
		echo -e "${YELLOW}sipping kubectl install: already installed${REST}"
	else
		echo -e "${GREEN}installing kubectl${REST}"
		sudo snap install kubectl --classic
	fi
	echo "===================================="

	echo "===================================="
	if which node; then
		echo -e "${YELLOW}skipping nodejs installation: already installed${RESET}"
	else
		echo -e "${GREEN}installing nodejs${RESET}"
		curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
		sudo apt update && sudo apt install -y nodejs
	fi
	echo "===================================="

	echo "===================================="
	if which tailscale; then
		echo -e "${YELLOW}skipping tailscale install: already installed"
	else
		echo -e "${GREEN}installing tailscale"
		curl -fsSL https://tailscale.com/install.sh | sh
	fi
	echo "===================================="

	echo "===================================="
	if which fpm; then
		echo -e "${YELLOW}skipping fpm install: already installed"
	else
		echo -e "${GREEN}installing fpm"
		sudo gem i fpm -f
	fi
	echo "===================================="

	echo "===================================="
	if which checkov || pipx list --short | grep checkov; then
		echo -e "${YELLOW}skipping checkov install; already installed"
	else
		echo -e "${GREEN}installing checkov"
		pipx install checkov
	fi
	echo "===================================="}

install_oh_my_zsh() {
	echo "===================================="
	if [ -d ~/.oh-my-zsh ]; then
		echo -e "${YELLOW}Skipping oh my zsh: already installed${RESET}"
	else
		echo -e "${GREEN}installing oh my zsh${RESET}"

		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
	echo "===================================="

	echo "===================================="
	if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
		echo -e "${YELLOW}Skipping zsh-autosuggestions plugin: already installed${RESET}"
	else
		echo -e "${GREEN}Installing zsh-autosuggestions plugin"
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	fi
	echo "===================================="
}

install_rust() {
	echo "===================================="
	if [ -d ~/.cargo ]; then
		echo -e "${YELLOW}skipping rust: already installed${RESET}"
	else
		echo -e "${GREEN}installing rust${RESET}"
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	fi
	echo "===================================="
}

install_aws_cli() {
	echo "===================================="
	if which aws; then
		echo -e "${YELLOW}skipping aws cli install: already installed${RESET}"
	else
		echo -e "${GREEN}installing aws cli${RESET}"
		curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o ~/Downloads/awscliv2.zip
		pushd ~/Downloads
		unzip awscliv2.zip
		sudo ./aws/install
		popd
	fi
	echo "===================================="
}

bootstrap_aws_config() {
	echo "===================================="
	if [ -f ~/.aws/config ]; then
		echo -e "${YELLOW}skipping bootstrap of aws config: ~/.aws/config already exists${RESET}"
	else
		echo -e "${GREEN}bootstrapping aws config${RESET}"
		pushd ~/code/terraform-account-factory
		make bootstrap
		popd
	fi
	echo "===================================="

	echo "===================================="
	if grep "\[profile event-horizon-api\]" ~/.aws/config; then
		echo -e "${YELLOW}event-horizon-api profile already configured${RESET}"
	else
		echo -e "${GREEN}adding event-horizon-api profile to aws config${RESET}"
		SNIPPET=$(cat <<- EOF

		[profile event-horizon-api]
		source_profile = event-horizon-api-dev-us-east-2-admin
		role_arn = arn:aws:iam::802872447332:role/event-horizon-api
		region = us-east-2
		role_sesson=scott-debug-shiva
		output = json

		EOF
		)
		cat <<< ${SNIPPET} >> ~/.aws/config
	fi
	echo "===================================="


	echo "===================================="
	if grep "\[profile event-horizon-ui\]" ~/.aws/config; then
		echo -e "${YELLOW}event-horizon-ui profile already configured${RESET}"
	else
		echo -e "${GREEN}adding event-horizon-ui profile to aws config${RESET}"
		SNIPPET=$(cat <<- EOF

		[profile event-horizon-ui]
		source_profile = event-horizon-api-dev-us-east-2-admin
		role_arn = arn:aws:iam::802872447332:role/event-horizon-ui
		region = us-east-2
		role_sesson=scott-debug-shiva
		output = json

		EOF
		)
		cat <<< ${SNIPPET} >> ~/.aws/config
	fi
	echo "===================================="

	echo "===================================="
	if grep "\[profile agent-wrapper\]" ~/.aws/config; then
		echo -e "${YELLOW}agent-wrapper profile already configured${RESET}"
	else
		echo -e "${GREEN}adding agent-wrapper profile to aws config${RESET}"
		SNIPPET=$(cat <<- EOF

		[profile agent-wrapper]
		source_profile = compute-001-dev-us-east-2-admin
		role_arn = arn:aws:iam::357278409228:role/compute-001-dev-agent-wrapper-role
		region = us-west-2
		role_session = scott-debug-shiva
		output = json

		EOF
		)
		cat <<< ${SNIPPET} >> ~/.aws/config
	fi
	echo "===================================="

}

configure_kubectl_contexts() {
	echo "===================================="
	if [ -f ~/.kube/config ] && (grep "event-horizon-api-eks" ~/.kube/config && grep "compute-001-dev" ~/.kube/config) > /dev/null ; then
		echo -e "${YELLOW}Skipping event-horizon-api-eks config${RESET}"
	else
		echo -e "${GREEN}configuring event-horizon-api-eks config contexts${RESET}"
		if ! aws sts get-caller-identity --profile root-account-admin 2>&1 > /dev/null; then
			aws sso login --profile root-account-admin
		fi
		AWS_PROFILE="event-horizon-api-dev-us-east-2-admin" aws eks --region us-east-2 update-kubeconfig --name event-horizon-api-eks
		AWS_PROFILE="compute-001-dev-us-east-2-admin" aws eks --region us-east-2 update-kubeconfig --name compute-001-dev
	fi
	echo "===================================="
}

install_golang_ci_lint() {
	echo "===================================="
	if which golang-ci-lint; then
		echo -e "${YELLOW}skipping glang-ci-lint install: already installed${REST}"
	else
		echo -e "${GREEN}installing glang-ci-lint install${RESET}"
		go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v${GOLANG_CI_LINT_VERSION}
	fi
	echo "===================================="
}

install_pnpm() {
	echo "===================================="
	if which pnpm; then
		echo -e "${YELLOW}skipping pnpm install: already installed${REST}"
	else
		echo -e "${GREEN}installing pnpm${REST}"
		wget -qO- https://get.pnpm.io/install.sh | sh -
	fi
}

indicate_done() {
	echo ""
	echo -e "${RED}************************************************************${RESET}"
	echo -e "${RED}*                                                          *${RESET}"
	echo -e "${RED}* System configured successfully.                          *${RESET}"
	echo -e "${RED}*                                                          *${RESET}"
	echo -e "${RED}* NOTE: If this is a fresh install, you need to reboot.    *${RESET}"
	echo -e "${RED}*                                                          *${RESET}"
	echo -e "${RED}************************************************************${RESET}"
	echo ""
}

checkout_repos
copy_personal_config
copy_dgx_spark_config
install_on_dgx_spark
install_oh_my_zsh
install_rust
install_aws_cli
bootstrap_aws_config
configure_kubectl_contexts
install_golang_ci_lint
install_pnpm
indicate_done
