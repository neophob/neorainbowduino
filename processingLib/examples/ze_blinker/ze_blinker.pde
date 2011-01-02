import com.neophob.lib.rainbowduino.test.*;
import com.neophob.lib.rainbowduino.*;

import processing.lib.blinken.jaxb.*;
import processing.lib.blinken.*;

private static int SIZE = 16;
BlinkenLibrary blink;
Rainbowduino r;

void setup() {
  blink = new BlinkenLibrary(this, "kreise-versetzt.bml", 255, 155, 166);  
  blink.loop();    
  frameRate(10);
  size(SIZE, SIZE);
  background(0);
  
  List<Integer> list = new ArrayList<Integer>();		
  list.add(16);
  try {
//    r = new Rainbowduino(this, list);
  } catch (Exception e) {
    println("FAILED to open serial port!!");
    e.printStackTrace();
  }

}


void draw() { 
    image(blink, 0, 0, SIZE, SIZE);
    
 //r.sendRgbFrame((byte)16, this);
 // r.sendRgbFrame((byte)17, this);
  //r.sendRgbFrame((byte)18, this);
//  r.sendRgbFrame((byte)19, this);

}
