package rit.calculator;

public class BinaryOperation {
	private double arg1, arg2;
	private BinaryOperator oper;
	
	public BinaryOperation(BinaryOperator op, double arg1, double arg2) {
		this.arg1 = arg1;
		this.arg2 = arg2;
		oper = op;
	}
	public BinaryOperation(BinaryOperator op, BinaryOperation one, BinaryOperation two) {
		arg1 = one.getResult();
		arg2 = two.getResult();
		oper = op;
	}
	public BinaryOperation(BinaryOperator op, BinaryOperation one, double arg2) {
		arg1 = one.getResult();
		this.arg2 = arg2;
		oper = op;
	}
	
	public double getResult() {
		return oper.apply(arg1, arg2);
	}
}
