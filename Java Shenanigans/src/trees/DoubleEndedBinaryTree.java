package trees;

public class DoubleEndedBinaryTree<T> {
	protected DoubleEndedNode<T> root;
	protected int height;

	public DoubleEndedBinaryTree() {
		root = null;
		height = 0;
	}

	public T get(String path) throws TreeException {
		if (path.length() >= height) {
			throw new TreeOutOfBoundsException("Out of depth on remove");
		}
		return find(path, root).getItem();
	}

	public void add(String path, T item) throws TreeException {
		if (path.length() > height + 1)
			throw new TreeOutOfBoundsException("Out of depth on remove");
		int dir = Integer.parseInt(path.charAt(path.length()) + "");
		DoubleEndedNode<T> parent = find(path.substring(0, path.length() - 1), root);
		if (parent.isEdge(Integer.parseInt(dir + "")))
			parent.setChild(new DoubleEndedNode<T>(item, parent), dir);
		else {
			// what to do with rest of tree?
			
		}
	}

	public T remove(String path) throws TreeException {
		if (path.length() > height)
			throw new TreeOutOfBoundsException("Out of depth on remove");
		DoubleEndedNode<T> parent = find(path.substring(0, path.length() - 1), root);
		int side = path.charAt(path.length());
		if (parent.isEdge(side))
			throw new TreeException("Node does not exist");
		return parent.getChild(side).getItem();
	}

	public boolean isEmpty() {
		return root == null;
	}

	protected DoubleEndedNode<T> find(String path, DoubleEndedNode<T> source) throws TreeException {
		if (path.length() == 0)
			return source;
		else if (source.isLeaf())
			throw new TreeException("Node does not exist");
		else {
			int dir = Integer.parseInt("" + path.charAt(0));
			if (dir == 0)
				return find(path.substring(1), source.getLeft());
			else
				return find(path.substring(1), source.getRight());
		}
	}

}
