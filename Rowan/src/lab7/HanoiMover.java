package lab7;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

public class HanoiMover {
	/*
	 * Purpose: Data Structure and Algorithms Lab 7 Problem 2
	 * Status: Complete and thoroughly tested
	 * Last update: 10/25/17
	 * Submitted:  10/31/17
	 * Comment: sample run attached
	 * @author: Nikhil Shah
	 * @version: 2017.10.25
	 */
	public static int countDiskMoves = 0;
	public static int countMethodCalls = 0;

	public static void main(String[] args) throws FileNotFoundException {
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

		System.out.print("Please enter number of disks: ");
		int d = key.nextInt();
		double curTime = System.currentTimeMillis();
		move(d);
		double totalTime = (System.currentTimeMillis() - curTime) / 1000;
		if (written) {
			System.setOut(stdout);
			System.out.println("Output written to " + args[1]);
		}
		System.out.println(totalTime + " seconds.");
		System.out.println("Total number of disk moves: " + countDiskMoves);
		System.out.println("Total number of method calls: " + countMethodCalls);
		key.close();
	}

	public static void move(int disks) { // move helper method
		if (disks == 0)
			System.out.println("There are no disks.");
		else {
			move(1, 2, 3, disks);
			countMethodCalls++;
		}
	}

	private static void move(int source, int target, int other, int disks) {
		// I like to move it move it!
		if (disks == 1) {
			System.out.println("Move a disk from peg " + source + " to peg " + target + ".");
			countDiskMoves++;
		} else {
			move(source, other, target, disks - 1);
			countMethodCalls++;
			System.out.println("Move a disk from peg " + source + " to peg " + target + ".");
			countDiskMoves++;
			move(other, target, other, disks - 1);
			countMethodCalls++;
		}
	}

}
