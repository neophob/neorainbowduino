/*
A nice wrapper class to control the Rainbowduino 

(c) copyright 2009 by rngtng - Tobias Bielohlawek
(c) copyright 2010 by Michael Vogt/neophob.com 
http://code.google.com/p/rainbowduino-firmware/wiki/FirmwareFunctionsReference

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General
Public License along with this library; if not, write to the
Free Software Foundation, Inc., 59 Temple Place, Suite 330,
Boston, MA  02111-1307  USA
 */

package com.neophob.lib.rainbowduino;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import processing.core.PApplet;
import processing.serial.Serial;

/**
 * library to communicate with an arduino via serial port
 * the arduino control up to n rainbowduinos usin the i2c protocol
 * 
 * @author Michael Vogt / neophob.com
 *
 */
public class Rainbowduino implements Runnable {

	static Logger log = Logger.getLogger(Rainbowduino.class.getName());

	public static int width = 8;
	public static int height = width;

	public final String VERSION = "1.0";

	private static final byte START_OF_CMD = 0x01;
	private static final byte CMD_PING = 0x04;
	private static final byte CMD_SENDFRAME = 0x03;
	private static final byte CMD_HEARTBEAT = 0x10;
	private static final byte START_OF_DATA = 0x10;
	private static final byte END_OF_DATA = 0x20;

	private PApplet app;

	private int baud = 57600;//115200;
	private Serial port;
	
	
	//the home made gamma table - please note:
	//the rainbowduino has a color resoution if 4096 colors (12bit)
	private static int[] gammaTab = {       
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      0,      0,      0,      0,
		0,      0,      0,      0,      16,     16,     16,     16,
        16,     16,     16,     16,     16,     16,     16,     16, 
        16,     16,     16,     16,     16,     16,     16,     16, 
        16,     16,     16,     16,     16,     16,     16,     16,
        16,     16,     16,     16,     16,     16,     16,     16,
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     32,     32,     32,     32, 
        32,     32,     32,     32,     48,     48,     48,     48, 
        48,     48,     48,     48,     48,     48,     48,     48, 
        48,     48,     48,     48,     48,     48,     48,     48, 
        48,     48,     48,     48,     64,     64,     64,     64, 
        64,     64,     64,     64,     64,     64,     64,     64, 
        64,     64,     64,     64,     64,     64,     64,     64, 
        64,     64,     64,     64,     64,     64,     64,     64, 
        80,     80,     80,     80,     80,     80,     80,     80, 
        80,     80,     80,     80,     80,     80,     80,     80, 
        96,     96,     96,     96,     96,     96,     96,     96, 
        96,     96,     96,     96,     96,     96,     96,     96, 
        112,    112,    112,    112,    112,    112,    112,    112, 
        128,    128,    128,    128,    128,    128,    128,    128, 
        144,    144,    144,    144,    144,    144,    144,    144, 
        160,    160,    160,    160,    160,    160,    160,    160, 
        176,    176,    176,    176,    176,    176,    176,    176, 
        192,    192,    192,    192,    192,    192,    192,    192, 
        208,    208,    208,    208,    224,    224,    224,    224, 
        240,    240,    240,    240,    240,    255,    255,    255 
    };

	private Thread runner;
	private long arduinoHeartbeat;
	private int arduinoBufferSize;
	//logical errors reported by arduino
	private int arduinoErrorCounter;
	//connection errors to arduino
	private int connectionErrorCounter;

	/**
	 * Create a new instance to communicate with the rainbowduino. Make sure to (auto)init the serial port, too 
	 * 
	 * @param _app parent Applet
	 */
	public Rainbowduino(PApplet _app) {
		this.app = _app;
		app.registerDispose(this);
	}

	/**
	 * 
	 */
	public void dispose() {
		runner = null;
		if(connected()) port.stop();
	}

