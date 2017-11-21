package lab9;

public class SortsImplemented {

	protected int totalSwaps;
	protected int totalComps;

	public SortsImplemented() {

	}

	/*-
	 * Option 1
	 * compares adjacent items
	 * if a[i] <  a[i-1]
	 * swap
	 */
	public int[] bubbleSort(int[] arr) {
		totalSwaps = totalComps = 0;
		for (int sorted = arr.length; sorted > 1; sorted--) {
			for (int i = 1; i < sorted; i++) {
				if (arr[i] < arr[i - 1]) {
					swap(arr, i, i - 1);
				}
				totalComps++;
			}
		}
		return arr;
	}

	/*-
	 * Option 2
	 * same as bubble
	 * maintains number of swaps per pass
	 * if swaps is 0 at end of pass
	 * array is sorted
	 */
	public int[] improvedBubble(int[] arr) {
		totalSwaps = totalComps = 0;
		for (int sorted = arr.length; sorted > 1; sorted--) {
			int swaps = 0;
			for (int i = 1; i < sorted; i++) {
				if (arr[i] < arr[i - 1]) {
					swap(arr, i, i - 1);
					swaps++; // count number of swaps
				}
				totalComps++;
			}
			if (swaps == 0)
				break;
		}
		return arr;
	}

	/*-
	 * Option 3
	* maintains two sections of list
	* first is unsorted
	* second is sorted
	* finds largest in unsorted and adds to start of sorted
	*/
	public int[] selectionSort(int[] arr) {
		totalSwaps = totalComps = 0;
		for (int sorted = arr.length; sorted > 0;) {
			int iMax = 0;
			for (int i = 1; i < sorted; i++) {
				if (arr[i] > arr[iMax]) { // find max
					iMax = i;
				}
				totalComps++;
			}
			swap(arr, iMax, --sorted); // move max to the end
		}
		return arr;
	}

	/*-
	 * Option 4
	 * same as selection
	 * count number of times iMax changed
	 * if changes == numUnsorted
	 * sorted
	 */
	public int[] improvedSelection(int[] arr) {
		totalSwaps = totalComps = 0;
		for (int sorted = arr.length; sorted > 0;) {
			int iMax = 0;
			int changed = 0;
			for (int i = 1; i < sorted; i++) {
				if (arr[i] > arr[iMax]) { // find max
					iMax = i;
					changed++;
				}
				totalComps++;
				if (changed == sorted-1)
					return arr;
			}
			swap(arr, iMax, --sorted); // move max to the end
		}
		return arr;
	}

	/*-
	 * Option 5
	 * maintains two sections of list 
	 * first is sorted 
	 * second is unsorted
	 * continuously adds next element to sorted until no more unsorted
	 * uses sequential search to find position in sorted array
	 * notes: totalSwaps is number of shifts in this case
	 */
	public int[] insertionSort(int[] arr) {
		totalSwaps = totalComps = 0;
		for (int toSort = 1; toSort < arr.length; toSort++) {
			int temp = arr[toSort];
			for (int i = toSort - 1; i <= 0; i--) {
				totalComps++;
				if (arr[i] > temp) { // shift all greater than temp over one
					arr[i + 1] = arr[i];
					totalSwaps++;
				} else { // drop temp in
					arr[i] = temp;
					break;
				}
			}
		}
		return arr;
	}

	/*-
	 * Option 6
	 * same as insertion
	 * uses binary search to find position in sorted array
	 * notes: totalSwaps is number of shifts in this case
	 */
	public int[] improvedInsertion(int[] arr) {
		totalSwaps = totalComps = 0;
		for (int toSort = 1; toSort < arr.length; toSort++) {
			int temp = arr[toSort];
			int pos = binarySearch(arr, temp, toSort - 1); // find place to put temp
			for (int i = toSort - 1; i > pos; i--) { // shift all to correct positions
				arr[i + 1] = arr[i];
				totalSwaps++;
			}
			arr[pos] = temp; // drop temp in
		}
		return arr;
	}

	private int binarySearch(int[] arr, int key, int end) {
		int high = end, low = 0;
		int mid = (high + low) / 2;
		while (high >= low) {
			if (key < arr[mid])
				high = mid - 1;
			else
				low = mid;
			mid = (high + low) / 2;
			totalComps++;
		}
		return mid;
	}

	private void swap(int[] array, int index1, int index2) {
		if (index1 == index2)
			return;
		int temp = array[index1];
		array[index1] = array[index2];
		array[index2] = temp;
		totalSwaps++;
	}
}