//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>

void setup()
{
  // Init. and start BLE library.
  ble_begin();
  
  // Enable serial debug
  Serial.begin(57600); 
}

void loop()
{
  
  // If data is ready
  while(ble_available())
  {   
    Serial.write(ble_read());
  }

  // Allow BLE Shield to send/receive data
  ble_do_events();  
}



