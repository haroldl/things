import java.nio.*;
import java.util.*;
import java.util.concurrent.*;

public class AllInts8 {
  public static final int NUM_THREADS = 8;

  // 2^32 / NUM_THREADS
  public static final int NUMBER_OF_INT_VALUES_PER_THREAD = 536870912;

  public static void main(String[] args) {
    long startTime = System.currentTimeMillis();

    int numCpuCores = Runtime.getRuntime().availableProcessors();
    ExecutorService executorService = Executors.newFixedThreadPool(numCpuCores);

    List<Future<IntBuffer>> parts = new ArrayList<>();
    for (int partNum = 0; partNum < NUM_THREADS; partNum++) {
      Filler filler = new Filler(NUMBER_OF_INT_VALUES_PER_THREAD, partNum);
      parts.add(executorService.submit(filler));
    }

    List<IntBuffer> results = new ArrayList<>(12);
    for (Future<IntBuffer> future : parts) {
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

  public static class Filler implements Callable<IntBuffer> {
    private final int targetSize;
    private final int offset;

    public Filler(int targetSize, int offset) {
      this.targetSize = targetSize;
      this.offset = offset;
    }

    @Override
    public IntBuffer call() {
      IntBuffer target = IntBuffer.allocate(this.targetSize);
      int value = Integer.MIN_VALUE + this.offset;
      for (int i = 0; i < this.targetSize; i++) {
        // Buffer.put advances the position in the buffer automatically.
        target.put(value);
        value += NUM_THREADS;
      }
      return target;
    }
  }
}
