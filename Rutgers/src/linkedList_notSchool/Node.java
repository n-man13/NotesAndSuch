package linkedList_notSchool;

public class Node<C> {
	
	private Node<C> next;
	private C item;
	
	public Node(){
		next = null;
		item = null;
	}
	public Node(C item) {
		this.item = item;
		next = null;
	}
	public Node(C item, Node<C> next) {
		this.item = item;
		this.next = next;
	}
	
	public Node<C> getNext() {
		return next;
	}
	public C getItem() {
		return item;
	}
	
	public Node<C> setNext(Node<C> next) {
		Node<C> temp = this.next;
		this.next = next;
		return temp;
	}
	
}
