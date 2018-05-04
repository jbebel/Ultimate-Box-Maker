/*//////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -
              -   http://heartygfx.blogspot.com    -
              -       OpenScad Parametric Box      -
              -         CC BY-NC 3.0 License       -
////////////////////////////////////////////////////////////////////
12/02/2016 - Fixed minor bug
28/02/2016 - Added holes ventilation option
09/03/2016 - Added PCB feet support, fixed the shell artefact on export mode.

*/////////////////////////// - Info - //////////////////////////////

// All coordinates are starting as integrated circuit pins.
// From the top view :

//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB


////////////////////////////////////////////////////////////////////


////////// - Paramètres de la boite - Box parameters - /////////////


/* [Box dimensions] */
// - Longueur - Length
Length = 160;
// - Largeur - Width
Width = 170;
// - Hauteur - Height
Height = 100;
// - Epaisseur - Wall thickness
Thick = 2; //[2:5]


/* [Box options] */
// - Diamètre Coin arrondi - Filet diameter
Filet = 2; //[0.1:12]
// - lissage de l'arrondi - Filet smoothness
Resolution = 50; //[1:100]
// - Tolérance - Tolerance (Panel/rails gap)
m = 0.9;
// Pieds PCB - PCB feet (x4)
PCBFeet = 1; // [0:No, 1:Yes]
// - Decorations to ventilation holes
Vent = 1; // [0:No, 1:Yes]
// - Decoration-Holes width (in mm)
Vent_width = 1.5;


/* [PCB_Feet] */
//All dimensions are from the center foot axis
// - Coin bas gauche - Low left corner X position
PCBPosX = 7;
// - Coin bas gauche - Low left corner Y position
PCBPosY = 6;
// - Longueur PCB - PCB Length
PCBLength = 70;
// - Largeur PCB - PCB Width
PCBWidth = 50;
// - Heuteur pied - Feet height
FootHeight = 10;
// - Diamètre pied - Foot diameter
FootDia = 8;
// - Diamètre trou - Hole diameter
FootHole = 3;


/* [STL element to export] */
//Coque haut - Top shell
TShell = 0; // [0:No, 1:Yes]
//Coque bas- Bottom shell
BShell = 1; // [0:No, 1:Yes]
//Panneau avant - Front panel
FPanL = 1; // [0:No, 1:Yes]
//Panneau arrière - Back panel
BPanL = 1; // [0:No, 1:Yes]


/* [Hidden] */
// - Couleur coque - Shell color
Couleur1 = "Orange";
// - Couleur panneaux - Panels color
Couleur2 = "OrangeRed";
// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick = Vent ? Thick*2 : Thick;
// - Depth decoration
Dec_size = Vent ? Thick*2 : 0.8;


/* Generic rounded box

    Produces a box of the specified dimensions. Corners are rounded according to
    Filet and Resolution parameters.
    
    Arguments:
    a: The length of the box. Defaults to "Length" parameter.
    b: The width of the box. Defaults to the "Width" parameter.
    c: The height of the box. Defaults to the "Height" parameter.   
*/
module RoundBox($a=Length, $b=Width, $c=Height) { // Cube bords arrondis
    translate([0, Filet, Filet]) {
        minkowski() {
            cube([$a - Length/2, $b - 2*Filet, $c - 2*Filet]);
            rotate([0, 90, 0]) {
                cylinder(Length/2, r=Filet, $fn=Resolution);
            }
        }
    }
} // End of RoundBox Module


