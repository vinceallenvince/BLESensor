var connect = require('connect'),
		io = require('socket.io').listen(1337),
		EventEmitter = require('events').EventEmitter,
    serialPort = require('serialport');

var emitter = new EventEmitter();
emitter.on('foundSerialPort', connectSerial);

// setup web page
connect(connect.static(__dirname + '/public')).listen(8080);

io.sockets.on('connection', function(socket) {

  socket.emit('connected');

  emitter.on('dataReceived', function(data) {
    socket.emit('dataReceived', data);
  });

});

var sp;
var SerialPort = serialPort.SerialPort;

serialPort.list(function (err, ports) {
  ports.forEach(function(port) {
    if (port.comName.search('usbmodem') !== -1) {
      emitter.emit('foundSerialPort', {name: port.comName});
    }
  });
});

function connectSerial(data) {
  console.log('Will try to connect to: ' + data.name);

  sp = new SerialPort(data.name, {
    baudrate: 57600
  }, false);

  sp.open(function() {

    console.log('serial port open!');

    sp.on('data', function(data) {
      //console.log(data);

      var axis, gravity = {
        x: 0,
        y: 0,
        z: 0
      };

      /*
       If data begins with a '&' (ascii code 38),
       we have a buffer.
       */
      if (data[0] == 38) { // '&'

        var axis = data[1]; //charCode

        var positions = data.slice(2, 8); // slice to end?

        var val = '';
        var sign = positions[0] == 45 ? '-' : '';

        for (var i = 0; i < positions.length; i++) {

          if (positions[i] == 46) {
            val = val + '.';
            continue;
          }

          if (positions[i] != 38 && positions[i] != 45 && positions[i] != 255) {
            val = val + positions[i];
          }
        };

        val = parseFloat(sign + val);
        //console.log(val);

        // when we receive data, publish it via the emitter
        emitter.emit('dataReceived', {
          val: val
        });

        /*
          want this formatted:
          {
            gravity: {
              x: 0.03,
              y: -1.2,
              z: 0.89
            }
          }
         */

      }

    });

    sp.on('close', function(data) {
      console.log('close: ' + data);
    });

    sp.on('error', function(data) {
      console.log('error: ' + data);
    });

  });
}
