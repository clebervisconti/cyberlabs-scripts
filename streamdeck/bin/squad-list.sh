#!/bin/bash
# Squad inventory and recent runs, in a Terminal window you can read and close.
source "$(dirname "$0")/../lib.sh"
term "cd '$ROOT/squads/management' && node bin/squad.js list && echo && node bin/squad.js runs | tail -20"