/*  Coque: Shell module

    This module takes no arguments, but produces a box shell. This is half the box,
    including slots for end panels, rounded corners according to Filet and Resolution,
    wall fixation legs and holes, and vents/decorations according to parameters.
*/
module Coque() { //Coque - Shell
    Thick = Thick*2;
    difference() {
        difference() { //sides decoration
            union() {
                difference() { //soustraction de la forme centrale - Substraction Fileted box
                    difference() { //soustraction cube median - Median cube slicer
                        union() { //union
                            difference() { //Coque
                                RoundBox();
                                translate([Thick/2, Thick/2, Thick/2]) {
                                    RoundBox($a=(Length - Thick), $b=(Width - Thick), $c=(Height - Thick));
                                }
                            } //Fin diff Coque
                            difference() { //largeur Rails
                                translate([Thick + m, Thick/2, Thick/2]) { // Rails
                                     RoundBox($a=(Length - (2*Thick + 2*m)), $b=(Width - Thick), $c=(Height - Thick*2));
                                } //fin Rails
                                // +0.1 added to avoid the artefact
                                translate([((Thick + m/2) * 1.55), Thick/2, Thick/2 + 0.1]) {
                                     RoundBox($a=(Length - ((Thick*3) + 2*m)), $b=(Width - Thick), $c=(Height - Thick));
                                }
                            } //Fin largeur Rails
                        } //Fin union
                        translate([ -Thick, -Thick, Height/2]) { // Cube à soustraire
                            cube([Length + 100, Width + 100, Height]);
                        }
                    } //fin soustraction cube median - End Median cube slicer
                    translate([-Thick/2, Thick, Thick]) { // Forme de soustraction centrale
                        RoundBox($a=(Length + Thick), $b=(Width - Thick*2), $c=(Height - Thick));
                    }
                } // End difference for main box

                difference() { // wall fixation box legs
                    union() {
                        translate([3*Thick + 5, Thick, Height/2]) {
                            rotate([90, 0, 0]) {
                                cylinder(Thick/2, d=16, $fn=6);
                            }
                        }
                        translate([Length - (3*Thick + 5), Thick, Height/2]) {
                            rotate([90, 0, 0]) {
                                cylinder(Thick/2, d=16, $fn=6);
                            }
                        }
                    }
                    translate([4, Thick + Filet, Height/2 - 57]) {
                        rotate([45, 0, 0]) {
                            cube([Length, 40, 40]);
                        }
                    }
                    translate([0, -(Thick*1.46), Height/2]) {
                        cube([Length, Thick*2, 10]);
                    }
                } //Fin fixation box legs
            } // End union for box and legs

            union() { // outbox sides decorations

                for (i=[0 : Thick : Length/4]) {
                    // Ventilation holes part code submitted by Ettie - Thanks ;)
                    translate([10 + i, -Dec_Thick + Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                    translate([(Length - 10) - i, -Dec_Thick + Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                    translate([(Length - 10) - i, Width - Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                    translate([10 + i, Width - Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                } // fin de for
            } //fin union decoration

        } //fin difference decoration

        union() { //sides holes
            $fn = 50;
            translate([3*Thick + 5, 20, Height/2 + 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=2);
                }
            }
            translate([Length - (3*Thick + 5), 20, Height/2 + 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=2);
                }
            }
            translate([3*Thick + 5, Width + 5, Height/2 - 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=2);
                }
            }
            translate([Length - (3*Thick + 5), Width + 5, Height/2 - 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=2);
                }
            }
        } //fin de sides holes

    } //fin de difference holes
} // fin coque


/*  foot module

    Produces a single foot for PCB mounting.

    Arguments:
    FootDia: Diameter of the foot
    FootHole: Diameter of the screw hole in the foot
    FootHeight: Height of the foot above the box interior
*/
module foot(FootDia, FootHole, FootHeight) {
    Filet = 2;
    color(Couleur1) {
        translate([0, 0, Filet - 1.5]) {
            difference() {
                difference() {
                    cylinder(FootHeight - Thick, d=(FootDia + Filet), $fn=100);
                    rotate_extrude($fn=100) {
                        translate([(FootDia + Filet*2) / 2, Filet, 0]) {
                             minkowski() {
                                 square(10);
                                 circle(Filet, $fn=100);
                             }
                         }
                     }
                 }
                 cylinder(FootHeight + 1, d=FootHole, $fn=100);
             }
         }
    }
} // Fin module foot


/*  Feet module

    Combines four feet to form mounting platform for PCB.
    A model of the PCB is included with the background modifier. It is translucent
    but visible in the preview, but not in the final render.

    No arguments are used, but parameters provide the PCB and foot dimensions.
*/
module Feet() {
//////////////////// - PCB only visible in the preview mode - /////////////////////
    translate([(3*Thick + 2), Thick + 5, (FootHeight + Thick/2 - 0.5)]) {
        %square([PCBLength + 10, PCBWidth + 10]);
        translate([PCBLength/2, PCBWidth/2, 0.5]) {
            color("Olive") {
                %text("PCB", halign="center", valign="center", font="Arial black");
            }
        }
    } // Fin PCB

////////////////////////////// - 4 Feet - //////////////////////////////////////////
    translate([3*Thick + 7, Thick + 10, Thick/2]) {
        foot(FootDia, FootHole, FootHeight);
    }
    translate([(3*Thick + PCBLength + 7), Thick + 10, Thick/2]) {
        foot(FootDia, FootHole, FootHeight);
        }
    translate([3*Thick + PCBLength + 7, Thick + PCBWidth + 10, Thick/2]) {
        foot(FootDia, FootHole, FootHeight);
        }
    translate([3*Thick + 7, Thick + PCBWidth + 10, Thick/2]) {
        foot(FootDia, FootHole, FootHeight);
    }

} // Fin du module Feet


////////////////////////////////////////////////////////////////////////
////////////////////// <- Holes Panel Manager -> ///////////////////////
////////////////////////////////////////////////////////////////////////


/*  Panel module

    Produces a single panel with potentially rounded corners.

    Arguments:
    Length: The length of the panel
    Width: The width of the panel
    Thick: The thickness of the panel
    Filet: The radius of the rounded corners
*/
module Panel(Length, Width, Thick, Filet) {
    scale([0.5, 1, 1])
    minkowski() {
        cube([Thick, Width - (Thick*2 + Filet*2 + m), Height - (Thick*2 + Filet*2 + m)]);
        translate([0, Filet, Filet]) {
            rotate([0, 90, 0]) {
                cylinder(Thick, r=Filet, $fn=100);
            }
        }
    }
}


/*  Cylinder Hole module

    Produces a cylinder for use as a holein a panel

    Arguments:
    OnOff: Rendered only if 1
    Cx: X position of hole center
    Cy: Y position of hole center
    Cdia: diameter of hole
*/
module CylinderHole(OnOff, Cx, Cy, Cdia) {
    if (OnOff == 1) {
        translate([Cx, Cy, -1]) {
            cylinder(10, d=Cdia, $fn=50);
        }
    }
}


/*  Square Hole module

    Produces a rectangular prism with potentially rounded corner for use as a hole in a panel

    Arguments:
    OnOff: Rendered only if 1
    Sx: X position of bottom left corner
    Sy: Y position of bottom left corner
    Sl: width of rectangle
    Sw: height of rectangle
    Filet: radius of rounded corner
*/
module SquareHole(OnOff, Sx, Sy, Sl, Sw, Filet) {
    if (OnOff == 1) {
        minkowski() {
            translate([Sx + Filet/2, Sy + Filet/2, -1]) {
                cube([Sl - Filet, Sw - Filet, 10]);
            }
            cylinder(10, d=Filet, $fn=100);
        }
    }
}


/*  LText module

    Produces linear text for use on a panel

    Arguments:
    OnOff: Rendered only if 1
    Tx: X position of bottom left corner of text
    Ty: Y position of bottom left corner of text
    Font: Font to use for text
    Size: Approximate Height of text in mm.
    Content: The text
*/
module LText(OnOff,Tx,Ty,Font,Size,Content) {
    if (OnOff == 1) {
        translate([Tx, Ty, Thick + .5]) {
            linear_extrude(height=0.5) {
                text(Content, size=Size, font=Font);
            }
        }
    }
}


/*  CText module

    Produces circular text for a panel

    OnOff:Rendered only if 1
    Tx: X position of text
    Ty: Y position of text
    Font: Font to use for text
    Size: Approximate height of text in mm
    TxtRadius: Radius of text
    Angl: Arc angle
    Turn: Starting angle
    Content: The text
*/
module CText(OnOff, Tx, Ty, Font, Size, TxtRadius, Angl, Turn, Content) {
    if (OnOff == 1) {
        Angle = -Angl / len(Content);
        translate([Tx, Ty, Thick + .5]) {
            for (i= [0 : len(Content) - 1] ) {
                rotate([0, 0, i*Angle + 90 + Turn]) {
                    translate([0, TxtRadius, 0]) {
                        linear_extrude(height=0.5) {
                            text(Content[i], font=Font, size=Size,  valign="baseline", halign="center");
                        }
                    }
                }
            }
        }
    }
}


////////////////////// <- New module Panel -> //////////////////////
/*  FPanL module

    Produces the front panel. No arguments are used, but this module must be
    edited to produce holes and text for your box.
*/
module FPanL() {
    difference() {
        color(Couleur2) {
            Panel(Length, Width, Thick, Filet);
        }
        rotate([90, 0, 90]) {
            color(Couleur2) {
//                     <- Cutting shapes from here ->
                //(On/Off, Xpos,Ypos,Length,Width,Filet)
                SquareHole(1, 20, 20, 15, 10, 1);
                SquareHole(1, 40, 20, 15, 10, 1);
                SquareHole(1, 60, 20, 15, 10, 1);
                //(On/Off, Xpos, Ypos, Diameter)
                CylinderHole(1, 27, 40, 8);
                CylinderHole(1, 47, 40, 8);
                CylinderHole(1, 67, 40, 8);
                SquareHole(1, 20, 50, 80, 30, 3);
                CylinderHole(1, 93, 30, 10);
                SquareHole(1, 120, 20, 30, 60, 3);
//                            <- To here ->
            }
        }
    }

    color(Couleur1) {
        translate ([-.5, 0, 0]) {
            rotate([90, 0, 90]) {
//                            <- Adding text from here ->
                //(On/Off, Xpos, Ypos, "Font", Size, "Text")
                LText(1, 20, 83, "Arial Black", 4, "Digital Screen");
                LText(1, 120, 83, "Arial Black", 4, "Level");
                LText(1, 20, 11, "Arial Black", 6, "  1     2      3");
                //(On/Off, Xpos, Ypos, "Font", Size, Diameter, Arc(Deg), Starting Angle(Deg),"Text")
                CText(1, 93, 29, "Arial Black", 4, 10, 180, 0, "1 . 2 . 3 . 4 . 5 . 6");
//                            <- To here ->
            }
        }
    }
} // End FPanL


/////////////////////////// <- Main part -> /////////////////////////

if (TShell == 1) {
    // Coque haut - Top Shell
    color( Couleur1, 1) {
        translate([0, Width, Height + 0.2]) {
            rotate([0, 180, 180]) {
                Coque();
            }
        }
    }
}

if (BShell == 1) {
    // Coque bas - Bottom shell
    color(Couleur1) {
        Coque();
    }
}

// Pied support PCB - PCB feet
if (PCBFeet == 1) {
    // Feet
    translate([PCBPosX, PCBPosY, 0]) {
        Feet();
    }
}

// Panneau avant - Front panel  <<<<<< Text and holes only on this one.
if (FPanL == 1) {
    translate([Length - (Thick*2 + m/2), Thick + m/2, Thick + m/2]) {
        FPanL();
    }
}

//Panneau arrière - Back panel
if (BPanL == 1) {
    color(Couleur2) {
        translate([Thick + m/2, Thick + m/2, Thick + m/2]) {
            Panel(Length, Width, Thick, Filet);
        }
    }
}
