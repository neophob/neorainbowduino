//ze blinker, seeedstudio carnival 2011 entry (c) by michu / neophob.com
import processing.serial.*;

import com.neophob.lib.rainbowduino.test.*;
import com.neophob.lib.rainbowduino.*;

//blinkenlight processing src: http://code.google.com/p/processing-blinkenlights/
import processing.lib.blinken.jaxb.*;
import processing.lib.blinken.*;

import ddf.minim.AudioInput;
import ddf.minim.Minim;
import ddf.minim.analysis.BeatDetect;

private Minim minim;
private AudioInput in;
private BeatDetect beat;
private BeatListener bl;

private static final int FPS=25;
private static final int SOUND_BUFFER_RESOLUTION = int(1.0f/(float)FPS);
private static int SIZE = 16;
private static final String[] ALL_BML_FILES = {
  "torus.bml",
  "bnf_auge.bml",
  "flatter_flatter.bml",
  "cube.bml", 
  "kreise-versetzt.bml"
};

BlinkenLibrary blink;
Rainbowduino r;
int blmFrames,sndLoop;
String currentFile;
float sndVolumeMax, currentFrame=0.0f;

//-------------------------------------------

void setup() {
  loadBlink(ALL_BML_FILES[0]);
  frameRate(FPS);
  size(SIZE, SIZE);
  background(0);

  List<Integer> list = new ArrayList<Integer>();		
  list.add(16);
  list.add(17);
  list.add(18);
  list.add(19);
  try {
    r = new Rainbowduino(this, list);
  } 
  catch (Exception e) {
    println("FAILED to open serial port!!");
    e.printStackTrace();
    exit();
  }

  minim = new Minim(this);
  in = minim.getLineIn( Minim.STEREO, 512 );
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  beat.setSensitivity(20);
  bl = new BeatListener(beat, in);
}

//-------------------------------------------

void draw() { 

  float volume = getSoundVolume();
  float addStep=0.1+volume*1.7f;
  if (beat.isKick()) {
    addStep=4.5f;
  }

  currentFrame+=addStep;
  blink.jump(int(currentFrame));

  if (int(currentFrame)>=blmFrames) {
    //load a new .bml file and make sure we pick a new file
    String name=currentFile;
    while (name.equals(currentFile)) {
      name=ALL_BML_FILES[int(random(0, ALL_BML_FILES.length))];
    }
    loadBlink(name);
  }

  image(blink, 0, 0, SIZE, SIZE);
  //send sketch content to four rainbowduino's
  r.sendRgbFrame((byte)16, (byte)18, (byte)19, (byte)17, this);
}


//-------------------------------------------

float getSoundVolume() {
  if (sndLoop>SOUND_BUFFER_RESOLUTION) {
    sndVolumeMax*=.93f;
  }
  float f = in.mix.level();
  if (f>sndVolumeMax) {
    sndVolumeMax=f;
    sndLoop=0;
  }
  sndLoop++;

  float norm=(1.0f/sndVolumeMax)*f;	

  //im a bad coder! limit it!
  if (norm>1f) {
    norm=1f;
  }

  //if the sound volume is very low, limit the normalized volume
  if (sndVolumeMax<0.004f) {
    norm/=2;
  }

  return norm;
}

//-------------------------------------------

void loadBlink(String name) {
  int r=0,g=0,b=0;
  while (r+g+b<400) {
    r = int(random(255));
    g = int(random(255));
    b = int(random(255));
  }
  currentFile=name;
  if (blink==null) {
    blink = new BlinkenLibrary(this, name, r, g, b);
  } 
  else {
    blink.loadFile(name, r, g, b);
  }
  blmFrames = blink.getNrOfFrames();
  //ignore the delay of the movie, use our fps!
  blink.setIgnoreFileDelay(true);
  currentFrame=0.0f;
  blink.jump(int(currentFrame));
}

