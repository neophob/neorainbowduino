#ifndef Rainbow_h
#define Rainbow_h

//Address of the device. Note: this must be changed and compiled for all unique Rainbowduinos
#define I2C_DEVICE_ADDRESS 0x05

//=============================================
//PORTC maps to Arduino analog pins 0 to 5. Pins 6 & 7 are only accessible on the Arduino Mini
//PORTC - The Port C Data Register - read/write

#define SH_BIT_SDI   0x01
#define SH_BIT_SDI_I 0xFE
#define SH_BIT_CLK   0x02
#define SH_BIT_CLK_I 0xFD

#define SH_BIT_LE    0x04
#define SH_BIT_LE_I  0xFB
#define SH_BIT_OE    0x08
#define SH_BIT_OE_I  0xF7

//============================================

//some handy hints, ripped form the arduino forum
//Setting a bit: byte |= 1 << bit;
//Clearing a bit: byte &= ~(1 << bit);
//Toggling a bit: byte ^= 1 << bit;
//Checking if a bit is set: if (byte & (1 << bit))
//Checking if a bit is cleared: if (~byte & (1 << bit)) OR if (!(byte & (1 << bit)))

//potential take too long! -> PORTC &=~0x02; PORTC|=0x02
//Clock input terminal for data shift on rising edge
#define CLK_RISING  {PORTC &= SH_BIT_CLK_I; PORTC |= SH_BIT_CLK;}

//Data strobe input terminal, Serial data is transfered to the respective latch when LE is high. 
//The data is latched when LE goes low.
#define LE_HIGH     {PORTC |= SH_BIT_LE;}
#define LE_LOW      {PORTC &= SH_BIT_LE_I;}

//Output Enabled, when (active) low, the output drivers are enabled; 
//when high, all output drivers are turned OFF (blanked).
#define ENABLE_OE   {PORTC &= SH_BIT_OE_I;}
#define DISABLE_OE  {PORTC |= SH_BIT_OE;}

#define SHIFT_DATA_1     {PORTC |= SH_BIT_SDI;}
//potential take too long! -> PORTC&=~0x01
#define SHIFT_DATA_0     {PORTC &= SH_BIT_SDI_I;}

#endif

