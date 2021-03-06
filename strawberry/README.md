
Harold Lee
harold@hotelling.net

Strawberry Fields
=================

This is my solution to the Strawberry Fields puzzle from

    http://www.itasoftware.com/careers/puzzle_archive.html

Now that these questions are no longer used, I feel it's fair for me
to post my code publically. I really enjoyed working on this and thank
them for posting such an interesting puzzle.

Here is their description of the problem:

> Strawberry Fields
> 
> Strawberries are growing in a rectangular field of length and width at
> most 50. You want to build greenhouses to enclose the
> strawberries. Greenhouses are rectangular, axis-aligned with the field
> (i.e., not diagonal), and may not overlap. The cost of each greenhouse
> is $10 plus $1 per unit of area covered.
> 
> Write a program that chooses the best number of greenhouses to build,
> and their locations, so as to enclose all the strawberries as cheaply
> as possible. Heuristic solutions that may not always produce the
> lowest possible cost will be accepted: seek a reasonable tradeoff of
> efficiency and optimality.
> 
> Your program must read a small integer 1 ≤ N ≤ 10 representing the
> maximum number of greenhouses to consider, and a matrix representation
> of the field, in which the '@' symbol represents a strawberry. Output
> must be a copy of the original matrix with letters used to represent
> greenhouses, preceded by the covering's cost. Here is an example
> input-output pair:
> 
>     Input
>     4
>     ..@@@@@...............
>     ..@@@@@@........@@@...
>     .....@@@@@......@@@...
>     .......@@@@@@@@@@@@...
>     .........@@@@@........
>     .........@@@@@........
> 
>     Output
>     90
>     ..AAAAAAAA............
>     ..AAAAAAAA....CCCCC...
>     ..AAAAAAAA....CCCCC...
>     .......BBBBBBBCCCCC...
>     .......BBBBBBB........
>     .......BBBBBBB........
> 
> In this example, the solution cost of $90 is computed as (10+8*3) +
> (10+7*3) + (10+5*3).
>  
> Run your program on the 9 sample inputs found in this file and report
> the total cost of the 9 solutions found by your program, as well as
> each individual solution.

Terminology:
============

* board - A board is a problem to be solved, read from the input file, consisting 
          of a map of a field with strawberries in it to be covered and a maximum 
          number of greenhouses allowed.

          (defstruct board ...)

          Local variable names: board, b

* house - A rectangular greenhouse, defined by the coordinates of the upper left 
          and lower right corners.

          (defstruct house ...)

          Local variable names: house, h, h1, h2

* layout - A list of houses that cover all strawberries for a board.

          Local variable names: layout

Algorithm:
==========

The boards are parsed from the input file.

* `#'read-boards` : open the file and read in each board, also parse each one 
                    with `#'parse-board`

For each board:

Start with a single layout with one house per strawberry, giving us, say, n 
houses to start with.

* `#'parse-board` : takes a board and provides a layout with one greenhouse per 
                    strawberry, parsed from the text from the file

Now we don't have to think about strawberries, only ways to reduce the number of 
houses, at the risk of enclosing space where there was no strawberry (creating 
wasted greenhouse space).

Subject to some pruning of the search space, try merging different pairs of 
houses together in different ways to get several layouts with less houses. This 
is called a reduction.

* `#'merge-houses` : takes two houses and returns a new house that encloses both

* `#'merge-waste`  : how much space is wasted by the merge, e.g.

        ....                          ....
        ..A.                          .AA.
        .B.. has the single reduction .AA. with 2 waste.
        ....                          ....

Each of those new layouts can be further reduced in several ways, and this 
reduction of layouts can be seen as exploring a tree where the root is the 
initial layout (one house per strawberry) and the leaf nodes are all the layout 
with a (the same) single greenhouse bounding all strawberries using minimal 
space.

Our goal is to walk the tree to find the layout with the minimal cost of those 
with a low enough number of greenhouses to qualify.

Because each reduction must reduce the number of houses by at least 1, the 
maximum depth of the tree is n. However, the number of reductions possible for 
a layout with m houses could be as large as `(m * (m - 1) / 2)`.

