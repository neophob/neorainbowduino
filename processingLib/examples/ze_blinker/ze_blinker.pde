import processing.serial.*;

import com.neophob.lib.rainbowduino.test.*;
import com.neophob.lib.rainbowduino.*;

import processing.lib.blinken.jaxb.*;
import processing.lib.blinken.*;

private static int SIZE = 160;
private static final String[] ALL_BML_FILES = {
                                                "torus.bml",
                                                "bnf_auge.bml",
                                                "flatter_flatter.bml",
                                                "cube.bml", 
                                                "kreise-versetzt.bml"
};

BlinkenLibrary blink;
Rainbowduino r;
int frames;
String currentFile;

void setup() {
  loadBlink("kreise-versetzt.bml");
  frameRate(45);
  size(SIZE, SIZE);
  background(0);
  
  List<Integer> list = new ArrayList<Integer>();		
  list.add(16);list.add(17);list.add(18);list.add(19);
  try {
//    r = new Rainbowduino(this, list);
  } catch (Exception e) {
    println("FAILED to open serial port!!");
    e.printStackTrace();
    exit();
  }

}


void draw() { 
    image(blink, 0, 0, SIZE, SIZE);
    //send sketch content to four rainbowduino's
//    r.sendRgbFrame((byte)16, (byte)18, (byte)19, (byte)17, this);
    frames--;
    if (frames<1) {
      //load a new .bml file and make sure we pick a new file
      String name=currentFile;
      while (name.equals(currentFile)){
        name=ALL_BML_FILES[int(random(ALL_BML_FILES.length))];
      }
      loadBlink(name);
    }
}

void loadBlink(String name) {
  currentFile=name;
  if (blink==null) {
    blink = new BlinkenLibrary(this, name, int(random(255)), int(random(255)), int(random(255)));
  } else {
    blink.loadFile(name, int(random(255)), int(random(255)), int(random(255)));
  }
  frames = blink.getNrOfFrames();
  //ignore the delay of the movie, use our fps!
  blink.setIgnoreFileDelay(true);
  blink.loop();
}

