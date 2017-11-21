package lab6;

public class Deq<T> extends QueueArrayBased<T> implements ExtendedQueueInterface<T> {

	@Override
	public void enqueueFirst(T newItem) throws ExtendedQueueException {
		if (numItems == items.length)
			resize();
		// circular decrement, drop in item, increment numItems
		front = (front + items.length - 1) % items.length;
		items[front] = newItem;
		numItems++;
	}

	@Override
	public T dequeueLast() throws ExtendedQueueException {
		if (numItems == 0)
			throw new QueueException("Queue is empty on dequeueLast");
		else {
			// circular decrement back, drop null, decrement numItems
			back = (back + items.length - 1) % items.length;
			T item = items[back];
			items[back] = null;
			numItems--;
			return item;
		}
	}

	@Override
	public T peekLast() throws ExtendedQueueException {
		if (numItems == 0)
			throw new QueueException("Queue is empty on peekLast");
		else
			return items[(back + items.length - 1) % items.length];
	}

}
