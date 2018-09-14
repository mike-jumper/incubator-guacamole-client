#!/bin/bash -e
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

##
## @fn entrypoint.sh
##
## Starts the SQL Server database, initializing it with the Guacamole
## schema if this has not already occurred.
##

##
## Tests whether SQL Server is currently online and available.
##
## @return
##     Zero (success) if SQl Server is online, one (failure) if SQl Server is
##     not yet online.
##
sqlserver_available() {
    /opt/mssql-tools/bin/sqlcmd              \
        -S localhost -U sa -P "$SA_PASSWORD" \
        -d master -i /dev/null 2> /dev/null || return 1
}

##
## Tests whether a database having the given name exists within SQL Server.
##
## @param DBNAME
##     The name of the database to test for.
##
## @return
##     Zero (success) if the database exists, one (failure) if the database
##     does not exist.
##
database_exists() {
    DBNAME="$1"
    /opt/mssql-tools/bin/sqlcmd              \
        -S localhost -U sa -P "$SA_PASSWORD" \
        -d master -b -Q "USE $DBNAME" &> /dev/null || return 1
}

#
# Start SQL Server in background
#

/opt/mssql/bin/sqlservr &

#
# Wait up to 120 seconds for SQL Server to come online
#

echo "Verifying SQL Server is available..."
for TRIES_REMAINING in `seq 12 -1 0`; do

    # Stop once SQL Server is available
    if sqlserver_available; then
        break
    fi

    # Give up after all tries have been exhausted
    if [ "$TRIES_REMAINING" -eq 0 ]; then
        echo "SQL Server still unavailable. Giving up."
        exit 1
    fi

    # Continue retrying as long as tries remain
    echo "SQL Server unavailable. Retrying..." \
         "($TRIES_REMAINING tries remaining)"
    sleep 10s

done

#
# Initialize database if it does not yet exist, exiting immediately if this
# fails
#

database_exists guacamole_db || /opt/guacamole/initdb.sh || exit 1

#
# Wait for SQL Server to exit
#

wait

