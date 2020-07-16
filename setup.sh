#!/bin/bash

[ -d ~/.profile.d ] || mkdir -v ~/.profile.d
cp -v .profile.d/* ~/.profile.d/
[ -d ~/.aws/cli ] || mkdir -p -v ~/.aws/cli
cp -v .aws/cli/* ~/.aws/cli/
[ -d ~/bin ] || mkdir -p -v ~/bin
cp -v bin/* ~/bin/

