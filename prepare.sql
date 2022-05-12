select pg_terminate_backend (pid) from pg_stat_activity where datname = '$PG_TO_DB' and pid <> pg_backend_pid();

alter database "$PG_TO_DB" rename to "$PG_OLD_DB_NAME";

create database "$PG_TO_DB" OWNER "$PG_TO_USER";

grant all privileges on database "$PG_TO_DB" to "$PG_TO_USER";

DROP DATABASE "$PG_OLD_DB_NAME";
