public class AllInts6 {
  public static final int NUMBER_OF_INT_VALUES_DIVIDED_BY_4 = 1073741824;

  public static void main(String[] args) {
    long startTime = System.currentTimeMillis();

    // Allocate space for all 2^32 int values in 4 equally-sized arrays.
    int[] ints1 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints2 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints3 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];
    int[] ints4 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_4];

    Thread thread1 = new Thread(new Filler(ints1, 0));
    Thread thread2 = new Thread(new Filler(ints2, 1));
    Thread thread3 = new Thread(new Filler(ints3, 2));
    Thread thread4 = new Thread(new Filler(ints4, 3));

    thread1.start();
    thread2.start();
    thread3.start();
    thread4.start();

    waitForThreadToFinish(thread1);
    waitForThreadToFinish(thread2);
    waitForThreadToFinish(thread3);
    waitForThreadToFinish(thread4);

    long elapsedTime = System.currentTimeMillis() - startTime;
    System.out.println("Success, took " + elapsedTime + " milliseconds.");
  }

  static void waitForThreadToFinish(Thread thread) {
    try {
      thread.join();
    } catch (InterruptedException e) {
      throw new RuntimeException(e);
    }
  }

  public static class Filler implements Runnable {
    private final int[] target;
    private final int offset;

    public Filler(int[] target, int offset) {
      this.target = target;
      this.offset = offset;
    }

    @Override
    public void run() {
      int value = Integer.MIN_VALUE + this.offset;
      for (int i = 0; i < this.target.length; i++) {
        this.target[i] = value;
        value += 4;
      }
    }
  }
}
