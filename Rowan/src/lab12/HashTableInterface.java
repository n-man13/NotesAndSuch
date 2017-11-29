package lab12;

public interface HashTableInterface<K, V> {

	public boolean tableIsEmpty();

	public int tableLength();

	public boolean tableInsert(K key, V value); // inserts association (key,value) only if key is not already in
												// HashTable and returns true; returns false if the key already has an
												// associated value in HashMap and does not insert

	public boolean tableDelete(K searchKey); // deletes the key and its association from the HashTable if it is in the
												// table and returns true; returns false if key is not in the HashTable

	public V tableRetrieve(K searchKey); // returns the value associated with searchkey in HashMap or null if there is
											// no association

	public int hashIndex(K key);

} // end HashTableInterface
