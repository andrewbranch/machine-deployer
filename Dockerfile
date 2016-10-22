FROM debian:stable

MAINTAINER Andrew Branch <andrew@wheream.io>

# Install packages
RUN apt-get update && apt-get install -y \
  curl \
  git \
  nodejs \
  npm \
  ssh-client \
  && ln -s `which nodejs` /usr/bin/node

# Install docker-machine and docker-compose
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.2/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine && \
    curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install machine-share
RUN npm install --global andrewbranch/machine-share

RUN mkdir -p /var/work
RUN /bin/bash -c "mkdir -p $HOME/.docker/machine/{machines,certs}"
WORKDIR /var/work
COPY functions.sh functions.sh
COPY .env .env
COPY *.key ./
COPY github_rsa* ./

# Make environment and functions available in shell
RUN cat .env >> $HOME/.bashrc && \
    cat functions.sh >> $HOME/.bashrc && \
    rm .env functions.sh

# Set up git
RUN gpg --import *.key
RUN eval `ssh-agent -s` && ssh-add github_rsa
RUN git config --global user.name "$GIT_NAME" && \
    git config --global user.email "$GIT_EMAIL" && \
    git config --global user.signingkey "$(echo `gpg --list-keys` | grep -o -E 'pub [^/]+/([A-F0-9]+)' | grep -o -E '[A-F0-9]+$')"

CMD ["/bin/bash"]
