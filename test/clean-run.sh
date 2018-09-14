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
## @fn clean-run.sh
##
## Runs the defined set of REST API tests on a fresh deployment of
## Apache Guacamole within Docker. The deployment is given an empty
## database, also within Docker. The various Docker resources involved
## are only used temporarily and are cleaned up upon completion.
##
## By default, tests will be performed against a PostgreSQL database, and the
## Docker image cache is not used. To make use of the Docker image cache to
## speed up future test runs, use the "-C" option. To use a different database,
## specify the "-d DATABASE" option, where DATABASE is any one of the following
## values:
##
##     "mysql"
##     "postgres"
##     "sqlserver"
##
## After the test script has finished, a copy of the Guacamole web application
## logs can be found at:
##
##     target/clean-run/logs/guacamole.log
##
## Debug-level logging is enabled.
##

##
## Whether the Docker image cache should be used. If the Docker image cache
## should be used, this will be set to a non-zero value. By default, the
## Docker image cache will NOT be used (for the sake of keeping the ASF
## Jenkins build slaves clean), and this will be set to zero.
##
USE_CACHE=0

##
## The unique suffix to append to each Docker resource created by this script.
##
SUFFIX="guac-test-$$"

##
## The type of database to test against. By default, PostgreSQL will be used,
## but this can be overridden with the "-d DATABASE" option, where DATABASE
## is one of:
##
##     "mysql"
##     "postgres"
##     "sqlserver"
##
DATABASE="postgres"

##
## Prints the given error message, advises the user of correct usage of this
## script, and exits the script with an error code.
##
## @param MESSAGE
##     The message to print.
##
invalid_usage() {
    MESSAGE="$1"
    cat <<END
$MESSAGE

USAGE: clean-run.sh [-C] [-d postgres | mysql | sqlserver]
END
    exit 1
}

#
# Parse command line arguments
#

while getopts ":Cd:" OPT; do
    case $OPT in

        # Enable cache if requested
        C)
            USE_CACHE=1
            SUFFIX="guac-test"
            ;;

        # Allow default database (postgres) to be overridden
        d)
            DATABASE="$OPTARG"
            ;;

        # Handle invalid arguments
        \?)
            invalid_usage "Invalid option: -$OPTARG"
            ;;
        :)
            invalid_usage "Option -$OPTARG requires an argument."
            ;;

    esac
done

##
## The absolute path to the directory containing the guacamole-client source.
##
BASE_DIR="$(realpath "$(dirname "$0")/..")"

##
## The directory that the Guacamole web application logs should be saved to
## upon completion of the test.
##
LOG_DIR="$BASE_DIR/target/clean-run/logs"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

##
## The name of the Docker network created by this script and shared by the
## Docker containers created by this script.
##
NETWORK="net-$SUFFIX"

##
## The tag to assign to guacamole-client Docker images built by this script.
##
GUAC_TAG="guac-image-$SUFFIX"

##
## The name to assign to the guacamole-client Docker container created by this
## script.
##
GUAC_CONTAINER="guac-$SUFFIX"

##
## The tag to assign to Guacamole database Docker images built by this script.
##
DATABASE_TAG="database-image-$SUFFIX"

##
## The tag to assign to test runner Docker images built by this script.
##
TEST_TAG="test-image-$SUFFIX"

##
## The name to assign to the Guacamole database Docker container created by
## this script.
##
DATABASE_CONTAINER="database-$SUFFIX"

##
## Performs cleanup after the test has completed. All Docker containers and
## the Docker network bridge are removed. If cache is not being used (the
## default), the images used for the containers are removed as well.
##
cleanup() {
    echo "Beginning cleanup..."

    # Clean up containers
    docker kill "$GUAC_CONTAINER" || true
    docker kill "$DATABASE_CONTAINER" || true

    # Clean up network shared between containers
    docker network rm "$NETWORK" || true

    # Save Guacamole logs and remove container
    (docker logs "$GUAC_CONTAINER" &> "$LOG_DIR/guacamole.log") || true
    docker rm "$GUAC_CONTAINER" || true

    # Clean up images if not using cache
    if [ "$USE_CACHE" -eq 0 ]; then
        docker rmi --force "$GUAC_TAG" || true
        docker rmi --force "$DATABASE_TAG" || true
        docker rmi --force "$TEST_TAG" || true
    fi

    echo "Cleanup complete."
}

