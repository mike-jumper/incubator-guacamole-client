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
## @fn stage-schema-upgrade.sh
##
## Resets the guacamole-auth-jdbc schema files to the version associated with
## the latest Apache Guacamole release, additionally creating
## "003-apply-upgrade.sql" files which apply the latest upgrade script for
## each guacamole-auth-jdbc module.
##
## This can be used to automatically test that the schema resulting from
## applying the upgrade script to the previous release behaves identically to
## the schema resulting from applying the latest schema scripts on a fresh
## database.
##

##
## The absolute path to the directory containing the guacamole-client source.
##
BASE_DIR="$(realpath "$(dirname "$0")/../..")"

# Run within guacamole-auth-jdbc source directory
cd "$BASE_DIR/extensions/guacamole-auth-jdbc/"

##
## The name of the tag for the latest Apache Guacamole release, determined as
## the most recent tag that applies to the parent of the current commit.
##
PREV_RELEASE="$(git describe --abbrev=0 --tags HEAD^1)"

#
# Temporarily revert schema files back to specific version
#

echo "Resetting base schema to version $PREV_RELEASE ..."
git checkout "$PREV_RELEASE" -- modules/guacamole-auth-jdbc-*/schema/00[12]*.sql
git reset HEAD modules/guacamole-auth-jdbc-*/schema/00[12]*.sql

#
# Create symbolic link which applies the latest upgrade script
#

echo "Creating additional 003-apply-upgrade.sql ..."
for DIR in modules/guacamole-auth-jdbc-*/schema/; do

    # Find upgrade script having the highest version number
	UPGRADE="$(ls "$DIR/upgrade/upgrade-pre-"*.sql \
		| sort --version-sort --reverse            \
        | head -n1)"

    ln -sf "upgrade/$(basename "$UPGRADE")" $DIR/003-apply-upgrade.sql

done

#
# Done
#

