package lab7;

import java.io.*;
import java.math.BigInteger;
import java.util.Scanner;

public class BinomialCoefficient {
	/*
	 * Purpose: Data Structure and Algorithms Lab 7 Problem 3
	 * Status: Complete and thoroughly tested
	 * Last update: 10/29/17
	 * Submitted:  10/31/17
	 * Comment: sample run attached
	 * @author: Nikhil Shah
	 * @version: 2017.10.29
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
		
		if (written) {
			menu2(key);
			System.setOut(stdout);
			System.out.println("Output written to " + args[1]);
		}
		else
			menu1(key);
		key.close();
	}

	public static void menu1(Scanner key) {
		while (true) {
			System.out.print("1. Recursive Binomial calculation. \n2. Display Pascal's triangle. \n"
					+ "3. Iterative Binomial calculation. \n4. Formula based Binomial calculation. \n" + "5. Exit\n");
			System.out.print("\nPlease enter your choice: ");
			int choice = key.nextInt();
			System.out.println();
			int n = 0, k = 0;
			switch (choice) {
			case 1:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.print("\nPlease enter value of k: ");
				k = key.nextInt();
				System.out.println("After recursing through, the value computed is: " + rBin(n, k));
				break;
			case 2:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.println();
				itPascal(n);
				break;
			case 3:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.print("\nPlease enter value of k: ");
				k = key.nextInt();
				System.out.println("After iterating through, the value computed is: " + itBin(n, k));
				break;
			case 4:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.print("\nPlease enter value of k: ");
				k = key.nextInt();
				System.out.println("After completing the formula, the value is: " + formBased(n, k));
				break;
			case 5:
				System.out.println("Goodbye.");
				return;
			}
			System.out.println();
		}
	}
	public static void menu2(Scanner key) {
		while (true) {
			System.out.print("1. Recursive Binomial calculation. \n2. Display Pascal's triangle. \n"
					+ "3. Iterative Binomial calculation. \n4. Formula based Binomial calculation. \n" + "5. Exit\n");
			System.out.print("\nPlease enter your choice: ");
			int choice = key.nextInt();
			System.out.println(choice);
			int n = 0, k = 0;
			switch (choice) {
			case 1:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.print(n + "\nPlease enter value of k: ");
				k = key.nextInt();
				System.out.println(k);
				System.out.println("After recursing through, the value computed is: " + rBin(n, k));
				break;
			case 2:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.println(n);
				itPascal(n);
				break;
			case 3:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.print(n + "\nPlease enter value of k: ");
				k = key.nextInt();
				System.out.println(k);
				System.out.println("After iterating through, the value computed is: " + itBin(n, k));
				break;
			case 4:
				System.out.print("Please enter value of n: ");
				n = key.nextInt();
				System.out.print(n + "\nPlease enter value of k: ");
				k = key.nextInt();
				System.out.print(k + "\nAfter completing the formula, the value is: " + formBased(n, k));
				break;
			case 5:
				System.out.println("Goodbye.");
				return;
			}
			System.out.println();
		}
	}

	public static int rBin(int n, int k) {
		if (n == k || k == 0)
			return 1;
		else
			return rBin(n-1, k) + rBin(n-1, k-1); 
	}

	public static void itPascal(int n) {
		BigInteger pascal[][] = new BigInteger[2][n]; // pascal[1] and pascal[2] will be interchanged
		int prev = 0;
		for(int i = 0; i < n; i++) {
			for (int j = 0; j <= i; j++) {
				//compute level i using pascal[prev] as previous level
				if (i == j || j == 0)
					pascal[(prev + 1) % 2][j] = BigInteger.ONE;
				else
					pascal[(prev + 1) % 2][j] = pascal[prev][j].add(pascal[prev][j-1]);
				System.out.print(pascal[(prev + 1) % 2][j] + " ");
			}
			System.out.println();
			prev = (prev + 1) % 2; // circular increment between 0 and 1
		}
	}

	public static BigInteger itBin(int n, int k) {
		BigInteger pascal[][] = new BigInteger[2][k + 1];
		int prev = 0;
		for (int i = 0; i <= n; i++) {
			for (int j = 0; j <= i && j <= k; j++) {
				if (i == j || j == 0)
					pascal[(prev+1) % 2][j] = BigInteger.ONE;
				else
					pascal[(prev + 1) % 2][j] = pascal[prev][j].add(pascal[prev][j - 1]);
			}
			prev = (prev + 1) % 2;
		}
		return pascal[prev][k]; 
	}

	public static BigInteger formBased(int n, int k) {
		BigInteger result = BigInteger.ONE;
		if (k == 0 || n == k)
			; // do nothing
		else  if (k > (n-k))
			result = fallFact(k+1, n).divide(fallFact(1,n-k));
		else
			result = fallFact((n - k + 1), n).divide(fallFact(1,k));
		return result;
	}
	public static BigInteger fallFact(int a, int b) { // a * (a+1) * ... * b
		BigInteger cur = new BigInteger(Integer.toString(b));
		if (a == b)
			return cur;
		return fallFact(a, b - 1).multiply(cur);
	}
}
