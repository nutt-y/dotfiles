# Dummy environment in case I need it
FROM fedora:44

# Install necesarry dependencies
RUN dnf install -y git ca-certificates sudo ansible-core ansible python-passlib nodejs

# Create the user to run everything with
RUN useradd -m -s /bin/bash dawg && \
  usermod -aG wheel dawg
RUN echo "dawg ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dawg
WORKDIR /home/dawg

# Setup environment
RUN git clone https://github.com/nutt-y/dotfiles dotfiles
RUN cd dotfiles/scripts/ansible && export USER_NAME=dawg; export PASSWORD=0000; sudo -E ansible-playbook -i inventory.yaml fedora-setup.yaml --limit localhost

