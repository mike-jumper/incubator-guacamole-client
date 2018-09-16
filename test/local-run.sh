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

##
## Prints an arbitrary message, clearly highlighting the message with a text
## art box and blank lines.
##
## @param MESSAGE
##     The message to display.
##
echo_header() {

    MESSAGE="$*"
    LINE="`sed s/./-/g <<<"$MESSAGE"`"

    cat <<END

+-$LINE-+
| $MESSAGE |
+-$LINE-+

END
}

#
# Notify that the tests are now actually beginning
#

echo_header "Beginning tests"

#
# Print a clear warning if tests fail
#

trap 'echo_header "FAILED :("' ERR

# Ensure the current directory is directory containing this script
cd "$(dirname "$0")"

# Wait for Apache Guacamole to become ready
./util/wait-for-guac.py "$GUACAMOLE_URL"

# Prepare test environment
echo_header "Preparing environment"
./util/run-as.py --username=guacadmin --password=guacadmin \
    --url="$GUACAMOLE_URL" -- gabbi-run "$GUACAMOLE_URL" -- test-suites/prepare/*.yml

# Run tests which require sysadmin privileges
echo_header "Running system administrator tests"
./util/run-as.py --username=guacadmin --password=guacadmin \
    --url="$GUACAMOLE_URL" -- gabbi-run "$GUACAMOLE_URL" -- test-suites/sysadmin/*.yml

# Run all management tests as guacadmin (full sysadmin user)
echo_header "Running management tests as full system-level admin"
./util/run-as.py --username=guacadmin --password=guacadmin \
    --url="$GUACAMOLE_URL" -- gabbi-run "$GUACAMOLE_URL" -- test-suites/management/*.yml

# Run all management tests as testadmin (normal user with admin permissions)
echo_header "Running management tests as normal user with admin permissions"
./util/run-as.py --username=testadmin --password=testadmin \
    --url="$GUACAMOLE_URL" -- gabbi-run "$GUACAMOLE_URL" -- test-suites/management/*.yml

#
# If we got this far, all tests passed!
#

echo_header "SUCCESS! :)"

