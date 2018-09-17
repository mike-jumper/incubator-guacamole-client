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
# Dockerfile for a pre-initialized SQL Server database for Apache Guacamole
#

ARG SQLSERVER_VERSION=2017-latest
FROM microsoft/mssql-server-linux:${SQLSERVER_VERSION}

# Add schema scripts
COPY extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-sqlserver/schema/ /opt/guacamole/schema
COPY test/databases/sqlserver/bin/initdb.sh /opt/guacamole/initdb.sh
COPY test/databases/sqlserver/bin/entrypoint.sh /opt/guacamole/entrypoint.sh

CMD [ "/opt/guacamole/entrypoint.sh" ]

