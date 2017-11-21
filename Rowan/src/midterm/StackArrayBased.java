package midterm;

public class StackArrayBased<T> implements StackInterface<T> {
	/*
	 * Purpose: Data Structure and Algorithms Lab 5 Problem 1(prelab) Status:
	 * Complete and thoroughly tested Last update: 10/04/17 Submitted: 10/10/17
	 * Comment: test suite and sample run attached
	 * 
	 * @author: Nikhil Shah
	 * 
	 * @version: 2017.10.4
	 */

	private T stack[];
	private int top = -1;

	public StackArrayBased() {
		stack = (T[]) new Object[3];
	}

	@Override
	public boolean isEmpty() {
		return top == -1;
	}

	@Override
	public void popAll() {
		stack = (T[]) new Object[3];
		top = -1;
	}

	@Override
	public void push(T newItem) throws StackException {
		if (top == stack.length - 1)
			resize();
		stack[++top] = (T) newItem;
	}

	@Override
	public T pop() throws StackException {
		if (top == -1)
			throw new StackException("Stack is empty");
		T item = stack[top];
		stack[top--] = null;
		return item;
	}

	@Override
	public T peek() throws StackException {
		if (top == -1)
			throw new StackException("Stack is empty");
		return stack[top];
	}

	private void resize() {
		T[] bigStack = (T[]) new Object[(int) (stack.length * 1.5 + 1)];
		for (int i = 0; i < stack.length; i++) {
			bigStack[i] = stack[i];
		}
		stack = bigStack;
	}

	public String toString() {
		// format: "size indexTopItem indexTopItem-1 ... index1 index0 "
		String result = "";
		for (int i = 0; i <= top; i++) {
			result = result + stack[i].toString() + " ";
		}
		return result;
	}
}
