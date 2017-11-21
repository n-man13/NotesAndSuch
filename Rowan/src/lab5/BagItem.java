package lab5;

public class BagItem {
	private double weight;
	private int num;
	public BagItem(double w, int n) {
		weight = w;
		num = n;
	}
	public double getWeight() {
		return weight;
	}
	public int getNumber() {
		return num;
	}
	public String toString(){
		// Only sends weight
		return weight + "";
	}
}
