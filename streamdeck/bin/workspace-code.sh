#!/bin/bash
# Open the whole workspace in VS Code.
source "$(dirname "$0")/../lib.sh"
require_root
open -a "Visual Studio Code" "$ROOT"
