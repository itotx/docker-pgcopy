FROM postgres:13

ENV PG_FROM_HOST="" \
    PG_FROM_PORT="5434" \
    PG_FROM_DB="" \
    PG_FROM_USER="" \
    PG_FROM_PASS="" \
    PG_TO_HOST="" \
    PG_TO_PORT="5433" \
    PG_TO_DB="" \
    PG_TO_USER="" \
    PG_TO_PASS="" \
    PG_DEFAULT_DB="postgres"  
    
    
RUN apt-get update && apt-get -y install gettext-base && apt-get clean
RUN mkdir -p /var/backups/
COPY ./prepare.sql /var/backups/

ENTRYPOINT echo "$(date +"%Y%m%d-%H-%M") - job start" && \
    cd /var/backups/ && \
    PG_BACKUP_FILENAME=$PG_FROM_DB-$(date +"%Y%m%d-%H-%M").sql && \
    export PG_OLD_DB_NAME=$PG_TO_DB$(date +"%Y%m%d%H%M") && \
    envsubst < prepare.sql > prepare.with.env.sql && \
    cat prepare.with.env.sql && \
    PGPASSWORD="$PG_FROM_PASS" pg_dump -U $PG_FROM_USER -h $PG_FROM_HOST -p $PG_FROM_PORT $PG_FROM_DB > $PG_BACKUP_FILENAME && \
    PGPASSWORD="$PG_TO_PASS" psql -h "$PG_TO_HOST"  -p "$PG_TO_PORT" -U "$PG_TO_USER" $PG_DEFAULT_DB -a -f prepare.with.env.sql && \
    PGPASSWORD="$PG_TO_PASS" psql -h "$PG_TO_HOST"  -p "$PG_TO_PORT" -U "$PG_TO_USER" $PG_TO_DB -a -f $PG_BACKUP_FILENAME && \
    rm -f $PG_BACKUP_FILENAME && \
    ls -l && \
    echo "$(date +"%Y%m%d-%H-%M") - job complete"
