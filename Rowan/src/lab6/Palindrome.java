package lab6;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;

import lab2.ListArrayBasedPlus;

public class Palindrome {
	/*
	 * Purpose: Data Structure and Algorithms Lab 6 Problem 3
	 * Status: Complete and thoroughly tested
	 * Last update: 10/11/17
	 * Submitted:  10/12/17
	 * Comment: test suite and sample run attached, There is
	 * 		  probably a more graceful solution, but I was pressed for time
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
		do {
			if (written)
				option2(key);
			else
				option1(key);
		} while (key.hasNext());
		key.close();
		System.setOut(stdout);
		if (written)
			System.out.println("Output written to " + args[1]);
	}

	public static void option1(Scanner key) {
		// Option 1 is for user input
		ListArrayBasedPlus list = new ListArrayBasedPlus();
		boolean dashed = false, palindrome = true, content = true;
		int left = 0, right = 0;
		char c = '\0';
		while (c != '.') {
			System.out.print("Enter character : ");
			c = key.next().charAt(0);
			System.out.println();
			if (c != '.') {
				if (!dashed) {
					if (c == '-')
						dashed = true;
					else {
						list.add(left, c);
						left++;
					}
				} else {
					if (content && left >= right)
						if ((Character) list.get(right) != c)
							content = false;
					right++;
				}
			}
		}
		for (int i = 0; i < left - 1 && palindrome && content; i++) {
			if ((Character) list.get(i) != (Character) list.get(left - i - 1))
				palindrome = false;
		}
		if (!dashed)
			System.out.println("No Minus");
		else if (left < right)
			System.out.println("Right Longer");
		else if (left > right)
			System.out.println("Left Longer");
		else if (content && palindrome)
			System.out.println("Same Length and Content, Palindrome");
		else if (content)
			System.out.println("Same Length and Content, No Palindrome");
		else
			System.out.println("Same Length, Different Content ");
	}
	public static void option2(Scanner key) {
		// Option 2 is for file inputs
		ListArrayBasedPlus list = new ListArrayBasedPlus();
		boolean dashed = false, palindrome = true, content = true;
		int left = 0, right = 0;
		char c = '\0';
		while (c != '.') {
			System.out.print("Enter character : ");
			c = key.next().charAt(0);
			System.out.print(c);
			System.out.println();
			if (c != '.') {
				if (!dashed) {
					if (c == '-')
						dashed = true;
					else {
						list.add(left, c);
						left++;
					}
				} else {
					if (content && left >= right)
						if ((Character) list.get(right) != c)
							content = false;
					right++;
				}
			}
		}
		for (int i = 0; i < left - 1 && palindrome && content; i++) {
			if ((Character) list.get(i) != (Character) list.get(left - i - 1))
				palindrome = false;
		}
		if (!dashed)
			System.out.println("No Minus");
		else if (left < right)
			System.out.println("Right Longer");
		else if (left > right)
			System.out.println("Left Longer");
		else if (left == 0)
			System.out.println("Same Length and Content, No Palindrome");
		else if (content && palindrome)
			System.out.println("Same Length and Content, Palindrome");
		else if (content)
			System.out.println("Same Length and Content, No Palindrome");
		else
			System.out.println("Same Length, Different Content ");
	}

}
