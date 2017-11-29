package hashing;


//********************************************************
//Hash table implementation.
//Assumption: A table contains unique items(at most one 
//        item with a given search key at any time)
//*********************************************************

public class HashTable<K, V> {
	private ChainNode[] table; // hash table
	private int size = 0; // size of ADT table

	public HashTable() {
		table = new ChainNode[3];
	} // end default constructor

	// table operations
	public boolean tableIsEmpty() {
		return size == 0;
	} // end tableIsEmpty

	public int tableLength() {
		return size;
	} // end tableLength

	// implement the following 4 methods

	public boolean tableInsert(K key, V value) { // inserts association (key,value) only if key is not already in
													// HashTable and returns true; returns false if the key already has
													// an associated value in HashTable and does not insert
		return false; // placeholder
	}

	public boolean tableDelete(K searchKey) { // deletes the key and its association from the HashTable if it is in the
												// table and returns true; returns false if key is not in the HashTable
		return false; // placeholder
	}

	public V tableRetrieve(K searchKey) {// returns the value associated with searchkey in HashTable or null if no
											// association
		return null; // placeholder
	}

	public int hash(K key) {
		return -1; // placeholder
	}
	
	private int hashIndex(K key) {
		return hash(key) % table.length;
	}

} // end HashTable
