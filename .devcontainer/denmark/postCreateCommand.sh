#!/usr/bin/env bash

set -e

PREFIX="🍰  "
echo "$PREFIX Running $(basename $0)"

# Set PYTHONPATH
export PYTHONPATH=/workspace


echo "$PREFIX Setting up safe git repository to prevent dubious ownership errors"
git config --global --add safe.directory /workspace

echo "$PREFIX Setting up git configuration to support .gitconfig in repo-root"
git config --local --get include.path | grep -e ../.gitconfig >/dev/null 2>&1 || git config --local --add include.path ../.gitconfig

echo "$PREFIX Setting up the uv environment"
uv venv
. .venv/bin/activate
uv sync --extra dev

# Check if the GH CLI is required
if [ -e $(dirname $0)/_temp.token ]; then
    $(dirname $0)/gh-login.sh postcreate
    echo "$PREFIX setting up GitHub CLI"
    echo "$PREFIX Installing the techcollective/gh-tt gh cli extension"
    gh extension install thetechcollective/gh-tt --pin stable
    echo "$PREFIX Installing the gh aliases"    
    gh alias import .devcontainer/.gh_alias.yml --clobber

fi

# Define certificate path and name
CERT_PATH="/workspace"
CERT_NAME="localhost+2"

# Check if SSL certificates exist
if [[ ! -f "$CERT_PATH/$CERT_NAME.pem" || ! -f "$CERT_PATH/$CERT_NAME-key.pem" ]]; then
    echo "$PREFIX Generating self-signed SSL certificates..."

    # Install mkcert only if not installed
    if ! command -v mkcert &> /dev/null; then
        echo "$PREFIX Installing mkcert..."
        sudo apt update && sudo apt install -y mkcert libnss3-tools
        mkcert -install
    fi

    # Generate SSL certs
    mkcert -cert-file "$CERT_PATH/$CERT_NAME.pem" -key-file "$CERT_PATH/$CERT_NAME-key.pem" localhost 127.0.0.1 ::1
    echo "$PREFIX ✅ Certificates generated successfully!"
else
    echo "$PREFIX 🔒 SSL certificates already exist, skipping..."
fi

echo "$PREFIX SUCCESS"
exit 0