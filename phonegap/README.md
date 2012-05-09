
# On first time (thse need to be done only once)
* Create symlink to following folders
 * ../gaso/public/javascripts -> ./javascripts
 * ../gaso/public/stylesheets -> ./stylesheets
 * ../gaso/public/images -> ./images
 * ../gaso/public/lib -> ./lib

# On updates
* Copy the source html from http://gaso.kilke.net to `index.html`

* Copy the production-mode codes from http://gaso.kilke.net
 * mobileinit-l3tt3r5numb3r5...js to -> js/mobileinit.js
 * application-l3tt3r5numb3r5...js to -> js/application.js


* Edit _index.html_
 1. remove production-code hashes from our snockets-generated js-file names, because we copied the code.
 * E.g. `<script src='/js/application-32915c983e4b300ab9a874ede80628f7.js'></script>` becomes `<script src='/js/application.js'></script>`.
 1. Fix path to socket.io from `/socket.io/socket.io.js` to `/js/socket.io.js`
