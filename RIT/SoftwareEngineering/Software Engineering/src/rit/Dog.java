package rit;
/**
 * This Object represents all dogs.
 */
public class Dog extends Animal {

  public Dog() {
    numberOfLegs = 4;
  }

  @Override
  public String move() {
    return "chase my tail";
  }
}