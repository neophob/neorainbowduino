package com.neophob.lib.rainbowduino.test;

import java.util.ArrayList;
import java.util.List;

import com.neophob.lib.rainbowduino.Rainbowduino;

import processing.core.PApplet;

public class TestPApplet extends PApplet {

	static int SIZE = 400;
	Rainbowduino r;

	public void setup() {
		List<Integer> list = new ArrayList<Integer>();		

		list.add(5);list.add(6);
		try {
			r = new Rainbowduino(this, list, "/dev/tty.usbserial-A9007QOH");
			System.out.println("ping: "+r.ping());
		} catch (Exception e) {
			e.printStackTrace();
		}

		frameRate(20);
		ellipseMode(CORNER);
		size(SIZE, SIZE);	
	}

	public void draw() {
		background(0);
		int r2 = 30+(int)random(SIZE/2);
		int x = (int)random(SIZE-r2);
		int y = (int)random(SIZE-r2);
		rect(x, y, r2, r2);
		
		r.sendRgbFrame((byte)5, this);
		r.sendRgbFrame((byte)6, this);		
	}

	public static void main(String args[]) {
		PApplet.main(new String[] { "com.neophob.lib.rainbowduino.test.TestPApplet" });
	}

}
