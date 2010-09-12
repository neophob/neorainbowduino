needed libraries:
 -MsTimer2 (http://www.arduino.cc/playground/Main/MsTimer2)
 -FlexiTimer (http://github.com/wimleers/flexitimer2)
 
libraries to patch:
 Wire: 
 	utility/twi.h: #define TWI_FREQ 400000L (was 100000L)
 				   #define TWI_BUFFER_LENGTH 98 (was 32)
 	wire.h: #define BUFFER_LENGTH 98 (was 32)
 	

Hint: make sure you restart arduino after patching the files!
 	
 
 