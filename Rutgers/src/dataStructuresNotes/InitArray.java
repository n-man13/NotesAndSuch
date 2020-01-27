package dataStructuresNotes;

public class InitArray {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		int[] array = {32, 27, 64, 18, 95, 14, 90, 70, 60, 37};
		
		System.out.printf("%s%8s%n", "Index", "Value");
		
		for(int count = 0; count < array.length; count++)
			System.out.printf("%5d%8d%n", count, array[count]);
	}

}
