package lab7;

import java.util.*;

public class FactorialHelper {
	private Map<Integer, Long> factorialStores;
	
	public FactorialHelper() {
		this.factorialStores = new HashMap<Integer, Long>();
		this.factorialStores.put(0, (long) 1);
		this.factorialStores.put(1, (long) 1);
	}
	public long rFact(int k) {
		if (this.factorialStores.containsKey(k))
			return this.factorialStores.get(k);
		else {
			long fact = rFact(k-1) * k;
			this.factorialStores.put(k, fact);
			return fact;
		}
	}
}
