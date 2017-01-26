public class AllInts6b {
  public static final int NUMBER_OF_INT_VALUES_DIVIDED_BY_8 = 1073741824 / 2;
  public static final int NUM_THREADS = 8;

  public static void main(String[] args) {
    long startTime = System.currentTimeMillis();

    // Allocate space for all 2^32 int values in 8 equally-sized arrays.
    int[] ints1 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];
    int[] ints2 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];
    int[] ints3 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];
    int[] ints4 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];
    int[] ints5 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];
    int[] ints6 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];
    int[] ints7 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];
    int[] ints8 = new int[NUMBER_OF_INT_VALUES_DIVIDED_BY_8];

    Thread thread1 = new Thread(new Filler(ints1, 0));
    Thread thread2 = new Thread(new Filler(ints2, 1));
    Thread thread3 = new Thread(new Filler(ints3, 2));
    Thread thread4 = new Thread(new Filler(ints4, 3));
    Thread thread5 = new Thread(new Filler(ints5, 4));
    Thread thread6 = new Thread(new Filler(ints6, 5));
    Thread thread7 = new Thread(new Filler(ints7, 6));
    Thread thread8 = new Thread(new Filler(ints8, 7));

    thread1.start();
    thread2.start();
    thread3.start();
    thread4.start();
    thread5.start();
    thread6.start();
    thread7.start();
    thread8.start();

    waitForThreadToFinish(thread1);
    waitForThreadToFinish(thread2);
    waitForThreadToFinish(thread3);
    waitForThreadToFinish(thread4);
    waitForThreadToFinish(thread5);
    waitForThreadToFinish(thread6);
    waitForThreadToFinish(thread7);
    waitForThreadToFinish(thread8);

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
        value += NUM_THREADS;
      }
    }
  }
}
