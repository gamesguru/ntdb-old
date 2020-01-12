:;
:;
:; # A script to start the PostgreSQL server locally
:; # Set env var:   PSQL_LOCAL_DB_DIR
:;


:; # -- BASH -- #
:; sudo chown -R $LOGNAME:$LOGNAME /var/run/postgresql
:; source .env
:; pg_ctl initdb -D $PSQL_LOCAL_DB_DIR -l $PSQL_LOCAL_DB_DIR/postgreslogfile || true
:; pg_ctl -D $PSQL_LOCAL_DB_DIR -l $PSQL_LOCAL_DB_DIR/postgreslogfile start || true
:; psql postgresql://$LOGNAME@localhost:5432/nutra
:; exit


:; # Note: Must create db usatt from /postgres
:; # Note: On Windows, must create superuser "Shane" or %USERNAME% from php my pg admin
:; # - cmd.exe - #
setlocal
FOR /F "tokens=*" %%i in ('.env') do SET %%i
pg_ctl initdb -D %PSQL_LOCAL_DB_DIR% -l %PSQL_LOCAL_DB_DIR%/postgreslogfile
pg_ctl -D %PSQL_LOCAL_DB_DIR% -l %PSQL_LOCAL_DB_DIR%/postgreslogfile start
psql postgresql://%USERNAME%:password@localhost:5432/nutra
endlocal
