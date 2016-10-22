#!/bin/bash

add_machine () {
  local PATH_TO_ARCHIVE=$1
  local REPO_NAME=$2
  local GIT_REPO_URL=$3
  
  cd $WORKDIR
  git clone $GIT_REPO_URL $REPO_NAME
  git submodule update --recursive --init
  machine-import $PATH_TO_ARCHIVE
}

build_and_deploy() {
  local REPO_NAME=$1
  local CONTAINER_NAME=$2 # Optional: deploys everything if omitted
  
  cd $WORKDIR
  cd $REPO_NAME
  eval "$(docker-machine env `basename $REPO_NAME`)"
  docker-compose build $CONTAINER_NAME
  docker-compose up -d $CONTAINER_NAME
}

deploy() {
  local REPO_NAME=$1
  local CONTAINER_NAME=$2 # Optional: deploys everything if omitted
  
  cd $WORKDIR
  cd $REPO_NAME
  eval "$(docker-machine env `basename $REPO_NAME`)"
  docker-compose up -d $CONTAINER_NAME
}

upgrade_definition() {
  local REPO_NAME=$1
  local CONTAINER_PATH=$2
  local BRANCH=${3:-master}
  local NPM_VERSION=${4-patch}
  
  cd $WORKDIR
  cd $REPO_NAME
  REPO_PATH=$PWD
  
  git pull origin
  git submodule update --recursive
  git checkout origin/$BRANCH
  
  if [ $NPM_VERSION ] ; then
    npm version $NPM_VERSION
  fi
  
  cd $REPO_PATH
  git commit -S -am "Update $REPO_NAME to $BRANCH"
  git push && git push --tags
}
