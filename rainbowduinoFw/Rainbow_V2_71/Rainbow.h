#ifndef Rainbow_h
#define Rainbow_h

//Address of the device. Note: this must be changed and compiled for all unique Rainbowduinos
#define I2C_DEVICE_ADDRESS 0x05

//=============================================
#define SH_BIT_OE    0x08
#define SH_BIT_SDI   0x01
#define SH_BIT_CLK   0x02
#define SH_BIT_LE    0x04

//PORTC maps to Arduino analog pins 0 to 5. Pins 6 & 7 are only accessible on the Arduino Mini
//PORTC - The Port C Data Register - read/write
#define SH_PORT_OE   PORTC
#define SH_PORT_SDI  PORTC
#define SH_PORT_CLK  PORTC
#define SH_PORT_LE   PORTC
//============================================

//some handy hints, ripped form the arduino forum
//Setting a bit: byte |= 1 << bit;
//Clearing a bit: byte &= ~(1 << bit);
//Toggling a bit: byte ^= 1 << bit;
//Checking if a bit is set: if (byte & (1 << bit))
//Checking if a bit is cleared: if (~byte & (1 << bit)) OR if (!(byte & (1 << bit)))

#define CLK_RISING  {SH_PORT_CLK&=~SH_BIT_CLK;SH_PORT_CLK|=SH_BIT_CLK;}
#define LE_HIGH     {SH_PORT_LE|=SH_BIT_LE;}
#define LE_LOW      {SH_PORT_LE&=~SH_BIT_LE;}
#define ENABLE_OE   {SH_PORT_OE&=~SH_BIT_OE;}
#define DISABLE_OE  {SH_PORT_OE|=SH_BIT_OE;}

#define SHIFT_DATA_1     {SH_PORT_SDI|=SH_BIT_SDI;}
#define SHIFT_DATA_0     {SH_PORT_SDI&=~SH_BIT_SDI;}

#endif

