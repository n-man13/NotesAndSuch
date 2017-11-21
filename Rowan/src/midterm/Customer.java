package midterm;

public class Customer {
	private String name;
	private int bbRequest;
	private int bRequest;
	private int fRequest;

	public Customer(String name, int bb, int b, int f) {
		this.name = name;
		bbRequest = bb;
		bRequest = b;
		fRequest = f;
	}

	public String toString() {
		return name + " requesting " + bbRequest + " basketball, " + bRequest + " baseball and " + fRequest
				+ " football cards";
	}

	public String getName() {
		return name;
	}

	public int getBB() {
		return bbRequest;
	}

	public int getB() {
		return bRequest;
	}

	public int getF() {
		return fRequest;
	}

	public String getRequests() {
		return bbRequest + " basketball, " + bRequest + " baseball and " + fRequest + " football cards";
	}
}
