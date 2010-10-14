package com.neophob.lib.rainbowduino;

import processing.core.PApplet;



public class SimpleTest extends PApplet {

	public void setup() {
		Rainbowduino r = new Rainbowduino(this);
		try {
			r.initPort();
		} catch (NoSerialPortFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
		noLoop();
	}
	
	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.SimpleTest" });
	}

}
