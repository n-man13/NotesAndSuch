package searches;

public interface Set<T> {
public T get(int index);
public boolean add(T item) throws Exception;
public boolean contains(T item);
public boolean remove(T item);
public boolean isEmpty();
public void clear();
public int size();
}
