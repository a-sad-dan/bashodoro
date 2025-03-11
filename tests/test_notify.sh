#!/bin/bash

set -euo pipefail

echo "Running Notify Tests..."
bash bin/notify.sh start
sleep 2
bash bin/notify.sh pause
sleep 2
bash bin/notify.sh complete
echo "Test Passed!"