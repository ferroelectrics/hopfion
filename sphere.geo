SetFactory("OpenCASCADE");

radius = 25;
shift = -0.2;
lccube = 1.0;
lcsphere = 1.0;
corner_delta = 5;
delta = 0;

Box(1) = {-(radius+corner_delta), 
          -(radius+corner_delta), 
          -(radius+shift), 
          (radius+corner_delta)*2, 
          (radius+corner_delta)*2, 
          (radius+shift)*2};
Sphere(2) = {0, 0, 0, radius, -Pi/2, Pi/2, 2*Pi};
BooleanIntersection(3) = { Volume{1}; Delete; }{ Volume{2}; Delete; };

Box(4) = {-(radius+corner_delta+delta), 
          -(radius+corner_delta+delta), 
          -(radius+delta)-shift, 
           (radius+delta+corner_delta)*2, 
           (radius+delta+corner_delta)*2, 
           (radius+delta+shift)*2};
//Rotate {{0, 0, 1}, {0, 0, 0}, Pi/4} {
//  Volume{4};
//}
//Rotate {{1, -1, 0}, {1, -1, 0}, -0.955} {
//  Volume{4};
//}
BooleanDifference(5) = { Volume{4}; Delete; }{ Volume{3}; };

Physical Surface("top") = {6};
Physical Surface("sphere_top") = {1};
Physical Surface("bottom") = {8};
Physical Surface("sphere_bottom") = {3};
Physical Surface("sphere_surface") = {2};
Characteristic Length {3, 5, 9, 8, 4, 6, 10, 7} = lccube;
Characteristic Length {1, 2} = lcsphere;
Physical Volume("sphere") = {3};
Physical Volume("cube") = {5};

