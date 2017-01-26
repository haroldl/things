import java.util.*;
import java.util.concurrent.*;

public class AllInts7 {
  public static final int NUMBER_OF_INT_VALUES_PER_THREAD = 1073741824 / 2;
  public static final int NUM_THREADS = 8;

  public static void main(String[] args) {
    long startTime = System.currentTimeMillis();

    int numCpuCores = Runtime.getRuntime().availableProcessors();
    ExecutorService executorService = Executors.newFixedThreadPool(numCpuCores);

    List<Future<int[]>> parts = new ArrayList<>();
    for (int partNum = 0; partNum < NUM_THREADS; partNum++) {
      Filler filler = new Filler(NUMBER_OF_INT_VALUES_PER_THREAD, partNum);
      parts.add(executorService.submit(filler));
    }

    List<int[]> results = new ArrayList<>(NUM_THREADS);
    for (Future<int[]> future : parts) {
      try {
        results.add(future.get());
      } catch (ExecutionException | InterruptedException e) {
        throw new RuntimeException(e);
      }
    }

    executorService.shutdown();

    long elapsedTime = System.currentTimeMillis() - startTime;
    System.out.println("Success, took " + elapsedTime + " milliseconds.");
  }

  public static class Filler implements Callable<int[]> {
    private final int targetSize;
    private final int offset;

    public Filler(int targetSize, int offset) {
      this.targetSize = targetSize;
      this.offset = offset;
    }

    @Override
    public int[] call() {
      int[] target = new int[this.targetSize];
      int value = Integer.MIN_VALUE + this.offset;
      for (int i = 0; i < target.length; i++) {
        target[i] = value;
        value += NUM_THREADS;
      }
      return target;
    }
  }
}
