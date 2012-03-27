set NODE_ENV=development
nodemon -w . -w assets\js\models -w routes -w views -x .\node_modules\.bin\coffee.cmd app.coffee