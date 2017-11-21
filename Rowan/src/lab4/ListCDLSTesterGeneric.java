package lab4;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;
/*
 * Purpose: Data Structure and Algorithms Lab 5 Problem 3
 * Status: Complete and thoroughly tested
 * Last update: 10/04/17
 * Submitted:  10/10/17
 * Comment: test suite and sample run attached
 * @author: Nikhil Shah
 * @version: 2017.10.04
 */
public class ListCDLSTesterGeneric {

	public static void main(String[] args) throws FileNotFoundException {
		// if args is provided then use file provided in
		// arg0, otherwise user input is required
		// output is to go to file at arg2
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
		int choice = 0;
		ListCDLSBasedGeneric<String> list = new ListCDLSBasedGeneric<>();
		while (choice != 6) {
			System.out.println("1. Insert item to list. \n2. Remove item from list. \n3. Get item from list. "
					+ "\n4. Clear list. \n5. Print size and content of list. \n6. Exit program.");
			System.out.print("Make your menu selection now: ");
			choice = key.nextInt();
			menu(choice, key, list);
		}
		key.close();
		System.setOut(stdout);
		if (written)
			System.out.println("Output written to " + args[1]);
	}

	private static void menu(int choice, Scanner key, ListCDLSBasedGeneric<String> list) {
		int index;
		switch (choice) {
		case 1:
			System.out.println("You are now inserting an item into the list.");
			System.out.print("\t Enter item : ");
			String item = key.next();
			System.out.print("\t Enter position to insert item in : ");
			index = key.nextInt();
			try {
				list.add(index, item);
			} catch (ListIndexOutOfBoundsException a) {
				System.out.println("Postion specified is out of range!");
				break;
			}
			System.out.println("Item " + item + " inserted in position " + index + " in the list.");
			break;
		case 2:
			if (list.isEmpty()) {
				System.out.println("Error: List is empty");
				break;
			}
			System.out.print("Enter position to remove item from : ");
			index = key.nextInt();
			Object removed = "none";
			try {
				removed = list.get(index);
				list.remove(index);
			} catch (ListIndexOutOfBoundsException a) {
				System.out.println("Postion specified is out of range!");
				break;
			}
			System.out.println("Item " + removed.toString() + " removed from position " + index + " in the list.");
			break;
		case 3:
			if (list.isEmpty()) {
				System.out.println("Error: list is empty");
				break;
			}
			System.out.print("Enter position to retrieve item from : ");
			index = key.nextInt();
			try {
				System.out.println("Item " + list.get(index) + " retrieved from position " + index + " in the list.");
			} catch (ListIndexOutOfBoundsException a) {
				System.out.println("Position specified is out of range!");
			}
			break;
		case 4:
			if (list.isEmpty()) {
				System.out.println("list is already empty");
				break;
			}
			list.removeAll();
			System.out.println();
			break;
		case 5:
			System.out.println("List of size " + list.size() + " has the following items : " + list.toString());
			break;
		case 6:
			System.out.println("Exiting program...Good Bye");
			return;
		default:
			System.out.println("Please enter a valid option for the menu.");
			break;
		}
	}

}
