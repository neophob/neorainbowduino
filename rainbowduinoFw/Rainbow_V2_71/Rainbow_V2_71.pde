/*
arduino serial-i2c-gateway, by michael vogt / neophob.com 2010
published as i-dont-give-a-shit-about-any-license

based on blinkm firmware by thingM and
"daft punk" firmware by Scott C / ThreeFN 

needed libraries:
 -FlexiTimer (http://github.com/wimleers/flexitimer2)
 
libraries to patch:
 Wire: 
 	utility/twi.h: #define TWI_FREQ 400000L (was 100000L)
                       #define TWI_BUFFER_LENGTH 98 (was 32)
 	wire.h: #define BUFFER_LENGTH 98 (was 32)
  	
*/


#include <Wire.h>
#include <FlexiTimer2.h>
#include "Rainbow.h"

/*
A variable should be declared volatile whenever its value can be changed by something beyond the control 
of the code section in which it appears, such as a concurrently executing thread. In the Arduino, the 
only place that this is likely to occur is in sections of code associated with interrupts, called an 
interrupt service routine.
*/
extern unsigned char buffer[2][3][8][4];  //define Two Buffs (one for Display ,the other for receive data)
unsigned char imageBuffer[96];            //buffer used to read data from i2c bus

volatile byte g_line,g_level;

//read from bufCurr, write to !bufCurr
//volatile mess everything up now, why?
volatile byte g_bufCurr, g_swapNow;
byte g_readI2c;

#define START_OF_DATA 0x10
#define END_OF_DATA 0x20

void setup() {
  g_readI2c=0;
  DDRD=0xff;        // Configure ports (see http://www.arduino.cc/en/Reference/PortManipulation): digital pins 0-7 as OUTPUT
  DDRC=0xff;        // analog pins 0-5 as OUTPUT
  DDRB=0xff;        // digital pins 8-13 as OUTPUT
  PORTD=0;          // Configure ports data register (see link above): digital pins 0-7 as READ
  PORTB=0;          // digital pins 8-13 as READ

  g_level = 0;
  g_line = 0;

  g_bufCurr = 0;
  g_swapNow = 0; 

  Wire.begin(I2C_DEVICE_ADDRESS); // join i2c bus as slave
  Wire.onReceive(receiveEvent);   // define the receive function for receiving data from master

  //calculate: 64(256-GAMMA)/16000000 = x;  
  //gamma 200(0xc8): 0.000224  -> flimmert
  //gamma 215(0xd7): 0.000164  -> leichtes flimmern
  //gamma 221(0xdd): 0.00014   -> original
  //gamma 231(0xe7): 0.0001    -> original 
  //gamma 240(0xf0): 0.000064  -> wie original
  //gamma 250(0xfa): 0.000024  -> does not work
  //10kHz resolution
  FlexiTimer2::set(1, 0.0001, displayNextLine);
  FlexiTimer2::start();                            //start interrupt code
}

//the mainloop - try to fetch data from the i2c bus and copy it into our buffer
void loop() {
  uint8_t b, i;
  delayMicroseconds(10);
  
  //check if buffer is filled, 96b image + 1b start marker + 1b end marker = 98b 
  if (g_readI2c>97) { 
    g_readI2c-=98;
    //read header, wait until we get a START_OF_DATA or queue is empty
    i=0;
    while (Wire.available()>0 && i==0) {
      b = Wire.receive();
      if (b == START_OF_DATA) {
        i=1;
      }
    }
    
    if (i==0) {
      //error, missing START_OF_DATA marker
      return;
    }
  
    i=0;
    while (Wire.available()>0 && i<96) { 
      imageBuffer[i]=Wire.receive();  //recieve whatever is available
      i++;
    }
    
    //check footer
    b=0;
    if (Wire.available()>0) {
      b = Wire.receive();      
    }
    
    //if the receieved data looks good - copy it into backBuffer
    if (b == END_OF_DATA) {
      DispshowFrame();        
    } else {
      //error, try to read data until eod marker if possible
      while (Wire.available()>0 && i==0) {
        b = Wire.receive();
        if (b == END_OF_DATA) {
          i=1;
        }
      }

    }
  }
}



//=============HANDLERS======================================

//get data from master
//HINT: do not handle stuff here!! this will NOT work
//collect only data here and process it in the main loop!
void receiveEvent(int numBytes) {
  g_readI2c+=numBytes;
}


//==============DISPSHOW========================================

//copy data from the i2c bus into backbuffer and set the g_swapNow flag
void DispshowFrame(void) {
  unsigned char color,row,dots,ofs;

  ofs=0;
  for(color=0;color<3;color++) {
    for (row=0;row<8;row++) {
      for (dots=0;dots<4;dots++) {
        //format: 32b G, 32b R, 32b B
        buffer[!g_bufCurr][color][row][dots]=imageBuffer[ofs++];  //get byte info for two dots directly from command
      }
    }
  }
  g_swapNow = 1;
}


//============INTERRUPTS======================================

//shift out led colors and swap buffer if needed (back buffer and front buffer)
void displayNextLine() {
  flash_next_line(g_line, g_level);  // scan the next line in LED matrix level by level.
  g_line++;
  if(g_line>7)        // when have scaned all LED's, back to line 0 and add the level
  {
    g_line=0;
    g_level++;
    if (g_level>15) {
      g_level=0;
      //SWAP buffer if requested
      if (g_swapNow==1) {
        g_bufCurr = !g_bufCurr;
        g_swapNow=0;
      }
    }
  }
}

// scan one line
//TODO: are local variables needed here? or may we use global?
void flash_next_line(unsigned char line,unsigned char level) {
  disable_oe;
  close_all_line;
  //open_line(line);
  //TODO    
  if(line < 3) {    // Open the line and close others
     PORTB  = (PINB & ~0x07) | 0x04 >> line;
     PORTD  = (PIND & ~0xF8);
  } else {
     PORTB  = (PINB & ~0x07);
     PORTD  = (PIND & ~0xF8) | 0x80 >> (line - 3);
   }
   
  shift_24_bit(line,level);
  enable_oe;
}

// display one line by the color level in buff
//TODO: are local variables needed here? or may we use global?
void shift_24_bit(unsigned char line, unsigned char level) {
  unsigned char color,row,data0,data1;
  le_high;
  for (color=0;color<3;color++)//GRB
  {
    for (row=0;row<4;row++)
    {
      data1=buffer[g_bufCurr][color][line][row]&0x0f;
      data0=buffer[g_bufCurr][color][line][row]>>4;

      if(data0>level) {    //gray scale, 0x0f aways light (original comment, not sure what it means)
        shift_data_1;
        clk_rising;
      } else {
        shift_data_0;
        clk_rising;
      }
      
      if(data1>level) {
        shift_data_1;
        clk_rising;        //TODO: document
      } else {
        shift_data_0;
        clk_rising;
      }
    }
  }
  le_low;
}

/*
//==============================================================
void open_line(unsigned char line)     // open the scaning line 
{
  switch(line)
  {
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
*/


