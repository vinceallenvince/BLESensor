var EventEmitter = require('events').EventEmitter,
    serialport = require('serialport');

var SerialPort = serialport.SerialPort;

var mySerialPort = '/dev/tty.usbmodemfd121';

var sp = new SerialPort(mySerialPort, {
  baudrate: 57600,
  parser: serialport.parsers.readline('/n')
});

sp.on('open', function() {

  console.log('serial port open!');
  sp.on('data', function(data) {
    console.log(data);
  });
});
