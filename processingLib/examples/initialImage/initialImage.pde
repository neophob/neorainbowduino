private static final int NR_OF_LED_HORIZONTAL = 8;
private static final int NR_OF_LED_VERTICAL = NR_OF_LED_HORIZONTAL ;

/**
this file create an include file (well, sort of) for the rainbowduino
firmware, that can be used as initial image.
*/
void setup() {
  PImage pic = loadImage("n.png");
  pic.loadPixels();
  byte neorainbowduinoImage[] = convertRgbToRainbowduino(pic.pixels);
  pic.updatePixels();
  
  String output="{";
  String line[] = new String[24];
  int cnt=0, idx=0;
  
  for (byte b: neorainbowduinoImage) {
    output+=(int)(b&255);

    if (cnt%4==3) {
      line[idx++] = output+"},";
      output = "{";
    } else output+=", ";
    cnt++;
  }
  saveStrings("data/image.txt", line);
  saveBytes("data/raw.dat", neorainbowduinoImage);
  noLoop();
}


private static byte[] convertRgbToRainbowduino(int[] data) {
  byte[] converted = new byte[3*8*4];
  int[] r = new int[NR_OF_LED_HORIZONTAL*NR_OF_LED_VERTICAL];
  int[] g = new int[NR_OF_LED_HORIZONTAL*NR_OF_LED_VERTICAL];
  int[] b = new int[NR_OF_LED_HORIZONTAL*NR_OF_LED_VERTICAL];
  int tmp;
  int ofs=0;
  int dst=0;

  //step#1: split up r/g/b and apply gammatab
  for (int y=0; y<NR_OF_LED_VERTICAL; y++) {
    for (int x=0; x<NR_OF_LED_HORIZONTAL; x++) {
      //one int contains the rgb color
      tmp = data[ofs++];

      //the buffer on the rainbowduino takes GRB, not RGB				
      g[dst] = gammaTab[(int) ((tmp>>16) & 255)];  //r
      r[dst] = gammaTab[(int) ((tmp>>8)  & 255)];  //g
      b[dst] = gammaTab[(int) ( tmp      & 255)];	 //b		
      dst++;
    }
  }
  //step#2: convert 8bit to 4bit
  //Each color byte, aka two pixels side by side, gives you 4 bit brightness control, 
  //first 4 bits for the left pixel and the last 4 for the right pixel. 
  //-> this means a value from 0 (min) to 15 (max) is possible for each pixel 		
  ofs=0;
  dst=0;
  for (int i=0; i<32;i++) {
    //240 = 11110000 - delete the lower 4 bits, then add the (shr-ed) 2nd color
    converted[00+dst] = (byte)(((r[ofs]&240) + (r[ofs+1]>>4))& 255); //r
    converted[32+dst] = (byte)(((g[ofs]&240) + (g[ofs+1]>>4))& 255); //g
    converted[64+dst] = (byte)(((b[ofs]&240) + (b[ofs+1]>>4))& 255); //b

    ofs+=2;
    dst++;
  }

  return converted;
}


	private static int[] gammaTab = {       
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      16,     16,     16,     16,
        16,     16,     16,     16,     16,     16,     16,     16, 
        16,     16,     16,     16,     16,     16,     16,     16, 
        16,     16,     16,     16,     16,     16,     16,     16,
        16,     16,     16,     16,     16,     16,     16,     16,
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     48,     48,     48,     48, 
        48,     48,     48,     48,     48,     48,     48,     48, 
        48,     48,     48,     48,     48,     48,     48,     48, 
        48,     48,     48,     48,     64,     64,     64,     64, 
        64,     64,     64,     64,     64,     64,     64,     64, 
        64,     64,     64,     64,     64,     64,     64,     64, 
        64,     64,     64,     64,     64,     64,     64,     64, 
        80,     80,     80,     80,     80,     80,     80,     80, 
        80,     80,     80,     80,     80,     80,     80,     80, 
        96,     96,     96,     96,     96,     96,     96,     96, 
        96,     96,     96,     96,     96,     96,     96,     96, 
        112,    112,    112,    112,    112,    112,    112,    112, 
        128,    128,    128,    128,    128,    128,    128,    128, 
        144,    144,    144,    144,    144,    144,    144,    144, 
        160,    160,    160,    160,    160,    160,    160,    160, 
        176,    176,    176,    176,    176,    176,    176,    176, 
        192,    192,    192,    192,    192,    192,    192,    192, 
        208,    208,    208,    208,    224,    224,    224,    224, 
        240,    240,    240,    240,    240,    255,    255,    255 
    };

