
## Installation to local machine

1. Install nodejs
1. Clone repository to your computer
1. `cd gaso`
1. Install `coffee-script` globally: `npm install coffee-script -g`
1. `npm install`

## Starting on local machine

### Start in development-mode
1. `gasodev`
1. Open browser to `http://localhost:3000`

### Start in production-mode
1. `gaso`

## Tips

To avoid need of re-running node app after each change use `nodemon`.

  1. `npm install nodemon -g`
  1. `nodemon app.coffee`

### Known problems with nodemon

  1. nodemon (at least v.0.6.12) won't work in windows with normal syntax
  1. -> this works: `nodemon -x .\node_modules\.bin\coffee.cmd app.coffee`
