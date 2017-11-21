package lab4;

public class DNodeGeneric<T> {
	private T item;
	private DNodeGeneric<T> next;
	private DNodeGeneric<T> prev;

	public DNodeGeneric(T i) {
		this.item = i;
		next = prev = this;
	}

	public DNodeGeneric(T item, DNodeGeneric<T> next, DNodeGeneric<T> prev) {
		this.item = item;
		this.next = next;
		this.prev = prev;
	}

	public T getItem() {
		return this.item;
	}

	public DNodeGeneric<T> getNext() {
		return this.next;
	}

	public DNodeGeneric<T> getPrev() {
		return prev;
	}

	public void setNext(DNodeGeneric<T> newNext) {
		this.next = newNext;
	}

	public void setPrev(DNodeGeneric<T> newPrev) {
		this.prev = newPrev;
	}
	public String toString() {
		return item.toString();
	}
}