# Clean up resources automatically upon exit
trap "cleanup" EXIT

#
# Set database-specific values
#

case "$DATABASE" in

    postgres)
        DATABASE_VAR_PREFIX="POSTGRES"
        DATABASE_MODULE="guacamole-auth-jdbc-postgresql"
        DATABASE_OPTS=""
        ;;

    mysql)
        DATABASE_VAR_PREFIX="MYSQL"
        DATABASE_MODULE="guacamole-auth-jdbc-mysql"
        DATABASE_OPTS="-e MYSQL_ROOT_PASSWORD=secret"
        ;;

    sqlserver)
        DATABASE_VAR_PREFIX="SQLSERVER"
        DATABASE_MODULE="guacamole-auth-jdbc-sqlserver"
        DATABASE_OPTS="-e SA_PASSWORD=SecretPassword123 -e ACCEPT_EULA=Y"
        ;;

    # Bail out if database is unknown
    *)
        invalid_usage "Unknown database type: $DATABASE"
        ;;

esac

#
# Build/refresh Docker images
#

# Allow use of Docker image cache if USE_CACHE is not zero
CACHE_OPTS="--no-cache=true --rm"
if [ "$USE_CACHE" -ne 0 ]; then
    CACHE_OPTS=""
fi

# Build guacamole-client image
cd "$BASE_DIR/"
docker build $CACHE_OPTS --tag "$GUAC_TAG" .

# Build PostgreSQL database image
cd "$BASE_DIR/extensions/guacamole-auth-jdbc/modules/$DATABASE_MODULE/"
docker build $CACHE_OPTS --tag "$DATABASE_TAG" .

# Build test runner image
cd "$BASE_DIR/test/"
docker build $CACHE_OPTS --tag "$TEST_TAG" .

#
# Perform test
#

# Create network shared between containers during the test
docker network create "$NETWORK"

# Create and initialize a fresh Guacamole database
docker run -d --rm --net "$NETWORK" --name "$DATABASE_CONTAINER" \
    -e GUACAMOLE_DB_NAME=guacamole_db                            \
    -e GUACAMOLE_DB_USER=guacamole_user                          \
    -e GUACAMOLE_DB_PASSWORD=S0me_P@s5woRD                       \
    $DATABASE_OPTS                                               \
    "$DATABASE_TAG"

# Start a Guacamole instance connected to that database
docker run -d --net "$NETWORK" --name "$GUAC_CONTAINER"               \
    -v "$BASE_DIR/test/debug-guacamole-home:/debug-guacamole-home"    \
    -e ${DATABASE_VAR_PREFIX}_HOSTNAME="$DATABASE_CONTAINER.$NETWORK" \
    -e ${DATABASE_VAR_PREFIX}_DATABASE=guacamole_db                   \
    -e ${DATABASE_VAR_PREFIX}_USER=guacamole_user                     \
    -e ${DATABASE_VAR_PREFIX}_PASSWORD=S0me_P@s5woRD                  \
    -e GUACAMOLE_HOME=/debug-guacamole-home                           \
    -e GUACD_HOSTNAME=localhost                                       \
    -e GUACD_PORT=4822                                                \
    "$GUAC_TAG"

# Execute tests against the Guacamole instance just created
docker run -t --rm --net "$NETWORK"                                   \
    -e GUACAMOLE_URL="http://$GUAC_CONTAINER.$NETWORK:8080/guacamole" \
    "$TEST_TAG"

