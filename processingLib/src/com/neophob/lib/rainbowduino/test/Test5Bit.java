package com.neophob.lib.rainbowduino.test;

import java.util.ArrayList;
import java.util.List;

import com.neophob.lib.rainbowduino.Rainbowduino;

import processing.core.PApplet;

public class Test5bit {

	public static void main(String args[]) {
		byte r=20;		//10100
		byte g=30;		//11110
		byte b=3;		//00011

		System.out.println("r: "+r);
		System.out.println("g: "+g);
		System.out.println("b: "+b);

		//RRRRRGGG GGXBBBBB
		int byte1 = (int)((r<<3) + (g>>2));		//10100111 -> 167
		int byte2 = (int)(((g&3)<<6) + b);		//10000011 -> 131
		System.out.println("byte1: "+byte1);
		System.out.println("byte2: "+byte2);
		
		byte r1, g1, b1;
		r1=(byte)(byte1>>3);
		g1=(byte)((byte1&7)<<2 | byte2>>6);
		b1=(byte)(byte2&0x1f);
		
		System.out.println("r1: "+r1);
		System.out.println("g1: "+g1);
		System.out.println("b1: "+b1);
	}

}
