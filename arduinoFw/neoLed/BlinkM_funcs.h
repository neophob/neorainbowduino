
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

static byte BlinkM_sendCmd(byte addr, byte* cmd, int cmdlen) {  
    unsigned char sendIsDone=0;
    unsigned char cmdsession=0;
    unsigned char state = transcmd;
    unsigned char slavestate = waitingcmd;
    unsigned int timeout = 0;
    byte ret=0;
    
    do { //cycle until slave transmits it's done
      
      switch (state) {
        case transcmd:  //transmit up to 32 bytes at a time
          Wire.beginTransmission(addr);
    
          if (cmdsession==0) {
            Wire.send('F');
          } else if (cmdsession > 0 && cmdsession < 4) { 
            byte ofs = (cmdsession-1)<<5;            
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
          //delayMicroseconds(10);
          break;
    
        case slavedone:  //trans done
          sendIsDone=1;  //trans confirmed and OK, will exit while loop
          //state=transcmd;  //reset state for next call of cmd
          //TODO not sure here about the state!
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


