// Gorg Super-Chip, bottom piece
// (it's mostly marketing)

// Using this picture as a reference:
// http://dreamworks.wikia.com/wiki/Gorg_Super-Chip

use <Common.scad>;

color("DimGrey") {
    holeScale = 0.7;

    translate([0,0,-2])
    scale(holeScale)
    difference() {
        translate([-10, -10 * tan(30), 0])
        trianglularConnector();

        scale([holeScale, holeScale, 1.1])
        translate([-10, -10 * tan(30), 0])
        trianglularConnector();
    }

    difference() {
        translate([-10, -10 * tan(30), 0])
        BottomPiece();

        scale(holeScale)
        translate([-10, -10 * tan(30), 0])
        BottomPiece();
    }
}
