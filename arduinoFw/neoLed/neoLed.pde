#include <MsTimer2.h>
#include "Wire.h"
#include "BlinkM_funcs.h"

#define BAUD_RATE 57600
//115200

//some magic numberes
#define CMD_START_BYTE  0x01
#define CMD_PING  0x04
#define CMD_HEARTBEAT 0x10
#define START_OF_DATA 0x10;
#define END_OF_DATA 0x20;

#define SERIAL_WAIT_TIME_IN_MS 20

//this should match RX_BUFFER_SIZE from HardwareSerial.cpp
byte serInStr[128];  // array that will hold the serial input string
byte errorCounter;
byte send[4];

static void sendSerialResponse(byte command, byte param) {
  send[0]=OK;
  send[1]=command;
  send[2]=param;
  send[3]=Serial.available();
  Serial.write(send, 4);
}

void heartbeat() {
  digitalWrite(13, HIGH);
  sendSerialResponse(CMD_HEARTBEAT, errorCounter);
  errorCounter=0;
  digitalWrite(13, LOW);
}

void setup() {
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

  //do not send serial data too often - it
  MsTimer2::set(3000, heartbeat); // 1000ms period
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
  byte* cmd    = serInStr+5;

  if (type == CMD_PING) {
    //simple ardiumo ping
    sendSerialResponse(CMD_PING, 0); 
  } 
  else {
    //else its a frame
    errorCounter += BlinkM_sendCmd(addr, cmd, sendlen);
  }    

}


//read a string from the serial and store it in an array
//you must supply the str array variable
//returns number of bytes read, or zero if fail
/* example ping command:
		cmdfull[0] = START_OF_CMD (marker);
		cmdfull[1] = addr; //unused yet!
		cmdfull[2] = 0x01;
		cmdfull[3] = CMD_PING;
		cmdfull[4] = START_OF_DATA (marker);
		cmdfull[5] = 0x02;
		cmdfull[6] = END_OF_DATA (marker);
*/
#define HEADER_SIZE 5
uint8_t readCommand(byte *str)
{
  uint8_t b,i;
  if( ! Serial.available() ) 
    return 0;  // wait for serial

  b = Serial.read();
  if( b != CMD_START_BYTE )         // check to see we're at the start
    return 0;

  str[0] = b;
  i = SERIAL_WAIT_TIME_IN_MS;
  while( Serial.available() < 4 ) {   // wait for the rest
    delay(1); 
    if( i-- == 0 ) return 0;        // get out if takes too long
  }
  for( i=1; i<HEADER_SIZE; i++)
    str[i] = Serial.read();       // fill it up

  uint8_t sendlen = str[2];
  if( sendlen == 0 ) return 0;
  uint8_t dataStartMarker = str[4];		//check if data is correct
  if( dataStartMarker != START_OF_DATA ) return 0;
  
  i = SERIAL_WAIT_TIME_IN_MS;
  while( Serial.available() < sendlen ) {  // wait for the final part
    delay(1); 
    if( i-- == 0 ) return 0;
  }
  for( i=HEADER_SIZE; i<6+sendlen; i++ ) 
    str[i] = Serial.read();       // fill it up

  uint8_t dataEndMarker = str[HEADER_SIZE+sendlen];		//check if data is correct
  if( dataEndMarker != END_OF_DATA ) return 0;
  
  //5 bytes header, we do not add the trailing check byte
  return HEADER_SIZE+sendlen;
}


