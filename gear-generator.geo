SetFactory("OpenCASCADE");

General.SaveOptions = 0;

DefineConstant[module = {2, Name "Gear Parameters/Module"}];
DefineConstant[number_of_teeth = {25, Name "Gear Parameters/Number of teeth"}];

DefineConstant[thickness = {5, Name "Gear Parameters/Thickness"}];
DefineConstant[shaft_diameter = {3, Name "Gear Parameters/Shaft diameter"}];
DefineConstant[pressure_angle = {20, Name "Gear Parameters/Pressure angle"}];

DefineConstant[BREP_export = {0, Choices{0, 1}, Name "Export to CAD format/BREP"}];
DefineConstant[STEP_export = {0, Choices{0, 1}, Name "Export to CAD format/STEP"}];
DefineConstant[STL_export = {0, Choices{0, 1}, Name "Export to CAD format/STL"}];

pitch = 180 / number_of_teeth;
fillet_radius = 0.3 * module;

// Sketch_1

    Point(1) = {0, 0, 0};
    origin[] = Point{1};

    // Circle 1 Pitch Diameter
    pitch_diameter = module * number_of_teeth;
    pitch_radius = pitch_diameter / 2;
    Circle(1) = {origin[0], origin[1], origin[2], pitch_radius};

    // Circle 2 Outside Diameter
    outside_diameter = (number_of_teeth + 2) * module;
    outside_radius = outside_diameter / 2;
    Circle(2) = {origin[0], origin[1], origin[2], outside_radius};

    // Circle 3 Root Diameter
    root_diameter = module * ((module >= 1.25) ? 2.25 : 2.4);
    root_radius = outside_radius - root_diameter;
    Circle(3) = {origin[0], origin[1], origin[2], root_radius};

    // Extrusion_1
    // NOTE: Extrusion_1 begins after Arc1.
    Curve Loop(1) = {2};

// Sketch_2

    // Circle 4 Offset1
    offset1 = (outside_diameter / 2) + 1;
    Circle(4) = {origin[0], origin[1], origin[2], offset1};

    // Line1
    Line(5) = {1, 5};

    // Arc1
    // NOTE: Arc1 begins after Arc2.

    // Line2
    Translate {0, Sin(Pi / (2 * number_of_teeth)) * number_of_teeth, 0} { Duplicata{Point{2};} }
    Symmetry {0, 1, 0} {Duplicata{Point{6};}}
    Extrude {-20, 0, 0} {Point{6, 7};}
    BooleanDifference {Curve{6}; Curve{7}; Delete;} {Curve{1};}
    Delete { Curve{6, 7, 8, 9}; Point{6, 8, 9, 11}; }
    // Line(6) = {7, 10};

    // Line3
    // NOTE: Line3 is unused.

    // Line4
/*     Extrude {20, 0, 0} {Point{7};}
    point7[] = Point{7};
    Rotate { {0, 0, 1}, {point7[0], point7[1], point7[2]}, (20 * (Pi/180)) } { Line{7}; }
    Delete { Curve{7}; Point{11}; }
    point13[] = Point{13};
    Rotate { {0, 0, 1}, {point13[0], point13[1], point13[2]}, Pi } { Duplicata{Point{12};} }
    Line(7) = {12, 13}; Line(8) = {13, 14};
    BooleanDifference {Curve{4};} {Curve{7};}
    BooleanDifference {Curve{5};} {Curve{8};}
    Delete { Curve{7, 8, 9, 10}; Point{12, 14}; }
    Line(7) = {15, 16}; */

    // Line5
/*     Point(17) = {origin[0], origin[1], origin[2]};
    Line(8) = {17, 3};
    Rotate { {0, 0, 1}, {origin[0], origin[1], origin[2]}, -Pi / number_of_teeth } { Line{8}; } */

    // Line6
