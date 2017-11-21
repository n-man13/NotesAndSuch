package midterm;

public interface ExtendedQueueInterface<T> {

	public void enqueueFirst(T newItem) throws ExtendedQueueException;

	public T dequeueLast() throws ExtendedQueueException;

	public T peekLast() throws ExtendedQueueException;
} // end ExtendedQueueInterface