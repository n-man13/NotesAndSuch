package lab3;

//Please note that this code is slightly different from the textbook code 
//to reflect the fact that the Node class is implemented using data encapsulation

//****************************************************
//Reference-based implementation of ADT list.
//****************************************************
public class MyListReferenceBased implements ListInterface {
	// reference to linked list of items
	private Node head;

	public MyListReferenceBased() {
		head = null;
	} // end default constructor

	public boolean isEmpty() {
		return head == null;
	} // end isEmpty

	public int size() {
		Node curr = head;
		int size = 0;
		while (curr != null) {
			curr = curr.getNext();
			size++;
		}
		return size;
	} // end size

	private Node find(int index) {
		// --------------------------------------------------
		// Locates a specified node in a linked list.
		// Precondition: index is the number of the desired
		// node. Assumes that 0 <= index <= numItems
		// Postcondition: Returns a reference to the desired
		// node.
		// --------------------------------------------------
		Node curr = head;
		for (int skip = 0; skip < index; skip++) {
			curr = curr.getNext();
		} // end for
		return curr;
	} // end find

	public Object get(int index) throws ListIndexOutOfBoundsException {
		if (index >= 0 && index < size()) {
			// get reference to node, then data in node
			Node curr = find(index);
			Object dataItem = curr.getItem();
			return dataItem;
		} else {
			throw new ListIndexOutOfBoundsException("List index out of bounds exception on get");
		} // end if
	} // end get

	public void add(int index, Object item) throws ListIndexOutOfBoundsException {
		if (index >= 0 && index < size() + 1) {
			if (index == 0) {
				// insert the new node containing item at
				// beginning of list
				Node newNode = new Node(item, head);
				head = newNode;
			} else {
				Node prev = find(index - 1);
				// insert the new node containing item after
				// the node that prev references
				Node newNode = new Node(item, prev.getNext());
				prev.setNext(newNode);
			} // end if
		} else {
			throw new ListIndexOutOfBoundsException("List index out of bounds exception on add");
		} // end if
	} // end add

	public void remove(int index) throws ListIndexOutOfBoundsException {
		if (index >= 0 && index < size()) {
			if (index == 0) {
				// delete the first node from the list
				head = head.getNext();
			} else {
				Node prev = find(index - 1);
				// delete the node after the node that prev
				// references, save reference to node
				Node curr = prev.getNext();
				prev.setNext(curr.getNext());
			} // end if
		} // end if
		else {
			throw new ListIndexOutOfBoundsException("List index out of bounds exception on remove");
		} // end if
	} // end remove

	public void removeAll() {
		// setting head to null causes list to be
		// unreachable and thus marked for garbage
		// collection
		head = null;
	} // end removeAll

	public String toString() {
		/*-----------------------------------------------------------
		* Returns a string representation of this list. The 
		* string representation consists of a list of the elements in 
		* the order they are returned by its iterator, enclosed in 
		* square brackets ("[]"). Adjacent elements are separated by 
		* the characters ", " (comma and space).
		* -----------------------------------------------------------
		*/
		if (head == null)
			return "[]";
		String result = "[";
		Node curr = head;
		while (curr != null){
			result = result.concat(curr.getItem().toString() + ", ");
			curr = curr.getNext();
		}
		result = result.substring(0,result.length()-2) + "]";
		return result;
	}
} // end MyListReferenceBased