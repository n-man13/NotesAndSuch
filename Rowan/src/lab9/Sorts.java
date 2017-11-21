package lab9;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

public class Sorts {

	/*-
	 * Purpose: Data Structure and Algorithms Lab 9
	 * Status: Complete and thoroughly tested/Incomplete/ Barely started (choose only one!!!)
	 * Last update: 11/08/17
	 * Submitted:  11/14/17
	 * Comment: test suite and sample run attached
	 * @author: Nikhil Shah
	 * @version: 2017.11.08
	 */

	public void main(String[] args) throws FileNotFoundException {
		// if args is provided then use file provided in
		// arg0, otherwise user input is required
		// output is to go to file at arg1
		Scanner key;
		boolean written = false;
		PrintStream stdout = System.out;
		if (args.length == 1) {
			key = new Scanner(System.in);
		} else {
			written = true;
			key = new Scanner(new File(args[0]));
			System.setOut(new PrintStream(new File(args[1])));
		}
		menu(key);
		key.close();
		System.setOut(stdout);
		if (written)
			System.out.println("Output written to " + args[1]);
	}

	public static void menu(Scanner key) {
		String opt = key.next();
		System.out.println("You have chosen: " + opt);
		System.out.print("Enter number of items: ");
		int num = key.nextInt();
		SortsImplemented sort = new SortsImplemented();
		int[] data = new int[num];
		for (int i = 0; i < num; i++) {
			System.out.println("Enter integer number " + (i + 1));
			data[i] = key.nextInt();
		}
		System.out.println("Input data : " + data);
		if (opt.equalsIgnoreCase("bubblesort"))
			sort.bubbleSort(data);
		else if (opt.equalsIgnoreCase("improvedbubblesort"))
			sort.improvedBubble(data);
		else if (opt.equalsIgnoreCase("insertionsort"))
			sort.insertionSort(data);
		else if (opt.equalsIgnoreCase("improvedinsertionsort"))
			sort.improvedInsertion(data);
		else if (opt.equalsIgnoreCase("selectionsort"))
			sort.selectionSort(data);
		else if (opt.equalsIgnoreCase("improvedselectionsort"))
			sort.improvedSelection(data);
		else
			System.out.println("Unknown sorting algorithm.");
		System.out.println("Sorted data : " + data);
		System.out.println("Number of comparisons: " + sort.totalComps);
		System.out.println("Number of swaps/shifts: " + sort.totalSwaps);
	}
}