	/**
	 * get messages from the serial port from a seperate thread
	 */
	public void run() {
		while (Thread.currentThread() == runner) {
			try {
				Thread.sleep(500);
			} catch (InterruptedException e) {
			}

			if (connected() && port.available() > 3) {
				byte[] msg = port.readBytes();
				if (msg!=null && msg.length>3) {
					if (msg[0]==START_OF_CMD && msg[1]==CMD_HEARTBEAT) {		
						arduinoHeartbeat = System.currentTimeMillis();
						arduinoErrorCounter = (int)(msg[2]&255);
						arduinoBufferSize = (int)msg[3];	
					}					
				}
			}
		}
	}


	/**
	 * return the version of the library.
	 *
	 * @return String version number
	 */
	public String version() {
		return VERSION;
	}

	
	/**
	 * @return wheter rainbowudino is connected
	 */
	public boolean connected() {
		return (port != null);
	}	

	
	/**
	 * auto init serial port by default values
	 */
	public void initPort() throws NoSerialPortFoundException {
		this.initPort(null, 0);
	}

	
	/**
	 * Auto init serial port with given baud rate
	 * @param baud
	 */
	public void initPort(int baud) throws NoSerialPortFoundException {
		this.initPort(null, baud);
	}	

	
	/**
	 * 
	 * @param portName
	 * @throws NoSerialPortFoundException
	 */
	public void initPort(String portName) throws NoSerialPortFoundException {
		this.initPort(portName, 0);
	}	

	
	/**
	 * Open serial port with given name and baud rate.
	 * No sensity checks
	 * 
	 */
	public void initPort(String portName, int baud) throws NoSerialPortFoundException {
		if(baud > 0) {
			this.baud = baud;
		}
		
		if (portName!=null && !portName.trim().isEmpty()) {
			//open specific port
			log.log(Level.INFO,	"open port: {0}", portName);
			openPort(portName);
		} else {
			//try to find the port
			String[] ports = Serial.list();
			for (int i=0; port==null && i<ports.length; i++) {
				log.log(Level.INFO,	"open port: {0}", ports[i]);
				openPort(ports[i]);
			}
		}
		
		if (port==null) {
			log.log(Level.WARNING,	"failed to open serial port!");
			throw new NoSerialPortFoundException();
		}
		
		log.log(Level.INFO,	"found serial port!");
		
	}
	

	/**
 	 * 
 	 * Open serial port with given name. Send ping to check if port is working.
	 * If not port is closed and set back to null
	 * 
	 * @param portName
	 */
	private void openPort(String portName) {
		if (portName == null) {
			return;
		}
		
		try {
			port = new Serial(app, portName, this.baud);
			sleep(1500); //give it time to initialize		
			if (ping((byte)0)) {
				this.runner = new Thread(this);
				this.runner.setName("ZZ Arduino Heartbeat Thread");
				this.runner.start(); 	
				return;
			}
			log.log(Level.WARNING, "No response from port {0}", portName);
		} catch (Exception e) {	
			log.log(Level.WARNING, "Failed to open port {0}", portName);
		}
		
		if (port != null) {
			port.stop();        					
		}
		port = null;
	}



	/**
	 * 
	 * @return wheter ping was successfull
	 * 
	 */
	public synchronized boolean ping(byte addr) {		
		/*
		 *  0   <startbyte>
		 *  1   <i2c_addr>
		 *  2   <num_bytes_to_send>
		 *  3   command type, was <num_bytes_to_receive>
		 *  4   data marker
		 *  5   ... data
		 *  n   end of data
		 */
		byte cmdfull[] = new byte[7];
		cmdfull[0] = START_OF_CMD;
		cmdfull[1] = addr; //unused here!
		cmdfull[2] = 0x01;
		cmdfull[3] = CMD_PING;
		cmdfull[4] = START_OF_DATA;
		cmdfull[5] = 0x02;
		cmdfull[6] = END_OF_DATA;

		//do not use the processing command, as it displays ugly error messages on the console!
		//port.write(cmdfull);
		try {
			port.output.write(cmdfull);
			port.output.flush();
		} catch (Exception e) {
			//e.printStackTrace();
			return false;
		}

		int timeout=25; //wait up to 2.5s
		while( timeout > 0 && port.available() < 2) {
			sleep(100); //in ms
			timeout--;
		}

		if (timeout < 1) {
			return false;
		}

		byte[] msg = port.readBytes();		
		if (msg[0]==START_OF_CMD && msg[1]==CMD_PING) {
			return true;
		}

		return false;
	}

