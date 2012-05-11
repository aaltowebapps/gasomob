@echo off
set NODE_ENV=development
rem Start with debugger for node-inspector
nodemon -x .\node_modules\.bin\coffee.cmd --nodejs --debug app.coffee
