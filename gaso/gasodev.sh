#!/bin/bash
# install nodemon first: npm install nodemon -g
# Start with --debug flag for node-inspector usage
NODE_ENV=development nodemon --nodejs --debug app.coffee
