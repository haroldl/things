// Gorg super chip
// (it's mostly marketing)

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
    faces=[ [0,1,3],[1,2,3],[0,2,3],[0,1,2]]);
}

color("DimGrey") {
  normalHeight = sqrt(10 * 10 + 10 * 10);

  /*
  // The taller bottom pyramid
  polyhedron(
    // the four points at base
    points=[ [10,10,0],[10,-10,0],[-10,-10,0],[-10,10,0], 
    // the apex point
             [0,0, -2 * normalHeight]  ],
    // each triangle side
    faces=[ [0,1,4],[1,2,4],[2,3,4],[3,0,4],
    // two triangles for square base
                [1,0,3],[2,1,3] ]);

  // The smaller top pyramid
  polyhedron(
    // the four points at base
    points=[ [10,10,0],[10,-10,0],[-10,-10,0],[-10,10,0], 
    // the apex point
             [0,0, 1.2 * normalHeight]  ],
    // each triangle side
    faces=[ [0,1,4],[1,2,4],[2,3,4],[3,0,4],
    // two triangles for square base
                [1,0,3],[2,1,3] ]);
*/

  // 75% scaled smaller pyramid that will be wedged into the top face
  //translate([17.5,0,0])
  //rotate([0,-90,0])
  triangularPyramid();
  translate([20,0,0])
  triangularPyramid(sideLength=30);
}