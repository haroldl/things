All of the ints
===============

I came across a beginner's question about int values in Java and I wanted to point out that because int values
are 32 bits each all of the possible int values fit in memory at once on newer computers. But actually doing
this in Java is not as trivial as it appears at first. So here are a series of iterations showing what you
need to do to actually get all int values in memory at the same time in Java.

To start with, you'll need a 64-bit Java implementation so that you can allocate enough memory. There are
`2^32` int values each taking up 4 bytes, so that's 16 GB of memory. To allocate that much memory in a single
process, you need at least 34-bit addresses just for the int values, so with other operating system and Java
overhead, at least a 35-bit machine. Of course, commonly available computers jump from 32-bit to 64-bit, so
you'll need a 64-bit computer, OS and Java implementation.

AllInts1.java
-

First we try to allocate an array large enough to hold all of the possible int values. This won't even compile
because, per the
[Java Language Specification](https://docs.oracle.com/javase/specs/jls/se7/html/jls-15.html#jls-15.10), the
number of elements to allocate must itself be a signed int value.

    $ javac AllInts1.java
    AllInts1.java:4: error: integer number too large: 4294967296
        int[] ints = new int[4294967296];

AllInts2.java
------------------

Okay, so we can do this with 2 arrays, right? Oops - the maximum int value is `2^31 - 1` to allow for zero. So
we need a minimum of 3 arrays. In this attempt, we create 2 arrays with Integer.MAX_VALUE elements, and a
third array with the extra 2 elements we need to have space for every possible int value.

Compiling the code now works but it fails at runtime:

    $ java -cp . AllInts2
    Exception in thread "main" java.lang.OutOfMemoryError: Requested array size exceeds VM limit
	    at AllInts2.main(AllInts2.java:6)

Oh wait - the default Java heap size is too low to allocate this much memory. Let's make sure we have enough
space for these arrays. 20 GB of memory will give us plenty of extra space in addition to the 16 GB of int
values.

    $ java -Xmx20g -cp . AllInts2
    Exception in thread "main" java.lang.OutOfMemoryError: Requested array size exceeds VM limit
	    at AllInts2.main(AllInts2.java:6)

Wait, it's the same problem? It turns out that the Java implementation is allowed to have a platform-specific
limit on the maximum size of an array.

AllInts3.java
-

This version is just looking for the largest array of ints we can allocate.

    $ javac AllInts3.java && java -Xmx20g -cp . AllInts3
    Too many elements: 2147483647
    Too many elements: 2147483646
    Success with numElems = 2147483645

Great! Now we know we can allocate an array that holds almost half of all int values. To make this less likely
to break on a different Java implementation, we will allocate `number of int values / 4` per array and have 4
arrays.

AllInts4.java
-

Let's allocate 4 arrays that together can hold all possible int values.

    $ javac AllInts4.java && java -Xmx20g -cp . AllInts4
    Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
	    at AllInts4.main(AllInts4.java:9)

Wow - the overhead of those int arrays is more than 4 GB of memory. After trying some other values, I found
that 25 GB of heap space does the trick on my Java implementation (and 24 GB fails).

    $ javac AllInts4.java && java -Xmx25g -cp . AllInts4
    Success

AllInts5.java
-

Okay, now let's fill in all of the possible values.

Here's a bit of a gotcha:

    for (long value = Integer.MIN_VALUE; value <= Integer.MAX_VALUE; value++) {

Here we need to use a long to hold the int values so that we can store `Integer.MAX_VALUE + 1` and the for
loop can terminate. If we use an int for the value, the loop never terminates because `Integer.MAX_VALUE + 1
== Integer.MIN_VALUE` due to overflow/wrap-around.

This takes 20 seconds to run on a machine with 64 GB of memory, and 35 seconds on a machine with 16 GB of
memory.

AllInts6.java
-

Here we use multiple threads to fill in the arrays. On a system with 12 CPU cores and 64 GB of memory
this took us from 20 seconds to 3.5 seconds to run. Interestingly, running with 8 threads (see
`AllInts6b.java`) takes the same 3.5 seconds to run which implies that memory bandwidth may have become the
bottleneck. Taking out all of the value assignments, the memory allocation alone takes 2.4 seconds. So maybe
that is worth parallelizing as well.

AllInts7.java
-

By parallelizing the `int[]` allocation, the execution time moved down to 2.0 seconds. When I increased the
number of threads from 8 to 16 (again, on a 12 core machine) the execution time went up to 2.4 seconds, even
when the size of the executor service's thread pool was also increased to 16, so throwing more threads at the
problem is not helping. Running with 12 threads took 2.5 seconds, so 8 threads seems like the most our RAM can
handle and adding more threads just adds more overhead for splitting up the work.

AllInts8.java
-

As a final thought, what if we use the `java.nio.IntBuffer` instead? Is there some optimization going on with
the allocation of buffers that does not apply to arrays? This takes 2.3 seconds. So no, it looks like buffers
really are just wrapping their backing arrays (while providing other useful I/O optimizations).

Conclusions
-

AllInts7 is our winner, allocating space for and filling in every possible Java int value in 2.0 seconds. The
main takeaway from this exercise it that we cannot think of the int values in Java as an infinite set, nor as
a set of values that are too expensive to explore. Brute-force algorithms to test every int value for some
property are very feasible. And if you have 4,000 machines handy you can visit all long values in about a month.
