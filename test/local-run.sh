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
## @fn local-test.sh
##
## Runs a series of REST API tests against a given Apache Guacamole instance
## available over the local network.
##
## @param GUACAMOLE_URL
##     The URL of the Apache Guacamole instance to test.
##

GUACAMOLE_URL="$1"

# Verify a URL was provided
if [ -z "$GUACAMOLE_URL" ]; then
    echo "Please specify the URL of the Apache Guacamole instance to test." >&2
    exit 1
fi

# Ensure the current directory is directory containing this script
cd "$(dirname "$0")"

# Wait for Apache Guacamole to become ready
./util/wait-for-guac.py "$GUACAMOLE_URL"

# Run all tests as guacadmin
./util/run-as.py --username=guacadmin --password=guacadmin \
    --url="$GUACAMOLE_URL" -- gabbi-run "$GUACAMOLE_URL" -- admin-tests/*.yml

