package lab2;

import java.util.ArrayList;

/*
 * Purpose: Data Structure and Algorithms Lab 2 Problem 1
 * Status: Completed and Thoroughly Tested
 * Last update: 09/13/17
 * Submitted:  09/19/17
 * Comment: 
 * @author: Nikhil Shah
 * @version: 2017.09.13
 */
public class ListArrayListBasedPlus extends ListArrayListBased{
	public String toString()
	{
		return list.toString();
	}
	public void reverse()
	{ 
		ArrayList extraList = new ArrayList();
		for (int i = 0; i < list.size(); i++) {
			extraList.add(list.get(list.size()-i-1));
		}
		list = extraList;
	}
}
