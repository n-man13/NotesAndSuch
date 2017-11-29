package lab12;

/*-
 * Purpose: Data Structure and Algorithms Lab 12 Problem 1
 * Status: Complete and thoroughly tested
 * Last update: 11/29/17
 * Submitted:  11/30/17
 * Comment: test suite and sample run attached
 * @author: Nikhil Shah
 * @version: 2017.11.29
 */
public class HashTable implements HashTableInterface<String, Integer> {
	private ChainNode<String, Integer>[] table;
	private int size;

	public HashTable() {
		size = 0;
		table = new ChainNode[3];
	}

	public boolean tableIsEmpty() {
		return size == 0;
	}

	public int tableLength() {
		return size;
	}

	public boolean tableInsert(String key, Integer value) {
		int hashIndex = hashIndex(key);
		ChainNode<String, Integer> node = table[hashIndex(key)];

		if (node == null) {
			table[hashIndex] = new ChainNode<>(key, value, null);
			return true;
		}
		while (node.getNext() != null && !node.getKey().equals(key)) {
			if (node.getKey().equals(key))
				return false;
			node = node.getNext();
		}
		node.setNext(new ChainNode<String, Integer>(key, value, node.getNext()));
		return true;
	}

	public boolean tableDelete(String searchKey) {
		int hashIndex = hashIndex(searchKey);
		ChainNode<String, Integer> node = table[hashIndex];
		if (node == null) {
			return false;
		} else if (node.getKey().equals(searchKey)) {
			table[hashIndex] = node.getNext();
			return true;
		}
		while (node.getNext() != null) {
			if (node.getNext().getKey().equals(searchKey)) {
				Integer val = node.getNext().getValue();
				node.setNext(node.getNext().getNext());
				return true;
			}
			node = node.getNext();
		}
		return false;// only reached if key is not in the table
	}

	public Integer tableRetrieve(String searchKey) {
		ChainNode<String, Integer> node = table[hashIndex(searchKey)];
		while (node != null) {
			if (node.getKey().equals(searchKey))
				return node.getValue();
			node = node.getNext();
		}
		return null;
	}

	/*
	 * @param searchKey key used to find specific node
	 * 
	 * @returns hash of key using horner's method
	 */
	public int hash(String key) {
		int hash = 0;
		;
		for (int i = 0; i < key.length(); i++) {
			int shifted = (key.charAt(i) - 'A' + 1) << (5 * (key.length() - i - 1));
			hash += shifted;
		}
		return hash;
	}

	public String toString() {
		String result = "";
		for (ChainNode<String, Integer> node : table) {
			while (node != null) {
				result = result.concat(node.toString() + ", ");
				node = node.getNext();
			}
		}
		return result.substring(0, result.length() - 2);
	}

	// use hashIndex(key) % table.length for index
	private int hashIndex(String key) {
		return hash(key) % table.length;
	}
}
