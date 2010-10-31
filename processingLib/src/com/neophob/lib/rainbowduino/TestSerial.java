package com.neophob.lib.rainbowduino;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import processing.core.PApplet;

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
		r = new Rainbowduino(this);
		frameRate(5);
		
		List<Integer> list = new ArrayList<Integer>();		

		list.add(5);list.add(6);
		try {
//			r.initPort("/dev/tty.usbserial-A9007QOH", list);
			r.initPort(list);
			System.out.println("ping: "+r.ping());
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
	    long lastHeatBeatTs = r.getArduinoHeartbeat();
	    println(
	        "updated: "+new Date(lastHeatBeatTs).toGMTString()+
	        " Serial Buffer Size: "+r.getArduinoBufferSize()+
	        " last error: "+r.getArduinoErrorCounter()
	    );

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
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.TestOutput" });
	}

}
