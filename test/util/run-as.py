#!/usr/bin/python3
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

import argparse
import os
import requests
import sys
import subprocess
import time
import urllib.parse

parser = argparse.ArgumentParser(description='Authenticates with an '
    'Apache Guacamole instace, running the given command within an '
    'environment that has the resulting auth token and data source '
    'identifier stored within environment variables.')

parser.add_argument('--tries', default=12, type=int)
parser.add_argument('--interval', default=5, type=int)
parser.add_argument('--url', required=True)
parser.add_argument('--username', required=True)
parser.add_argument('--password', required=True)
parser.add_argument('command', nargs='+')

args = parser.parse_args();

# Ensure base URL ends with trailing slash (necessary for urljoin() to work as
# expected)
base_url = args.url;
if not base_url.endswith('/'):
    base_url += '/'

# Produce URL of authentication endpoint
auth_url = urllib.parse.urljoin(base_url, 'api/tokens');

# Repeatedly attempt to authenticate (the backend database, etc. may not yet
# be ready)
for tries_remaining in reversed(range(args.tries)):

    # Attempt authentication using provided credentials
    try:
        response = requests.post(auth_url, data = {
            "username" : args.username,
            "password" : args.password
        });
        if response.ok:
            break

    # Ignore failures, simply retrying later if the request is not successful
    except requests.exceptions.RequestException:
        pass

    # If no more tries remain, give up now
    if tries_remaining == 0:
        sys.exit('Could not authenticate. Giving up.')

    # Otherwise, wait a bit and retry
    time.sleep(args.interval)
    print('Authentication failed (HTTP {}). Retrying... ({} tries '
            'remaining)'.format(response.status_code, tries_remaining))

# Extract token and data source from authentication result, storing their
# values as environment variables
auth_result = response.json()
username = auth_result['username']
token = auth_result['authToken']
data_source = auth_result['dataSource']

# Report success
print('Successfully authenticated as "{}".'.format(username))

# Run provided command within updated environment
os.environ['USERNAME'] = username
os.environ['TOKEN'] = token
os.environ['DATASOURCE'] = data_source
subprocess.check_call(args.command)

# Attempt authentication using provided credentials
token_url = urllib.parse.urljoin(auth_url + '/', token);
response = requests.delete(token_url);

# Warn if logout failed
if not response.ok:
    sys.exit('Logout failed for user "{}".'.format(username))

# All done
print('Successfully logged out as "{}".'.format(username))

