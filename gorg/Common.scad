// Create a 3-d pyramid with a triangular base (thus 4 sides/faces).
module triangularPyramid(sideLength=20) {
    // For a 4-sided pyramid, make the maximum y coordinate such that
    // each side of the pyramid is length 20.
    triangularHeight = sideLength * sin(60);
    // Make the y coordinate for the top of the pyramid the center of
    // an equilateral triangle on the xy plane with sides of length 20.
    topY = sideLength * 0.5 * tan(30);
    // To find the topZ height, start from [-triangularHeight, 0]
    // (viewing yz plane, so x coordinates make no sense)
    // and move up (positive z direction) 20 units at an angle to intersect
    // at (-topY, topZ).
    // So (triangularHeight - topY)^2 + (topZ)^2 == 20^2
    // and we solve for topZ
    deltaYForTop = triangularHeight - topY;
    topZ = sqrt(sideLength * sideLength - deltaYForTop * deltaYForTop);

    polyhedron(
        // the three points at base
        points= [ [0,0,0],[sideLength,0,0],[sideLength * 0.5, triangularHeight, 0],
        // the apex point
                  [sideLength * 0.5, topY, topZ]  ],
        // each triangle side
        faces=[ [0,3,1],[1,3,2],[2,3,0],[0,1,2] ]);
}

module trianglularConnector(sideLength = 20) {
    height = sideLength * sin(60);

    polyhedron(
        points = [ [0,0,-5], [sideLength,0, -5], [sideLength * 0.5, height, -5],
                   [0,0,10], [sideLength,0, 10], [sideLength * 0.5, height, 10] ],
        faces = [ /* bottom */ [0, 1, 2], /* top */ [3, 5, 4],
            /* 3 sides: */ [0, 3, 4, 1], [1, 4, 5, 2], [2, 5, 3, 0] ]);
}

function polarToXYZ(thetaXY, thetaZ, radius) =
    [ radius * cos(thetaXY) * cos(thetaZ),
      radius * sin(thetaXY) * cos(thetaZ),
      radius * sin(thetaZ) ];

//
// Create a wedge that goes from the origin out to form a line between two
// points. The points are given in polar coordinates:
// * thetaXY is the rotation about the Z axis
// * thetaZ is the rotation up from the XY plane
//
module wedgeThing(theta1XY=0, theta1Z=0, theta2XY=0, theta2Z=45, deltaZ=0) {
    // Figure out an orthogonal vector to the line so that we can give it
    // some width:
    dXY = theta2XY - theta1XY;
    dZ = theta2Z - theta1Z;
    orthoVec = -0.15 * [dZ, dXY];

    translate([0,0,deltaZ])
    polyhedron(points=[[0,0,0],
            polarToXYZ(-0.15 * dZ + theta1XY, -0.15 * dXY + theta1Z, 30),
            polarToXYZ( 0.15 * dZ + theta1XY,  0.15 * dXY + theta1Z, 30),
            polarToXYZ( 0.15 * dZ + theta2XY,  0.15 * dXY + theta2Z, 30),
            polarToXYZ(-0.15 * dZ + theta2XY, -0.15 * dXY + theta2Z, 30)],
        faces = [[1,2,3,4], [0,2,1], [0,3,2], [0,4,3], [0,1,4]]);
}

module TopPiece() {
    // The top
    scale([1, 1, 1.2]) // is stretched out vertically a bit
    triangularPyramid();

    //
    // 3 little pyramids sticking out of the top:
    //
    littleScale = 0.6;

    // 1. is on the x axis
    translate([10 * (1 - littleScale), 0, 8])
    scale(littleScale)
    scale([1, 1, 1.2])
    triangularPyramid();

    mainTopY = 20 * 0.5 * tan(30);
    littleTopY = mainTopY * littleScale;
    topToTopDist = mainTopY - littleTopY;

    // 2. is rotated clockwise 120 degrees around the top-to-bottom line
    //    To do that rotation, translate the pyramid to be centered over 0,0,z
    //    then rotate, then untranslate.
    //    However, rotating a triangle by 120 degrees is the same triangle, so
    //    we will just move the thing a little off in the -x, +y direction :-)
    translate([-1 * topToTopDist * cos(30), topToTopDist * (1 + sin(30)), 0])
    translate([10 * (1 - littleScale), 0, 8])
    scale(littleScale)
    scale([1, 1, 1.2])
    triangularPyramid();

    // 3. is rotated counter-clockwise 120 degrees around the top-to-bottom line
    //    To do that rotation, translate the pyramid to be centered over 0,0,z
    //    then rotate, then untranslate.
    //    However, rotating a triangle by 120 degrees is the same triangle, so
    //    we will just move the thing a little off in the +x, +y direction :-)
    translate([topToTopDist * cos(30), topToTopDist * (1 + sin(30)), 0])
    translate([10 * (1 - littleScale), 0, 8])
    scale(littleScale)
    scale([1, 1, 1.2])
    triangularPyramid();
}

module BottomPiece() {
    // The bottom
    scale([1, 1, 1.5]) // is stretched out vertically a bit
    translate([20,0,0])
    rotate([0,180,0])
    triangularPyramid();
}