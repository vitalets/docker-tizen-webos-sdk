#!/usr/bin/env bash

cmd() {
  echo $(docker run -it --rm -v /.webos vitalets/tizen-webos-sdk $@) | tr -d '\r'
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

assert "$(cmd tizen version)" "Tizen CLI 2.5.21"
assert "$(cmd sdb version)" "Smart Development Bridge version 4.2.12"
assert "$(cmd ares-setup-device --version)" "Version: 1.10.4-j1703-k"
