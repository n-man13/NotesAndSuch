package lab10;

public class Node <T>{
	protected T item;
	protected Node<T> next;
	
	public Node(T item) {
		this.item = item;
	}
	public void setNext(Node<T> n) {
		next = n;
	}
	public T getItem() {
		return item;
	}
	public Node<T> getNext() {
		return next;
	}

}
