package lab4;

/*
 * Purpose: Data Structure and Algorithms Lab 4 Problem Prelab
 * Status: Complete and thoroughly tested/Incomplete/ Barely started (choose only one!!!)
 * Last update: 09/26/17
 * Submitted:  09/27/17
 * Comment: 
 * @author: Nikhil Shah
 * @version: 2017.09.26
 */
public class DNode<T> {
	private T item;
	private DNode<T> next;
	private DNode<T> prev;

	public DNode(T item) {
		this.item = item;
		next = prev = this;
	}

	public DNode(T item, DNode<T> next, DNode<T> prev) {
		this.item = item;
		this.next = next;
		this.prev = prev;
	}

	public T getItem() {
		return this.item;
	}

	public DNode<T> getNext() {
		return this.next;
	}

	public DNode<T> getPrev() {
		return prev;
	}

	public void setNext(DNode<T> newNext) {
		this.next = newNext;
	}

	public void setPrev(DNode<T> newPrev) {
		this.prev = newPrev;
	}
}
