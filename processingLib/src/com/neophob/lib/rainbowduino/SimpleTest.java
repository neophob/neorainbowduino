package com.neophob.lib.rainbowduino;

import java.util.ArrayList;

import processing.core.PApplet;

/**
 * 
 * @author michu
 *
 */
public class SimpleTest extends PApplet {

	/**
	 * 
	 */
	public void setup() {
		Rainbowduino r = new Rainbowduino(this);		
		/*try {
			r.initPort(new ArrayList<Integer>());
		} catch (NoSerialPortFoundException e) {
			e.printStackTrace();
		}	*/	

		try {
			r.initPort("dunno", new ArrayList<Integer>());
		} catch (NoSerialPortFoundException e) {
			e.printStackTrace();
		}/**/	
		noLoop();
	}
	
	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.SimpleTest" });
	}

}
