package trees;

public class Node<T> {
	private T item;
	private Node<T> leftC, rightC;
	
	public Node(T item) {
		this.item = item;
		this.leftC = this.rightC = null;
	}
	
	public T getItem() {
		return item;
	}
	
	public Node<T> getLeft(){
		return leftC;
	}
	
	public Node<T> getRight(){
		return rightC;
	}
	
	public Node<T> getChild(int side){
		if (side == 0)
			return leftC;
		else return rightC;
	}
	
	public void setLeft(Node<T> left) {
		leftC = left;
	}
	
	public void setRight(Node<T> right) {
		rightC = right;
	}
	
	public void setItem(T item) {
		this.item = item;
	}
	
	public boolean hasLeft() {
		return leftC == null;
	}
	
	public boolean hasRight() {
		return rightC == null;
	}
}
