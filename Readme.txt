Info
----
Some of the neorainbowduino v0.8 features:

Multiple Rainbowduinos supported via i2c protocol
 -Running fast and stable, you need about 20ms are needed to send a frame from Processing/Java to an Rainbowduino matrix
 -A Processing library, so you can easily control your Rainbowduino from Processing! Check http://www.neophob.com/neorainbowduino for a description of the library.
 -Send frames from Processing to your RGB matrix, each frame has a size of 8x8 pixel, 12bit color resolution (4096 colors). The color conversion is handled by the library
 -Optimized processing lib - send only frames to Rainbowduino if needed (save ~50% of traffic - of course it depends on your frames)
 -Fixed buffer swapping (no more flickering)
 -Check if Arduino is ready (ping arduino)
 -Added i2c bus scanner, find your Rainbowduinos if you forget their addresses

More information:
 -http://www.neophob.com/2010/09/neorainbowduino-processing-library
 -http://www.neophob.com/2010/07/rainbowduino-fun-aka-neorainbowduino
 -http://garden.seeedstudio.com/index.php?title=Rainbowduino_LED_driver_platform_-_Atmega_328

Installation
Needed libraries
 -FlexiTimer (http://github.com/wimleers/flexitimer2)
 
Libraries to patch
Wire (TWI/I2C):
  utility/twi.h:
---  
     #define TWI_FREQ 400000L (was 100000L)
     #define TWI_BUFFER_LENGTH 98 (was 32)
---     

  wire.h: 
---
     #define BUFFER_LENGTH 98 (was 32)
---
Hint: make sure that the Arduino ide is NOT running while you patch the files!

Step by Step
 -Make sure you installed the needed libs and patched your Arduino installation
 -Upload firmware to one or more Rainbowduinos. If you're uploading to multiple Rainbowduinos, make sure to change the I2C adress for each Rainbowduino. Hint: make sure you first upload an empty sketch to the Arduino - else the upload to the Rainbowduinos may not work!
 -Upload firmware to Arduino
 -Wire up (I2C from Arduino to Rainbowduinos, Power... Check blog entry for more information)
 -Install Processing library (see below)
 -Start an example sketch - check if the I2C slave address match your Rainbowduinos.

Install Processing libraries
the zip file you downloaded contains 3 main directories (and the directory name should be self explaining):
 -arduinoFw
 -processingLib
 -rainbowduinoFw
You can find the processing library in the processingLib\distribution\neorainbowduino-x.y\download directory. In this directory you'll find the processing library as zip file, containing an INSTALL.txt file.