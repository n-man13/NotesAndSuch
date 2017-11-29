package hashing;

public class HashableString1 extends Hashable<String> {
	/*
	 * HashableString is a string of uppercase alphabetic letters no longer than 6
	 */
	
	public HashableString1(String s) {
		super(s);
	}
	
	public int hash() {
		int hash = 0;
		for (int i = 0; i < data.length(); i++) {
			hash += ((data.charAt(i) - 'A' + 1) << (5* (data.length() - i - 1)));
		}
		return hash;
	}

}
