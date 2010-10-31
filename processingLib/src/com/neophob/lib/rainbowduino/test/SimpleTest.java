package com.neophob.lib.rainbowduino.test;

import java.util.ArrayList;
import java.util.Arrays;
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
public class SimpleTest extends PApplet {

	Rainbowduino r;
	
	/**
	 * 
	 */
	public void setup() {
		r = new Rainbowduino(this);
		
		List<Integer> list = new ArrayList<Integer>();		
		frameRate(1);
		  
		list.add(5);list.add(6);
		try {
			r.initPort(list);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		System.out.println("Scan I2C bus: ");
		r.i2cBusScan();
		//give the scanner some time!
		try {
			Thread.sleep(3000);
		} catch (Exception e) {}
		
		System.out.println("Found I2C devices: "+Arrays.toString(r.getScannedI2cDevices().toArray()));

/*		try {
			r.initPort("dunno", new ArrayList<Integer>());
		} catch (NoSerialPortFoundException e) {
			e.printStackTrace();
		}/**/	
	}
	
	public void draw() {  
		    long lastHeatBeatTs = r.getArduinoHeartbeat();
		    println(
		        "updated: "+new Date(lastHeatBeatTs).toGMTString()+
		        " Serial Buffer Size: "+r.getArduinoBufferSize()+
		        " last error: "+r.getArduinoErrorCounter()
		    );
	}
	
	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.SimpleTest" });
	}

}
