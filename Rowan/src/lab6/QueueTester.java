package lab6;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

public class QueueTester {
	/*-
	 * Purpose: Data Structure and Algorithms Lab 6 Problem 1 (prelab)
	 * Status: Complete and thoroughly tested
	 * Last update: 10/11/17
	 * Submitted:  10/12/17
	 * Comment: test suite and sample run attached
	 * @author: Nikhil Shah
	 * @version: 2017.10.11
	 */
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
		QueueArrayBased<String> q = new QueueArrayBased<>();
		do {
			System.out.println("1. Insert item at the end of the queue. \n2. Remove item from beginning of queue. \n"
					+ "3. Get item from beginning of queue. \n4. Clear queue. \n"
					+ "5. Display content of queue. \n6. Exit program. \n");
			System.out.print("Make your menu selection now: ");
			choice = key.nextInt();
			if (written)
				menuW(choice, key, q);
			else
				menu(choice, key, q);
			System.out.println();
		} while (choice != 6);
		System.out.println("Goodbye");
		key.close();
		System.setOut(stdout);
		if (written)
			System.out.println("Output written to " + args[1]);
	}

	private static void menu(int choice, Scanner key, QueueArrayBased<String> q) {
		String item = "";
		switch (choice) {
		case 1: // insert at back
			System.out.println("You are now inserting an item into the end of the queue.");
			System.out.print("\t Enter item : ");
			item = key.next();
			System.out.println();
			try {
				q.enqueue(item);
			} catch (QueueException a) {
				System.out.println("Error, Please report to developer");
				break;
			}
			System.out.println("Item " + item + " inserted in the queue.");
			break;
		case 2: // remove from front
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			item = q.dequeue();
			System.out.println("Item " + " removed from beginning of queue");
			break;
		case 3: // peek
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			System.out.println("item " + q.peek() + " has been retrieved.");
			break;
		case 4: // clear queue
			if (q.isEmpty()) {
				System.out.println("Error: Queue is already empty.");
				break;
			}
			q.dequeueAll();
			System.out.println("Queue has been cleared.");
			break;
		case 5: // display contents
			if (q.isEmpty()) {
				System.out.println("This queue is empty.");
				break;
			}
			System.out.println("The queue contains: " + q.toString());
			break;
		case 6: // exit
			System.out.println("Exiting...");
			break;
		default:
			System.out.println("Invalid menu selection");
			break;
		}
	}

	private static void menuW(int choice, Scanner key, QueueArrayBased<String> q) {
		String item = "";
		System.out.print(choice + "\n");
		switch (choice) {
		case 1: // insert at back
			System.out.println("You are now inserting an item into the end of the queue.");
			System.out.print("\t Enter item : ");
			item = key.next();
			System.out.print(item);
			System.out.println();
			try {
				q.enqueue(item);
			} catch (QueueException a) {
				System.out.println("Error, Please report to developer");
				break;
			}
			System.out.println("Item " + item + " inserted in the queue.");
			break;
		case 2: // remove from front
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			item = q.dequeue();
			System.out.println("Item " + " removed from beginning of queue");
			break;
		case 3: // peek
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			System.out.println("item " + q.peek() + " has been retrieved.");
			break;
		case 4: // clear queue
			if (q.isEmpty()) {
				System.out.println("Error: Queue is already empty.");
				break;
			}
			q.dequeueAll();
			System.out.println("Queue has been cleared.");
			break;
		case 5: // display contents
			if (q.isEmpty()) {
				System.out.println("This queue is empty.");
				break;
			}
			System.out.println("The queue contains: " + q.toString());
			break;
		case 6: // exit
			System.out.println("Exiting...");
			break;
		default:
			System.out.println("Invalid menu selection");
			break;
		}
	}

}
