package rit;
/**
 * This Object represents all spiders.
 */
public class Spider extends Animal {

  public Spider() {
    numberOfLegs = 8;
  }

  @Override
  public String move() {
    return "climb my web";
  }
}