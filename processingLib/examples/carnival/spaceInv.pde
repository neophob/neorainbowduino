/*

 set screensize to 8 if you want to use the rainbowduino. if we resize the image to 400 pixel
 (for example) the image gets blurry - and this will look very ugly on the rainbowduino!
 
 see processing issue #165: http://code.google.com/p/processing/issues/detail?id=165#c2
 */
import processing.serial.*;

import com.neophob.lib.rainbowduino.test.*;
import com.neophob.lib.rainbowduino.*;

import java.awt.Color;

static final int SCREENSIZE = 8*1;
static final int SIZE = 8;
static final int INVADER_DISPLAY_TIME_IN_MS = 666;
static final int SCROLLER_TIME_IN_MS = 88;
int[][] grid = new int[SIZE][SIZE];
int gridsize = SCREENSIZE/SIZE;

Rainbowduino r;

PImage introImg;
float introImgMulti;
int introImgOfs;
boolean introDone = false;
int frame=0;

PImage plasma;
int rnd=0;
int rndR, rndG, rndB;

static final int NR_OF_IMAGES = 12;
int[][] images = new int[15][2];
long t=0;


void setup() {
  size(SCREENSIZE,SCREENSIZE);
  background(255);
  frameRate(25);
  noStroke();
  noSmooth();
  
  //populate known images
  images[0][0]=0x1537; 
  images[0][1]=0xfbdb;        //neorainbowduino logo
  images[1][0]=0x553d; 
  images[1][1]=0xfb15;        //alien head
  images[2][0]=0x177f; 
  images[2][1]=0xf771;        //cross
  images[3][0]=0x6017; 
  images[3][1]=0xf930;        //skull
  images[4][0]=0x4137; 
  images[4][1]=0xa5b0;        //invader  
  images[5][0]=0x11bf; 
  images[5][1]=0xf731;        //heart  
  images[6][0]=0x51bd; 
  images[6][1]=0xe411;        //invader
  images[7][0]=0x999f; 
  images[7][1]=0xf999;        //pause
  images[8][0]=0x1513; 
  images[8][1]=0xf511;        //pacman
  images[9][0]=0x13DF; 
  images[9][1]=0x7B35;        //ant
  images[10][0]=0x6413; 
  images[10][1]=0x8316;       //big eye alien
  images[11][0]=0x4413; 
  images[11][1]=0xA610;       //skull

  introImg = loadImage("I_O_Pixels.png"); 
  introImgMulti = SCREENSIZE/introImg.height;

  plasma=createImage(SCREENSIZE, SCREENSIZE, RGB);
  
  List<Integer> list = new ArrayList<Integer>();		
  list.add(16);
  try {
    r = new Rainbowduino(this, list);

    System.out.println("ping: "+r.ping());
  } catch (Exception e) {
    println("FAILED to open serial port!!");
    e.printStackTrace();
  }
  
  background(0);
  r.sendRgbFrame((byte)16, this);
  r.sendRgbFrame((byte)17, this);
  r.sendRgbFrame((byte)18, this);
  r.sendRgbFrame((byte)19, this);
  
  delay(3000);
}

void mouseReleased() {
  doInvader();
}

void draw() {//8 4 2 1

  if (introDone){//=true) {
    if (System.currentTimeMillis()-t > INVADER_DISPLAY_TIME_IN_MS) { 
      doInvader();
      t=System.currentTimeMillis();
      frame++;
      //colorize the plasma different for each invader
      rndB = 128+int(random(128));
      rndG = 128+int(random(128));
      rndR = 255-rndB;//128+int(random(92));
      
      println("RGB: "+rndR+", "+rndG+","+rndB);
    }
    drawInvader();
    drawPlasma();
  } 
  else {
    if (System.currentTimeMillis()-t > SCROLLER_TIME_IN_MS) {
      t=System.currentTimeMillis();
      doScrollText();
    }
  }/**/
  
  //r.sendRgbFrame((byte)16, this);
 // r.sendRgbFrame((byte)17, this);
  //r.sendRgbFrame((byte)18, this);
  r.sendRgbFrame((byte)19, this);

}

// -------------------------------------
void doScrollText() {
  //image(introImg, 0, 0, SCREENSIZE, SCREENSIZE);
  copy(introImg, introImgOfs, 0, SIZE, SIZE, 0, 0, SCREENSIZE, SCREENSIZE);
  introImgOfs++;

  if (introImgOfs>=introImg.width) {
    introDone = true;
    print("intro part done");
  }
}

