package searches;

public class SortedSearches<T extends Comparable<T>> {
	
	public SearchReturn selectionSearch(Set<T> a, T key) { // O(n)
		for (int i = 0; i < a.size();) {
			if (a.get(i).compareTo(key) > 0)
				i++;
			else if (a.get(i).compareTo(key) == 0)
				return new SearchReturn(true, i);
			else 
				return new SearchReturn(false, i);
		}
		return new SearchReturn(false, a.size());
	}
	
	public SearchReturn binarySearch(Set<T> a, T key) { // O(log n)
		int high = a.size();
		int low = 0;
		int mid = (low + high) / 2;
		while (low <= high) {
			if (key.equals(a.get(mid)))
				return new SearchReturn(true, mid);
			else if (key.compareTo(a.get(mid)) < 0) {
				high = mid - 1;
				mid = (low + high) / 2;
			}
			else {
				low = mid + 1;
				mid = (low + high) / 2;
			}
		}
		return new SearchReturn(false, mid);
	}
	
	public SearchReturn binarySearch2(Set<T> a, T key) { // O(log n)
		int high = a.size();
		int low = 0;
		int mid = (low + high) / 2;
		while (low < high) {
			if (key.compareTo(a.get(mid)) < 0) 
				high = mid;
			else
				low = mid;
			mid = (low + high) / 2;
		}
		return new SearchReturn(key.equals(a.get(mid)), mid);
	}
}
