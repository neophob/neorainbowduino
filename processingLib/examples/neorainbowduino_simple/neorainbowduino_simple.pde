import processing.serial.*;
import com.neophob.lib.rainbowduino.*;

int frame;

//the rainbowduino device
Rainbowduino rainbowduino;

//buffer for our image data, must be 8*8 pixel
int[] simpleImage;

/**
show random pixels on rainbowduinos with i2c address 5 and 6
*/
void setup() 
{
  frameRate(10);
  simpleImage = new int[64];
  
  //create a list with i2c slave destination (=rainbowduinos)
  List<Integer> i2cDest = new ArrayList<Integer>();
  i2cDest.add(5);i2cDest.add(6);
  try {
    //initialize library
    rainbowduino = new Rainbowduino(this, i2cDest);
  } catch (Exception e) {
    //if an error occours handle it here!
    //we just print out the stacktrace and exit.
    e.printStackTrace();
    println("failed to initialize serial port - exit!");
    exit();
  }
    
  println("neorainbowduino version: "+rainbowduino.version());
  boolean ping = rainbowduino.ping();
  println("ping arduino, result: "+ping);
  frame=0;
  
}

void fillImage() {
  //make some random noise...
  for (int i=0; i<64; i++) {
    int r = (int)random(256);
    int g = (int)random(256);
    int b = (int)random(256);
    simpleImage[i]=(r<<16) | (g<<8) | (b);
  }  
}

void draw() {  
  //send the noise image to i2c address 5 and 6. make sure the simpleImage buffer is an array of exactly 64 int's!
  fillImage();
  rainbowduino.sendRgbFrame((byte)5, simpleImage);
  fillImage();
  rainbowduino.sendRgbFrame((byte)6, simpleImage);
  
  //from time to time, add some debug infomration
  if (frame%25==24) {
    long lastHeatBeatTs = rainbowduino.getArduinoHeartbeat();
    println(
        "Last Timestamp at "+new Date(lastHeatBeatTs).toGMTString()+
        " Arduino Serial Buffer Size: "+rainbowduino.getArduinoBufferSize()+
        " last arduino error: "+rainbowduino.getArduinoErrorCounter()
    );
  }
  
  frame++;
}



