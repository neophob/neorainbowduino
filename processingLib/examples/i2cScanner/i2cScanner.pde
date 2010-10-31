import processing.serial.*;
import com.neophob.lib.rainbowduino.*;

void setup() {
  println("Found i2c devices: "
    +Arrays.toString(Rainbowduino.scanI2cBus(this).toArray()));
  noLoop();
}

void draw() {  
}



