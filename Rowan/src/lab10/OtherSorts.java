package lab10;

public class OtherSorts {

	public void quickSort(int[] data) {
		quickSort(data, 0, data.length - 1);
	}

	/*-
	 * recursive helper method
	 */
	public SortReturn quickSort(int[] data, int start, int end) {
		SortReturn result = new SortReturn();
		if (start >= end)
			return new SortReturn();
		int pivot = start;
		int topLow = 1;
		int topHi = 1;
		while (topHi <= end) {
			if (data[topHi] < data[pivot]) {
				swap(data, topHi, topLow);
				result.swaps++;
				topLow++;
			}
			result.comps++;
			topHi++;
		}
		swap(data, pivot, --topLow);
		result.swaps++;
		result.add(quickSort(data, start, topLow - 1));
		result.add(quickSort(data, topLow + 1, end));
		return result;
	}

	/*-
	 * iterative
	 */
	public void mergeSort(int[] data) {
		int[] helper = new int[data.length];
		for (int size = 1, mergeSize = 2; size < data.length; size = mergeSize, mergeSize *= 2) {
			for (int i = 0; i < data.length; i += mergeSize) {

			}
		}
	}

	public int[] mergeSort(int[] data, int start, int end) throws Exception {
		int[] result = new int[end - start];
		if (end - start < 1) {
			throw new Exception("unable to sort array of length 0");
		} else if (result.length == 1) {
			result[0] = data[start];
		} else {
			int mid = (start+end) / 2;
			merger(result, mergeSort(data, start, mid), mergeSort(data, mid+1, end));
		}
		return result;
	}

	private void merger(int[] merged, int[] left, int[] right) {
		for (int i = 0; i < left.length; i++) {
			merged[i] = left[i];
		}
		for (int i = 0; i < right.length; i++) {
			merged[i + left.length - 1] = right[i];
		}
	}

	private void swap(int[] data, int index1, int index2) {
		int temp = data[index1];
		data[index1] = data[index2];
		data[index2] = temp;
	}

	private void copyArray(int[] from, int[] to) {
		for (int i = 0; i < from.length; i++) {
			to[i] = from[i];
		}
	}
}
