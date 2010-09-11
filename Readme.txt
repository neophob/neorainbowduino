needed libraries:
 -MsTimer2 (http://www.arduino.cc/playground/Main/MsTimer2)
 
libraries to patch:
 Wire: 
 	utility/twi.h: #define TWI_FREQ 400000L (was 100000L)
 	wure.h: #define BUFFER_LENGTH 96 (was 32)
 	

Hint: make sure you restart arduino after patching the files!
 	
 
 