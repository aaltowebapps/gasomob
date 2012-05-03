# Labs
* Note: lab-exercises are in [labs-branch](gasomob/tree/labs)


# Gaso

## Demo
* Demo app running at: [http://gaso.kilke.net][demo]. If it doesn't work, try [alternative link](http://50.16.203.50:3000).


## Installation to local machine
1. Install MongoDB
1. Install nodejs
1. Install `coffee-script` globally: `npm install coffee-script -g`
1. Clone gaso repository to your computer
1. `cd gaso`
1. `npm install -d`


## Starting on local machine

### Start in development-mode
1. Use `gasodev.cmd` or `./gasodev.sh`
1. Open browser to `http://localhost:3000`


### Start in production-mode
1. Use `gaso.cmd` or `./gaso.sh`

_Note: After starting the app in production mode in windows (!¤"#3¤#" windows again...?) and when you open the browser to the server you'll pbobably get only "Internal server errror" displayed. -> Refresh the page a couple of times and then everything will work._


## Tests

To run tests:
`run_tests.cmd`

_OR_

1. `npm install -g vows`
1. `vows --spec` in `gaso`-dir


## Tips

To avoid need of re-running node app after each change use `nodemon`.

  1. `npm install nodemon -g`
  1. `nodemon app.coffee`

## Known problems

### Libraries
1. _connect-assets_ v2.1.9 doesn't work too well in windows, it messes up file paths. This is due to a bug in it's dependency library _snockets_. There's a fix to available to snockets [here](https://github.com/TrevorBurnham/snockets/pull/9/files#diff-0). Patched snockets for windows is in `dev`-folder for your convenience.
  1. Install dependencies as instructed in _Installation to local machine_
  1. Copy & replace patched lib from `gaso/dev/snockets.js` over `gaso/node_modules/connect-assets/node_modules/snockets/lib/snockets.js`
1. _nodemon_ (at least v.0.6.12) won't work in windows with normal syntax, some workarounds:
  1. For this reason we include _coffee-script_ non-globally into `devDependencies` in _package.json_
  1. Run app in development mode using `nodemon -x .\node_modules\.bin\coffee.cmd app.coffee`
1. Also another issue with _nodemon_ (at least in windows) is that nodemon will throw an exception `Error: use fs.watch api instead`, when starting nodemon. Nodemon seems to run at least partially nevertheless, but the exception is just annoying.
  1. This can be fixed by replacing `fs.watchFile(ignoreFilePath...` with `fs.watch(ignoreFilePath...` at _line 195_ of _C:\Users\YOUR_USERNAME\AppData\Roaming\npm\node_modules\nodemon\nodemon.js_.


[demo]: http://gaso.kilke.net
