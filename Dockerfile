# Use the Ubuntu version with all packages required by VS Code pre-installed.
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-18.04

# Use the default non-root user from the base image.
USER vscode

# Avoid warnings by temporarily switching to non-interactive mode.
ARG DEBIAN_FRONTEND=noninteractive

# Define the GitHub fingerprint to add to known hosts.
# https://help.github.com/en/github/authenticating-to-github/githubs-ssh-key-fingerprints
ARG GITHUB_FINGERPRINT=SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8

# Update packages lists.
RUN sudo apt-get update \
  # Install software-properties-common to be able to add PPA in Ubuntu.
  && sudo apt-get install -y software-properties-common \
  # Add Git-Core PPA, which provides the latest Git version.
  && sudo apt-add-repository ppa:git-core/ppa \
  # Install packages.
  && sudo apt-get install -y \
  git \
  build-essential \
  # Clean up packages.
  && sudo apt-get autoremove -y \
  && sudo apt-get clean -y \
  && sudo rm -rf /var/lib/apt/lists/* \
  # Create the workspace directory for VS Code.
  && sudo mkdir -p /workspace \
  && sudo chown -R $(id -u) /workspace \
  # Install NVM.
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash - \
  && export NVM_DIR="$HOME/.nvm" \
  && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
  && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
  # Install the latest Node.js and NPM versions.
  && nvm install --lts --latest-npm \
  # Create the folder for storing vs-code extensions.
  && mkdir -p ~/.vscode-server/extensions \
  && mkdir -p ~/.vscode-server-insiders \
  && ln -s ~/.vscode-server/extensions ~/.vscode-server-insiders/extensions \
  # Add GitHub to known hosts if it matches the fingerprint.
  && mkdir -p ~/.ssh \
  && ssh-keyscan -H github.com > /tmp/keyscan-result \
  && if ssh-keygen -lf /tmp/keyscan-result | grep -q ${GITHUB_FINGERPRINT}; then cat /tmp/keyscan-result >> ~/.ssh/known_hosts; fi \
  && rm /tmp/keyscan-result
