package lab10;

import java.util.Random;

public class Lab10Driver {

	public static void main(String[] args) throws Exception {
		int numItems = 8;
		Integer[] toSort = randomOrder(numItems);
		printArr(toSort);
		System.out.println();
		Integer[] sorted = mergeSort(toSort, 0, numItems);
		printArr(sorted);
	}

	public static Integer[] inOrder(int numItems) {
		Integer[] ordered = new Integer[numItems];
		for (int i = 0; i < numItems; i++) {
			ordered[i] = i + 1;
		}
		return ordered;
	}

	public static Integer[] reverseOrder(int numItems) {
		Integer[] reverse = new Integer[numItems];
		for (int i = 0; i < numItems; i++) {
			reverse[i] = numItems - i + 1;
		}
		return reverse;
	}

	public static Integer[] randomOrder(int numItems) {
		Integer[] random = new Integer[numItems];
		LinkedList<Integer> toChoose = new LinkedList<>();
		try {
			toChoose.addAll(inOrder(numItems));
			Random rg = new Random();
			for (int i = 0; i < numItems - 1; i++) {
				random[i] = toChoose.remove(rg.nextInt(toChoose.getSize()));
			}
		} catch (ListIndexOutOfBoundsException e) {
			System.out.println("this should be impossible");
			e.printStackTrace();
		}
		return random;
	}

	public static void printArr(Integer[] toSort) {
		for (int i = 0; i < toSort.length; i++) {
			System.out.println(toSort[i]);
		}
	}

	public static Integer[] mergeSort(Integer[] toSort, int start, int end) throws Exception {
		Integer[] result = new Integer[end - start];
		if (end - start < 1) {
			// throw new Exception("unable to sort array of length 0");
		} else if (result.length == 1) {
			result[0] = toSort[start];
		} else {
			int mid = (start + end) / 2;
			merger(result, mergeSort(toSort, start, mid), mergeSort(toSort, mid, end));
		}
		return result;
	}

	private static void merger(Integer[] merged, Integer[] left, Integer[] right) {
		int l = 0, r = 0;
		boolean leftLast = false;
		for (int i = 0; i < merged.length; i++) {
			if (l < left.length && r < right.length)
				if (left[l] < right[r]) {
					merged[i] = left[l++];
					leftLast = true;
				} else {
					merged[i] = right[r++];
					leftLast = false;
				}
			else {
				if (leftLast)
					merged[i] = right[r++];
				else
					merged[i] = left[l++];
			}
		}
	}

}
