package lab6;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

public class DeqTester {
	/*
	 * Purpose: Data Structure and Algorithms Lab 6 Problem 2
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
		Deq<String> q = new Deq<>();
		do {
			System.out.println(
					"1. Insert item at the end of the queue. \n2. Insert item at the beginning of the queue. \n"
							+ "3. Remove item from beginning of queue. \n4. Remove item from end of queue. \n"
							+ "5. Get item from beginning of queue. \n6. Get item from end of queue. \n"
							+ "7. Clear queue. \n8. Display content of queue. \n9. Exit program. \n");
			System.out.print("Make your menu selection now: ");
			choice = key.nextInt();
			if (written)
				menuW(choice, key, q);
			else
				menu(choice, key, q);
			System.out.println();
		} while (choice != 9);
		System.out.println("Goodbye");
		key.close();
		System.setOut(stdout);
		if (written)
			System.out.println("Output written to " + args[1]);
	}

	private static void menu(int choice, Scanner key, Deq<String> q) {
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
			System.out.println("Item " + item + " inserted in end of queue.");
			break;
		case 2: // insert at front
			System.out.println("You are now inserting an item into the beginning of the queue.");
			System.out.print("\t Enter item : ");
			item = key.next();
			System.out.println();
			q.enqueueFirst(item);
			System.out.println("Item " + item + " inserted in beginning of queue.");
			break;
		case 3: // remove from front
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			item = q.dequeue();
			System.out.println("Item " + item + " removed from beginning of queue");
			break;
		case 4: // remove from back
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			item = q.dequeueLast();
			System.out.println("Item " + item + " removed from end of queue");
			break;
		case 5: // peek front
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			System.out.println("item " + q.peek() + " has been retrieved from beginning.");
			break;
		case 6: // peek back
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			System.out.println("item " + q.peekLast() + " has been retrieved from end.");
			break;
		case 7: // clear queue
			if (q.isEmpty()) {
				System.out.println("Error: Queue is already empty.");
				break;
			}
			q.dequeueAll();
			System.out.println("Queue has been cleared.");
			break;
		case 8: // display contents
			if (q.isEmpty()) {
				System.out.println("This queue is empty.");
				break;
			}
			System.out.println("This queue contains: " + q.toString());
			break;
		case 9: // exit
			System.out.println("Exiting...");
			break;
		default:
			System.out.println("Invalid menu selection");
			break;
		}
	}
	private static void menuW(int choice, Scanner key, Deq<String> q) {
		String item = "";
		System.out.print(choice + "\n");
		switch (choice) {
		case 1: // insert at back
			System.out.println("You are now inserting an item into the end of the queue.");
			System.out.print("\t Enter item : ");
			item = key.next();
			System.out.print(item + "\n");
			try {
				q.enqueue(item);
			} catch (QueueException a) {
				System.out.println("Error, Please report to developer");
				break;
			}
			System.out.println("Item " + item + " inserted in end of queue.");
			break;
		case 2: // insert at front
			System.out.println("You are now inserting an item into the beginning of the queue.");
			System.out.print("\t Enter item : ");
			item = key.next();
			System.out.print(item + "\n");
			q.enqueueFirst(item);
			System.out.println("Item " + item + " inserted in beginning of queue.");
			break;
		case 3: // remove from front
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			item = q.dequeue();
			System.out.println("Item " + item + " removed from beginning of queue");
			break;
		case 4: // remove from back
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			item = q.dequeueLast();
			System.out.println("Item " + item + " removed from end of queue");
			break;
		case 5: // peek front
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			System.out.println("item " + q.peek() + " has been retrieved from beginning.");
			break;
		case 6: // peek back
			if (q.isEmpty()) {
				System.out.println("Error: Queue is empty.");
				break;
			}
			System.out.println("item " + q.peekLast() + " has been retrieved from end.");
			break;
		case 7: // clear queue
			if (q.isEmpty()) {
				System.out.println("Error: Queue is already empty.");
				break;
			}
			q.dequeueAll();
			System.out.println("Queue has been cleared.");
			break;
		case 8: // display contents
			if (q.isEmpty()) {
				System.out.println("This queue is empty.");
				break;
			}
			System.out.println("This queue contains: " + q.toString());
			break;
		case 9: // exit
			System.out.println("Exiting...");
			break;
		default:
			System.out.println("Invalid menu selection");
			break;
		}
	}
}
