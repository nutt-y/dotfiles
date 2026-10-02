# Dummy container with full config
# In order to be able to use tmux+neovim do the following:
# export DOCKER_CONFIG="$PWD/.docker"
# echo '{"detachKeys": "ctrl+\\"}' >> '$PWD/.docker/config.json'
FROM fedora:44

# Install necesarry dependencies
RUN dnf install -y git ca-certificates sudo ansible-core ansible python-passlib nodejs tree-sitter gcc clang make procps-ng

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

# Run the playbook. The dotfiles role probes GitHub over SSH and falls back
# to HTTPS on its own, so no ssh juggling is needed here.
RUN cd dotfiles/scripts/ansible && \
  export USER_NAME=dawg PASSWORD=0000 && \
  sudo -E ansible-playbook -i inventory.yaml setup.yaml --limit localhost

# Setup bob
RUN bob use stable && echo 'export PATH="/home/dawg/.local/share/bob/nvim-bin:$PATH"' >> /home/dawg/.zshrc
