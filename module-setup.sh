#!/bin/bash
#
# Dracut Module Initialization Script
# 

# Check Function -- return 1 so we're never included by default
check() {
  . $(dirname $0)/check
}

install() {
  . $(dirname $0)/install
}
