package trees;

public class DoubleEndedNode<T> {
	protected DoubleEndedNode<T> parent, leftC, rightC;
	protected T item;

	public DoubleEndedNode() {

	}

	public DoubleEndedNode(T item) {
		this.item = item;
		this.leftC = this.rightC = parent = null;
	}

	public DoubleEndedNode(T item, DoubleEndedNode<T> parent) {
		this.item = item;
		this.parent = parent;
		this.leftC = this.rightC = null;
	}

	public DoubleEndedNode<T> getParent() {
		return parent;
	}

	public DoubleEndedNode<T> getLeft() {
		return leftC;
	}

	public DoubleEndedNode<T> getRight() {
		return rightC;
	}

	public T getItem() {
		return item;
	}

	public void setParent(DoubleEndedNode<T> p) {
		parent = p;
	}

	public void setLeft(DoubleEndedNode<T> l) {
		leftC = l;
	}

	public void setRight(DoubleEndedNode<T> r) {
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

	public void setChild(DoubleEndedNode<T> child, int side) {
		if (side == 0)
			this.setLeft(child);
		else
			this.setRight(child);
	}

	public DoubleEndedNode<T> getChild(int side) {
		if (side == 0)
			return getLeft();
		else
			return getRight();
	}

	public boolean isLeaf() {
		return leftC == null && rightC == null;
	}
}
