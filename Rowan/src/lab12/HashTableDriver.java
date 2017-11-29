package lab12;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

/*-
 * Purpose: Data Structure and Algorithms Lab 12 Problem 2
 * Status: Complete and thoroughly tested
 * Last update: 11/29/17
 * Submitted:  11/30/17
 * Comment: test suite and sample run attached
 * @author: Nikhil Shah
 * @version: 2017.11.29
 */
public class HashTableDriver {
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
			written = true;
			key = new Scanner(new File(args[0]));
			System.setOut(new PrintStream(new File(args[1])));
		}

		HashTable table = new HashTable();

		System.out.println("Welcome to the Hash Table Program!");
		System.out.println("Today we are going to use Strings as the key and Integers as values.");

		int menuSelection = 0;

		while (menuSelection != 5) {
			System.out.println("\nMenu:");
			System.out.println("1. Insert a symbol key with an associated value in the table.");
			System.out.println("2. Delete a symbol from the table.");
			System.out.println("3. Retrieve and display the value associated with a symbol key in the table.");
			System.out.println("4. Display the hash value of a symbol key");
			System.out.println("5. Exit the program.");
			System.out.println("Please select from this menu: ");
			menuSelection = key.nextInt();

			boolean changed;
			String k;
			Integer v;

			switch (menuSelection) {
			case 1:
				System.out.println("Inserting into the table: \n");
				System.out.println("Please enter the key you would like to insert:");
				k = key.next();
				System.out.println("Please enter the value you would like:");
				v = key.nextInt();
				System.out.println("Now inserting (" + k + "," + v + ")");
				changed = table.tableInsert(k, v);
				if (changed)
					System.out.println("Item has been inserted.");
				else
					System.out.println("Unable to insert! Key is already associated with a value.");
				break;
			case 2:
				System.out.println("Removing from the table: \n");
				System.out.println("Please enter the key you would like to remove:");
				k = key.next();
				System.out.println("Now removing pair with " + k + " as the key.");
				changed = table.tableDelete(k);
				if (changed)
					System.out.println("Item has been removed.");
				else
					System.out.println("Unable to remove! Key is not in the table.");
				break;
			case 3:
				System.out.println("Retrieving from the table: \n");
				System.out.println("Please enter the key you would like to know the value associated with:");
				k = key.next();
				System.out.println("Searching for value paired with " + k + ".");
				v = table.tableRetrieve(k);
				if (v != null)
					System.out.println("(" + k + "," + v + ") has been retrieved.");
				else
					System.out.println("Unable to retrieve! Key is not in the table.");
				break;
			case 4:
				System.out.println("Displaying hashes: \n");
				System.out.println("Please enter the key you would like to compute the hash for:");
				k = key.next();
				System.out.println("Computing hash for key " + k + ".");
				v = table.hash(k);
				System.out.println("Hash value for " + k + " is " + v + ".");
				break;
			case 6:
				System.out.println("Printing full table:");
				System.out.println(table);
				break;
			case 5:
				System.out.println("Goodbye!");
				break;
			default:
				System.out.println("That is not one of the menu options.");
			}

		}

		key.close();
		if (written) {
			System.setOut(stdout);
			System.out.println("Output written to " + args[1]);
		}
	}
}
