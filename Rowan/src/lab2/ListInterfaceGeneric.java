package lab2;

// ********************************************************
// Interface ListInterface for the ADT list.
// *********************************************************
public interface ListInterfaceGeneric<T> {
	boolean isEmpty();

	int size();

	void add(int index, T item) throws ListIndexOutOfBoundsException;

	T get(int index) throws ListIndexOutOfBoundsException;

	void remove(int index) throws ListIndexOutOfBoundsException;

	void removeAll();
} // end ListInterface
