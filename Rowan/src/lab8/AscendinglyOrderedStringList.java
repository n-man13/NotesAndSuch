package lab8;

public class AscendinglyOrderedStringList implements AscendinglyOrderedStringListInterface {
	private String[] items;
	private int numItems;

	public AscendinglyOrderedStringList() {
		items = new String[3];
		numItems = 0;
	}

	@Override
	public boolean isEmpty() {
		return numItems == 0;
	}

	@Override
	public int size() {
		return numItems;
	}

	@Override
	public void add(String item) throws ListIndexOutOfBoundsException {
		if (numItems == 0) {
			items[0] = item;
			numItems++;
		} else {
			if (numItems == items.length)
				resize();
			int i = (-search(item) - 1);
			if (i >= 0) {
				if (i != numItems)
					for (int j = numItems; j > i; j--)
						items[j] = items[j - 1];
				items[i] = item;
				numItems++;
			} else
				throw new ListIndexOutOfBoundsException("Item already exists in list");
		}
	}

	private void resize() {
		String[] itemsNew = new String[items.length << 1];
		for (int i = 0; i < items.length; i++) {
			itemsNew[i] = items[i];
		}
		items = itemsNew;
	}

	@Override
	public String get(int index) throws ListIndexOutOfBoundsException {
		if (index >= 0 && index < numItems)
			return items[index];
		throw new ListIndexOutOfBoundsException("out of bounds on get");
	}

	@Override
	public void remove(int index) throws ListIndexOutOfBoundsException {
		if (index < 0 || index > numItems)
			throw new ListIndexOutOfBoundsException("out of bounds on remove");
		else if (index == numItems)
			items[index] = null;
		else {
			for (int i = index; i < numItems; i++) {
				items[i] = items[i + 1];
			}
		}
		numItems--;
	}

	/*
	 * returns index of position in list if exists else returns negative index - 1
	 * of where it should go
	 */
	@Override
	public int search(String key) { // binary search
		int high = numItems;
		int low = 0;
		int mid = (high + low) / 2;
		while (low <= high && items[mid] != null) {
			if (key.equals(items[mid]))
				return mid;
			else if (key.compareTo(items[mid]) < 0) {
				high = mid - 1;
				mid = (low + high) / 2;
			} else {
				low = mid + 1;
				mid = (low + high) / 2;
			}
		}
		return (-mid - 1);
	}

	@Override
	public void clear() {
		items = new String[3];
		numItems = 0;
	}

	public void remove(String item) throws ListIndexOutOfBoundsException { // special remove only needs item to remove
		if (numItems == 0)
			throw new ListIndexOutOfBoundsException("Empty list on special remove.");
		else {
			int index = search(item);
			if (index < 0)
				throw new ListIndexOutOfBoundsException("Item is not in list.");
			remove(index);
		}
	}

	public String toString() {
		String result = "[";

		for (int i = 0; i < numItems; i++) {
			result += items[i] + ", ";
		}
		result = result.substring(0, result.length() - 2) + "]";
		return result;
	}
}
