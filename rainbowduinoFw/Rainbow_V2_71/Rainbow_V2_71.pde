#include <Wire.h>
#include "Rainbow.h"

#define I2C_WAIT_TIME_IN_MS 10

extern unsigned char GamaTab[16];        //define the Gamma value for correct the different LED matrix

unsigned char RainbowCMD[4][32];  //the glorious command structure array
unsigned char buffer[2][3][8][4]; //define Two Buffs (one for Display ,the other for receive data)
unsigned char line,level;
unsigned char buffprt=0;  //define variable that keeps track of which buffer is displaying and which recieves
unsigned char State=0;  //the state of the Rainbowduino, used to figure out what to do next
unsigned char g8Flag1;  //flag for onrequest from IIC to if master has asked
unsigned char cmdsession=0;  //the number of the cmdsession that last took place, total number that has occured, first is 1 not 0


void setup() {
  DDRD=0xff;
  DDRC=0xff;
  DDRB=0xff;
  PORTD=0;
  PORTB=0;
  memset(RainbowCMD, 0, 4*32);
  memset(buffer, 0, 192);

  Wire.begin(I2C_DEVICE_ADDRESS); // join i2c bus (address optional for master) 
  Wire.onReceive(receiveEvent); // define the receive function for receiving data from master
  Wire.onRequest(requestEvent); // define the request function for the request from master

  init_timer2();  // initialize the timer for scanning the LED matrix
}

void loop() {
  switch (State) {

  case waitingcmd:
    delayMicroseconds(4);
    break;

  case morecmd:
    break;

  case processing:
    processWireCommand();
    State=checking;
    break;

  case checking:
    if(CheckRequest) {
      State=waitingcmd;
      ClrRequest;
    }
    break;

  default:
    State=waitingcmd; 
    break;
  }

}



//============INTERRUPTS======================================

ISR(TIMER2_OVF_vect) {         //Timer2  Service 
  TCNT2 = GamaTab[level];    // Reset a  scanning time by gamma value table
  flash_next_line(line,level);  // scan the next line in LED matrix level by level.
  line++;
  if(line>7)        // when have scaned all LEC the back to line 0 and add the level
  {
    line=0;
    level++;
    if(level>15) {
      level=0;
    }
  }
}

void init_timer2(void) {
  TCCR2A |= (1 << WGM21) | (1 << WGM20);   
  TCCR2B |= (1<<CS22);   // by clk/64
  TCCR2B &= ~((1<<CS21) | (1<<CS20));   // by clk/64
  TCCR2B &= ~((1<<WGM21) | (1<<WGM20));   // Use normal mode
  ASSR |= (0<<AS2);       // Use internal clock - external clock not used in Arduino
  TIMSK2 |= (1<<TOIE2) | (0<<OCIE2B);   //Timer2 Overflow Interrupt Enable
  TCNT2 = GamaTab[0];
  sei();   
}


//=============HANDLERS======================================

//get data from master
void receiveEvent(int howMany) {
  if (cmdsession>4) {
    //oops!
    cmdsession=0;
  }

  //wait loop (10ms) until needed buffer is filled up
  byte i = I2C_WAIT_TIME_IN_MS;
  while (Wire.available() < 32) {
    delay(1);
    if (i-- == 0) {
      return;
    }
  }

  i=0;
  while (i<32) { 
    RainbowCMD[cmdsession][i]=Wire.receive();  //recieve whatever is available
    i++;
  }
  cmdsession++;  //increment that the session has finished

  switch (RainbowCMD[0][0]){

  case 'F':    //get frame
    if (cmdsession<4) {
      State=morecmd;  //if not all 4 have been recieved change state to ask for more
    } 
    else 
      if ((i==32)&&(cmdsession==4)) {  //if 4th session occured, and double check it's the right size
      State=processing;
      cmdsession=0;  //reset cmdsession
    } 
    break;
  }
}


void requestEvent(void) { //when the master requests from the slave, this is the handler
  unsigned char trans;  //what is to be transmitted

  if (State==morecmd) {
    trans=(morecmd|cmdsession);  //when asking for more data, send the number of the last session recived, then master knows to send the next one
  } 
  else {
    trans=State;  //otherwise tell the master what state the slave is in
  }

  Wire.send(trans); 

  if ((State==processing)||(State==checking)) {
    //the slave is now working on a command, can continue to run without receiving data
    SetRequest;
  } 

}


void processWireCommand(void) {
  switch (RainbowCMD[0][0]){  //figure out which function to run based on command
  case 'F':
    DispshowFrame();
    break;
  }
}
//==============DISPSHOW========================================
void DispshowFrame(void) {
  unsigned char color, row, dots, correctcol, targetbuf, ofs;
  targetbuf=(buffprt+1)&1;

  for(color=0;color<4;color++) {
    switch (color) //fixes the fact that the buffer needs GRB, not RGB
    {
    case 0:  //in frame Red
      correctcol = 2;  //out green
      break;
    case 1:  //in frame Green
      correctcol = 1; //out red
      break;
    case 2:  //in frame Blue
      correctcol = 3; //out blue
      break;
    }
    
    ofs=0;
    for (row=0; row<8; row++) {
      for (dots=0; dots<4; dots++) {
        buffer[targetbuf][color][row][dots] = RainbowCMD[correctcol][ofs++];  //get byte info for two dots directly from command
      }
    }
  }
  buffprt++;  //increment buffer, will switch which one reads from and other writes to
  buffprt&=1;
}

//==============================================================
void shift_1_bit(unsigned char LS) { //shift 1 bit of  1 Byte color data into Shift register by clock
  if(LS)
  {
    shift_data_1;
  }
  else
  {
    shift_data_0;
  }
  clk_rising;
}
//==============================================================
void flash_next_line(unsigned char line, unsigned char level) // scan one line
{
  disable_oe;
  close_all_line;
  open_line(line);
  /*TODO    if(ln < 3) {    // Open the line and close others
   PORTB  = (PINB & ~0x07) | 0x04 >> ln;
   PORTD  = (PIND & ~0xF8);
   } else {
   PORTB  = (PINB & ~0x07);
   PORTD  = (PIND & ~0xF8) | 0x80 >> (ln - 3);
   }
   */
  shift_24_bit(line,level);
  enable_oe;
}

//==============================================================
void shift_24_bit(unsigned char line, unsigned char level) {  // display one line by the color level in buff
  unsigned char color=0,row=0;
  unsigned char data0=0,data1=0;
  le_high;
  for (color=0;color<3;color++)//GRB
  {
    for (row=0;row<4;row++)
    {
      data1=buffer[buffprt][color][line][row]&0x0f;
      data0=buffer[buffprt][color][line][row]>>4;

      if(data0>level)   //gray scale,0x0f aways light
      {
        shift_1_bit(1);
      }
      else
      {
        shift_1_bit(0);
      }

      if(data1>level)
      {
        shift_1_bit(1);
      }
      else
      {
        shift_1_bit(0);
      }
    }
  }
  le_low;
}



//==============================================================
void open_line(unsigned char line) {    // open the scaning line 
  switch(line) {
  case 0:
    {
      open_line0;
      break;
    }
  case 1:
    {
      open_line1;
      break;
    }
  case 2:
    {
      open_line2;
      break;
    }
  case 3:
    {
      open_line3;
      break;
    }
  case 4:
    {
      open_line4;
      break;
    }
  case 5:
    {
      open_line5;
      break;
    }
  case 6:
    {
      open_line6;
      break;
    }
  case 7:
    {
      open_line7;
      break;
    }
  }
}




