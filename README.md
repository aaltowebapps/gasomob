# Labs
* Note: lab-exercises are in branch `labs`

# Gaso

## Demo
* Demo app running at: [http://gaso.kilke.net][demo]

## Installation to local machine
1. Install MongoDB
1. Install nodejs
1. Install `coffee-script` globally: `npm install coffee-script -g`
1. Clone gaso repository to your computer
1. `cd gaso`
1. `npm install -d`

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

### Known problems
1. _connect-asseets_ v2.1.9 doesn't work too well in windows, it messes up file paths. This is due to a bug in it's dependency library _snockets_. There's a fix to available to snockets [here](https://github.com/TrevorBurnham/snockets/pull/9/files#diff-0). Patched snockets is in `dev`-folder.
  1. Install dependencies as instructed in _Installation to local machine_
  1. Copy & replace patched lib from `gaso/dev/snockets.js` over `gaso/node_modules/connect-assets/node_modules/snockets/lib/snockets.js`
1. _nodemon_ (at least v.0.6.12) won't work in windows with normal syntax, workaround:
  1. For this reason we include _coffee-script_ non-globally into `devDependencies` in _package.json_
  1. Run app in development mode using `nodemon -x .\node_modules\.bin\coffee.cmd app.coffee`


[demo]: http://gaso.kilke.net
