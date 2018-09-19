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
## @fn initdb.sh
##
## Initializes the SQL Server database running within the current Docker
## container with Guacamole's schema, and creates a Guacamole-specific
## database user that the web application can use to query that database.
##

#
# Create Guacamole database and user account
#

/opt/mssql-tools/bin/sqlcmd              \
    -S localhost -U sa -P "$SA_PASSWORD" \
    -d master -b <<END

    CREATE DATABASE $GUACAMOLE_DB_NAME;
    GO

    ALTER DATABASE $GUACAMOLE_DB_NAME SET COMPATIBILITY_LEVEL = $COMPAT_LEVEL;
    GO

    CREATE LOGIN $GUACAMOLE_DB_USER WITH PASSWORD = '$GUACAMOLE_DB_PASSWORD';
    GO

    USE $GUACAMOLE_DB_NAME;
    GO

    CREATE USER $GUACAMOLE_DB_USER;
    GO

    ALTER ROLE db_datawriter ADD MEMBER $GUACAMOLE_DB_USER;
    ALTER ROLE db_datareader ADD MEMBER $GUACAMOLE_DB_USER;
    GO

EXIT
END

#
# Initialize database using schema scripts
#

for SCRIPT in /opt/guacamole/schema/*.sql; do
    echo "Running $SCRIPT ..."
    /opt/mssql-tools/bin/sqlcmd              \
        -S localhost -U sa -P "$SA_PASSWORD" \
        -d "$GUACAMOLE_DB_NAME" -b -i "$SCRIPT"
done

