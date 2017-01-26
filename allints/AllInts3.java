public class AllInts3 {
  public static void main(String[] args) {
    // Find out what the maximum array size is for our platform.
    int numElems = Integer.MAX_VALUE;
    while (true) {
      try {
        int [] ints = new int[numElems];
        System.out.println("Success with numElems = " + numElems);
        break;
      } catch (OutOfMemoryError e) {
        System.out.println("Too many elements: " + numElems);
        numElems--;
      }
    }
  }
}
