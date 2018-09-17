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
## Initializes the MySQL database running within the current Docker
## container with Guacamole's schema, and creates a Guacamole-specific
## database user that the web application can use to query that database.
##

#
# Create Guacamole database
#

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
    CREATE DATABASE $GUACAMOLE_DB_NAME;
EOF

#
# Initialize database using schema scripts
#

cat /opt/guacamole/schema/*.sql | \
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$GUACAMOLE_DB_NAME"

#
# Create Guacamole-specific database user with only necessary permissions
#

mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$GUACAMOLE_DB_NAME" <<EOF
    CREATE USER '$GUACAMOLE_DB_USER' IDENTIFIED BY '$GUACAMOLE_DB_PASSWORD';
    GRANT SELECT,INSERT,UPDATE,DELETE ON $GUACAMOLE_DB_NAME.*
        TO '$GUACAMOLE_DB_USER';
    FLUSH PRIVILEGES;
EOF

