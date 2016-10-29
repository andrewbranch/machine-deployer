#!/usr/bin/env/node

const write = require('write-yaml');
const read = require('read-yaml');
const args = process.argv.slice(1);
const composeFilePath = args[0];
const command = args[1];
const container = args[2];
const config = read.sync(composeFilePath);

const commands = {
  update() {
    const version = args[3];
    config[container].image = config[container].image.replace(/:.+$/, `:${version}`);
    write.sync(composeFilePath, config);
  }
};

commands[command]();
