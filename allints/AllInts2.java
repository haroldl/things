public class AllInts2 {
  public static void main(String[] args) {
    // Allocate space for all 2^32 int values in a pair of arrays
    // with the maximum number of elements, and a third array to
    // make space for the extra 2 values we need.
    int[] ints1 = new int[Integer.MAX_VALUE];
    int[] ints2 = new int[Integer.MAX_VALUE];
    int[] ints3 = new int[2];
  }
}
