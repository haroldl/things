// Gorg Super-Chip, top piece
// (it's mostly marketing)

// Using this picture as a reference:
// http://dreamworks.wikia.com/wiki/Gorg_Super-Chip

use <Common.scad>;

translate([-10, -10 * tan(30), 7])
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

        // Cut out space for this top piece to overlap
        // with the bottom piece for gluing together.
        // This hole has sideLength=16 and the connector
        // has sideLength=14 to allow some gap for glue.
        sideLength = 16;
        scale([1,1,0.4])
        translate([2,1,-5])
        trianglularConnector(sideLength=sideLength);        
    }

}
