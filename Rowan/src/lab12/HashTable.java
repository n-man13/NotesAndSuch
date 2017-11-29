package lab12;

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
		ChainNode<String, Integer> node = findNode(key);
		if (node.getKey().equals(key)) {
			return false;
			//set value to new value
		}
		else {
			node.setNext(new ChainNode<String, Integer>(key, value, null));
			return true;
			//set node.next to new node with key and value
		}
	}

	public boolean tableDelete(String searchKey) {
		int hashIndex = hashIndex(searchKey);
		ChainNode<String, Integer> curr = table[hashIndex];
		while(curr.getNext() != null) {
			if (curr.getNext().getKey().equals(searchKey)) { 
				curr.setNext(curr.getNext().getNext()); // curr.getNext is the node to remove
				return true;
			}
			curr = curr.getNext();
		}
		return false; // only reached if key is not in the table
	}

	public Integer tableRetrieve(String searchKey) {
		ChainNode<String, Integer> node = findNode(searchKey);
		if (node.getKey().equals(searchKey))
			return node.getValue(); 
		else return null;
	}

	/*
	 * @param searchKey key used to find specific node
	 * @returns hash of key using horner's method
	 */
	public int hash(String key) {
		// A = 65
		int hash = 0;;
		for (int i = 0; i < key.length(); i++) {
			int shifted = (key.charAt(i) - 'A' + 1)<< (5 * (key.length()-i-1));
			hash += shifted;
		}
		return hash;
	}
	/*
	 * @param searchKey key used to find specific node
	 * @returns node if found else node.getNext() is place to be put
	 */
	private ChainNode<String, Integer> findNode(String searchKey){
		int hashIndex = hashIndex(searchKey);
		ChainNode<String, Integer> curr = table[hashIndex];
		while(curr.getNext() != null) {
			if (curr.getNext().getKey().equals(searchKey))
				return curr.getNext();
			curr = curr.getNext();
		}
		return curr;
	}
	
	// use hashIndex(key) % table.length for index
	private int hashIndex(String key) {
		return hash(key) % table.length;
	}
}