/*     Rotate { {0, 0, 1}, {origin[0], origin[1], origin[2]}, -Pi / number_of_teeth } { Duplicata{Point{10};} }
    Line(13) = {10, 19}; */

    // Arc2
    Point(20) = {origin[0], origin[1], origin[2]};
    Rotate { {0, 0, 1}, {origin[0], origin[1], origin[2]}, ((outside_radius * 2) * Sin(Pi / number_of_teeth)) * (Pi/180) } { Duplicata{Point{5};} }
/*     Line(14) = {20, 21};
    BooleanDifference {Curve{4};} {Curve{14};}
    Delete { Curve{14, 16}; } */

    // Arc3
    Point(23) = {origin[0], origin[1], origin[2]};
    Rotate { {0, 0, 1}, {origin[0], origin[1], origin[2]}, ((root_radius) * Sin(Pi / number_of_teeth)) * (Pi/180) } { Duplicata{Point{4};} }
/*     Line(17) = {23, 24};
    BooleanDifference {Curve{3};} {Curve{17};}
    Delete { Curve{17, 19}; } */

    // Arc1
    Spline(25) = {21, 7, 24};

    // Mirror1
    Symmetry {0, 1, 0} {Duplicata{Curve{25};}}
    BooleanDifference {Curve{3, 4}; Delete;} {Curve{25, 26};}
    Delete { Curve{28, 31}; }

    Delete { Curve{5}; }

// Extrusion_1
    // Shaft Diameter
    Circle(33) = {origin[0], origin[1], origin[2], shaft_diameter};

    Curve Loop(2) = {33};
    Plane Surface(1) = {1, 2};
    Extrude{0, 0, thickness} {Surface{1};}

// Extrusion_2
    Curve Loop(7) = {25, 27, 29, 26, 32, 30};
    Plane Surface(5) = {7};
    Translate {0, 0, -1} { Surface{5}; }
    Extrude{0, 0, (thickness + 2)} {Surface{5};}

// Fillet_1
    Fillet {2} {45, 49} {fillet_radius}
    Plane Surface(16) = Duplicata{ Surface{6}; };
    Delete { Surface{16}; }
    Recursive Delete { Volume{2}; }
    Delete { Curve{1}; Point{1, 2, 7, 10, 20, 23};}

// Angular_Copy_1
    Fillet_1[] = {15};

    For t In {1:(number_of_teeth - 1)}
        Angular_Copy_1[] = Rotate {{0, 0, 1}, {0, 0, 0}, t * (2 * Pi / number_of_teeth)} { Duplicata{Surface{15};} };
        Fillet_1[] += Angular_Copy_1[0];
    EndFor

    Extrude {0, 0, (-thickness - 2)} { Surface{Fillet_1[]}; }

// Cut
    AngularCopy_1_1[] = Volume "*";
    AngularCopy_1_1[] -= {1};
    BooleanDifference { Volume{1}; Delete; } { Volume{AngularCopy_1_1[]}; Delete; }

// Info
    Printf("Pitch: [radius: %g] [diameter: %g]", pitch_radius, (pitch_radius * 2));
    Printf("Outside: [radius: %g] [diameter: %g]", outside_radius, (outside_radius * 2));
    Printf("Root: [radius: %g] [diameter: %g]", root_radius, (root_radius * 2));
    Printf("Offset1: [radius: %g] [diameter: %g]", offset1, (offset1 * 2));

// Export
    If(BREP_export == 1)
        Printf("Exporting to BREP");
        Save Sprintf("exported/%g-tooth-gear.brep", number_of_teeth);
        SetNumber("Export to CAD format/BREP", 0);
    EndIf

    If(STEP_export == 1)
        Printf("Exporting to STEP");
        Save Sprintf("exported/%g-tooth-gear.step", number_of_teeth);
        SetNumber("Export to CAD format/STEP", 0);
    EndIf

    If(STL_export == 1)
        Printf("Exporting to STL");
        Save Sprintf("exported/%g-tooth-gear.stl", number_of_teeth);
        SetNumber("Export to CAD format/STL", 0);
    EndIf
