package lab10;

public class LinkedList<T> {
	private Node<T> head;
	private int size;

	public LinkedList() {
		head = null;
		size = 0;
	}

	public int getSize() {
		return size;
	}

	public boolean isEmpty() {
		return head == null;
	}

	public T get(int index) throws ListIndexOutOfBoundsException {
		return getNode(index).getItem();
	}

	public T remove(int index) throws ListIndexOutOfBoundsException {
		if (index >= size) {
			throw new ListIndexOutOfBoundsException();
		} else if (index == 0) {
			T item = head.getItem();
			head = head.getNext();
			return item;
		} else {
			Node<T> parent = getNode(index - 1);
			T item = parent.getNext().getItem();
			parent.setNext(parent.getNext().getNext());
			size--;
			return item;
		}
	}

	public void add(int index, T item) throws ListIndexOutOfBoundsException {
		if (head == null)
			if (index == 0)
				head = new Node<T>(item);
			else
				throw new ListIndexOutOfBoundsException();
		else {
			Node<T> parent = getNode(index - 1);
			Node<T> n = new Node<>(item);
			n.setNext(parent.getNext());
			parent.setNext(n);
		}
		size++;
	}

	public void addAll(T[] a) throws ListIndexOutOfBoundsException {
		for (int i = a.length - 1; i > 1; i--) {
			add(0, a[i]);
		}
	}

	public void clear() {
		head = null;
		size = 0;
	}

	private Node<T> getNode(int index) throws ListIndexOutOfBoundsException {
		if (index >= size || head == null)
			throw new ListIndexOutOfBoundsException();
		Node<T> curr = head;
		for (int i = 0; i < index; i++) {
			curr = curr.getNext();
		}
		return curr;
	}
}
