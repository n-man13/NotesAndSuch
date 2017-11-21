package lab2;

import java.util.ArrayList;

public class ListArrayListBased implements ListInterface {
	/*
	 * Purpose: Data Structure and Algorithms Lab 2 Problem 2
	 * Status: Complete and thoroughly tested
	 * Last update: 09/14/17
	 * Submitted:  09/19/17
	 * Comment: test suite and sample run attached
	 * @author: Nikhil Shah
	 * @version: 2017.09.14
	 */
	protected ArrayList list;

	public ListArrayListBased() {
		list = new ArrayList();
	}

	@Override
	public boolean isEmpty() {
		// TODO Auto-generated method stub
		return list.isEmpty();// placeholder
	}

	@Override
	public int size() {
		// TODO Auto-generated method stub
		return list.size();// placeholder
	}

	@Override
	public void add(int index, Object item) throws ListIndexOutOfBoundsException {
		// TODO Auto-generated method stub
		if (index >= list.size())
			throw new ListIndexOutOfBoundsException("exception on add");
		list.add(index, item);
	}

	@Override
	public Object get(int index) throws ListIndexOutOfBoundsException {
		// TODO Auto-generated method stub
		if (index >= list.size())
			throw new ListIndexOutOfBoundsException("exception on get");
		return list.get(index);
	}

	@Override
	public void remove(int index) throws ListIndexOutOfBoundsException {
		if (index >= list.size())
			throw new ListIndexOutOfBoundsException("exception on remove");
		list.remove(index);
	}

	@Override
	public void removeAll() {
		// TODO Auto-generated method stub
		list = new ArrayList();
	}

	public String toString() {
		return list.toString();
	}

}
