public class AllInts4 {
  public static final int NUMBER_OF_INT_VALUES_DIVIDED_BY_4 = 1073741824;

  public static void main(String[] args) {
    // Allocate space for all 2^32 int values in 4 equally-sized arrays.
    int[] ints1 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints2 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints3 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints4 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    System.out.println("Success");
  }
}
