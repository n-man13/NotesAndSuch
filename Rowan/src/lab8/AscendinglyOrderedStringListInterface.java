package lab8;

public interface AscendinglyOrderedStringListInterface

{
	boolean isEmpty();

	int size();

	void add(String item) throws ListIndexOutOfBoundsException;

	String get(int index) throws ListIndexOutOfBoundsException;

	void remove(int index) throws ListIndexOutOfBoundsException;

	int search(String item);

	void clear();

}