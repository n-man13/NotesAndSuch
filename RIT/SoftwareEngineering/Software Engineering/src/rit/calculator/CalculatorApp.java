package rit.calculator;

/**
 * The main class to test the {@code BinaryOperation} subsystem.
 *
 * @author <a href='mailto:bdbvse@rit.edu'>Bryan Basham</a>
 */
public class CalculatorApp {

	public static void main(String[] args) {
		// create a calculation
		final double sideA = 3;
		final double sideB = 4;
		BinaryOperation pythagoreanCalculation = new BinaryOperation(new PowerOperator(),
				new BinaryOperation(new AddOperator(), new BinaryOperation(new PowerOperator(), sideA, 2),
						new BinaryOperation(new PowerOperator(), sideB, 2)),
				0.5);

		final double sideC = pythagoreanCalculation.getResult();
		if (Math.abs(sideC - 5) < 0.001) {
			System.out.println("Pythagorean's theoreom works!  sideC = " + sideC);
		} else {
			System.err.println("Doh!");
		}
	}
}
