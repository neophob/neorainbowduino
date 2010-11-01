package com.neophob.lib.rainbowduino;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Various Helper Methods
 * <br><br>
 * part of the neorainbowduino library
 * 
 * @author Michael Vogt / neophob.com
 *
 */
public class HelperUtils {

	static Logger log = Logger.getLogger(HelperUtils.class.getName());
	
	/**
	 * get md5 checksum of an byte array
	 * @param input
	 * @return
	 */
    public static String getMD5(byte[] input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(input);
            BigInteger number = new BigInteger(1, messageDigest);
            String hashtext = number.toString(16);
            // Now we need to zero pad it if you actually want the full 32 chars.
            while (hashtext.length() < 32) {
                hashtext = "0" + hashtext;
            }
            return hashtext;
        }
        catch (NoSuchAlgorithmException e) {
        	log.log(Level.WARNING, "Failed to calculate MD5 sum: {0}", e);
            return "";
        }
    }
}
