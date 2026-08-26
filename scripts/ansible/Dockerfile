# Dummy container with full config
FROM fedora:44

# Install necesarry dependencies
RUN dnf install -y git ca-certificates sudo ansible-core ansible python-passlib nodejs

# Create the user to run everything with
RUN useradd -m -s /bin/bash dawg && \
  usermod -aG wheel dawg
RUN echo "dawg ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dawg
WORKDIR /home/dawg

# Setup git for user dawg
RUN git config --global user.name "dawg"

# Setup environment
RUN git clone https://github.com/nutt-y/dotfiles dotfiles

# Remove ssh for a second just so that we can install dotfiles and everything through http
RUN sudo mv /usr/bin/ssh /usr/bin/ssh.disabled && \
  cd dotfiles/scripts/ansible && \
  export USER_NAME=dawg PASSWORD=0000 && \
  sudo -E ansible-playbook -i inventory.yaml fedora-setup.yaml --limit localhost && \
  sudo mv /usr/bin/ssh.disabled /usr/bin/ssh
