#!/usr/bin/env bash

set -e

PREFIX="🍰  "
echo "$PREFIX Running $(basename $0)"


echo "$PREFIX Setting up git configuration to support .gitconfig in devcontainer root"
git config --local --get include.path | grep -e ../.devcontainer/denmark/.gitconfig >/dev/null 2>&1 || git config --local --add include.path ../.devcontainer/denmark/.gitconfig


echo "$PREFIX SUCCESS"
exit 0