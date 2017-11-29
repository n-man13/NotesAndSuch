package testing;

public class BitShift {
	public static void main(String[] args) {
		String s = "ZZZZZZ";
		System.out.println(s + " should equal 900557658");
		System.out.println("output from horners: " + horners(s));
		String t = "TOP";
		System.out.println(t + " should equal 20976");
		System.out.println("output from horners: " + horners(t));
	}
	public static void hornersWorst() { // worst case of "ZZZZZZ"
		int len = 6;
		int sum = 0;
		for (int i = 0; i < len; i++) {
			int x = 26<< (5 * (len-i-1));
			System.out.println(x);
			sum += x;
		}
		System.out.println(sum);
	}
	public static int horners(String item) {
		int sum = 0;
		for (int i = 0; i < item.length(); i++) {
			sum += ((item.charAt(i) - 64) << (5* (item.length() - i - 1)));
		}
		return sum;
	}
}
