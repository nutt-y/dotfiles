# Dummy environment incase we need it
FROM fedora:44

# Install necesarry dependencies
RUN dnf install -y git ca-certificates sudo ansible-core ansible python-passlib nodejs ssh

# Create the user to run everything with
RUN useradd -m -s /bin/bash dawg && \
  usermod -aG wheel dawg
RUN echo "dawg ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dawg
WORKDIR /home/dawg

# Setup git for user dawg
RUN git config --global user.name "dawg"

# Add GitHub's SSH host key so that we can download anything that need to be preinstalled
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Setup environment
RUN git clone https://github.com/nutt-y/dotfiles dotfiles
RUN cd dotfiles/scripts/ansible && export USER_NAME=dawg; export PASSWORD=0000; sudo -E ansible-playbook -i inventory.yaml fedora-setup.yaml --limit localhost

