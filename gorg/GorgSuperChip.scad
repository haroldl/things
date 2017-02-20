// Gorg Super-Chip, top piece
// (it's mostly marketing)

// Using this picture as a reference:
// http://dreamworks.wikia.com/wiki/Gorg_Super-Chip

use <Common.scad>;

translate([-10, -10 * tan(30), 10])
color("DimGrey") {
      topHoleScale = 0.7;
      mainTopY = 20 * 0.5 * tan(30);
      littleTopY = mainTopY * topHoleScale;
      topToTopDist = mainTopY - littleTopY;
      echo(topToTopDist);
      difference() {
        TopPiece();

        translate([10 * (1 - topHoleScale), topToTopDist, -0.2])
        scale(topHoleScale)
        triangularPyramid();
    }
}
