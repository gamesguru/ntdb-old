:;
:;
:; # A script to connect to remote HelioHost postgreSQL server
:; # Set env vars:   PSQL_PASSWORD, PSQL_HOST
:;


:; # -- BASH -- #
:; . ./dotenv.sh
:; psql postgresql://nutra:$PSQL_PASSWORD@$PSQL_HOST:5432/nutra
:; exit

:; # - cmd.exe - #
setlocal
FOR /F "tokens=*" %%i in ('.env') do SET %%i
psql postgresql://nutra:%PSQL_PASSWORD%@%PSQL_HOST%:5432/nutra
endlocal
