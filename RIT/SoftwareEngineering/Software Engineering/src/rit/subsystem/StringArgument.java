package rit.subsystem;

/**
 * A definition for a command-line argument that is an ordinary string,
 * but must have a minimum length.
 *
 * @author <a href='mailto:bdbvse@rit.edu'>Bryan Basham</a>
 */
public class StringArgument extends Argument {

  private final int minSize;

  /**
   * Create a new string argument definition.
   *
   * @param name
   *   the name of the argument for display purposes
   * @param isRequired
   *   {@code true} if this argument is required
   * @param minSize
   *   the minimum length of the string
   */
  public StringArgument(final String name, final boolean isRequired, final int minSize) {
    super(name, isRequired);
    this.minSize = minSize;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Object parse(String argumentStr) {
    argumentStr = argumentStr.trim();
    if (argumentStr.length() >= minSize) {
      return argumentStr;
    } else {
      throw new IllegalArgumentException("length too small, must be at least " + minSize + " characters.");
    }
  }
}
