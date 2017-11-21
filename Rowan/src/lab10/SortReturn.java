package lab10;

public class SortReturn {
	protected int swaps = 0;
	protected int comps = 0;
	
	public void add(SortReturn other) {
		this.swaps += other.swaps;
		this.comps += other.comps;
	}
}