// -------------------------------------
void doInvader() {
  int r = int(random(7));
  if (frame<8) {
    r = int(random(4));
  }
  //  r=0;
  //  invader(images[11][0], images[11][1]);
  switch (r) {
  case 0: //mix prestored
  case 5:  
    invader(images[int(random(NR_OF_IMAGES))][0], images[int(random(NR_OF_IMAGES))][1]);
    break;
  case 1: //prestored
    int i = int(random(NR_OF_IMAGES));
    invader(images[i][0], images[i][1]);
    break;
  case 2: //mutate invader
  case 6:  
    invader(images[int(random(NR_OF_IMAGES))][0], images[int(random(NR_OF_IMAGES))][1]);
    mutateInvader();
    break;
  case 3: //prestored + random
    invader(images[int(random(NR_OF_IMAGES))][0], int(random(0xffff)));
    break;
  case 4: //random + prestored 
    invader(int(random(0xffff)), images[int(random(NR_OF_IMAGES))][0]);
    break;
  default: 
    print("oops");
  }
}

// -------------------------------------
void drawInvader() {
  for (int i=0; i<SIZE; i++) {
    for (int j=0; j<SIZE; j++) {
      if (grid[i][j] == 0)
        fill(0);
      else 
        fill(255);

      rect(i*gridsize, j*gridsize, gridsize, gridsize);
    }
  }
}

// -------------------------------------
void randomInvader() {
  for (int y=0; y<8; y++) { // i = columns
    for (int x=0; x<4; x++) { // j = rows
      grid[x][y] = int(random(2));
    }
  }
  mirrorInvader(grid);
}

// -------------------------------------
void invader(int nr1, int nr2) {
  if (nr1>0xffff) {
    nr1=0xffff;
  }
  if (nr2>0xffff) {
    nr2=0xffff;
  }

  int[] value = new int[4*8];
  int ofs=0;

  int nr=nr1;
  for (int i=0; i<4; i++) {
    if (i==2) {
      nr=nr2;
    }
    String bin = binary((int)(nr & 0xff), 8);
    nr = nr>>8;
    for (int j=7; j>-1; j--) {
      char x = bin.charAt(j);
      if (x=='0') value[ofs++] = 0;
      else value[ofs++] = 1;
    }
  }

  ofs=0;
  for (int y=0; y<8; y++) { // i = columns
    for (int x=0; x<4; x++) { // j = rows
      grid[x][y] = value[ofs++];
    }
  }
  mirrorInvader(grid);
}

// -------------------------------------
void mutateInvader() {
  for (int y=1; y<7; y++) { // i = columns
    for (int x=0; x<4; x++) { // j = rows
      if (1==int(random(3))) {
        grid[x][y] = int(random(2));
      }
    }
  }
  mirrorInvader(grid);
}

// -------------------------------------
void mirrorInvader(int[][] grid) {
  for (int y=0; y<8; y++) {
    grid[7][y] = grid[0][y];
    grid[6][y] = grid[1][y];  
    grid[5][y] = grid[2][y]; 
    grid[4][y] = grid[3][y];
  }
}

// -------------------------------------
void drawPlasma() { 
  plasma.loadPixels();

  float xc = 20;

  // This runs plasma as fast as your computer can handle
  int timeDisplacement = (frameCount++)>>2;

  // No need to do this math for every pixel
  float calculation1 = sin( radians(timeDisplacement * 0.61655617f));
  float calculation2 = sin( radians(timeDisplacement * -3.6352262f));

  int aaa = 1024;
  // Plasma algorithm
  for (int x = 0; x < SCREENSIZE; x++, xc++) {
    float yc = 20;
    float s1 = aaa + aaa * sin(radians(xc) * calculation1 );

    for (int y = 0; y < SCREENSIZE; y++, yc++) {
      float s2 = aaa + aaa * sin(radians(yc) * calculation2 );
      float s3 = aaa + aaa * sin(radians((xc + yc + timeDisplacement * 5) / 1));  
      float s  = (s1 + s2 + s3) / (1024+512);
      //MULTIPLY
      plasma.pixels[y*SCREENSIZE+x] = tintMe( Color.HSBtoRGB(s, 0.4, 1.0f), rndR, rndG, rndB );
      //plasma.pixels[y*SCREENSIZE+x] = tintMe( Color.HSBtoRGB(s, 0.2, 0.5f), rndR, rndG, rndB );
    }
  }
  plasma.updatePixels();
  //MULTIPLY
  this.blend(plasma, 0, 0, SCREENSIZE, SCREENSIZE, 0, 0, SCREENSIZE, SCREENSIZE, MULTIPLY );
  //ADD
  //this.blend(plasma, 0, 0, SCREENSIZE, SCREENSIZE, 0, 0, SCREENSIZE, SCREENSIZE, ADD);
}

int tintMe(int col, int r, int g, int b) {
  short cr = (short) ((col>>16)&255);
  cr = (short)(cr*r/255);
  short cg = (short) ((col>>8)&255);
  cg = (short)(cg*g/255);
  short cb = (short) (col&255);
  cb = (short)(cb*b/255);
  return  (0xff << 24) | (cr << 16) | (cg << 8) | cb;
}

