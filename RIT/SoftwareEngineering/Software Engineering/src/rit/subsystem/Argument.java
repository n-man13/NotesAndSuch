package rit.subsystem;

/**
 * A definition for a command-line argument.  Each argument will have a name
 * and a flag whether the argument is required.
 *
 * @author <a href='mailto:bdbvse@rit.edu'>Bryan Basham</a>
 */
public abstract class Argument {
  private final boolean isRequired;
  private final String name;

  /**
   * Create a new argument definition.
   *
   * @param name
   *   the name of the argument for display purposes
   * @param isRequired
   *   {@code true} if this argument is required
   */
  public Argument(final String name, final boolean isRequired) {
    this.name = name;
    this.isRequired = isRequired;
  }

  public boolean isRequired() {
    return isRequired;
  }
  public String getName() {
    return name;
  }

  /**
   * Validate and convert a command-line argument string into some Java object
   * that could be a {@link String} of course but it could also be some other
   * Java object like a file or a number.
   *
   * @param argumentStr
   *    a single command-line argument string
   *
   * @return
   *    the Java object equivalent of that string
   *
   * @throws
   *    IllegalArgumentException when the string isn't valid
   */
  public abstract Object parse(final String argumentStr);
}
