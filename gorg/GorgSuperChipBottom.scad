// Gorg Super-Chip, bottom piece
// (it's mostly marketing)

// Using this picture as a reference:
// http://dreamworks.wikia.com/wiki/Gorg_Super-Chip

use <Common.scad>;

color("DimGrey") {
    holeScale = 0.7;

    difference() {
        translate([-10, -10 * tan(30), 0])
        BottomPiece();

        scale(holeScale)
        translate([-10, -10 * tan(30), 0])
        BottomPiece();
    }
}
