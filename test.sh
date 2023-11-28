#!/usr/bin/env bash

cmd() {
  echo $(docker run -it --rm --platform linux/amd64 -v /home/developer vitalets/tizen-webos-sdk $@) | tr -d '\r'
}

assert() {
  local actual="$1"
  local expected="$2"
  if [ "$actual" == "$expected" ]; then
    echo "OK: \"$expected\""
  else
    echo "ERROR: \"$actual\" != \"$expected\""
    exit 1
  fi
}

assert "$(cmd tizen version)" "Tizen CLI 2.5.25"
assert "$(cmd sdb version)" "Smart Development Bridge version 4.2.25"
assert "$(cmd ares -V)" "webOS TV CLI Version: 1.12.4-j27"
