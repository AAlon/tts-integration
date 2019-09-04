#!/bin/bash

if [ -f "./travis" ]; then
    export TRAVIS=true
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
workspace=${SCRIPT_DIR}
source /opt/ros/dashing/local_setup.bash

if [ ! -f "./install/local_setup.bash" ]; then
    echo "Building workspace"
    if [ "$TRAVIS" != true ]; then
        rosws update
        rosdep install --from-paths src --ignore-src -r -y
        colcon build
    fi
fi

if [ "$TRAVIS" != true ]; then
    upstream_workspace=.
else
    upstream_workspace=/root/upstream_ws
    . .creds
fi
source ${upstream_workspace}/install/local_setup.bash

echo "Running tts_integration.py"
cp $(find ${upstream_workspace} -name "tts_integration.py") /tmp/tts_integration.py
cd /tmp
launch_test tts_integration.py
exit_code=$?
exit ${exit_code}
