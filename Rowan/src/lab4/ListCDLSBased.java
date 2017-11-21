package lab4;

import lab3.Node;

public class ListCDLSBased implements ListInterface {
	private DNode tail;
	private int numItems;

	public ListCDLSBased() {
		tail = null;
		numItems = 0;
	}

	private DNode find(int index) {
		// --------------------------------------------------
		// Locates a specified node in a linked list.
		// Precondition: index is the number of the desired
		// node. Assumes that 0 <= index <= numItems
		// Postcondition: Returns a reference to the desired
		// node.
		// --------------------------------------------------
		DNode curr = tail;
		if (index == numItems)
			return curr.getPrev();
		if ((numItems - 1) >> 2 > index) {
			for (int skip = -1; skip < index; skip++) {
				curr = curr.getNext();
			}
		} else {
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
	public void add(int index, Object item) throws ListIndexOutOfBoundsException {
		if (index < 0 || index > numItems) {
			throw new ListIndexOutOfBoundsException("List index out of bounds exception on add");
		} else if (tail == null) {
			tail = new DNode(item);
		} else {
			DNode curr = find(index);
			DNode addThis = new DNode(item, curr, curr.getPrev());
			curr.getPrev().setNext(addThis);
			curr.setPrev(addThis);
			if (index == numItems) {
				tail = addThis;
			}
		}
		numItems++;
	}

	@Override
	public Object get(int index) throws ListIndexOutOfBoundsException {
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
			DNode curr = find(index);
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
		DNode curr = tail.getNext();
		do {
			result = result.concat(curr.getItem().toString() + ", ");
			curr = curr.getNext();
		} while (curr != tail.getNext());
		result = result.substring(0, result.length() - 2) + "]";
		return result;
	}
}
