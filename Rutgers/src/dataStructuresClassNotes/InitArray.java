package dataStructuresClassNotes;

public class InitArray {

	public static void main(String[] args) {
		int[] myArray = {32, 27, 64, 18, 95, 14, 90, 70, 60, 37};
		
		System.out.printf("%5s%8s%n", "Index", "Value");
		
		int total = 0;
		for(int count = 0; count < myArray.length; count++) {
			System.out.printf("%5d%8d%n", count, myArray[count]);
			total += myArray[count];
		}
		System.out.println("\nThe total is: " + total + ".");
	}

}
