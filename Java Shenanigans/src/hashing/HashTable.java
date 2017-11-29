package hashing;

//********************************************************
//Hash table implementation.
//Assumption: A table contains unique items(at most one 
//        item with a given search key at any time)
//*********************************************************

public class HashTable<K extends Hashable, V> {
	private ChainNode<K, V>[] table; // hash table
	private int size = 0; // size of ADT table

	public HashTable() {
		table = new ChainNode[3];
	} // end default constructor

	public HashTable(int i) {
		table = new ChainNode[i];
	}

	// table operations
	public boolean tableIsEmpty() {
		return size == 0;
	} // end tableIsEmpty

	public int tableLength() {
		return size;
	} // end tableLength

	/*
	 * inserts association (key,value) if key is not already in HashTable returns
	 * false; returns true if the key already has an associated value in HashTable
	 */
	public boolean tableInsert(K key, V value) {
		int hashIndex = hashIndex(key);
		ChainNode<K,V> node = table[hashIndex];
		if (node == null) {
			table[hashIndex] = new ChainNode<>(key, value, null);
			return true;
		}			
		while(node.getNext() != null && !node.getKey().equals(key)) {
			if (node.getKey().equals(key))
				return false;
			node = node.getNext();
		}
		node.setNext(new ChainNode<K,V>(key, value, node.getNext()));
		return true;
	}

	/*
	 * deletes the key and its association from the HashTable if it is in the table
	 * and returns value removed; returns null if key is not in the HashTable
	 */
	public V tableDelete(K searchKey) {
		ChainNode<K,V> node = table[hashIndex(searchKey)];
		while (node.getNext() != null) {
			if (node.getNext().getKey().equals(searchKey)) {
				V val = node.getNext().getValue();
				node.setNext(node.getNext().getNext());
				return val;
			}
		}
		return null;
	}

	/*
	 * returns the value associated with searchkey in HashTable or null if no
	 * association
	 */
	public V tableRetrieve(K searchKey) {
		ChainNode<K, V> node = table[hashIndex(searchKey)];
		while(node != null) {
			if (node.getKey().equals(searchKey))
				return node.getValue();
			node = node.getNext();
		}
		return null;
	}

	public String toString() {
		String result = "";
		for (ChainNode<K,V> node: table) {
			while (node != null) {
				result.concat(node.toString() + ", ");
				node = node.getNext();
			}
		}
		return result.substring(0, result.length()-3);
	}
	
	private int hashIndex(K key) {
		return key.hash() % table.length;
	}

} // end HashTable
