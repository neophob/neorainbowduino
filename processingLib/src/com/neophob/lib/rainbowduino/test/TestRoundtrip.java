package com.neophob.lib.rainbowduino.test;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

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
public class TestRoundtrip extends PApplet {

	Rainbowduino r;
	int [] frame1;
	
	/**
	 * 
	 */
	public void setup() {		
		frameRate(100);
		
		try {
			r = new Rainbowduino(this, new ArrayList<Integer>());
			long l1 = System.currentTimeMillis();
			r.ping();
			long l2= System.currentTimeMillis()-l1;
			System.out.println("need "+l2+"ms to send ping");
		} catch (Exception e) {
			e.printStackTrace();
		}
		frame1 = new int[64];
	}
	
	public void draw() {
		long l1 = System.currentTimeMillis();
		r.sendRgbFrame((byte)1, frame1);
		long l2= System.currentTimeMillis()-l1;
		System.out.println("need "+l2+"ms to send data");
	}
	
	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.test.TestRoundtrip" });
	}

}