The search space is very wide, but not very deep. A depth first search will 
require less intermediate storage for the "to do" list of layouts to consider 
reducing.

* `#'depth-first-search` : takes a board and searches for the best layout of 
                            greenhouses for it.

Reducing the search space:
==========================

A bit tricky because descending in the tree usually drops the cost because it 
reduces the number of greenhouses. Also, one reduction may increase the cost, 
but enble other cost-reducing merges to take place or get the number of total 
greenhouses below the maximum number allowed.

* Only consider reductions where merging two greenhouses won't overlap with 
  another greenhouse. This also protects us from generating layouts where 
  greenhouses overlap.

  `#'safe-merges` : filter a list of merges and return only those that don't 
                    overlap with another house in the layout.

* Perform trivial merges regularly without trying each combination (but don't 
  merge contested houses). These are a no-brainer because the cost function 
  favors fewer houses if no extra space is wasted (actually, 9 or less extra 
  spaces are wasted).

  `#'trivial-merges` : perform all such merges possible, e.g.

        ....             ....
        .A..             .A..
        .B.. will become .A.. via trivial merge
        .C..             .A..

        but

        ....
        .A..
        .BC. will not change because B is contested
        ....

      i.e. {A,B} or {B,C} can be trivially merged, but {A,C} cannot.

* Only consider merges with least waste at each iteration of reduction. This 
  means that if there are several possible reductions of a layout, only those 
  with the least amount of wasted space will be considered.

  `#'least-waste-merges` : filter a set of candidate merges leaving only those 
                           which introduce the least amount of wasted space.



Performance
===========

These numbers are the result of running under CLisp on a 1.6 GHz machine with 
1 GB of memory. LispWorks performed so much better (better compiler? compiled 
to machine code?) that I ended up using it. In LispWorks, the whole thing runs 
in 4:53.

I have since added the timings for OpenMCL on a Mac Mini 1.42 GHz G4 with 
512 MB RAM. Given the jump from board 7 to board 8, I'm glad I didn't wait 
around for board 8 to finish in CLisp. Despite the CLisp teams' suggestion 
that their performance is competitive, it looks like even an open source 
compiled Lisp does much better. For a same-machine comparison, I've also 
added LispWorks (Mac), run on the same Mini.

The really strange thing is that LispWorks reports that it checked far fewer 
layouts than CLisp or OpenMCL. Don't know why... but maybe LispWorks is getting 
lucky with the order that it processes entries via MAPHASH? 
 - Though in some cases OpenMCL checks fewer layouts but still runs longer.
 - I'm trying to find the best case here, how could we skip layouts?

For map \#8, we start to see significant page faults, which could be the reason 
performance jumps off a cliff.

                  Thinkpad T40             Mac Mini
                 1.6 GHz / 1 GB       1.42 GHz / 0.5 GB
              /-----------------\ /---------------------\
     Board # | CLisp | LispWorks | OpenMCL   | LispWorks
    ---------+-------+-----------+-----------+-----------
        0    |  0:01 |           |     0.007 |    0.003
        1    |  1:15 |           |     6.342 |    2.393
        2    |  0:02 |           |     0.595 |    0.167
        3    |  0:03 |           |     1.312 |    0.258
        4    |  7:47 |           |    34.431 |    6.184
        5    |  2:57 |           |    13.991 |    2.513
        6    |  0:01 |           |     0.109 |    0.038
        7    | 14:04 |           |    42.974 |   12.053
        8    |     ? |           | 24:30.316 | 5:49.980
    ---------+-------+-----------+-----------+-----------
     Total   |     ? |     4:53  | 26:10.077 | 6:13.599



My solutions:
=============

