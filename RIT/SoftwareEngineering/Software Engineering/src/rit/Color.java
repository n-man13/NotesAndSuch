package rit;
/**
 * This Object holds an RGB color definition.
 * 
 * WHAT PRICIPLE IS VIOLATED?
 * Improper Data Encapsulation
 */
public class Color {
  private int red;
  private int green;
  private int blue;
  
  public String getCssCode() {
    return "#"
        + Integer.toHexString(red)
        + Integer.toHexString(green)
        + Integer.toHexString(blue);
  }
}