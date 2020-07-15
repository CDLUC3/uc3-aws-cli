#!/bin/bash

[ -d ~/.profile.d ] || mkdir ~/.profile.d
cp .profile.d/* ~/.profile.d/
[ -d ~/.aws/cli ] || mkdir -p ~/.aws/cli
cp .aws/cli/* ~/.aws/cli/
[ -d ~/bin ] || mkdir -p ~/bin
cp bin/* ~/bin/

