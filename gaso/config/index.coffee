npminfo = require '../package'

# Set the current environment to true in the env object
currentEnv = process.env.NODE_ENV or 'development'

# Exports
exports.appName = "Gaso"
exports.version = npminfo.version
exports.env =
  production: false
  staging: false
  test: false
  development: false
  current: currentEnv
exports.env[currentEnv] = true
exports.log =
  path: __dirname + "/var/log/app_#{currentEnv}.log"
exports.server =
  port: 3000
  # In staging and production, listen loopback. nginx listens on the network.
  ip: '127.0.0.1'
if currentEnv not in ['production', 'staging']
  exports.enableTests = true
  # Listen on all IPs in dev/test (for testing from other machines)
  exports.server.ip = '0.0.0.0'
exports.db =
  URL: "mongodb://localhost/#{exports.appName.toLowerCase()}_#{currentEnv}"
  #URL: "mongodb://localhost:27017/#{exports.appName.toLowerCase()}_#{currentEnv}"
