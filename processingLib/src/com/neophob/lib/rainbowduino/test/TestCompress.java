package com.neophob.lib.rainbowduino.test;

import com.neophob.lib.rainbowduino.RainbowduinoHelper;


/**
 * simply test class, only used to test the lib<br>
 * <br>
 * part of the neorainbowduino library
 * 
 * @author Michael Vogt / neophob.com
 *
 */
public class TestCompress {

	static void printCompressed(byte[] data) {
		byte[] ret1 = RainbowduinoHelper.rleCompress8bit(data);
		
		for (byte b: ret1) {
//			System.out.print("0x"+Integer.toString(b & 0xFF, 16)+" ");
			System.out.print((b & 0xFF)+" ");
		}
		System.out.println();
	}
	
	public static void main(String args[]) {

		byte data1[] = new byte[] {'A','A','A','A','A','A','A','B'};
		printCompressed(data1);
		
		byte data2[] = new byte[] {

				(byte)0xff,(byte)0xff,(byte)0xff,(byte)0xff,
				100,100,100,100,
				100,100,100,100,
				100,100,100,100,
				100,100,100,100,
				100,100,100,100,
				100,100,100,100,
				33,64,24,85
		};
		printCompressed(data2);
	}

}
