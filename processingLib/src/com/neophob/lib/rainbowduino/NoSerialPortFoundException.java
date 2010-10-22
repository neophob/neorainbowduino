package com.neophob.lib.rainbowduino;

/**
 * If the library is unable to find a serial port, this Exception will be thrown
 * <br><br>
 * part of the neorainbowduino library
 * 
 * @author Michael Vogt / neophob.com
 *
 */
public class NoSerialPortFoundException extends Exception {

	/**
	 * 
	 * @param s
	 */
	public NoSerialPortFoundException(String s) {
		super(s);
	}
}
