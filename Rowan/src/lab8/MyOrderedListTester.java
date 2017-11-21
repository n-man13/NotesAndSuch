package lab8;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

public class MyOrderedListTester {

	public static void main(String[] args) throws FileNotFoundException {
		// if args is provided then use file provided in
		// arg0, otherwise user input is required
		// output is to go to file at arg2
		AscendinglyOrderedStringList list = new AscendinglyOrderedStringList();
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
		int choice = 0;
		while (choice != 6) {
			System.out.println("1. Insert item to list. \n2. Remove item from list. \n"
					+ "3. Search for a specified item in the list. \n4. Clear list."
					+ "\n5. Print size and content of list. \n6. Exit program.");
			System.out.print("Make your menu selection now: ");
			choice = key.nextInt();
			if (!written)
				menu(choice, key, list);
			else
				menuWritten(choice, key, list);
			System.out.println();
		}
		key.close();
		System.setOut(stdout);
		if (written)
			System.out.println("Output written to " + args[1]);
	}

	public static void menu(int choice, Scanner key, AscendinglyOrderedStringList list) {
		int index = 0;
		String item = "";
		switch (choice) {
		case 1:
			System.out.println("You are now inserting an item into the list.");
			System.out.print("\t Enter item : ");
			item = key.next();
			try {
				list.add(item);
			} catch (ListIndexOutOfBoundsException a) {
				System.out.println("Item is already in the list.");
				break;
			}
			System.out.println("Item " + item + " inserted in the list.");
			break;
		case 2:
			if (list.isEmpty()) {
				System.out.println("Error: list is empty");
				break;
			}
			System.out.print("Enter position to remove item from : ");
			index = key.nextInt();
			try {
				String removed = list.get(index);
				list.remove(index);
				System.out.println("Item " + removed.toString() + " has been removed.");
			} catch (ListIndexOutOfBoundsException e) {
				System.out.println("Error: Position specified is out of range");
			}
			break;
		case 3:
			if (list.isEmpty())
				System.out.println("List is empty");
			else {
				System.out.print("Enter item to search for : ");
				item = key.next();
				index = list.search(item);
				if (index < 0)
					System.out.println("This item is not in the list.");
				else
					System.out.println("Item " + item + " is located at position " + index + ".");
			}
			break;
		case 4:
			if (list.isEmpty()) {
				System.out.println("List is already empty");
				break;
			}
			list.clear();
			System.out.println();
			break;
		case 5:
			if (list.isEmpty()) {
				System.out.println("List is empty");
				break;
			}
			System.out.println("List of size " + list.size() + " has the following items : " + list.toString());
			break;
		case 6:
			System.out.println("Exiting program...Good Bye");
			break;
		case 7:
			System.out.print("Enter item to remove : ");
			item = key.next();
			try {
				list.remove(item);
				System.out.println("Item " + item.toString() + " has been removed.");
			} catch (ListIndexOutOfBoundsException e) {
				System.out.println(e.getLocalizedMessage());
			}
			break;
		default:
			System.out.println("Please enter a valid option for the menu.");
			break;
		}
	}

	public static void menuWritten(int choice, Scanner key, AscendinglyOrderedStringList list) {
		System.out.println(choice);
		int index = 0;
		String item = "";
		switch (choice) {
		case 1:
			System.out.println("You are now inserting an item into the list.");
			System.out.print("\t Enter item : ");
			item = key.next();
			System.out.println(item);
			try {
				list.add(item);
			} catch (ListIndexOutOfBoundsException a) {
				System.out.println("Item is already in the list.");
				break;
			}
			System.out.println("Item " + item + " inserted in the list.");
			break;
		case 2:
			if (list.isEmpty()) {
				System.out.println("Error: list is empty");
				break;
			}
			System.out.print("Enter position to remove item from : ");
			index = key.nextInt();
			System.out.println(index);
			try {
				String removed = list.get(index);
				list.remove(index);
				System.out.println("Item " + removed.toString() + " has been removed.");
			} catch (ListIndexOutOfBoundsException e) {
				System.out.println("Error: Position specified is out of range");
			}
			break;
		case 3:
			if (list.isEmpty())
				System.out.println("List is empty");
			else {
				System.out.print("Enter item to search for : ");
				item = key.next();
				System.out.println(item);
				index = list.search(item);
				if (index < 0)
					System.out.println("This item is not in the list.");
				else
					System.out.println("Item " + item + " is located at position " + index + ".");
			}
			break;
		case 4:
			if (list.isEmpty()) {
				System.out.println("List is already empty");
				break;
			}
			list.clear();
			System.out.println();
			break;
		case 5:
			if (list.isEmpty()) {
				System.out.println("List is empty");
				break;
			}
			System.out.println("List of size " + list.size() + " has the following items : " + list.toString());
			break;
		case 6:
			System.out.println("Exiting program...Good Bye");
			break;
		default:
			System.out.println("Please enter a valid option for the menu.");
			break;
		}
	}
}
