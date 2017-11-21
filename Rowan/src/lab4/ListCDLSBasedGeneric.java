package lab4;

public class ListCDLSBasedGeneric<T> implements ListInterfaceGeneric<T> {
	private DNode<T> tail;
	private int numItems;

	public ListCDLSBasedGeneric() {
		tail = null;
		numItems = 0;
	}

	private DNode<T> find(int index) {
		// --------------------------------------------------
		// Locates a specified node in a linked list.
		// Precondition: index is the number of the desired
		// node. Assumes that 0 <= index <= numItems
		// Postcondition: Returns a reference to the desired
		// node.
		// --------------------------------------------------
		DNode<T> curr = tail;
		if (index == numItems)
			return curr.getNext();
		if ((numItems - 1) >> 1 > index) { // then go forwards
			for (int skip = -1; skip < index; skip++) {
				curr = curr.getNext(); 
			}
		} else { // go backwards
			for (int skip = numItems-1; skip < index; skip--) {
				curr = curr.getPrev();
			}
		}
		return curr;

		/* Old Find:
		 * DNode curr = tail.getNext();
		 * for (int skip = 0; skip < index; skip++) { 
		 *   curr = curr.getNext();
		 * }
		 * return curr;
		 */
	}

	@Override
	public boolean isEmpty() {
		return tail == null;
	}

	@Override
	public int size() {
		return numItems;
	}

	@Override
	public void add(int index, T item) throws ListIndexOutOfBoundsException {
		if (index < 0 || index > numItems) {
			throw new ListIndexOutOfBoundsException("List index out of bounds exception on add");
		} else if (tail == null) {
			tail = new DNode<>((T)item);
		} else {
			DNode<T> curr = find(index);
			DNode<T> addThis = new DNode<>((T)item, curr, curr.getPrev());
			curr.getPrev().setNext(addThis);
			curr.setPrev(addThis);
			if (index == numItems) {
				tail = addThis;
			}
		}
		numItems++;
	}

	@Override
	public T get(int index) throws ListIndexOutOfBoundsException {
		if (index < 0 || index > numItems - 1 || tail == null) {
			throw new ListIndexOutOfBoundsException("List index out of bounds exception on get");
		}
		return find(index).getItem();
	}

	@Override
	public void remove(int index) throws ListIndexOutOfBoundsException {
		if (index < 0 || index > numItems || tail == null) {
			throw new ListIndexOutOfBoundsException("List index out of bounds exception on remove");
		} else if (numItems == 1) {
			tail = null;
		} else {
			DNode<T> curr = find(index);
			curr.getNext().setPrev(curr.getPrev());
			curr.getPrev().setNext(curr.getNext());
			if (index == numItems - 1) {
				tail = curr.getPrev();
			}
		}
		numItems--;
	}

	@Override
	public void removeAll() {
		tail = null;
		numItems = 0;
	}

	public String toString() {
		/*-----------------------------------------------------------
		* Returns a string representation of this list. The 
		* string representation consists of a list of the elements in 
		* the order they are returned by its iterator, enclosed in 
		* square brackets ("[]"). Adjacent elements are separated by 
		* the characters ", " (comma and space).
		* -----------------------------------------------------------
		*/
		if (tail == null) {
			return "[]";
		}
		String result = "[";
		DNode<T> curr = tail.getNext();
		do {
			result = result.concat(curr.getItem().toString() + ", ");
			curr = curr.getNext();
		} while (curr != tail.getNext());
		result = result.substring(0, result.length() - 2) + "]";
		return result;
	}
}
