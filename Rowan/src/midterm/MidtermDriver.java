package midterm;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

public class MidtermDriver {
	/*-
	 * list = arrayBased 
	 * stack = arrayBased 
	 * queue = arrayBased 
	 * deq = arrayBased
	 */
	
	/*-
	 * Purpose: Data Structure and Algorithms Midterm
	 * Status: Complete and thoroughly tested
	 * Last update: 10/18/17
	 * Submitted:  10/18/17
	 * Comment: multiple sample runs attached
	 * @author: Nikhil Shah
	 * @version: 2017.10.18
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

		// Store stock of cards
		ListArrayBasedPlus<Card> storeStock = new ListArrayBasedPlus<>();
		System.out.println("Welcome to the Card Trading Center!");
		System.out.print("Enter number of basketball cards in the stock: ");
		storeStock.add(0, new Card(key.nextInt(), "basketball"));
		System.out.print("\nEnter number of baseball cards in the stock: ");
		storeStock.add(1, new Card(key.nextInt(), "baseball"));
		System.out.print("\nEnter number of football cards in the stock: ");
		storeStock.add(2, new Card(key.nextInt(), "football"));
		System.out.println();

		// Other fields needed for this program
		Deq<Customer> customerLine = new Deq<>();
		StackArrayBased<Customer> pendingCustomers = new StackArrayBased<>();
		int customersServed = 0;

		System.out.println("Select from the following menu: \n0. Display stock and exit. \n"
				+ "1. Customer enters with request to buy cards. \n2. Customer enters with cards to sell cards. \n"
				+ "3. Customer with request is served. \n4. Display customers waiting to be served and their requests. \n"
				+ "5. Display pending requests waiting to be processed. \n6. Process pending requests. \n"
				+ "7. Display number of customers whose requests have been processed. \n8. Display menu again \n");
		do {
			System.out.print("You know the choices; make your menu selection now: ");
			choice = key.nextInt();
			System.out.println("\n");
			customersServed = menu(choice, key, storeStock, customerLine, pendingCustomers, customersServed);
		} while (choice != 0); // 0 is exit
		System.out.println("Goodbye.");
		key.close();
		System.setOut(stdout);
		if (written)
			System.out.println("Output written to " + args[1]);
	}

	private static int menu(int choice, Scanner key, ListArrayBasedPlus<Card> stock, Deq<Customer> line,
			StackArrayBased<Customer> pending, int customersServed) {
		int bb = 0, b = 0, f = 0;
		String n = "";
		switch (choice) {
		case 0: // display stock and exit
			System.out.println(
					"The Card Trading Center has " + stock.get(0).getNum() + " basketball, " + stock.get(1).getNum()
							+ " baseball and " + stock.get(2).getNum() + " football cards and is now closing.");
			break;
		case 1: // customer buys cards
			System.out.print("Welcome, your name, please: ");
			n = key.next();
			System.out.print("\nHow many basketball cards do you want: ");
			bb = key.nextInt();
			System.out.print("\nHow many baseball cards do you want: ");
			b = key.nextInt();
			System.out.print("\nHow many football cards do you want: ");
			f = key.nextInt();
			line.enqueue(new Customer(n, bb, b, f));
			System.out.println("\n" + line.peekLast() + " is now waiting.");
			break;
		case 2: // customer sells cards
			System.out.print("Welcome, your name, please: ");
			n = key.next();
			System.out.print("\nHow many basketball cards do you have: ");
			bb = key.nextInt();
			System.out.print("\nHow many baseball cards do you have: ");
			b = key.nextInt();
			System.out.print("\nHow many football cards do you have: ");
			f = key.nextInt();
			Customer seller = new Customer(n, bb, b, f);
			stock.get(0).addCards(bb);
			stock.get(1).addCards(b);
			stock.get(2).addCards(f);
			System.out.println(
					"\nThanks " + seller.getName() + ", here is your reciept for the " + seller.getRequests() + "!");
			customersServed++;
			break;
		case 3: // serve buyer
			if (line.isEmpty())
				System.out.println("No customer is waiting to be served!");
			else {
				Customer serve = line.dequeue();
				if (cantServe(stock, serve)) { // add to pending requests
					pending.push(serve);
					System.out.println(
							serve.getName() + "'s request for " + serve.getRequests() + "is now pending. Goodbye "
									+ serve.getName() + ". We will let you know when the order is processed!");
				} else { // remove cards from stock and say goodbye
					stock.get(0).addCards(-serve.getBB());
					stock.get(1).addCards(-serve.getB());
					stock.get(2).addCards(-serve.getF());
					System.out.println(serve.getName() + " is leaving with " + serve.getRequests() + ".");
					customersServed++;
				}
			}
			break;
		case 4: // display service line
			if (line.isEmpty())
				System.out.println("No customers waiting to be served!");
			else
				System.out.println(line.toString());
			break;
		case 5: // display requests
			if (pending.isEmpty())
				System.out.println("No customer requests are pending!");
			else
				System.out.println(pending.toString());
			break;
		case 6: // process all requests pending
			if (pending.isEmpty())
				System.out.println("No customer requests are pending!");
			else {
				if (cantServe(stock, pending.peek())) {
					System.out.println("No request could be processed!");
				} else
					while (!pending.isEmpty() && !cantServe(stock, pending.peek())) {
						Customer serve = pending.pop();
						stock.get(0).addCards(-serve.getBB());
						stock.get(1).addCards(-serve.getB());
						stock.get(2).addCards(-serve.getF());
						System.out.println(serve.getName() + "'s request of " + serve.getRequests()
								+ " has been processed and the customer has been notified.");
						customersServed++;
					}
			}
			break;
		case 7: // display number of customers served
			if (customersServed == 0)
				System.out.println("No customers have been served yet!");
			else
				System.out.println(customersServed + " customer(s) have been served.");
			break;
		case 8:
			System.out.println("Please select from the following menu: \n0. Display stock and exit. \n"
					+ "1. Customer enters with request to buy cards. \n2. Customer enters with cards to sell cards. \n"
					+ "3. Customer with request is served. \n4. Display customers waiting to be served and their requests. \n"
					+ "5. Display pending requests waiting to be processed. \n6. Process pending requests. \n"
					+ "7. Display number of customers whose requests have been processed. \n");
			break;
		default:
			System.out.println("Invalid menu selection! Try again.");
			break;
		}
		return customersServed;
	}

	public static boolean cantServe(ListArrayBased<Card> stock, Customer serve) {
		return (serve.getBB() > stock.get(0).getNum() || serve.getB() > stock.get(1).getNum()
				|| serve.getF() > stock.get(2).getNum());
	}
}
