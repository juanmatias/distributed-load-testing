#!/bin/bash

# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#bail on fail
set -eo pipefail

LOCUST=( "/usr/local/bin/locust" )

LOCUST+=( -f ${LOCUST_SCRIPT:-/locust-tasks/tasks.py} )
LOCUST+=( --host=$TARGET_HOST )

LOCUST_MODE=${LOCUST_MODE:-standalone}
if [[ "$LOCUST_MODE" = "master" ]]; then
    LOCUST+=( --master)
elif [[ "$LOCUST_MODE" = "worker" ]]; then
    LOCUST+=( --slave --master-host=$LOCUST_MASTER)
    # wait for master
    while ! wget -qT5 $LOCUST_MASTER:$LOCUST_MASTER_WEB >/dev/null 2>&1; do
        echo "Waiting for master"
        sleep 5
    done
fi

echo "${LOCUST[@]}"

#replace bash, let locust handle signals
exec ${LOCUST[@]}
