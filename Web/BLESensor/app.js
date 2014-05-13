var connect = require('connect'),
		io = require('socket.io').listen(1337),
		EventEmitter = require('events').EventEmitter,
    serialPort = require('serialport');

/*serialPort.list(function (err, ports) {
  ports.forEach(function(port) {
    console.log(port.comName);
    console.log(port.pnpId);
    console.log(port.manufacturer);
  });
});*/

var emitter = new EventEmitter();

connect(connect.static(__dirname + '/public')).listen(8080);

io.sockets.on('connection', function(socket) {

  socket.emit('connected');

  // control frame rate slider
  emitter.on('dataReceived', function(data) {
    socket.emit('dataReceived', data);
  });

});
var SerialPort = serialPort.SerialPort;

//var mySerialPort = '/dev/tty.usbmodemfd121';
var mySerialPort = '/dev/tty.usbmodem1421';

var sp = new SerialPort(mySerialPort, {
  baudrate: 57600
  //parser: serialPort.parsers.readline('/n')
}, false);

sp.open(function() {

  console.log('serial port open!');

  sp.on('data', function(data) {
  	console.log(data);

  	if (data[0] == 38) { // '&'

	  	var val = '';
	  	var sign = data[1] == 45 ? '-' : '';

	  	for (var i = 0; i < data.length; i++) {

	  		if (data[i] == 46) {
	  			val = val + '.';
	  			continue;
	  		}

	  		if (data[i] != 38 && data[i] != 45) {
	  			val = val + data[i];
	  		}
	  	};

	  	val = parseFloat(sign + val);
	  	console.log(val);

	  	// when we receive data, publish it via the emitter
			emitter.emit('dataReceived', {
				val: val
			});

  	}

  });

  sp.on('close', function(data) {
    console.log('close: ' + data);
  });

  sp.on('error', function(data) {
    console.log('error: ' + data);
  });
});
