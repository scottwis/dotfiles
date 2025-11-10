export PGPASSWORD=$(aws dsql generate-db-connect-admin-auth-token \
--region us-east-2 \
--expires-in 3600 \
--hostname aiabui4qj4tzepgdw5sf5yc264.dsql.us-east-2.on.aws)

#PGPASSWORD=$(aws dsql generate-db-connect-auth-token --hostname tmabtw3svuq5o33rhy7wvhlyai.dsql.us-east-2.on.aws --region us-east-2)

PGSSLMODE=require psql --dbname postgres --username admin --host aiabui4qj4tzepgdw5sf5yc264.dsql.us-east-2.on.aws $*
