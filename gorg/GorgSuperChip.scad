// Gorg Super-Chip, top piece
// (it's mostly marketing)

// Using this picture as a reference:
// http://dreamworks.wikia.com/wiki/Gorg_Super-Chip

use <Common.scad>;

color("DimGrey") {
      topHoleScale = 0.7;
      mainTopY = 20 * 0.5 * tan(30);
      littleTopY = mainTopY * topHoleScale;
      topToTopDist = mainTopY - littleTopY;
      echo(topToTopDist);

      difference() {
        translate([-10, -10 * tan(30), 7])
        TopPiece();

        translate([-10, -10 * tan(30), 7])
        translate([10 * (1 - topHoleScale), topToTopDist, -0.2])
        scale(topHoleScale)
        triangularPyramid();

        // Cut out space for this top piece to overlap
        // with the bottom piece for gluing together.
        // This hole has sideLength=16 and the connector
        // has sideLength=14 to allow some gap for glue.
        sideLength = 16;
        translate([-10, -10 * tan(30), 7])
        scale([1,1,0.4])
        translate([2,1,-5])
        trianglularConnector(sideLength=sideLength);

        // Cut out some wedges to create lines of green light :-)
        //wedgeThing(theta1XY=-115, theta1Z=20,
        //  theta2XY=-85, theta2Z=70, deltaZ=12);
        for (rotationAngle = [0,120,240]) {
        rotate([0,0,rotationAngle])
        translate([-2,-5,15])
        rotate([-30,20,-20])
        scale([0.2,1,1])
        translate([-5,-5,-5])
        cube(10);
        }
    }
}
