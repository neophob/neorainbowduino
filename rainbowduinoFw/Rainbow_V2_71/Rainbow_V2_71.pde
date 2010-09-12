#include <Wire.h>
#include <FlexiTimer2.h>
#include "Rainbow.h"

//extern unsigned char GamaTab[16];             //define the Gamma value for correct the different LED matrix
extern unsigned char buffer[2][3][8][4];  //define Two Buffs (one for Display ,the other for receive data)
extern unsigned char RainbowCMD[4][32];  //the glorious command structure array

unsigned char line,level;
unsigned char g8Flag1;  //flag for onrequest from IIC to if master has asked

byte bufFront, bufBack, bufCurr;                // used for handling the buffers
byte readI2c,i;

#define START_OF_DATA 0x10
#define END_OF_DATA 0x20

void setup() {
  readI2c=0;
  //needed?
  DDRD=0xff;
  DDRC=0xff;
  DDRB=0xff;
  PORTD=0;
  PORTB=0; 

  level = 0;
  line = 0;

  bufFront = 0;
  bufBack = 1;
  bufCurr = 0;    

  Wire.begin(I2C_DEVICE_ADDRESS); // join i2c bus (address optional for master) 
  Wire.onReceive(receiveEvent); // define the receive function for receiving data from master

  //calculate: 64(256-GAMMA)/16000000 = x;  
  //gamma 231: 0.0001    -> original 
  //gamma 240: 0.000064  -> wie original
  //gamma 250: 0.000024  -> does not work
  FlexiTimer2::set(1, 0.0001, displayNextLine);
  FlexiTimer2::start();
}

void loop() {
  uint8_t b;
  delayMicroseconds(10);
  
  //check if buffer is filled
  if (readI2c>97) {
    readI2c=0;
    //read header, wait until we get a START__OF_DATA or queue is empty
    i=0;
    while (Wire.available()>0 && i==0) {
      b = Wire.receive();
      if (b == START_OF_DATA) {
        i=1;
      }
    }
    
    if (i==0) {
      //error
      return;
    }
  
    for (byte b=1; b<4; b++) {
      i=0;
      while (Wire.available()>0 && i<32) { 
        RainbowCMD[b][i]=Wire.receive();  //recieve whatever is available
        i++;
      }
    }
    
    //check footer
    b=0;
    if (Wire.available()>0) {
      b = Wire.receive();      
    }
    
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


void swapBuffers() { // Swap Front with Back buffer
  // bufFront = !bufFront;
  // bufBack = !bufBack;

  //TODO: 
  //cli();  // disable interrupts
  if (bufFront==0) bufFront=1; 
  else bufFront=0;
  if (bufBack==0) bufBack=1; 
  else bufBack=0;
  //sei();  // enable interrupts

  while(bufCurr != bufFront) {    // Wait for display to change.
    delayMicroseconds(5);
  }
}

//============INTERRUPTS======================================

//shift out led colors
void displayNextLine() {
  flash_next_line(line, level);  // scan the next line in LED matrix level by level.
  line++;
  if(line>7)        // when have scaned all LEC the back to line 0 and add the level
  {
    line=0;
    level++;
    if(level>15) {
      level=0;
      //SWAP buffer
      bufCurr = bufFront;       // do the actual swapping, synced with display refresh.
    }
  }
}

//=============HANDLERS======================================

//get data from master
//HINT: do not handle stuff here!! this will NOT work
//collect only data here and process it in the main loop!
void receiveEvent(int numBytes) {
  readI2c+=numBytes;
}


//==============DISPSHOW========================================
void DispshowFrame(void) {
  unsigned char color,row,dots,correctcol,ofs;

  swapBuffers();

  for(color=0;color<3;color++) {
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
    for (row=0;row<8;row++) {
      for (dots=0;dots<4;dots++) {
        buffer[bufCurr][color][row][dots]=RainbowCMD[correctcol][ofs++];  //get byte info for two dots directly from command
      }
    }
  }

  //Buffprt++;  //increment buffer, will switch which one reads from and other writes to
  //Buffprt&=1;
  //  while((Buffprt+1)&1 == targetbuf) {    // Wait for display to change.
  //  while(Buffprt == targetbuf) {    // Wait for display to change.
  //    delayMicroseconds(10);
  //  }

}

//==============================================================
void shift_1_bit(unsigned char LS)  //shift 1 bit of  1 Byte color data into Shift register by clock
{
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
void flash_next_line(unsigned char line,unsigned char level) // scan one line
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
void shift_24_bit(unsigned char line, unsigned char level)   // display one line by the color level in buff
{
  unsigned char color=0,row=0;
  unsigned char data0=0,data1=0;
  le_high;
  for(color=0;color<3;color++)//GRB
  {
    for(row=0;row<4;row++)
    {
      data1=buffer[bufCurr][color][line][row]&0x0f;
      data0=buffer[bufCurr][color][line][row]>>4;

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



