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
public class TestOutput extends PApplet {

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
			r.initPort("/dev/tty.usbserial-A9007QOH", list);
			System.out.println("ping: "+r.ping());
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		frame1 = new int[64];
		x=64;
	}
	
	private void slp(int ms) {
		try {
			Thread.sleep(ms);
		} catch (Exception e) {
			// TODO: handle exception
		}
	} 
	
	public void draw() {  
		
		for (int i=0; i<64;i++) {
			frame1[i]=x;//(int)((x&255)<<16 | (x%255)<<8 | (x&255));
		}
		for (int i=0; i<x/16;i++) {
			frame1[i] = 0xffffff;
		}
		x+=16;
		if (x>255) x=16;
		
		long l1 = System.currentTimeMillis();
		boolean result5 = r.sendRgbFrame((byte)5, frame1);
		long l2 = System.currentTimeMillis();
		boolean result6 = r.sendRgbFrame((byte)6, frame1);
		
		System.out.println("6:"+result6+", "+(l2-l1)+"ms, n5:"+result5+" "+(System.currentTimeMillis()-l2)+"ms");
		
	    long lastHeatBeatTs = r.getArduinoHeartbeat();
	    println(
	        "updated: "+new Date(lastHeatBeatTs).toGMTString()+
	        " Serial Buffer Size: "+r.getArduinoBufferSize()+
	        " last error: "+r.getArduinoErrorCounter()
	    );
	    slp(1500);
	}
	
	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.TestOutput" });
	}

}
