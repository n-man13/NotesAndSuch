package lab2;
/*
 * Old Header:
 * Purpose: Data Structure and Algorithms Lab 2 Problem 1
 * Status: Completed and Thoroughly Tested
 * Last update: 09/13/17
 * Submitted:  09/19/17
 * Comment: 
 * @author: Nikhil Shah
 * @version: 2017.09.13
 */
public class ListArrayBasedPlus extends ListArrayBased{
	
	private void resize()
	{ 
		Object[] itemsNew = new Object[items.length << 1];
		
		for (int i = 0; i < items.length; i++){
			itemsNew[i] = items[i];
		}
		
		items = itemsNew;
	}
	public void add(int index, Object item)
	{	
		if (numItems == items.length)
			resize();
		super.add(index, item);
	}
	public String toString()
	{
		String result = "[";
		
		for (int i = 0; i < numItems; i++){
			result += items[i].toString() + ", ";
		}
		result = result.substring(0,result.length()-2) + "]";
		return result;
	}
	public void reverse()
	{ 
		Object[] extraList = new Object[items.length];
		for (int i = 0; i < numItems; i++) {
			extraList[i] = items[numItems-i-1];
		}
		items = extraList;
	}
}
