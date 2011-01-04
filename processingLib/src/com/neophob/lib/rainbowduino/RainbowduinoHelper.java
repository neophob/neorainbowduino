package com.neophob.lib.rainbowduino;

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Various Helper Methods
 * <br><br>
 * part of the neorainbowduino library
 * 
 * @author Michael Vogt / neophob.com
 *
 */
public class RainbowduinoHelper {

	private static Logger log = Logger.getLogger(RainbowduinoHelper.class.getName());

	private static final int BUFFERSIZE = Rainbowduino.NR_OF_LED_HORIZONTAL*Rainbowduino.NR_OF_LED_VERTICAL;


	//the home made gamma table - please note:
	//the rainbowduino has a color resoution if 4096 colors (12bit)
	private static int[] GAMMA_TAB = {       
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


	/*

{
  0,  0,    0,   0,   0,   0,   0,   0, 
  0,  0,    0,   0,   0,   0,   1,   1,
  1,  1,    1,   1,   1,   1,   1,   1,
  2,  2,    2,   2,   2,   2,   2,   3, 
  3,  3,    3,   3,   4,   4,   4,   4, 
  5,  5,    5,   5,   6,   6,   6,   6, 
  7,  7,    7,   8,   8,   8,   9,   9, 
  9,  10,  10,  11,  11,  11,  12,  12, 
 13,  13,  13,  14,  14,  15,  15,  16,
 16,  17,  17,  18,  18,  19,  19,  20, 
 20,  21,  22,  22,  23,  23,  24,  25, 
 25,  26,  26,  27,  28,  28,  29,  30, 
 30,  31,  32,  33,  33,  34,  35,  35, 
 36,  37,  38,  39,  39,  40,  41,  42, 
 43,  43,  44,  45,  46,  47,  48,  49,  
 49,  50,  51,  52,  53,  54,  55,  56, 
 57,  58,  59,  60,  61,  62,  63,  64,
 65,  66,  67,  68,  69,  70,  71,  73,  
 74,  75,  76,  77,  78,  79,  81,  82,  
 83,  84,  85,  87,  88,  89,  90,  91,  
 93,  94,  95,  97,  98,  99, 100, 102, 
103, 105, 106, 107, 109, 110, 111, 113, 
114, 116, 117, 119, 120, 121, 123, 124, 
126, 127, 129, 130, 132, 133, 135, 137, 
138, 140, 141, 143, 145, 146, 148, 149, 
151, 153, 154, 156, 158, 159, 161, 163, 
165, 166, 168, 170, 172, 173, 175, 177, 
179, 181, 182, 184, 186, 188, 190, 192, 
194, 196, 197, 199, 201, 203, 205, 207, 
209, 211, 213, 215, 217, 219, 221, 223, 
225, 227, 229, 231, 234, 236, 238, 240, 
242, 244, 246, 248, 251, 253, 255} 

	 */

	/**
	 * 
	 */
	private RainbowduinoHelper() {
		//no instance allowed
	}
	
	/**
	 * get md5 checksum of an byte array
	 * @param input
	 * @return
	 */
	public static String getMD5(byte[] input) {
		try {
			MessageDigest md = MessageDigest.getInstance("MD5");
			byte[] messageDigest = md.digest(input);
			BigInteger number = new BigInteger(1, messageDigest);
			String hashtext = number.toString(16);
			// Now we need to zero pad it if you actually want the full 32 chars.
			while (hashtext.length() < 32) {
				hashtext = "0" + hashtext;
			}
			return hashtext;
		}
		catch (NoSuchAlgorithmException e) {
			log.log(Level.WARNING, "Failed to calculate MD5 sum: {0}", e);
			return "";
		}
	}


	/**
	 * convert rgb image data to rainbowduino compatible format
	 * format 8x8x4
	 * 
	 * @param data the rgb image as int[64]
	 * @return rainbowduino compatible format as byte[3*8*4] 
	 */
	public static byte[] convertRgbToRainbowduino(int[] data) throws IllegalArgumentException {
		if (data.length!=64) {
			throw new IllegalArgumentException("data lenght must be 64 bytes!");
		}
		byte[] converted = new byte[3*8*4];
		int[] r = new int[BUFFERSIZE];
		int[] g = new int[BUFFERSIZE];
		int[] b = new int[BUFFERSIZE];
		int tmp;
		int ofs=0;
		int dst;

		//step#1: split up r/g/b and apply gammatab
		for (int n=0; n<BUFFERSIZE; n++) {
			//one int contains the rgb color
			tmp = data[ofs];

			//the buffer on the rainbowduino takes GRB, not RGB				
			g[ofs] = GAMMA_TAB[(int) ((tmp>>16) & 255)];  //r
			r[ofs] = GAMMA_TAB[(int) ((tmp>>8)  & 255)];  //g
			b[ofs] = GAMMA_TAB[(int) ( tmp      & 255)];	 //b		
			ofs++;
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


	/**
	 * resize an pixel array using 
	 * @param buffer
	 * @param newXSize
	 * @param newYSize
	 * @param oldXSize
	 * @param oldYSize
	 * @return
	 */
	public static int[] resizeImage(int[] buffer, int newXSize, int newYSize, int oldXSize, int oldYSize) {
		return multiStepBilinearResize(buffer, newXSize, newYSize, oldXSize, oldYSize);
	}
	
	/**
	 * 
	 */
	private static int[] multiStepBilinearResize(int[] buffer, int deviceXSize, int deviceYSize, int currentXSize, int currentYSize) {
		BufferedImage bi = new BufferedImage(currentXSize, currentYSize, BufferedImage.TYPE_INT_RGB);
		bi.setRGB(0, 0, currentXSize, currentYSize, buffer, 0, currentXSize);		
		
		if (deviceXSize > currentXSize) {
			//upscale - used for debug view
			bi = Scalr.resize(bi, Scalr.Method.SPEED, deviceXSize, deviceYSize);
		} else {
			//downscale - used to send to device
			bi = Scalr.resize(bi, Scalr.Method.QUALITY, deviceXSize, deviceYSize);	
		}		              
        return getPixelsFromImage(bi, deviceXSize, deviceYSize);
    }
	
	/**
	 * 
	 */
	/**
	 * internal use - get buffer from image
	 * @param scaledImage
	 * @param deviceXSize
	 * @param deviceYSize
	 * @return
	 */
	private static int[] getPixelsFromImage(BufferedImage scaledImage, int deviceXSize, int deviceYSize) {
		//painfull slow!
		//return scaledImage.getRGB(0, 0, deviceXSize, deviceYSize, null, 0, deviceXSize);
		DataBufferInt buf = (DataBufferInt) scaledImage.getRaster().getDataBuffer();
		return buf.getData();
	}

}
