#BLESensor

This repo contains code to send gyroscope and accelerometer data from an iOS device to a web browser. There are four components involved.

* [an iOS app](https://github.com/vinceallenvince/BLESensor/tree/master/BLESensor)
* [Arduino code](https://github.com/vinceallenvince/BLESensor/tree/master/Arduino/BLESensor)
* [a NodeJS app](https://github.com/vinceallenvince/BLESensor/tree/master/Web/BLESensor)
* [JS and HTML for the browser](https://github.com/vinceallenvince/BLESensor/tree/master/Web/BLESensor/public)

The iOS app connects to a [Red Bear Labs Bluetooth Low Energy shield](http://redbearlab.com/bleshield/) on an Arduino. The Arduino writes the data to the serial port. The NodeJS app uses the [node-serialport](https://github.com/voodootikigod/node-serialport) node module to receive the data and forward it to a browser via [web sockets](http://socket.io).

You can also find [cutting plans](https://github.com/vinceallenvince/BLESensor/tree/master/enclosure) to laser cut the enclosure.

![BLESensor](http://raw.githubusercontent.com/vinceallenvince/BLESensor/master/images/bluetooth-accel.jpg)

Check out [the video](http://youtu.be/Tu3zn0sqZpQ).