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

#
# Dockerfile for a pre-initialized MariaDB database for Apache Guacamole
#

ARG MARIADB_VERSION=10.3
FROM mariadb:${MARIADB_VERSION}

# Add schema scripts
COPY extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-mysql/schema/ /opt/guacamole/schema

# Copy database initialization script to location where MariaDB will run it
# automatically
COPY test/databases/mariadb/bin/initdb.sh /docker-entrypoint-initdb.d/initdb.sh

