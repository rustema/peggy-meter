#!/bin/bash

/usr/local/xctool/xctool.sh -scheme PassiveDataKit -reporter json-compilation-database:compile_commands.json clean build
/usr/local/oclint/bin/oclint-json-compilation-database -e AFNetworking -e mixpanel-iphone
