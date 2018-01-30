package rit.subsystem;

import java.io.File;

/**
 * A definition for a command-line argument that must point
 * to some local file.
 *
 * @author <a href='mailto:bdbvse@rit.edu'>Bryan Basham</a>
 */
public class FileArgument extends Argument {

  /**
   * Create a new file argument definition.
   *
   * @param name
   *   the name of the argument for display purposes
   * @param isRequired
   *   {@code true} if this argument is required
   */
  public FileArgument(final String name, final boolean isRequired) {
    super(name, isRequired);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Object parse(String argumentStr) {
    argumentStr = argumentStr.trim();
    final File file = new File(argumentStr);
    if (file.exists()) {
      return file;
    } else {
      throw new IllegalArgumentException("file not found.");
    }
  }

}
