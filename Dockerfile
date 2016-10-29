FROM debian:stable

MAINTAINER Andrew Branch <andrew@wheream.io>

# Install packages
RUN apt-get update && apt-get install -y \
  curl \
  git \
  ssh-client

# Update Node source and install
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
  apt-get install -y nodejs

# Install docker-machine and docker-compose
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.2/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine && \
    curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install machine-share
RUN npm install --global andrewbranch/machine-share

RUN /bin/bash -c "mkdir -p $HOME/.docker/machine/{machines,certs}"
ENV WORKDIR /var/work
ENV SCRIPTDIR /var/scripts
ENV PATH $PATH:$SCRIPTDIR
ENV MISCDIR /var/misc
RUN mkdir -p $WORKDIR && mkdir -p $SCRIPTDIR
WORKDIR $WORKDIR

# Install local npm dependencies
COPY package.json $SCRIPTDIR/
RUN cd $SCRIPTDIR && npm install

# Copy all the things
COPY functions.sh $MISCDIR/
COPY update_compose_file.js $SCRIPTDIR/update_compose_file
COPY .env $MISCDIR/
COPY *.key $MISCDIR/
COPY github_rsa* $MISCDIR/

# Make environment and functions available in shell
RUN cat $MISCDIR/.env >> $HOME/.bashrc && \
    cat $MISCDIR/functions.sh >> $HOME/.bashrc

# Make scripts executable
RUN chmod +x $SCRIPTDIR/*

# Set up git
RUN gpg --import $MISCDIR/*.key
RUN eval `ssh-agent -s` && ssh-add $MISCDIR/github_rsa
RUN git config --global user.name "$GIT_NAME" && \
    git config --global user.email "$GIT_EMAIL" && \
    git config --global user.signingkey "$(echo `gpg --list-keys` | grep -o -E 'pub [^/]+/([A-F0-9]+)' | grep -o -E '[A-F0-9]+$')"

CMD ["/bin/bash"]
