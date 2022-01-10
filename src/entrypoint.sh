#!/bin/bash
set -Eeuo pipefail

#set -x		# Uncomment for debugging

echo "Executing as '$(whoami)': $@"

exec "$@"