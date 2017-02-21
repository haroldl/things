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

        // Circular holes in the central trench for light:
        for(rotation = [120,240]) {
            rotate([0,0,rotation])
            translate([0,-4,5])
            rotate([90,0,0])
            cylinder(h=50, r1=1, r2=1);

            rotate([0,0,rotation])
            translate([5,-4,5])
            rotate([90,0,0])
            cylinder(h=50, r1=1, r2=1);

            rotate([0,0,rotation])
            translate([-5,-4,5])
            rotate([90,0,0])
            cylinder(h=50, r1=1, r2=1);
        }

        // Rectangular gap in the central trench for an on/off switch:
        switchSize = 4;
        translate([-0.5 * switchSize,-9.5,4])
        scale([2,1.8,1])
        cube(switchSize);
    }

    difference() {
        translate([-10, -10 * tan(30), 0])
        BottomPiece();

        scale(holeScale)
        translate([-10, -10 * tan(30), 0])
        BottomPiece();
    }
}
