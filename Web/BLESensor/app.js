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

    var buffer;
    var mode = 0;

    sp.on('data', function(data) {

      //console.log(data);

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

      // loop over data
      // if char == '!', reset buffer, start loading data
      // if char == null, emit data

      for (var i = 0; i < data.length; i++) {
        if (String.fromCharCode(data[i]) == '!') { // package begins with '!'
          buffer = '';
          mode = 1;
          continue;
        } else if (data[i] == 0) { // package ends w null
          mode = 2;
          //console.log(buffer);
          emitter.emit('dataReceived', {
            val: buffer
          });
          continue;
        }
        if (mode == 1) {
          buffer = buffer + String.fromCharCode(data[i]);
        }
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
