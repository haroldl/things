public class AllInts5 {
  public static final int NUMBER_OF_INT_VALUES_DIVIDED_BY_4 = 1073741824;

  public static void main(String[] args) {
    long startTime = System.currentTimeMillis();

    // Allocate space for all 2^32 int values in 4 equally-sized arrays.
    int[] ints1 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints2 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints3 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints4 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];

    // We will put the first 4 values at index 0 in the arrays int1..int4, etc.
    for (long value = Integer.MIN_VALUE; value <= Integer.MAX_VALUE; value++) {
      // The index should go from 0 to MAX_VALUE/4
      int index = (int) (value / 4) - (Integer.MIN_VALUE / 4);
      switch ((int) value % 4) {
      case 0:
        ints1[index] = (int) value;
        break;
      case 1:
        ints2[index] = (int) value;
        break;
      case 2:
        ints3[index] = (int) value;
        break;
      case 3:
        ints4[index] = (int) value;
        break;
      }
    }

    long elapsedTime = System.currentTimeMillis() - startTime;
    System.out.println("Success, took " + elapsedTime + " milliseconds.");
  }
}
