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
public class TestSerial extends PApplet {

	Rainbowduino r;
	int [] frame2, frame1;
	int x;
	
	/**
	 * 
	 */
	public void setup() {		
		frameRate(5);
		
		List<Integer> list = new ArrayList<Integer>();		

		list.add(5);list.add(6);
		try {
			r = new Rainbowduino(this, list);
			System.out.println("ping: "+r.ping());
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		if (r.getArduinoErrorCounter()!=0) {
	    long lastHeatBeatTs = r.getArduinoHeartbeat();
	    println(
	        "updated: "+new Date(lastHeatBeatTs).toGMTString()+
	        " Serial Buffer Size: "+r.getArduinoBufferSize()+
	        " last error: "+r.getArduinoErrorCounter()
	    );
		}

	}
	
	private void slp(int ms) {
		try {
			Thread.sleep(ms);
		} catch (Exception e) {
			// TODO: handle exception
		}
	} 
	
	public void draw() {  

	}
	
	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.test.TestOutput" });
	}

}
