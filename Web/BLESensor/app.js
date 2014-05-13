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
}
