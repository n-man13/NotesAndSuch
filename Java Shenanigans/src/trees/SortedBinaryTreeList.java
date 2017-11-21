package trees;

import java.util.ArrayList;

public class SortedBinaryTreeList<T extends Comparable<T>> extends DoubleEndedBinaryTree<T> {

	public SortedBinaryTreeList() {
		super();
	}

	public void add(T item) {
		// TODO add item in proper position
		// if (item.equals(root.getItem()))
			
	}

	public String toString() {
		return inOrder(root);
	}

	public String inOrder(DoubleEndedNode<T> n) {
		if (n.isLeaf())
			return n.toString();
		else if (n.isEdge(0))
			return n.toString() + inOrder(n.getRight());
		else if (n.isEdge(1))
			return inOrder(n.getLeft()) + n.toString();
		else
			return (inOrder(n.getLeft()) + n.toString() + inOrder(n.getRight()));
	}

	public boolean remove(T item) {
		// returns if item is removed or not
		DoubleEndedNode<T> curr = root;
		DoubleEndedNode<T> temp = null;
		while (curr != null) {
			if (curr.getItem().equals(item)) {
				if (curr.isLeaf())
					if (curr.getParent().getLeft().getItem().equals(curr.getItem()))
						curr.getParent().setLeft(null);
					else
						curr.getParent().setRight(null);
				else {
					temp = rightMost(curr.getLeft());
					removeHelper(temp);
					return true;
				}
			} else if (curr.isLeaf())
				return false;
			else if (curr.getItem().compareTo(item) < 0 && !curr.isEdge(1))
				curr = curr.getRight();
			else if (curr.isEdge(0))
				curr = curr.getLeft();
			else
				return false;
		}
		return false;
	}

	private void removeHelper(DoubleEndedNode<T> node) {

	}

	private DoubleEndedNode<T> rightMost(DoubleEndedNode<T> n) {
		DoubleEndedNode<T> curr = n;
		while (!curr.isEdge(1))
			curr = curr.getRight();
		return curr;
	}

	// private void shittyReorder() {}

	@SuppressWarnings("unchecked")
	public T[] toArray() {
		ArrayList<T> temp = toArray(root, new ArrayList<T>());
		return temp.toArray((T[]) new Object[temp.size()]);
	}

	private ArrayList<T> toArray(DoubleEndedNode<T> n, ArrayList<T> a) {
		if (n.isLeaf())
			a.add(n.getItem());
		else if (n.isEdge(1)) {
			a.addAll(toArray(n.getLeft(), a));
			a.add(n.getItem());
		} else if (n.isEdge(0)) {
			a.add(n.getItem());
			a.addAll(toArray(n.getRight(), a));
		} else {
			a.addAll(toArray(n.getLeft(), a));
			a.add(n.getItem());
			a.addAll(toArray(n.getRight(), a));
		}
		return a;
	}
}