	/**
	 * wrapper class to send a rgb image to the rainbowduino.
	 * the rgb image gets converted to the rainbowduino compatible
	 * "image format"
	 * 
	 * @param data rgb data
	 * @param check wheter to perform sensity check
	 */
	public void sendRgbFrame(byte addr, int[] data) {
		byte buffer[] = convertRgbToRainbowduino(data);
		sendFrame(addr, buffer);
	}

	
	/**
	 * send a frame to the active rainbowduino the data needs to be in this format:
	 * buffer[3][8][4], The array to be sent formatted as [color][row][dots]   
	 * 
	 * @param data byte[3][8][4]
	 * @param check wheter to perform sensity check
	 */
	public synchronized void sendFrame(byte addr, byte data[]) {
		//TODO stop if connection countrer > n
		//if (connectionErrorCounter>10000) {}
		
		byte cmdfull[] = new byte[6+data.length];
		cmdfull[0] = START_OF_CMD;
		cmdfull[1] = addr;
		cmdfull[2] = (byte)data.length;
		cmdfull[3] = CMD_SENDFRAME;
		cmdfull[4] = START_OF_DATA;		
		for (int i=0; i<data.length; i++) {
			cmdfull[5+i] = data[i];
		}
		cmdfull[data.length+5] = END_OF_DATA;
		
		try {
			port.write(cmdfull);	
		} catch (Exception e) {
			log.warning("Failed to send data to serial port! errorcnt: "+connectionErrorCounter);
			connectionErrorCounter++;
		}
	}


	public int getArduinoErrorCounter() {
		return arduinoErrorCounter;
	}

	public int getArduinoBufferSize() {
		return arduinoBufferSize;
	}

	public long getArduinoHeartbeat() {
		return arduinoHeartbeat;
	}

	/**
	 * convert rgb image data to rainbowduino compatible format
	 * format 8x8x4
	 * @param data
	 * @return
	 */
	private static byte[] convertRgbToRainbowduino(int[] data) {
		byte[] converted = new byte[3*8*4];
		int[] r = new int[64];
		int[] g = new int[64];
		int[] b = new int[64];
		int tmp;
		int ofs=0;
		int dst=0;

		//step#1: split up r/g/b and apply gammatab
		for (int y=0; y<height; y++) {
			for (int x=0; x<width; x++) {
				//one int contains the rgb color
				tmp = data[ofs++];
				//the buffer on the rainbowduino takes GRB, not RGB
				
				r[dst] = gammaTab[(int) ((tmp>>16) & 255)];
				g[dst] = gammaTab[(int) ((tmp>>8)  & 255)];
				b[dst] = gammaTab[(int) ( tmp      & 255)];				
				dst++;
			}
		}
		//step#2: convert 8bit to 4bit
		//Each color byte, aka two pixels side by side, gives you 4 bit brightness control, 
		//first 4 bits for the left pixel and the last 4 for the right pixel. 
		//-> this means a value from 0 (min) to 15 (max) is possible for each pixel 		
		ofs=0;
		dst=0;
		for (int i=0; i<32;i++) {
			//240 = 11110000 - delete the lower 4 bits, then add the (shr-ed) 2nd color
			converted[00+dst] = (byte)(((r[ofs]&240) + (r[ofs+1]>>4))& 255); //r
			converted[32+dst] = (byte)(((g[ofs]&240) + (g[ofs+1]>>4))& 255); //g
			converted[64+dst] = (byte)(((b[ofs]&240) + (b[ofs+1]>>4))& 255); //b

			ofs+=2;
			dst++;
		}

		return converted;
	}


	private void sleep(int ms) {
		try {
			Thread.sleep(ms);
		}
		catch(InterruptedException e) {
		}
	}

	class RainbowduinoTimeOut extends Exception {}
	class RainbowduinoError extends Exception {
		int error;

		public RainbowduinoError(int _error) {
			this.error = _error;			
		}

		public void print() {
			log.log(Level.INFO,
					"Error happend: {0} "
					, new Object[] { this.error });

		}		
	}

}