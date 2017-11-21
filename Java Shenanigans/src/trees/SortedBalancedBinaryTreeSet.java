package trees;

import java.util.List;


public class SortedBalancedBinaryTreeSet<T extends Comparable<T>> implements Set<T> {
	private DoubleEndedTreeNode<T> root; // need to keep tree balanced for least memory and fastest time for all methods

	public SortedBalancedBinaryTreeSet() {
		root = null;
	}

	public SortedBalancedBinaryTreeSet(List<T> a) throws Exception {
		// add all to the set
		for (int i = 0; i < a.size(); i++) {
			this.add(a.get(i));
		}
	}

	public boolean add(T item) throws Exception { // utilize size of nodes to balance tree
		if (root == null)
			root = new DoubleEndedTreeNode<T>(item);
		DoubleEndedTreeNode<T> cur = root;
		while (cur != null) {
			if (cur.getItem().equals(item))
				return false;
			else if (cur.getItem().compareTo(item) < 0)
				if (cur.hasRight())
					cur = cur.getRight();
				else {
					cur.setRight(new DoubleEndedTreeNode<T>(item));
					return true;
				}
			else if (cur.hasLeft())
				cur = cur.getLeft();
			else {
				cur.setLeft(new DoubleEndedTreeNode<T>(item));
				return true;
			}
		}
		throw new TreeException("error: unknown");
	}

	public String getPath(T item) {
		String result = "";
		if (root == null)
			return result;
		DoubleEndedTreeNode<T> curr = root;
		while (curr != null) {
			if (curr.getItem().equals(item))
				return result;
			else if (curr.getItem().compareTo(item) < 0) {
				result = result.concat("1");
				if (curr.hasRight()) {
					curr = curr.getRight();
				} else
					return result;
			} else {
				result = result.concat("0");
				if (curr.hasLeft())
					curr = curr.getLeft();
				else
					return result;
			}
		}
		return result; // if state correct, should never reach this
	}

	public boolean isEmpty() {
		return root == null;
	}

	public T getItem(String path) {
		DoubleEndedTreeNode<T> curr = root;
		char side = ' ';
		while (curr != null && path.length() > 0) {
			side = path.charAt(0);
			path = path.substring(1);
			if (side == '0')
				curr = curr.getLeft();
			else
				curr = curr.getRight();
		}
		return curr.getItem();
	}

	public T remove(T item) { // utilize size of node to balance the tree
		T removed = null;
		if (root == null)
			return null;
		DoubleEndedTreeNode<T> curr = root;
		while (curr != null) {
			if (curr.getItem().equals(item)) {
				removed = curr.getItem();
				DoubleEndedTreeNode<T> l = curr.getLeft();
				while (l.hasRight())
					l = l.getRight();
				l.setRight(curr.getRight());
				DoubleEndedTreeNode<T> temp = curr.getParent();
				if (temp.getLeft().getItem() == item)
					temp.setLeft(curr.getLeft());
				else
					temp.setRight(curr.getLeft());
			} else if (curr.getItem().compareTo(item) < 0)
				curr = curr.getRight();
			else
				curr = curr.getLeft();
		}
		return removed;
	}

	public int size() {
		return root.size;
	}
	
	public void clear() {
		root = null;
	}

	@Override
	public T get(int index) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean contains(T item) {
		// TODO Auto-generated method stub
		return false;
	}
}
