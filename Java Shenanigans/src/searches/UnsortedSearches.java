package searches;

import java.util.List;

public class UnsortedSearches<T extends Comparable<T>> {
	public int sequentialSearch(List<T> a, T key) {
		for (int i = 0; i < a.size(); i++) {
			if (a.get(i).equals(key))
				return i;
		}
		return -1;
	}
}
