package rit.subsystem;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * A definition for a command-line argument that must be an email address.
 *
 * <p>
 * Inspired by
 * <a href="https://www.mkyong.com/regular-expressions/how-to-validate-email-address-with-regular-expression/">
 *   How to validate email address with regular expression
 * </a>
 * by <code>Mkyong.com</code>.
 * </p>
 *
 * @author <a href='mailto:bdbvse@rit.edu'>Bryan Basham</a>
 */
public class EmailArgument extends Argument {
  private static final String EMAIL_PATTERN =
      "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
      + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

  private Pattern pattern;

  /**
   * Create a new email argument definition.
   *
   * @param name
   *   the name of the argument for display purposes
   * @param isRequired
   *   {@code true} if this argument is required
   */
  public EmailArgument(final String name, final boolean isRequired) {
    super(name, isRequired);
    pattern = Pattern.compile(EMAIL_PATTERN);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Object parse(String argumentStr) {
    argumentStr = argumentStr.trim();
    final Matcher matcher = pattern.matcher(argumentStr);
    if (matcher.matches()) {
      return argumentStr;
    } else {
      throw new IllegalArgumentException();
    }
  }

}
