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
import requests
import sys
import time 

parser = argparse.ArgumentParser(description='Periodically polls a given '
        'Apache Guacamole deployment, exiting successfully only once the '
        'deployment becomes available. If the deployment never becomes '
        'available, this script will exit with an error code.')

parser.add_argument('--tries', default=6, type=int)
parser.add_argument('--interval', default=5, type=int)
parser.add_argument('URL')
args = parser.parse_args();

print('Waiting for Apache Guacamole to be ready...')
for tries_remaining in reversed(range(args.tries)):

    # Attempt to retrieve index.html
    try:
        response = requests.get(args.URL);
        if response.ok:
            break

    # Ignore failures, simply retrying later if the request is not successful
    except requests.exceptions.RequestException:
        pass

    # If no more tries remain, give up now
    if tries_remaining == 0:
        sys.exit('Guacamole did not become ready in time. Giving up.')

    # Otherwise, wait a bit and retry
    time.sleep(args.interval)
    print('Not yet ready. Retrying... ({} tries '
            'remaining)'.format(tries_remaining))

# Success!
print('Guacamole is ready.')

