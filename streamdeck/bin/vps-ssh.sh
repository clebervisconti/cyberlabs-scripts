#!/bin/bash
# SSH into the HostGator VPS using the `hostgator` alias from ~/.ssh/config.
source "$(dirname "$0")/../lib.sh"
term "ssh hostgator"
