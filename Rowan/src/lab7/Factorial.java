package lab7;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.math.BigInteger;
import java.util.Scanner;

public class Factorial {
	/*
	 * Purpose: Data Structure and Algorithms Lab 7 Problem 1
	 * Status: Complete and thoroughly tested
	 * Last update: 10/25/17
	 * Submitted:  10/31/17
	 * Comment: sample runs attached
	 * @author: Nikhil Shah
	 * @version: 2017.10.25
	 */

	public static void main(String[] args) throws IOException {
		boolean written = false;
		Scanner key;
		PrintStream stdout = System.out;
		if (args.length == 0) {
			key = new Scanner(System.in);
		} else {
			written = true;
			key = new Scanner(new File(args[0]));
			System.setOut(new PrintStream(new File(args[1])));
		}
		System.out.print("Please enter the number of factorials to compute: ");
		int numOfFactorials = key.nextInt();
		long start1 = System.currentTimeMillis();
		option1(numOfFactorials);
		long end1 = System.currentTimeMillis();
		System.out.println("Starting option 2");
		long start2 = System.currentTimeMillis();
		option2(numOfFactorials);
		long end2 = System.currentTimeMillis();
		if (written) {
			System.setOut(stdout);
			System.out.println("Output written to " + args[1]);
		}
		System.out.println("For " + numOfFactorials + " of factorials, option 1: " + (end1 - start1) + " milliseconds and option 2: " + (end2 - start2) + " milliseconds");
		key.close();
		// int fails at 13 and long fails at 21
		// Conclusion: option 1 is faster in the small case, but increases exponentially when option 2 is linear increase
	}
	public static BigInteger rFactBig(int num) {
		BigInteger b = new BigInteger(Integer.toString(num));
		if (num == 1 || num == 0)
			return b;
		return rFactBig(num-1).multiply(b);
	}
	public static long rFactLong(int num) {
		if (num == 1 || num == 0)
			return num;
		return rFactLong(num - 1) * num;
	}
	public static int rFactInt(int num) {
		if (num == 1 || num == 0)
			return num;
		return rFactInt(num - 1) * num;
	}
	public static void option1(int num) throws IOException {
		//basic recursive factorial
		BigInteger fact = BigInteger.ONE;
		for (int i = 1; i < num;i++) {
			fact = rFactBig(i);
			System.out.println(i+ "! = " + fact);
		}
	}
	public static void option2(int num) throws IOException {
		//uses a map to store already computed factorial values for easy access
		FactorialHelper help = new FactorialHelper();
		long fact = 0;
		for (int i = 0; i < num; i++) {
			fact = help.rFact(i);
			//System.out.println(i + "! = " + fact);
		}
	}

}
