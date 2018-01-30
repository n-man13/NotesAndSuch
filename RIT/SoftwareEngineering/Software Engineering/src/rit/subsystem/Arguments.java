package rit.subsystem;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * An object representing the structure of a sequence of
 * command-line arguments.  Each {@linkplain Argument argument definition}
 * has a name and a {@code isRequired} flag.
 *
 * @author <a href='mailto:bdbvse@rit.edu'>Bryan Basham</a>
 */
public class Arguments {

  private final List<Argument> argumentDefinitions;

  /**
   * Create a arguments declaration.
   *
   * @param arguments
   *   an arbitrary array of argument definitions
   */
  public Arguments(final Argument... arguments) {
    argumentDefinitions =
        Collections.unmodifiableList(
            Arrays.asList(arguments));
  }

  /**
   * Parse the command-line arguments (an array of strings).
   *
   * @param args
   *   the command-line arguments from the application's main method
   *
   * @return
   *   a {@link Map} between the argument name and the parsed argument value
   *
   * @throws
   *   IllegalArgumentException when a parsing error occurs
   */
  public Map<String, Object> parse(String[] args) {
    final Map<String, Object> argValues = new HashMap<>();
    int argIdx = 0;
    for (final Argument argDef : argumentDefinitions) {
      try {
        final Object value = argDef.parse(args[argIdx]);
        argValues.put(argDef.getName(), value);
        argIdx++;

      } catch (IllegalArgumentException e) {
        if (argDef.isRequired()) {
          // if this argument is required, then fail now
          throw new IllegalArgumentException(
              argDef.getName() + " didn't parse because " + e.getMessage());
        } else {
          // otherwise go to the next arg def
          continue;
        }
      }
    }
    //
    return argValues;
  }

}