sum of costs:
(+ 41 62 71 181 184 186 185 196 359)
1465

    41
    .............
    .............
    .............
    ...AAAA......
    ...AAAA......
    ...AAAA......
    .......BBB...
    .......BBB...
    .......BBB...
    .............

    62
    .............
    ..AAAAAA.....
    ..AAAAAA.....
    ..AAAAAA.....
    ..AAAAAA.....
    ..AAAAAA.....
    ..AAAAAA.....
    ..........BBB
    ..........BBB

    71
    .........A...
    .........A...
    BBBBBBBBBA...
    ..C......A...
    ..C......A...
    ..C......A...
    ..CDDDDDDDDDD
    ..C..........
    ..C..........

    181
    .........................
    ..GGGGGGGGGGGGGGGGGGGG...
    ..GGGGGGGGGGGGGGGGGGGG...
    ..CC.................B...
    ..CC.................B...
    ..CC.......DDD.......B.A.
    ..CC.......DDD.......B...
    ..CC...FFFFFFFFFFFFFFB...
    ..CC...FFFFFFFFFFFFFFB...
    ..CC.......EEE.......B...
    ..CC.......EEE.......B...
    ..CC.................B...
    ..CC.................B...
    .........................

    184
    .........................
    ......DDDDDDDDDDDDD......
    .........................
    .....F........CCCCCCC....
    .....F........CCCCCCC....
    .....F......A.CCCCCCC....
    .....F......A.CCCCCCC....
    .....F......A.CCCCCCC....
    .....F......A.CCCCCCC....
    .....F......A............
    ..EEEEEE....A............
    ..EEEEEE....A............
    ..EEEEEE....A............
    ..EEEEEE....A............
    ..EEEEEE.................
    ..BBBBBBBBBBBBBBBBBBBBBBB

    186
    ........................................
    ........................................
    ...EEEEEE...............................
    ...EEEEEE...............................
    ...EEEEEE...............................
    ...EEEEEE.........DDDDDDDDDD............
    ...EEEEEE.........DDDDDDDDDD............
    ..................DDDDDDDDDD............
    ..................DDDDDDDDDD............
    .............CCCCCDDDDDDDDDD............
    .............CCCCCDDDDDDDDDD............
    ........BBBBBBBBBBBB....................
    ........BBBBBBBBBBBB....................
    ........AAAAAA..........................
    ........AAAAAA..........................
    ........................................
    ........................................
    ........................................

    185
    ........................................
    ..CC.E.GGG..............................
    ..CC.E.GGG............BBBB..............
    ..CC.E.GGG............BBBB..............
    ..CC.E.GGG..............................
    ..CC.E.GGG..............DDDD............
    ..CC.E..................DDDD............
    ..CC.E..................................
    ..CC.E..................................
    ..CC.E..............FFFFFFFF............
    ..CC.E..............FFFFFFFF............
    ..CC.E..............FFFFFFFF............
    ..CC.E..............FFFFFFFF............
    ..CC.E..................................
    ..CC.E................AAAA..............
    ..CC.E..................................
    ..CC.E..................................
    ........................................

    196
    DDDDD...................................
    DDDDD...................................
    DDDDD...................................
    DDDDD...................................
    DDDDD...................................
    DDDDD...........BBBBBBBBBBB.............
    DDDDD...........BBBBBBBBBBB.............
    ....................FFFF................
    ....................FFFF................
    ....................FFFF................
    ....................FFFF................
    ....................FFFF................
    ...............EEEEEEEEEEEEEE...........
    ...............EEEEEEEEEEEEEE...........
    .......CCCCCCCCCCCCCCCCCCCCCC...........
    .......AAAAAAAAA........................
    ........................................
    ........................................
    ........................................

    359
    ...............GGGGGGGGG................
    ...............GGGGGGGGG................
    ..........DDDDDDDDDDDDDDDDDDD...........
    ..........DDDDDDDDDDDDDDDDDDD...........
    ..........DDDDDDDDDDDDDDDDDDD...........
    .......III...................HHH........
    .......III...................HHH........
    .......III....BBBBBBBBBBBB...HHH........
    .......III....BBBBBBBBBBBB...HHH........
    .......III...................HHH........
    .......III...................HHH........
    .......III.........EE........HHH........
    .......III.........EE........HHH........
    .......III...................HHH........
    .......III...................HHH........
    .......III.....CCCCCCCCC.....HHH........
    .......III.....CCCCCCCCC.....HHH........
    .......III...................HHH........
    .......III...................HHH........
    .......III...................HHH........
    ..........AAAAA.........JJJJJ...........
    ..........AAAAA.........JJJJJ...........
    ..........AAAAA.........JJJJJ...........
    ...............FFFFFFFFF................
    ...............FFFFFFFFF................

