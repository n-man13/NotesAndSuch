package hashing;

public class HashableInteger extends Hashable<Integer> {

	public HashableInteger(int n) {
		super(n);
	}

	public int hash() {
		int hash = 0;
		int first = data % 10;
		int x = data / 10;
		while (x != 0) {
			hash += x % 10;
			x = x / 10;
		}
		hash *= first;
		return hash;
	}
}
