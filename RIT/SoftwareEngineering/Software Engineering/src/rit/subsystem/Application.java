package rit.subsystem;

import java.util.Map;

/**
 * A sample of using the {@linkplain Arguments arguments subsystem}.
 *
 * @author <a href='mailto:bdbvse@rit.edu'>Bryan Basham</a>
 */
public class Application {

  private static final int MIN_SIZE = 5;
  private static final String USAGE = "Application <NAME> [<EMAIL_ADDR>] <PROFILE_FILE>";

  public static void main(String[] args) {
    final Argument name = new StringArgument("NAME", true, MIN_SIZE);
    final Argument emailAddr = new EmailArgument("EMAIL_ADDR", false);
    final Argument profileFile = new FileArgument("PROFILE_FILE", true);
    final Arguments myArgs = new Arguments(name, emailAddr, profileFile);

    try {
      final Map<String, Object> argMap = myArgs.parse(args);
      System.out.println("argMap: " + argMap);
    } catch (Exception e) {
      System.out.println(USAGE);
      throw e;
    }
  }
}
