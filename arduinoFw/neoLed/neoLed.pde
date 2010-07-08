#include <MsTimer2.h>
#include "Wire.h"
#include "BlinkM_funcs.h"

#define BAUD_RATE 115200
#define CMD_START_BYTE  0x01
#define CMD_PING  0x04
#define CMD_HEARTBEAT 0x10

byte serInStr[128];  // array that will hold the serial input string
byte errorCounter;


static void sendSerialResponse(byte command, byte param) {
  Serial.write(OK);
  Serial.write(command);
  Serial.write(param);
  Serial.write(Serial.available())
}

void heartbeat() {
  digitalWrite(13, HIGH);
  sendSerialResponse(CMD_HEARTBEAT, errorCounter);
  digitalWrite(13, LOW);
}

void setup()
{
  Wire.begin(); // join i2c bus (address optional for master)

  //TODO initial image
  
  for (byte b=0; b<128; b++)
    serInStr[b]=164;
  
  errorCounter=0;
  
  //clear both rainbowduinos - 
  //hint init will fail if both rainbowduinos are not available!
  errorCounter+=BlinkM_sendCmd(0x06, serInStr, 96);
  errorCounter+=BlinkM_sendCmd(0x05, serInStr, 96);
  
  pinMode(13, OUTPUT);
  
  //im your slave and wait for your commands, master!
  Serial.begin(BAUD_RATE); //Setup high speed Serial
  Serial.flush();
  
  MsTimer2::set(1000, heartbeat); // 1000ms period
  MsTimer2::start();
}

void loop()
{
    int num;

    //read the serial port and create a string out of what you read
    num = readCommand(serInStr);
    if( num == 0 )   // see if we got a proper command string yet
        return;

    //digitalWrite(ledPin,HIGH);  // say we're working on it
    
    //i2c addres of device
    byte addr    = serInStr[1];
    //how many bytes we're sending
    byte sendlen = serInStr[2];
    //what kind of command we send
    byte type = serInStr[3];
    //parameter
    byte* cmd    = serInStr+4;

    if (type == CMD_PING) {
       //simple ardiumo ping
       sendSerialResponse(CMD_PING, 0); 
    } else {
      // digitalWrite(ledPin,LOW);
       //else its a frame
       errorCounter += BlinkM_sendCmd(addr, cmd, sendlen);
    }    
  
}


//read a string from the serial and store it in an array
//you must supply the str array variable
//returns number of bytes read, or zero if fail
uint8_t readCommand(byte *str)
{
    uint8_t b,i;
    if( ! Serial.available() ) 
      return 0;  // wait for serial

    b = Serial.read();
    if( b != CMD_START_BYTE )         // check to see we're at the start
        return 0;
#ifdef DEBUG
    Serial.println("startbyte");
#endif

    str[0] = b;
    i = 100;
    while( Serial.available() < 3 ) {   // wait for the rest
        delay(1); 
        if( i-- == 0 ) return 0;        // get out if takes too long
    }
    for( i=1; i<4; i++)
        str[i] = Serial.read();       // fill it up
#ifdef DEBUG
    Serial.println("header");
#endif

    uint8_t sendlen = str[2];
#ifdef DEBUG
    Serial.print("cmdlen:");  Serial.println( sendlen, DEC);
#endif
    if( sendlen == 0 ) return 0;
    i = 100;
    while( Serial.available() < sendlen ) {  // wait for the final part
        delay(1); if( i-- == 0 ) return 0;
    }
    for( i=4; i<4+sendlen; i++ ) 
        str[i] = Serial.read();       // fill it up

#ifdef DEBUG
    Serial.println("got all");
#endif
    return 4+sendlen;
}

