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
    var roll = '', pitch = '', yaw = '';
    var gravityX = '', gravityY = '', gravityZ = '';
    var accelX = '', accelY = '', accelZ = '';
    var mode = 0;
    var index = null;
    var calibrate = false;

    sp.on('data', function(data) {

      //console.log(data);
      /*

        - data package should look like
        ![type][val]0

        Values map to type:
        A = attitude.roll
        B = attitude.pitch
        C = attitude.yaw
        D = gravity.x
        E = gravity.y
        F = gravity.z
        G = accel.x
        H = accel.y
        I = accel.z
       */

      /*
        Want this format:
        {
          attitude: {
            roll: 0.03,
            pitch: -1.2,
            yaw: 0.89
          },
          gravity: {
            x: 0.03,
            y: -1.2,
            z: 0.89
          },
          accel: {
						x: 1.8,
						y: 0.01,
						z: -0.03
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
            attitude: {
              roll: roll,
              pitch: pitch,
              yaw: yaw
            },
            gravity: {
              x: gravityX,
              y: gravityY,
              z: gravityZ
            },
            accel: {
              x: accelX,
              y: accelY,
              z: accelZ
            }
          };
          //console.log(vals);
          emitter.emit('dataReceived', {
          	calibrate: calibrate,
            val: vals
          });
          // reset vals
          calibrate = false;
          roll = '';
          pitch = '';
          yaw = '';
          gravityX = '';
          gravityY = '';
          gravityZ = '';
          accelX = '';
          accelY = '';
          accelZ = '';
        }

        if (mode == 1) {
          var chr = String.fromCharCode(data[i]);

          if (chr === 'A' || chr === 'B' || chr === 'C' || chr === 'D' || chr === 'E' || chr === 'F' || chr === 'G' || chr === 'H' || chr === 'I') {
            index = chr;
            continue;
          } else if (chr === '$') { // calibrate
          	calibrate = true;
          }
          switch(index) {
            case 'A':
              roll = roll + chr;
              break;
            case 'B':
              pitch = pitch + chr;
              break;
            case 'C':
              yaw = yaw + chr;
              break;
            case 'D':
              gravityX = gravityX + chr;
              break;
            case 'E':
              gravityY = gravityY + chr;
              break;
            case 'F':
              gravityZ = gravityZ + chr;
              break;
            case 'G':
              accelX = accelX + chr;
              break;
            case 'H':
              accelY = accelY + chr;
              break;
            case 'I':
              accelZ = accelZ + chr;
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
