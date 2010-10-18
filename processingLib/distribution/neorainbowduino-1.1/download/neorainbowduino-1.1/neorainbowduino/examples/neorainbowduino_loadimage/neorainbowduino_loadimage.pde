import processing.serial.*;
import com.neophob.lib.rainbowduino.*;

//the rainbowduino device
Rainbowduino rainbowduino;

//buffer for our image data, must be 8*8 pixel
int[] simpleImage;

void setup() 
{
  frameRate(5);
  simpleImage = new int[64];
  
  //initialize library
  rainbowduino = new Rainbowduino(this);
  rainbowduino.initPort();

  //load+resize image
  PImage pimage = loadImage("hsv.jpg");
  //hint: this function is still buggy!
  //check Issue 332: PImage resize is not pretty
  pimage.resize(8, 8);
  
  //get image data
  pimage.loadPixels();
  System.arraycopy(pimage.pixels, 0, simpleImage, 0, 8*8);
  pimage.updatePixels();

  rainbowduino.sendRgbFrame((byte)6, simpleImage);
}

void draw()
{
}
