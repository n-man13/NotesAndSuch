package trees;

public class DoubleEndedTreeNode<T> extends DoubleEndedNode<T> {
	protected int size;
	protected DoubleEndedTreeNode<T> parent, leftC, rightC;
	protected T item;

	public DoubleEndedTreeNode() { // unused constructor
		this.leftC = this.rightC = this.parent = null;
		item = null;
		size = 0;
	}

	public DoubleEndedTreeNode(T item) {
		this.item = item;
		this.size = 1;
		this.leftC = this.rightC = parent = null;
	}

	public DoubleEndedTreeNode(T item, DoubleEndedTreeNode<T> parent) {
		this.item = item;
		size = 1;
		this.parent = parent;
		this.leftC = this.rightC = null;
	}

	public DoubleEndedTreeNode<T> getParent() {
		return parent;
	}

	public DoubleEndedTreeNode<T> getLeft() {
		return leftC;
	}

	public DoubleEndedTreeNode<T> getRight() {
		return rightC;
	}

	public T getItem() {
		return item;
	}

	public void setParent(DoubleEndedTreeNode<T> p) {
		parent = p;
	}

	public void setLeft(DoubleEndedTreeNode<T> l) {
		if (leftC != null)
			size -= leftC.size;
		size = +l.size;
		leftC = l;
	}

	public void setRight(DoubleEndedTreeNode<T> r) {
		if (rightC != null)
			size -= rightC.size;
		size += r.size;
		rightC = r;
	}

	public void setItem(T item) {
		this.item = item;
	}

	public boolean isEdge(int side) {
		if (side == 0)
			return leftC == null;
		else
			return rightC == null;
	}

	public boolean hasLeft() {
		return leftC != null;
	}

	public boolean hasRight() {
		return rightC != null;
	}

	public void setChild(DoubleEndedTreeNode<T> child, int side) {
		if (side == 0)
			this.setLeft(child);
		else
			this.setRight(child);
	}

	public DoubleEndedTreeNode<T> getChild(int side) {
		if (side == 0)
			return getLeft();
		else
			return getRight();
	}

	public boolean isLeaf() {
		return leftC == null && rightC == null;
	}
}
