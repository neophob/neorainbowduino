import processing.serial.*;
import com.neophob.lib.rainbowduino.*;

//the rainbowduino device
Rainbowduino rainbowduino;

void setup() 
{
  //initialize library
  rainbowduino = new Rainbowduino(this);

  //create a list with i2c slave destination (=rainbowduinos)
  List<Integer> i2cDest = new ArrayList<Integer>();
  try {
    rainbowduino.initPort(i2cDest);
    rainbowduino.i2cBusScan();
    delay(3000);
  } catch (Exception e) {
    //if an error occours handle it here!
    //we just print out the stacktrace and exit.
    e.printStackTrace();
    println("failed to initialize serial port - exit!");
    exit();
  }
    
  println("neorainbowduino version: "+rainbowduino.version());
  println("found i2c devices: "+Arrays.toString(r.getScannedI2cDevices().toArray()));
  noLoop();
}

void draw() {  
}



