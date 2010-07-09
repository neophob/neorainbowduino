
#include "WProgram.h"
#include "wiring.h"
#include "Wire.h"

#define OK          1   //followed by return params

//#define PING        2 //returns OK + Version number
#define API_VER     3 //returns OK + Version number
#define API_VERSION_NR 1

#define transcmd 0xA0
#define checkslavestate 0xB0
#define slavedone 0xC0
#define waitingcmd 0x00
#define morecmd 0x10
#define processing 0x20
#define checking  0x30

#define F 0x46

static byte BlinkM_sendBuffer(byte addr, byte* cmd) {
	unsigned int timeout = 0;  
    byte sendIsDone = 0;
    byte cmdsession = 0;
    byte state = transcmd;
    byte slavestate = waitingcmd;    
    byte ret = 0;
    
    do { //cycle until slave transmits it's done
      
      switch (state) {
        case transcmd:  //transmit up to 32 bytes at a time
          Wire.beginTransmission(addr);
    
          if (cmdsession==0) {
            Wire.send(F);
          } else if (cmdsession > 0 && cmdsession < 4) {
          	//<<5 equals *32
            byte ofs = (cmdsession-1)<<5;
            //transmit one color array(r/g/b)
            Wire.send(cmd+ofs, 32);
          }
          
          Wire.endTransmission();
          //give the rainbowduino some time to process (230)
          delayMicroseconds(250);
          state=checkslavestate;
          break;
        
        case checkslavestate:
          Wire.requestFrom((int)addr,1);   
          if (Wire.available()>0) 
            slavestate=Wire.receive();    
          else {
            slavestate = 0xFF;
            timeout++;
          }
    
          if ((slavestate&0xF0)==morecmd){
            cmdsession=(slavestate&0x0F);
            state=transcmd;
          } else if ((slavestate==processing)||(slavestate==checking)) 
            state=slavedone;
          else 
            state=transcmd;
    
          if (timeout>500) { //time out occurs
            timeout=0;  //reset timout
            state=transcmd;  //trans failure, resend
            sendIsDone=1;
            ret=1; // return error
          }
          break;
    
        case slavedone:  //trans done
          sendIsDone=1;  //trans confirmed and OK, will exit while loop
          break;
    
        default:
          state=transcmd;
          break;
      } 
    
  } while(!sendIsDone);
  return ret;
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


