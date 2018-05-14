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



/* [Box options] */
// - Epaisseur - Wall thickness
Thick = 2; //[2:5]
// - Panel thickness
PanelThick = 2;
// - Diamètre Coin arrondi - Filet diameter
Filet = 2; //[0.1:12]
// - 0 for beveled, 1 for rounded
Round = 0;
// - Tolérance - Tolerance (Panel/rails gap)
m = 0.9;
// - Printer margin around interior cutouts
CutoutMargin = 0.6;
// Pieds PCB - PCB feet (x4)
PCBFeet = 1; // [0:No, 1:Yes]
// - Decorations to ventilation holes
Vent = 1; // [0:No, 1:Yes]
// - Decoration-Holes width (in mm)
Vent_width = 1.5;

/* [PCB options] */
// - Longueur PCB - PCB Length
PCBLength = 80;
// - Largeur PCB - PCB Width
PCBWidth = 60;
// - Epaisseur PCB Thickness
PCBThick = 1.6;
// You likely need to maintain |Thick| margin on the left and right for tabs
// and whatnot.
// - Margin between front panel and PCB
FrontEdgeMargin = 60;
// - Margin between back panel and PCB
BackEdgeMargin = 10;
// - Margin between left wall and PCB
LeftEdgeMargin = 11;
// - Margin between right wall and PCB
RightEdgeMargin = 95;
// - Margin between top of PCB and box top.
TopPCBMargin = 84;
// - Side screw hole diameter
ScrewHole = 2.2606;



/* [PCB_Feet] */
// - Heuteur pied - Feet height above box interior
FootHeight = 8;
// - Diamètre pied - Foot diameter
FootDia = 8;
// - Diamètre trou - Hole diameter
FootHole = 2.2606; // tap size for #4 coarse-thread
FootFilet = Thick;


// Foot centers are specified as distance from PCB top-left corner.
// X is along the "length" axis, and Y is along the "width" axis.
// - Foot 1 distance from top PCB edge
Foot1X = 5;
// - Foot 1 distance from left edge
Foot1Y = 5;

// - Foot 2 distance from top PCB edge
Foot2X = 5;
// - Foot 2 distance from left edge
Foot2YFromEdge = 5;
Foot2Y = PCBWidth - Foot2YFromEdge;

// - Foot 3 distance from top PCB edge
Foot3XFromEdge = 5;
Foot3X = PCBLength - Foot3XFromEdge;
// - Foot 3 distance from left edge
Foot3Y = 5;

// - Foot 4 distance from top PCB edge
Foot4XFromEdge = 5;
Foot4X = PCBLength - Foot4XFromEdge;
// - Foot 3 distance from left edge
Foot4YFromEdge = 5;
Foot4Y = PCBWidth - Foot4YFromEdge;

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
// - Text colors
TextColor = "White";
// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick = Vent ? Thick*2 : Thick;
// - Depth decoration
Dec_size = Vent ? Thick*2 : 0.8;
// Resolution based on Round parameter
Resolution = Round ? 100: 4;
echo(Round=Round, Resolution=Resolution);



// Calculate box dimensions from PCB.
TopMargin = PCBThick + TopPCBMargin;
Length = PCBLength + FrontEdgeMargin + BackEdgeMargin + ((Thick + PanelThick + m)*2);
Width = PCBWidth + LeftEdgeMargin + RightEdgeMargin + Thick*2;
Height = FootHeight + TopMargin + Thick*2;
echo("Box: ", Length=Length, Width=Width, Height=Height);

// Calculate panel dimensions from box dimensions.
PanelWidth = Width - Thick*2 - m;
PanelHeight = Height - Thick*2 - m;


