#!/bin/bash
#
# Dracut Module Initialization Script
# 

# Check Function -- return 1 so we're never included by default
check() {
  return 1
}

install() {
  inst_hook pre-mount 99 "$moddir/jban.sh"
}
