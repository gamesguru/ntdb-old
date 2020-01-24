:;
:;
:; # A script to connect to remote HelioHost postgreSQL server
:; # Set env vars:   PSQL_PASSWORD, PSQL_HOST
:;


:; # -- BASH -- #
:; source .env
:; psql -c "ALTER ROLE routesim_admin SET search_path TO cz;" postgresql://routesim_admin:$PSQL_PASSWORD@$PSQL_HOST:5432/routesim_dev
:; psql postgresql://routesim_admin:$PSQL_PASSWORD@$PSQL_HOST:5432/routesim_dev
:; exit

:; # - cmd.exe - #
setlocal
FOR /F "tokens=*" %%i in ('.env') do SET %%i
psql postgresql://routesim_admin:%PSQL_PASSWORD%@%PSQL_HOST%:5432/routesim_dev
endlocal
