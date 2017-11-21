import java.util.Scanner;

public class Test {

	public static void main(String[] args) {
		test2();
	}
	public static void test1() {
		String st = "5 1 0.2 0.7 7 2.1 ";
		Scanner s = new Scanner(st);
		int ints = s.nextInt();
		double dubs = 0;
		while(s.hasNext()) {
			dubs += s.nextDouble();
		}
		System.out.println(ints + " " + dubs);
		s.close();
	}
	public static void test2() {
		String st = "5 2.4 3.5 2.0 5";
		Scanner scanHelper = new Scanner(st);
		scanHelper.nextInt();
		double sum = 0;
		while (scanHelper.hasNextDouble()) {
			sum += scanHelper.nextDouble();
		}
		System.out.println(sum);
	}
}
