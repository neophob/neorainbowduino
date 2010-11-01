package com.neophob.lib.rainbowduino.test;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import processing.core.PApplet;

import com.neophob.lib.rainbowduino.Rainbowduino;

/**
 * simply test class, only used to test the lib<br>
 * <br>
 * part of the neorainbowduino library
 * 
 * @author Michael Vogt / neophob.com
 *
 */
public class TestSerial {
	
	public static void main(String args[]) {
		byte test1[] = new byte[] {1,2,3,4,5,6,7,8,9};
		byte test2[] = new byte[] {1,2,3,5,4,6,7,8,9};
		
		System.out.println(HelperUtils.getMD5(test1));
		System.out.println(HelperUtils.getMD5(test2));
		System.out.println(HelperUtils.getMD5(test1));
	}

}
