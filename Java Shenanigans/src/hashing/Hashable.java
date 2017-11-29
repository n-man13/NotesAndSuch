package hashing;

public abstract class Hashable<T extends Comparable<? super T>> {
	protected T data;
	public Hashable(T item) {
		this.data = item;
	}
	public abstract int hash(); 
	public String toString() {
		return data.toString();
	}
	public T getData() {
		return data;
	}
}