// Calculate board-relative positions with respect to the panel, for
// convenience in placing panel elements.
TopOfBoardWRTPanel = FootHeight + PCBThick - (m/2);
LeftEdgeOfBoardWRTFPanel = LeftEdgeMargin - (m/2);
LeftEdgeOfBoardWRTBPanel = RightEdgeMargin - (m/2);


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
    difference() {
        difference() { //sides decoration
            union() {
                difference() { //soustraction de la forme centrale - Substraction Fileted box
                    difference() { //soustraction cube median - Median cube slicer
                        union() { //union
                            difference() { //Coque
                                RoundBox();
                                translate([Thick, Thick, Thick]) {
                                    RoundBox($a=(Length - Thick*2),
                                             $b=(Width - Thick*2),
                                             $c=(Height - Thick*2));
                                }
                            } //Fin diff Coque
                            difference() { //largeur Rails
                                translate([Thick + PanelThick + m, Thick, Thick]) { // Rails
                                     RoundBox($a=(Length - ((Thick + PanelThick + m)*2)),
                                              $b=(Width - Thick*2),
                                              $c=(Height - Thick*2));
                                } //fin Rails
                                translate([Thick*2 + PanelThick + m, Thick, Thick]) {
                                     RoundBox($a=(Length - ((Thick*2 + PanelThick + m) * 2)),
                                              $b=(Width - Thick*2),
                                              $c=(Height - Thick*2));
                                }
                            } //Fin largeur Rails
                        } //Fin union
                        translate([-Thick, -Thick, Height/2]) { // Cube à soustraire
                            cube([Length + Thick*2, Width + Thick*2, Height]);
                        }
                    } //fin soustraction cube median - End Median cube slicer
                    translate([-Thick, Thick*2, Thick*2]) { // Forme de soustraction centrale
                        RoundBox($a=(Length + Thick*2), $b=(Width - Thick*4), $c=(Height - Thick*4));
                    }
                } // End difference for main box

                difference() { // wall fixation box legs
                    union() {
                        translate([Thick*5 + PanelThick + 5, Thick*2, Height/2]) {
                            rotate([90, 0, 0]) {
                                cylinder(Thick, d=16, $fn=6);
                            }
                        }
                        translate([Length - (Thick*5 + PanelThick + 5), Thick*2, Height/2]) {
                            rotate([90, 0, 0]) {
                                cylinder(Thick, d=16, $fn=6);
                            }
                        }
                    }
                    translate([0, Thick*2 + Filet, Height/2 - 57]) {
                        rotate([45, 0, 0]) {
                            cube([Length, 40, 40]);
                        }
                    }
                    translate([0, 0, Height/2]) {
                        cube([Length, Thick + 0.16, 10]);
                    }
                } //Fin fixation box legs
            } // End union for box and legs

            union() { // outbox sides decorations

                for (i=[0 : Thick*2 : Length/4]) {
                    // Ventilation holes part code submitted by Ettie - Thanks ;)
                    translate([(10 + PanelThick - Thick) + i - Vent_width/2, -Dec_Thick + Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                    translate([(Length - (10 + PanelThick - Thick)) - i - Vent_width/2, -Dec_Thick + Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                    translate([(Length - (10 + PanelThick - Thick)) - i - Vent_width/2, Width - Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                    translate([(10 + PanelThick - Thick) + i - Vent_width/2, Width - Dec_size, 1]) {
                        cube([Vent_width, Dec_Thick, Height/4]);
                    }
                } // fin de for
            } //fin union decoration

        } //fin difference decoration

        union() { //sides holes
            $fn = 100;
            translate([Thick*5 + PanelThick + 5, 20, Height/2 + 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=ScrewHole);
                }
            }
            translate([Length - (Thick*5 + PanelThick + 5), 20, Height/2 + 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=ScrewHole);
                }
            }
            translate([Thick*5 + PanelThick + 5, Width + 5, Height/2 - 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=ScrewHole);
                }
            }
            translate([Length - (Thick*5 + PanelThick + 5), Width + 5, Height/2 - 4]) {
                rotate([90, 0, 0]) {
                    cylinder(20, d=ScrewHole);
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
    Filet = FootFilet;
    color(Couleur1) {
        difference() {
            difference() {
                cylinder(FootHeight, d=(FootDia + Filet*2), $fn=100);
                rotate_extrude($fn=100) {
                    translate([FootDia/2 + Filet, Filet, 0]) {
                         minkowski() {
                             square(FootHeight);
                             circle(Filet, $fn=Resolution);
                         }
                     }
                 }
             }
             cylinder(FootHeight + 1, d=FootHole + CutoutMargin, $fn=100);
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
    translate([BackEdgeMargin + Thick + PanelThick + m, LeftEdgeMargin + Thick, Thick]) {
        /////////////// - PCB only visible in the preview mode - ///////////////
        translate([0, 0, FootHeight]) {
            %cube([PCBLength, PCBWidth, PCBThick]);
            translate([PCBLength/2, PCBWidth/2, PCBThick + 0.5]) {
                color("Olive") {
                    %text("PCB", halign="center", valign="center", font="Arial black");
                }
            }
        } // Fin PCB
    
        ////////////////////////////// - 4 Feet - //////////////////////////////
        translate([Foot1X, Foot1Y]) {
            foot(FootDia, FootHole, FootHeight);
        }
        translate([Foot2X, Foot2Y]) {
            foot(FootDia, FootHole, FootHeight);
            }
        translate([Foot3X, Foot3Y]) {
            foot(FootDia, FootHole, FootHeight);
            }
        translate([Foot4X, Foot4Y]) {
            foot(FootDia, FootHole, FootHeight);
        }
    } // End main translate
} // Fin du module Feet


////////////////////////////////////////////////////////////////////////
////////////////////// <- Holes Panel Manager -> ///////////////////////
////////////////////////////////////////////////////////////////////////


/*  Panel module

    Produces a single panel with potentially rounded corners. Takes no arguments
    but uses the global parameters.
*/
module Panel() {
    echo("Panel:", Thick=PanelThick, PanelWidth=PanelWidth, PanelHeight=PanelHeight);
    minkowski() {
        cube([PanelThick/2, PanelWidth - Filet*2, PanelHeight - Filet*2]);
        translate([0, Filet, Filet]) {
            rotate([0, 90, 0]) {
                cylinder(PanelThick/2, r=Filet, $fn=Resolution);
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
        echo("CylinderHole:", Cx=Cx, Cy=Cy, Cdia=Cdia + CutoutMargin);
        translate([Cx, Cy, -PanelThick/2]) {
            cylinder(PanelThick*2, d=Cdia + CutoutMargin, $fn=100);
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
        echo("SquareHole:", Sx=Sx - CutoutMargin/2, Sy=Sy - CutoutMargin/2,
             Sl=Sl + CutoutMargin, Sw=Sw + CutoutMargin, Filet=Filet);
        minkowski() {
            translate([Sx + Filet/2 - CutoutMargin/2, Sy + Filet/2 - CutoutMargin/2, -PanelThick/2]) {
                cube([Sl + CutoutMargin - Filet, Sw + CutoutMargin - Filet, PanelThick]);
            }
            cylinder(PanelThick, d=Filet, $fn=Resolution);
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
    HAlign: Text alignment. Defaults to "center"
*/
module LText(OnOff,Tx,Ty,Font,Size,Content, HAlign="center") {
    if (OnOff == 1) {
        echo("LText:", Tx=Tx, Ty=Ty, Font=Font, Size=Size, Content=Content, HAlign=HAlign);
        translate([Tx, Ty, PanelThick + .5]) {
            linear_extrude(height=0.5) {
                text(Content, size=Size, font=Font, halign=HAlign);
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
        echo("CText:", Tx=Tx, Ty=Ty, Font=Font, Size=Size,
             TxtRadius=TxtRadius, Turn=Turn, Content=Content);
        Angle = -Angl / len(Content);
        translate([Tx, Ty, PanelThick + .5]) {
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
            Panel();
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

    color(TextColor) {
        translate ([-.5, 0, 0]) {
            rotate([90, 0, 90]) {
//                            <- Adding text from here ->
                //(On/Off, Xpos, Ypos, "Font", Size, "Text", "HAlign")
                LText(1, 20, 83, "Arial Black", 4, "Digital Screen", HAlign="left");
                LText(1, 120, 83, "Arial Black", 4, "Level", HAlign="left");
                LText(1, 20, 11, "Arial Black", 6, "  1     2      3", HAlign="left");
                //(On/Off, Xpos, Ypos, "Font", Size, Diameter, Arc(Deg), Starting Angle(Deg),"Text")
                CText(1, 93, 29, "Arial Black", 4, 10, 180, 0, "1 . 2 . 3 . 4 . 5 . 6");
//                            <- To here ->
            }
        }
    }
} // End FPanL


////////////////////// <- New module Panel -> //////////////////////
/*  BPanL module

    Produces the back panel. No arguments are used, but this module must be
    edited to produce holes and text for your box.
*/
module BPanL() {
    translate([PanelThick, PanelWidth, 0]) {
        rotate([0, 0, 180]) {
            difference() {
                color(Couleur2) {
                    Panel();
                }
                rotate([90, 0, 90]) {
                    color(Couleur2) {
        //                     <- Cutting shapes from here ->

        //                            <- To here ->
                    }
                }
            }

            color(TextColor) {
                translate ([-.5, 0, 0]) {
                    rotate([90, 0, 90]) {
        //                            <- Adding text from here ->

        //                            <- To here ->
                    }
                }
            }
        } // End 180 degree rotate
    }
} // End BPanL


/////////////////////////// <- Main part -> /////////////////////////

if (TShell == 1) {
    // Coque haut - Top Shell
    color(Couleur1) {
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
    // Pied support PCB - PCB feet
    if (PCBFeet == 1) {
       Feet();
    }
}

// Panneau avant - Front panel
if (FPanL == 1) {
    translate([Length - (Thick + PanelThick + m/2), Thick + m/2, Thick + m/2]) {
        FPanL();
    }
}

//Panneau arrière - Back panel
if (BPanL == 1) {
    translate([Thick + m/2, Thick + m/2, Thick + m/2]) {
        BPanL();
    }
}
