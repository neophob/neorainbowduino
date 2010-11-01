package com.neophob.lib.rainbowduino.test;

import com.neophob.lib.rainbowduino.HelperUtils;

/**
 * simply test class, only used to test the lib<br>
 * <br>
 * part of the neorainbowduino library
 * 
 * @author Michael Vogt / neophob.com
 *
 */
public class TestMD5 {
	
	public static void main(String args[]) {
		byte test1[] = new byte[] {1,2,3,4,5,6,7,8,9};
		byte test2[] = new byte[] {1,2,3,5,4,6,7,8,9};
		
		System.out.println(HelperUtils.getMD5(test1));
		System.out.println(HelperUtils.getMD5(test2));
		System.out.println(HelperUtils.getMD5(test1));
	}

}
