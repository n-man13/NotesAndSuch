package lab11;

/*
 * Purpose: Data Structure and Algorithms Lab 11 Problem 2
 * Status: Complete but untested
 * Last update: 11/26/17
 * Submitted:  11/28/17
 * Comment: 
 * @author: Nikhil Shah
 * @version: 2017.11.26
 */
public class MyBinarySearchTreePlus<T extends KeyedItem<KT>, KT extends Comparable<? super KT>>
		extends MyBinarySearchTree<T, KT> implements BSTPInterface<T, KT> {

	@Override
	public int getHeight() {
		// TODO Auto-generated method stub
		return getHeight(root);
	}

	@Override
	public int getSize() {
		return getSize(root);
	}

	@Override
	public String toStringInorder() {
		// left root right
		return inOrder(root);
	}

	@Override
	public String toStringPreorder() {
		// root left right
		return preOrder(root);
	}

	@Override
	public String toStringPostorder() {
		// left right root
		return postOrder(root);
	}

	@Override
	public BSTPInterface<T, KT> getCopyOfTree() {
		// TODO Auto-generated method stub
		return remake(root, new MyBinarySearchTreePlus<T, KT>());
	}

	protected int getHeight(TreeNode<T> curr) {
		if (curr == null)
			return 0;
		int left = getHeight(curr.getLeftChild());
		int right = getHeight(curr.getRightChild());
		if (left > right)
			return left + 1;
		else
			return right + 1;
	}

	protected int getSize(TreeNode<T> curr) {
		if (curr == null)
			return 0;
		else
			return getSize(curr.getLeftChild()) + getSize(curr.getRightChild()) + 1;
	}

	protected String inOrder(TreeNode<T> curr) {
		if (curr == null)
			return "";
		String result = "";
		result.concat(inOrder(curr.getLeftChild()) + " ");
		result.concat(curr.toString() + " ");
		result.concat(inOrder(curr.getRightChild()) + " ");
		return result;
	}

	protected String postOrder(TreeNode<T> curr) {
		if (curr == null)
			return "";
		String result = "";
		result.concat(postOrder(curr.getLeftChild()) + " ");
		result.concat(postOrder(curr.getRightChild()) + " ");
		result.concat(curr.toString() + " ");
		return result;
	}

	protected String preOrder(TreeNode<T> curr) {
		if (curr == null)
			return "";
		String result = "";
		result.concat(curr.toString() + " ");
		result.concat(preOrder(curr.getLeftChild()) + " ");
		result.concat(preOrder(curr.getRightChild()) + " ");
		return result;
	}

	protected BSTPInterface<T, KT> remake(TreeNode<T> main, MyBinarySearchTreePlus<T, KT> other) {
		if (main != null) {
			other.insert(main.getItem());
			remake(main.getLeftChild(), other);
			remake(main.getRightChild(), other);
		}
		return other;
	}

}
