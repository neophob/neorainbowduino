
#include "WProgram.h"
#include "Wire.h"

#define START_OF_DATA 0x10
#define END_OF_DATA 0x20

//send data via i2c to a client
static byte BlinkM_sendBuffer(byte addr, byte* cmd) {
    Wire.beginTransmission(addr);
    Wire.send(START_OF_DATA);
    Wire.send(cmd, 96);
    Wire.send(END_OF_DATA);
    return Wire.endTransmission();
}

// receives generic data
// returns 0 on success, and -1 if no data available
// note: responsiblity of caller to know how many bytes to expect
/*static int BlinkM_receiveBytes(byte addr, byte* resp, byte len)
{
  Wire.requestFrom(addr, len);
  if( Wire.available() ) {
    for( int i=0; i<len; i++) 
      resp[i] = Wire.receive();
    return 0;
  }
  return -1;
} /**/


