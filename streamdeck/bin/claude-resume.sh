#!/bin/bash
# Pick up the last Claude Code conversation in the workspace root.
source "$(dirname "$0")/../lib.sh"
require_root
term "cd '$ROOT' && claude --continue"
