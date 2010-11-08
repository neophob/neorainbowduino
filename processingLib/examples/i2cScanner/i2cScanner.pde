import processing.serial.*;
import com.neophob.lib.rainbowduino.*;

/**
this file demonstrate how to use the i2c scanner feature
of the arduino fw.
connect your arduino device and scan its i2c bus
*/
void setup() {
  println("Found i2c devices: "
    +Arrays.toString(Rainbowduino.scanI2cBus(this).toArray()));
  noLoop();
}

void draw() {  
}



