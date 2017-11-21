package midterm;

public class Card {
	private int num;
	private String type;

	public Card(int num, String type) {
		this.num = num;
		this.type = type;
	}

	public String getType() {
		return type;
	}

	public int getNum() {
		return num;
	}

	public String toString() {
		return num + " " + type + " cards";
	}

	public void setNum(int value) {
		num = value;
	}

	public void addCards(int more) {
		num += more;
	}
}
