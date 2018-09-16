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
# Dockerfile for running tests against the Apache Guacamole REST API
#

ARG DEBIAN_VERSION=stable
FROM debian:${DEBIAN_VERSION}

# Bring environment up to date and install
RUN apt-get update                 && \
    apt-get install -y python3-pip

#
# Install python dependencies of REST API tests
#

RUN pip3 install --no-cache-dir \
    gabbi                       \
    requests

#
# Copy test runner script and dependent utilities
#

COPY local-run.sh /opt/guacamole/test/local-run.sh
COPY util/ /opt/guacamole/test/util

#
# Copy REST service tests
#

COPY test-suites /opt/guacamole/test/test-suites

#
# Container should run tests upon startup
#

ENV PYTHONIOENCODING UTF-8
CMD /opt/guacamole/test/local-run.sh "$GUACAMOLE_URL"

