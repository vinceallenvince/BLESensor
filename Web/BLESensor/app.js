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
    var gravityX = '', gravityY = '', gravityZ = '';
    var accelX = '', accelY = '', accelZ = '';
    var mode = 0;
    var index = null;

    sp.on('data', function(data) {

      //console.log(data);
      /*

        - data package should look like
        ![type][val]0

        Values map to type:
        A = gravity.x
        B = gravity.y
        C = gravity.z

        Second three values are:
        - userAcceleration.x
        - userAcceleration.y
        - userAcceleration.z

       */

      /*
        want this formatted:
        {
          gravity: {
            x: 0.03,
            y: -1.2,
            z: 0.89
          },
          accel: {
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
          index = null;
          var vals = {
            gravity: {
              x: gravityX,
              y: gravityY,
              z: gravityZ
            }/*,
            accel: {
              x: accelX,
              y: accelY,
              z: accelZ
            }*/
          };
          console.log(vals);
          emitter.emit('dataReceived', {
            val: vals
          });
          // reset vals
          gravityX = '';
          gravityY = '';
          gravityZ = '';
          accelX = '';
          accelY = '';
          accelZ = '';
        }

        if (mode == 1) {
          var chr = String.fromCharCode(data[i]);

          if (chr === 'A' || chr === 'B' || chr === 'C') {
            index = chr;
            continue;
          }
          switch(index) {
            case 'A':
              gravityX = gravityX + chr;
              break;
            case 'B':
              gravityY = gravityY + chr;
              break;
            case 'C':
              gravityZ = gravityZ + chr;
              break;
          }
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
