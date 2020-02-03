package linkedList_notSchool;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

public class MyLinkedList<C> implements List<C>{
	
	private int size = 0;
	private Node<C> head = null;
	
	public MyLinkedList() {
		
	}
	public MyLinkedList(C item) {
		head = new Node<C>(item);
		size = 1;
	}

	@Override
	public int size() {
		// TODO Auto-generated method stub
		return size;
	}

	@Override
	public boolean isEmpty() {
		// TODO Auto-generated method stub
		return size == 0;
	}

	@Override
	public boolean contains(Object o) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public Iterator<C> iterator() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public C[] toArray() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public C[] toArray(Object[] a) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean add(Object e) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean remove(Object o) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean containsAll(Collection c) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean addAll(Collection c) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean addAll(int index, Collection c) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean removeAll(Collection c) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean retainAll(Collection c) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public void clear() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public C get(int index) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public C set(int index, Object element) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void add(int index, Object element) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public C remove(int index) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int indexOf(Object o) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int lastIndexOf(Object o) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public ListIterator<C> listIterator() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ListIterator<C> listIterator(int index) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<C> subList(int fromIndex, int toIndex) {
		// TODO Auto-generated method stub
		return null;
	}

}
