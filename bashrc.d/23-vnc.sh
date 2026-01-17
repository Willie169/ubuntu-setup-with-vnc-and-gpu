#!/bin/bash

alias vnc='vncserver'
alias vnck='vncserver -kill'
alias vncl='vncserver -list'

xdgset() {
  if [ -z "$TMPDIR" ] || [ -n "$TMPDIR" ]; then
    export XDG_RUNTIME_DIR="$TMPDIR/runtime-root"
  else
    export XDG_RUNTIME_DIR="/tmp/runtime-root"
  fi
  mkdir -p $XDG_RUNTIME_DIR
  export DISPLAY="$1"
}

vncclean() {
  if [ $# -ne 1 ] || ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Usage: vncclean <display_number>" >&2
    return 1
  fi

  if [ -z "$TMPDIR" ] || [ -n "$TMPDIR" ]; then
    rm -f "$TMPDIR/.X${1}-lock"
    rm -f "$TMPDIR/.X11-unix/.X${1}"
  else
    rm -f "/tmp/.X${1}-lock"
    rm -f "/tmp/.X11-unix/.X${1}"
  fi
}
