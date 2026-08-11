#!/bin/bash
# Fresh Claude Code session in the workspace root.
source "$(dirname "$0")/../lib.sh"
require_root
term "cd '$ROOT' && claude"
