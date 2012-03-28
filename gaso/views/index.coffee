p	id: "foo"
	"tsippadaidoi"

script 'var socket = io.connect(\'http://localhost\'); socket.on(\'news\', function (data) {\n    console.log(data);\n    socket.emit(\'my other event\', { my: \'data\' });\n  });'