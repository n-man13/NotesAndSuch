package rit.calculator;

public class AddOperator implements BinaryOperator{
	
	@Override
	public double apply(double arg1, double arg2) {
		return arg1 + arg2;
	}
}
