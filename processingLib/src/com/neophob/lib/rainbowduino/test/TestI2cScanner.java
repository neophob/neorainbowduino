package com.neophob.lib.rainbowduino.test;

import java.util.ArrayList;
import java.util.Arrays;
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
public class TestI2cScanner extends PApplet {

	Rainbowduino r;
	
	/**
	 * 
	 */
	public void setup() {
		r = new Rainbowduino(this);
		
		try {
			r.initPort(new ArrayList<Integer>());
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		System.out.println("Scan I2C bus: ");
		System.out.println(r.i2cBusScan());
		System.out.println("Found I2C devices: "+Arrays.toString(r.getScannedI2cDevices().toArray()));
		
		noLoop();
	}
	
	public void draw() {  
	}
	
	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.test.TestI2cScanner" });
	}

}
