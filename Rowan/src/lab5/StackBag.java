package lab5;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

public class StackBag {
	/*
	 * Purpose: Data Structure and Algorithms Lab 5 Problem 2
	 * Status: Complete and thoroughly tested
	 * Last update: 10/04/17
	 * Submitted:  10/10/17
	 * Comment: test suite and sample run attached
	 * @author: Nikhil Shah
	 * @version: 2017.10.04
	 */

	public static void main(String[] args) throws FileNotFoundException {
		// if args is provided then use file provided in
		// arg0, otherwise user input is required
		// output is to go to file at arg2
		Scanner key;
		boolean written = false;
		PrintStream stdout = System.out;
		if (args.length == 0) {
			key = new Scanner(System.in);
		} else {
			key = new Scanner(new File(args[0]));
			System.setOut(new PrintStream(new File(args[1])));
			written = true;
		}
		int choice = 0;
		StackArrayBased<BagItem> bag = new StackArrayBased<BagItem>();
		StackArrayBased<Double> samples = new StackArrayBased<Double>();
		while (choice != 8) {
			System.out.println("\t1. Place a layer of item(s) in the bag.\n"
					+ "\t2. Remove a layer of item(s) from the bag.\n" + "\t3. Display the weight of the bag.\n"
					+ "\t4. Display the number of layers in the bag.\n"
					+ "\t5. Display the number of items and the weight of the sample bag.\n"
					+ "\t6. Remove an item from the sample bag.\n" + "\t7. Empty the sample bag.\n" + "\t8. Exit.");
			System.out.print("Make your menu selection now: ");
			try {
				choice = Integer.parseInt(key.next());
			} catch (NumberFormatException e) {
				choice = 0;
				System.out.println("Invalid menu selection");
			}
			bagMenu(choice, key, bag, samples);
			System.out.println();
		}
		System.out.println("Goodbye :)");
		key.close();
		System.setOut(stdout);
		if(written)
			System.out.println("Output written to " + args[1]);
	}

	private static void bagMenu(int choice, Scanner key, StackArrayBased<BagItem> bag,
			StackArrayBased<Double> samples) {
		Scanner scanHelper = null;
		switch (choice) {
		case 1:
			System.out.print("Enter number of items to place in bag : ");
			int n = key.nextInt();
			System.out.print("Enter weight of item (lb): ");
			double w = key.nextDouble();
			bag.push(new BagItem(w, n));
			System.out.println(n + " items weighing " + w + " lbs have been placed in the bag.");
			break;
		case 2:
			if (bag.isEmpty()) {
				System.out.println("Error: Bag is empty");
				break;
			}
			BagItem r = (BagItem) bag.pop();
			System.out.println(r.getNumber() + " items have been removed from the bag.");
			System.out.print("Would you like to store a sample from this layer(Y/N)?");
			if (key.next().equalsIgnoreCase("Y")) {
				samples.push(r.getWeight());
				System.out.println("Sample stored");
			}
			break;
		case 3:
			if (bag.isEmpty()) {
				System.out.println("The bag is empty : No weight.");
				break;
			}
			scanHelper = new Scanner(bag.toString());
			scanHelper.nextInt();
			double weight = 0;// fix weight
			while (scanHelper.hasNext()) {
				weight += scanHelper.nextDouble();
			}
			System.out.println("The weight of the bag is " + weight + " lbs.");
			break;
		case 4:
			if (bag.isEmpty()) {
				System.out.println("The bag is empty : No layers.");
				break;
			}
			scanHelper = new Scanner(bag.toString());
			System.out.println("The number of layers in the bag is " + scanHelper.nextInt() + ".");
			break;
		case 5:
			if (samples.isEmpty()) {
				System.out.println("The sample bag is empty : No items.");
				break;
			}
			String sa = samples.toString();
			scanHelper = new Scanner(sa);
			int numItems = scanHelper.nextInt();
			double totalWeight = 0;
			while (scanHelper.hasNext()) {
				totalWeight += scanHelper.nextDouble();
			}
			System.out.println("The number of items in the sample bag is " + numItems + ".\n" + "The sample bag weighs "
					+ totalWeight + " lbs.");
			break;
		case 6:
			if (samples.isEmpty()) {
				System.out.println("Error: Empty sample bag.");
				break;
			}
			System.out.println(
					"An item weighing " + (Double) samples.pop() + " lbs has been removed from the sample bag.");
			break;
		case 7:
			if (samples.isEmpty()) {
				System.out.println("The sample bag is empty already.");
				break;
			}
			samples.popAll();
			System.out.println("The sample bag has been emptied.");
			break;
		case 8:
			System.out.println("Exiting...");
			break;
		default:
			System.out.println("Invalid menu selection");
			break;
		}
		try {
			scanHelper.close();
		} catch (NullPointerException e) {
			// do nothing
		}
	}

}
