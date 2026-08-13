#!/bin/bash
#
# prepare.sh
# Auto-dispatching entry point.
# Detects the OS and runs the appropriate prepare script.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
	Darwin)
		echo "Detected macOS → using prepare_macos.sh"
		exec "$SCRIPT_DIR/prepare_macos.sh" "$@"
		;;
	Linux)
		echo "Detected Linux → using prepare_linux.sh"
		exec "$SCRIPT_DIR/prepare_linux.sh" "$@"
		;;
	*)
		echo "Unsupported OS: $(uname -s)"
		echo "You can run ./prepare_macos.sh or ./prepare_linux.sh directly."
		exit 1
		;;
esac
