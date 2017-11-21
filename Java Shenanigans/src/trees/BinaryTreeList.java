package trees;

public class BinaryTreeList<T> {
	protected DoubleEndedNode<T> root;
	protected int size;

	public BinaryTreeList() {
		root = null;
		size = 0;
	}

	public BinaryTreeList(T element) {
		root = new DoubleEndedNode<T>(element);
		size = 1;
	}

	public void add(int index, T element) {
		
	}

	public void clear() {
		root = null;
		size = 0;
	}

	public boolean contains(T element) {
		return !sequentialSearch(element, root).equals("");
	}

	private String sequentialSearch(T item, DoubleEndedNode<T> cur) {
		String result = "";
		if (cur.getItem() == item)
			return result;
		else {
			String tempL = sequentialSearch(item, cur.getLeft());
			String tempR = sequentialSearch(item, cur.getRight());
			if (tempL.equals("") && tempR.equals(""))
				return "";
			else if (!tempL.equals(""))
				return tempL.concat("0");
			else
				return tempR.concat("1");
		}
	}

	public T get(int index) {
		return null;
	}

	public boolean isEmpty() {
		return root == null;
	}

	public T remove(int index) {
		return null;
	}

	public T set(int index, T element) {
		return null;
	}

	public int size() {
		return size;
	}

	public T[] toArray(T[] a) {
		return null;
	}
}
