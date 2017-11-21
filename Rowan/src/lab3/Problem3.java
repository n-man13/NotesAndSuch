package lab3;

public class Problem3 {
	/*
	 * Purpose: Data Structure and Algorithms Lab 3 Problem 3
	 * Status: Complete and thoroughly tested
	 * Last update: 10/04/17
	 * Submitted:  10/05/17
	 * Comment: run attached and conclusion added
	 * @author: Nikhil Shah
	 * @version: 2017.10.4
	 */
	public static void main(String[] args) {
		test1();
		System.out.println();
		test2();
		System.out.println();
		test3();
		System.out.println();
		test4();
		System.out.println();
		test5();
		System.out.println();
		test6();
		System.out.println();
		test7();
		System.out.println();
	}

	/*
	 * The compareTo method of String Is more useful than what many believe. The
	 * return of the method is the difference in the first different Unicode
	 * character numbers in the Strings. If all the characters are the same but the
	 * length is different, then it will return that difference. This method is a
	 * very useful method of the String class.
	 */
	public static void test1() {
		String s1 = "A";
		String s2 = "a";

		System.out.println(s1);
		System.out.println(s2);
		System.out.println(s1.compareTo(s2));
		System.out.println(s1 + " - " + s2 + " = " + (int) ('A' - 'a'));
	}

	public static void test2() {
		String s1 = "18";
		String s2 = "1";

		System.out.println(s1);
		System.out.println(s2);
		System.out.println(s1.compareTo(s2));
		System.out.println("what is happening? see test 4");
	}

	public static void test3() {
		String s1 = "A";
		String s2 = "1";

		System.out.println(s1);
		System.out.println(s2);
		System.out.println(s1.compareTo(s2));
		System.out.println(s1 + " - " + s2 + " = " + (int) ('A' - '1'));
	}

	public static void test4() {
		String s1 = "A";
		String s2 = "Alabaster";

		System.out.println(s1);
		System.out.println(s2);
		System.out.println(s1.compareTo(s2));
		System.out.println("Length of " + s1 + " - length of " + s2 + " = " + ((s1.length()) - (s2.length())));
	}

	public static void test5() {
		String s1 = "s";
		String s2 = "alabaster";

		System.out.println(s1);
		System.out.println(s2);
		System.out.println(s1.compareTo(s2));
		System.out.println(s1 + " - " + s2.charAt(0) + " = " + (int) ('s' - 'a'));
	}

	public static void test6() {
		String s1 = "alabama";
		String s2 = "alabaster";

		System.out.println(s1);
		System.out.println(s2);
		System.out.println(s1.compareTo(s2));
		System.out.println(s1.charAt(5) + " - " + s2.charAt(5) + " = " + (int) ('m' - 's'));
	}

	public static void test7() {
		String s1 = "1";
		String s2 = "3";

		System.out.println(s1);
		System.out.println(s2);
		System.out.println(s1.compareTo(s2));
		System.out.println(s1 + " - " + s2 + " = " + (int) ('1' - '3'));
	}
}
