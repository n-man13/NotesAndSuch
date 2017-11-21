package midterm;

public class QueueArrayBased<T> implements QueueInterface<T> {

	protected T[] items;
	protected int front, back, numItems;

	@SuppressWarnings("unchecked")
	public QueueArrayBased() {
		items = (T[]) new Object[3];
		front = back = numItems = 0;
	}

	@Override
	public boolean isEmpty() {
		// TODO Auto-generated method stub
		return numItems == 0;
	}

	@Override
	public void enqueue(T newItem) throws QueueException {
		if (numItems == items.length) {
			resize();
		}
		items[back] = newItem;
		back = (back + 1) % items.length;
		numItems++;
	}

	@Override
	public T dequeue() throws QueueException {
		// TODO Auto-generated method stub
		if (numItems == 0)
			throw new QueueException("Queue is empty on dequeue");
		else {
			T temp = items[front];
			items[front] = null;
			front = (front + 1) % items.length;
			numItems--;
			return temp;
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void dequeueAll() {
		// TODO Auto-generated method stub
		if (numItems == 0)
			throw new QueueException("Queue is empty on dequeueAll");
		else {
			items = (T[]) new Object[3];
			numItems = front = back = 0;
		}
	}

	@Override
	public T peek() throws QueueException {
		// TODO Auto-generated method stub
		if (numItems == 0)
			throw new QueueException("Queue is empty on peek");
		else
			return items[front];
	}

	@SuppressWarnings("unchecked")
	protected T[] resize() {
		T[] temp = (T[]) new Object[items.length * 2];
		for (int i = 0; i < numItems; i++) {
			temp[i] = items[(front + i) % items.length];
		}
		front = 0;
		back = numItems;
		items = temp;
		return temp;
	}

	@Override
	public String toString() {
		String result = "";
		for (int i = 0; i < numItems; i++) {
			result += (items[(front + i) % items.length] + " \n");
		}
		return result;
	}

}
