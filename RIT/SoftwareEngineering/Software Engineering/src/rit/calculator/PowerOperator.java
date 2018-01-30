package rit.calculator;

public class PowerOperator implements BinaryOperator {

	@Override
	public double apply(double arg1, double arg2) {
		return Math.pow(arg1, arg2);
	}

}
