#!/bin/bash

set -euo pipefail

echo "Running Timer Tests..."
bash bin/timer.sh start 2
echo "Test Passed!"
