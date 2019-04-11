/* Box design originally by:
////////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -
              -   http://heartygfx.blogspot.com    -
              -       OpenScad Parametric Box      -
              -         CC BY-NC 3.0 License       -
////////////////////////////////////////////////////////////////////

Improved by jbebel:
http://github.com/jbebel/Ultimate-Box-Maker

To create a box, start by modifying the numerical parameters in the sections
below. This can be accomplished using a release of OpenSCAD newer than 2015.03.
As of the time of writing, this means that a development snapshot is required.
The Thingiverse Customizer may also potentially work, but at the time of
writing, it was inoperable.

The simplest choice is to hand-edit the .scad file. Feature toggles are
annotated with a comment. The other numerical parameters are measurements in
mm. Everything is parametrized, so if you double all the non-feature parameters
you will double the box size in every dimension. Certain parameters are derived
from other parameters. If you wish to override them, you may, but sensible
defaults have been chosen. Notably the design in this revision is particularly
PCB-centric, in that you should start with your PCB size and adjust the margins
around it to determine the box size. If you care more about the box size, you
can set the Length, Width, and Height explicitly, but read the comments around
them.

Once your box is sized appropriately, you can use the Panel modules to design
the holes and text for the front and back panels. Helper variables are provided
to assist you in positioning these holes relative to the PCB, if your holes are
for PCB-mounted components.

When you are ready to print, adjust the values in the "STL element to export"
section, and export each part one at a time.

Experimental options are provided for a screwless design, but these are
untested. In particular, the box fixation tabs may need thicknesses adjusted
in order to have the appropriate flexibility.
*/

// preview[view:north east, tilt:top diagonal]
//----------------------- Box parameters ---------------------------

/* [Box options] */
// - Wall thickness
Thick = 2;
// - Panel thickness
PanelThick = 2;
// - Font Thickness
FontThick = 0.5;
// - Filet Radius
Filet = 2;
// - 0 for beveled, 1 for rounded
Round = 1; // [0:No, 1:Yes]
// - Printer margin around interior cutouts
CutoutMargin = 0.3;
// - Margin between mating parts
PartMargin = 0.1;
// - PCB feet? (x4)
PCBFeet = 1; // [0:No, 1:Yes]
// - Decorations?
Decorations = 1; // [0:No, 1:Yes]
// - Decorations to ventilation holes
Vent = 1; // [0:No, 1:Yes]
// - Decoration-Holes width (in mm)
Vent_width = 1.5;
// - Tolerance (Panel/rails gap on one edge)
PanelThickGap = CutoutMargin + PartMargin;
PanelVerticalGap = PartMargin;
PanelHorizontalGap = CutoutMargin + PartMargin;


/* [Box Fixation Tabs] */
// - Side screw hole (or snap) diameter
ScrewHole = 2.2606;
// - Screw thread major diameter for outer shell
BoxHole = 2.8448;
// Thickness of fixation tabs
TabThick = 2;
// Back left tab
BLTab = 1; // [0:Bottom, 1:Top]
// Back right tab
BRTab = 1; // [0:Bottom, 1:Top]
// Front left tab
FLTab = 1; // [0:Bottom, 1:Top]
// Front right tab
FRTab = 1; // [0:Bottom, 1:Top]
// EXPERIMENTAL: Snap tabs
SnapTabs = 0; // [0:Screws, 1:Snaps]


/* [PCB options] */
// - PCB Length
PCBLength = 80;
// - PCB Width
PCBWidth = 144;
// - PCB Thickness
PCBThick = 1.6;
// You likely need to maintain |TabThick| margin on the left and right for tabs
// and whatnot.
// - Margin between front panel and PCB
FrontEdgeMargin = 70;
// - Margin between back panel and PCB
BackEdgeMargin = 0;
// - Margin between left wall and PCB
LeftEdgeMargin = 11;
// - Margin between right wall and PCB
RightEdgeMargin = 11;
// - Margin between top of PCB and box top.
TopMargin = 84;


/* [PCB_Feet] */
// - Foot height above box interior
FootHeight = 8;
// - Foot diameter
FootDia = 8;
// - Hole diameter, or peg for screwless design
FootHole = 2.2606; // tap size for #4 coarse-thread
// - EXPERIMENTAL Screwless design
Screwless = 0; // [0:Screws, 1:Screwless]
FootFilet = FootHeight/4;

// Foot centers are specified as distance from PCB back-left corner.
// X is along the "length" axis, and Y is along the "width" axis.
// - Foot 1 distance from back PCB edge
Foot1X = 5;
// - Foot 1 distance from left PCB edge
Foot1Y = 5;
// - Foot 2 distance from back PCB edge
Foot2X = 5;
// - Foot 2 distance from right PCB edge
Foot2YFromEdge = 5;
Foot2Y = PCBWidth - Foot2YFromEdge;
// - Foot 3 distance from front PCB edge
Foot3XFromEdge = 5;
Foot3X = PCBLength - Foot3XFromEdge;
// - Foot 3 distance from left PCB edge
Foot3Y = 5;
// - Foot 4 distance from front PCB edge
Foot4XFromEdge = 5;
Foot4X = PCBLength - Foot4XFromEdge;
// - Foot 4 distance from right PCB edge
Foot4YFromEdge = 5;
Foot4Y = PCBWidth - Foot4YFromEdge;


/* [STL element to export] */
// - Top shell
TShell = 0; // [0:No, 1:Yes]
// - Bottom shell
BShell = 1; // [0:No, 1:Yes]
// - Front panel
FPanL = 1; // [0:No, 1:Yes]
// - Back panel
BPanL = 1; // [0:No, 1:Yes]
// - Panel holes and text
PanelFeatures = 0; // [0:No, 1:Yes]


/* [Hidden] */
// - Shell color
Couleur1 = "Orange";
// - Panel color
Couleur2 = "OrangeRed";
// - Text color
TextColor = "White";
// - making decorations thicker if it is a vent to make sure they go through
// shell
// Add a small number to Thick in case Filet is 0.
Dec_Thick = Vent ? Thick*1.001 + Filet : Thick/2;
// Separate vents with a square pillar by default.
Dec_Spacing = Thick + Vent_width;
// X offset to center of first vent
Dec_Offset = Thick*2 + PanelThick + PanelThickGap*2 + Dec_Spacing - Vent_width/2;

// Resolution based on Round parameter. Set this first number to something
// smaller to speed up processing. It should always be a multiple of 4.
Resolution = Round ? 100: 4;

/* Calculate box dimensions from PCB. If you want a more box-centric design
   where the outer diameter of the box matters more than the margins around
   the PCB you can set these manually. The PCB will still be placedaccording
   to the left and back margins, and if you want to use the screwless box
   design, you will need to set the TopMargin to
   (Height - Thick*2 - FootHeight - PCBThick)
*/
Length = PCBLength + FrontEdgeMargin + BackEdgeMargin + ((Thick + PanelThick + PanelThickGap*2)*2);
Width = PCBWidth + LeftEdgeMargin + RightEdgeMargin + Thick*2;
Height = FootHeight + PCBThick + TopMargin + Thick*2;
echo("Box: ", Length=Length, Width=Width, Height=Height);
// X position inset of mounting holes and tabs
MountInset = Thick*3 + PanelThick + PanelThickGap*2 + ScrewHole*4;

// Calculate panel dimensions from box dimensions.
PanelWidth = Width - Thick*2 - PanelHorizontalGap*2;
PanelHeight = Height - Thick*2 - PanelVerticalGap*2;


/*  Panel Manager

    Use the below 4 modules to produce holes and text on the front and back
    panels. The holes modules should contain instances of SquareHole or
    CylinderHole defined later in this file. The text modules should contain
    instances of LText or CText defined later in this file. It is
    recommended to use variables that you define for your needs to create
    the size and positions of these objects.
*/

// Calculate board-relative positions with respect to the panel, for
// convenience in placing panel elements.
TopOfBoardWRTPanel = FootHeight + PCBThick - PanelVerticalGap;
LeftEdgeOfBoardWRTFPanel = LeftEdgeMargin - PanelHorizontalGap;
LeftEdgeOfBoardWRTBPanel = RightEdgeMargin - PanelHorizontalGap;
// Visible panel edges
PanelBottomEdge = Thick - PanelVerticalGap;
PanelTopEdge = PanelHeight - Thick + PanelVerticalGap;
PanelLeftEdge = Thick - PanelHorizontalGap;
PanelRightEdge = PanelWidth - Thick + PanelHorizontalGap;


// Holes for front panel
module FPanelHoles() {
    // SquareHole(On/Off, Xpos,Ypos,Length,Width,Filet)
    SquareHole(1, 20, 20, 15, 10, 1);
    SquareHole(1, 40, 20, 15, 10, 1);
    SquareHole(1, 60, 20, 15, 10, 1);
    // CylinderHole(On/Off, Xpos, Ypos, Diameter)
    CylinderHole(1, 27, 40, 8);
    CylinderHole(1, 47, 40, 8);
    CylinderHole(1, 67, 40, 8);
    SquareHole(1, 20, 50, 80, 30, 3);
    CylinderHole(1, 93, 30, 10);
    SquareHole(1, 120, 20, 30, 60, 3);
}


// Text for front panel
module FPanelText() {
    // LText(On/Off, Xpos, Ypos, "Font", Size, "Text", "HAlign", "VAlign")
    LText(1, 20, 83, "Arial Black", 4, "Digital Screen", HAlign="left");
    LText(1, 120, 83, "Arial Black", 4, "Level", HAlign="left");
    LText(1, 20, 11, "Arial Black", 6, "  1     2      3", HAlign="left");
    // CText(On/Off, Xpos, Ypos, "Font", Size, Diameter, Arc(Deg), Starting Angle(Deg),"Text")
    CText(1, 93, 29, "Arial Black", 4, 10, 180, 0,
          ["1", "." , "3", "." , "5", "." , "7", "." , "9", "." , "11"]);
}


// Holes for back panel
module BPanelHoles() {
    CylinderHole(1,
                 LeftEdgeOfBoardWRTBPanel + 16.4,
                 TopOfBoardWRTPanel + 7,
                 5 + PartMargin*2);
    SquareHole(1,
               LeftEdgeOfBoardWRTBPanel + 37.3,
               TopOfBoardWRTPanel,
               39.2,
               12.55,
               1);
}


// Text for back panel
module BPanelText() {
    LText(1,
          LeftEdgeOfBoardWRTBPanel + 16.4,
          TopOfBoardWRTPanel + 7 + 5,
          "Arial Black",
          4, "PWR"
    );
    LText(1,
          LeftEdgeOfBoardWRTBPanel + 37.3 + 39.2/2,
          TopOfBoardWRTPanel + 12.55 + 2,
          "Arial Black",
          4,
          "DATA"
    );
}


// ------- You probably don't need to modify anything below this line. --------


/* Generic rounded box

    Produces a box of the specified dimensions. Corners are rounded
    according to Filet and Resolution parameters.
    
    Arguments:
    xshrink: the amount to reduce the length on one end compared to the full
        length
    yzshrink: the amount to reduce the width or height on one edge compared
        to the full box  
*/
module RoundBox(xshrink=0, yzshrink=0) {
    Filet = (Filet > Thick*2) ? Filet - yzshrink : Filet;
    translate([xshrink, yzshrink, yzshrink]) {
        rotate([90, 0, 90]) {
            linear_extrude(height=Length - xshrink*2) {
                translate([Filet, Filet, 0]) {
                    offset(r=Filet, $fn=Resolution) {
                        square([Width - 2*yzshrink - 2*Filet, Height - 2*yzshrink - 2*Filet]);
                    }
                }
            }
        }
    }
}


/*  MainBox: Main box module

    This module produces the simple main box half. No feet, tabs, vents or
    fixation is applied here.
*/
module MainBox() {
    difference() {
        union() {
            // Makes a hollow box with walls of Thick thickness.
            difference() {
                RoundBox();
                RoundBox(xshrink=Thick, yzshrink=Thick);
            }
            // Makes interior backing for panel as a wall
            difference() {
                RoundBox(xshrink=(Thick + PanelThick + PanelThickGap*2), yzshrink=Thick/2);
                RoundBox(xshrink=(Thick*2 + PanelThick + PanelThickGap*2));
            }
        }
        // Remove the top half
        translate([-Thick, -Thick, Height/2]) {
            cube([Length + Thick*2, Width + Thick*2, Height]);
        }
        // Remove the center for panel visibility.
        RoundBox(xshrink=-Thick, yzshrink=Thick*2);
    }
}


/*  decoration: a single box decoration
*/
module decoration() {
    translate([-Vent_width/2, -Thick, -Thick]) {
        cube([Vent_width, Dec_Thick + Thick, Height/4 + Thick]);
    }
}


/* LeftDecorations: left decorations module

    Produces the decorations/vents for just the left side of the box.
    These can be rotated and translated for the right side.
*/
module LeftDecorations() {
    for (i=[0 : Dec_Spacing : Length/4]) {
        translate([Dec_Offset + i, 0, 0]) {
            decoration();
        }
        translate([Length - Dec_Offset - i, 0, 0]) {
            decoration();
        }
    }
}


/*  Decorations: decorations module

    This module produces the box vents or decorations.
*/
module Decorations() {
    LeftDecorations();
    // Mirror for the right side decorations
    translate([0, Width, 0]) {
        mirror([0, 1, 0]) {
            LeftDecorations();
        }
    }
}


/*  Coque: Shell module

    This module takes no arguments, but produces a box shell. This is half
    the box, including slots for end panels, rounded corners according to
    Filet and Resolution, and vents/decorations according to parameters.
*/
module Coque() {
    color(Couleur1) {
        difference() {
            MainBox();
            if (Decorations) {
                Decorations();
            }
        }
    }
}


/*  tab: tab module

    Produces a single box fixation tab with screw hole or snap button
*/
module tab() {
    translate([0, Thick, Height/2]) {
        rotate([90, 0, 180]) {
            difference() {
                linear_extrude(TabThick) {
                    difference() {
                        circle(r=4*ScrewHole, $fn=6);
                        if (!SnapTabs) {
                            translate([0, ScrewHole*2, 0]) {
                                circle(d=ScrewHole, $fn=100);
                            }
                        }
                    }
                }
                translate([-4*ScrewHole, -ScrewHole, TabThick]) {
                    rotate([90+45, 0, 0]) {
                        cube([8*ScrewHole, 3*ScrewHole, 5*ScrewHole]);
                    }
                }
                translate([-4*ScrewHole, 0, -PartMargin]) {
                    cube([8*ScrewHole,4*ScrewHole,PartMargin*2]);
                }
            }
            if (SnapTabs) {
                translate([0, ScrewHole*2, PartMargin]) {
                    difference() {
                        sphere(d=(ScrewHole - PartMargin*2), $fn=100);
                        translate([0, 0, ScrewHole*.5 + TabThick/2]) {
                            cube(ScrewHole, center=true);
                        }
                    }
                }
            }
        }
    }
}


/*  Tabs: tabs module

    This module produces the wall fixation box tabs.
    Tabs are produced according to the parameters for XXTab indicating top
    or bottom.

    Arguments:
        top: 0 for bottom shell tabs. 1 for top shell tabs. defaults to bottom.
*/
module Tabs(top=0) {
    color(Couleur1) {
        if (BLTab == top) {
            translate([MountInset, 0, 0]) {
                tab();
            }
        }
        if (FLTab == top) {
            translate([Length - MountInset, 0, 0]) {
                tab();
            }
        }
        if (BRTab == top) {
            translate([MountInset, Width, 0]) {
                rotate([0, 0, 180]) {
                    tab();
                }
            }
        }
        if (FRTab == top) {
            translate([Length - MountInset, Width, 0]) {
                rotate([0, 0, 180]) {
                    tab();
                }
            }
        }
    }
}


/*  hole: hole module

    Produces a box hole for fixation. This is either a cylinder for a screw
    or a semispherical indention for snap tabs.
*/
module hole() {
    if (SnapTabs) {
        translate([0, -Thick, Height/2 - 2*ScrewHole]) {
            sphere(d=ScrewHole, $fn=100);
        }
    }
    else {
        translate([0, Thick, Height/2 - 2*ScrewHole]) {
            rotate([90, 0, 0]) {
                cylinder(Thick*3, d=BoxHole, $fn=100);
            }
        }
    }
}


/*  Holes: holes module

    This module produces the holes necessary in the box fixation tabs and in
    the wall of the box for the corresponding tabs to affix to. Holes are
    produced according to the parameters for XXTab indicating top or bottom.

    Arguments:
        top: 0 for bottom shell holes. 1 for top shell holes. defaults to
            bottom.
*/
module Holes(top=0) {
    color(Couleur1) {
        if (BRTab != top) {
            translate([MountInset, Width, 0]) {
                hole();
            }
        }
        if (FRTab != top) {
            translate([Length - MountInset, Width, 0]) {
                hole();
            }
        }
        if (BLTab != top) {
            translate([MountInset, 0, 0]) {
                rotate([0, 0, 180]) {
                    hole();
                }
            }
        }
        if (FLTab != top) {
            translate([Length - MountInset, 0, 0]) {
                rotate([0, 0, 180]) {
                    hole();
                }
            }
        }
    }
}

/*  PCB: PCB module

    Produces the model of the PCB using parameters for its size and thickness.
    The text PCB is placed on top of the board. This is called by the Feet()
    module with the % modifier which makes this module translucent and only
    viewed in preview mode.
*/
module PCB() {
    translate([0, 0, FootHeight]) {
        cube([PCBLength, PCBWidth, PCBThick]);
        translate([PCBLength/2, PCBWidth/2, PCBThick]) {
            color("Olive") {
                linear_extrude(height=FontThick) {
                    text("PCB", font="Arial black", halign="center", valign="center");
                }
            }
        }
    }
}


/*  foot module

    Produces a single foot for PCB mounting.
*/
module foot(top=0) {
    color(Couleur1) {
        rotate_extrude($fn=100) {
            difference() {
                union() {
                    if (Screwless && top) { // Foot with TopMargin height
                        square([FootDia/2 + FootFilet, TopMargin]);
                    }
                    else if (Screwless && !top) { // Foot for PCB peg
                        square([FootDia/2 + FootFilet, FootHeight + PCBThick*2]);
                    }
                    else if (!Screwless && !top) { // Foot with screw hole
                        translate([FootHole/2 + CutoutMargin, 0, 0]) {
                            square([(FootDia - FootHole)/2 - CutoutMargin + FootFilet, FootHeight]);
                        }
                    }
                }
                translate([FootDia/2 + FootFilet, FootFilet, 0]) {
                    offset(r=FootFilet, $fn=Resolution) {
                        square(Height);
                    }
                }
                if (Screwless && !top) { // Remove around peg
                    translate([FootHole/2 - PartMargin, FootHeight]) {
                        polygon([[0, 0],
                                 [FootDia/2, 0],
                                 [FootDia/2, PCBThick*3],
                                 [-FootHole/3, PCBThick*3],
                                 [0, PCBThick]
                                ]
                        );
                    }
                }
                if (Screwless && top) { // Remove hole for peg
                    translate([-FootHole/2, TopMargin - PCBThick, 0]) {
                        polygon([[0, 0],
                                 [(FootHole*5/6 + CutoutMargin), 0],
                                 [(FootHole + CutoutMargin), PCBThick],
                                 [(FootHole + CutoutMargin), PCBThick*2],
                                 [0, PCBThick*2],
                                ]
                        );
                    }
                }

            }
        }
    }
}


/*  Feet module

    Combines four feet to form mounting platform for PCB.
    A model of the PCB is included with the background modifier. It is
    translucent but visible in the preview, but not in the final render.

    No arguments are used, but parameters provide the PCB and foot dimensions.
*/
module Feet(top=0) {
    translate([BackEdgeMargin + Thick + PanelThick + PanelThickGap*2, LeftEdgeMargin + Thick, Thick]) {
        if (!top) {
            %PCB();
        }
    
        if (Screwless || !top ) {
            translate([Foot1X, Foot1Y]) {
                foot(top=top);
            }
            translate([Foot2X, Foot2Y]) {
                foot(top=top);
                }
            translate([Foot3X, Foot3Y]) {
                foot(top=top);
                }
            translate([Foot4X, Foot4Y]) {
                foot(top=top);
            }
        }
    }
}


/*  TopShell: top shell module

    Produces the top shell, including requested fixation tabs and holes
    Model is rotated and translated to the appropriate position.
*/
module TopShell() {
    translate([0, 0, Height + 0.2]) {
        mirror([0, 0, 1]) {
            difference() {
                union() {
                    Coque();
                    Tabs(top=1);
                    if (Screwless && PCBFeet) {
                       Feet(top=1);
                    }
                }
                Holes(top=1);
            }
        }
    }
}


/*  BottomShell: bottom shell module

    Produces the bottom shell, including requested fixation tabs, holes,
    and PCB feet.
*/
module BottomShell() {
    difference() {
        union() {
            Coque();
            Tabs();
            if (PCBFeet) {
               Feet(top=0);
            }
        }
        Holes();
    }
}


/*  Panel module

    Produces a single panel with potentially rounded corners. Takes no
    arguments but uses the global parameters.
*/
module Panel() {
    Filet = (Filet > Thick*2) ? Filet - Thick - PanelVerticalGap : Filet - PanelVerticalGap;
    echo("Panel:", Thick=PanelThick, PanelWidth=PanelWidth, PanelHeight=PanelHeight, Filet=Filet);
    translate([Filet, Filet, 0]) {
        offset(r=Filet, $fn=Resolution) {
            square([PanelWidth - Filet*2, PanelHeight - Filet*2]);
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
    if (OnOff) {
        echo("CylinderHole:", Cx=Cx, Cy=Cy, Cdia=Cdia + CutoutMargin*2);
        translate([Cx, Cy, 0]) {
            circle(d=Cdia + CutoutMargin*2, $fn=100);
        }
    }
}


/*  Square Hole module

    Produces a rectangular prism with potentially rounded corner for use as
    a hole in a panel

    Arguments:
    OnOff: Rendered only if 1
    Sx: X position of bottom left corner
    Sy: Y position of bottom left corner
    Sl: width of rectangle
    Sw: height of rectangle
    Filet: radius of rounded corner
*/
module SquareHole(OnOff, Sx, Sy, Sl, Sw, Filet) {
    if (OnOff) {
        Offset = Filet + CutoutMargin;
        echo("SquareHole:", Sx=Sx - CutoutMargin, Sy=Sy - CutoutMargin,
             Sl=Sl + CutoutMargin*2, Sw=Sw + CutoutMargin*2, Filet=Offset);
        translate([Sx + Filet, Sy + Filet, 0]) {
            offset(r=Offset, $fn=Resolution) {
                square([Sl - Filet*2, Sw - Filet*2]);
            }
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
    HAlign: Text horizontal alignment. Defaults to "center". "left" and
        "right" available.
    VAlign: Text vertical alignment. Defaults to "baseline". "top",
        "center", and "bottom" available.
*/
module LText(OnOff,Tx,Ty,Font,Size,Content, HAlign="center", VAlign="baseline") {
    if (OnOff) {
        echo("LText:", Tx=Tx, Ty=Ty, Font=Font, Size=Size, Content=Content, HAlign=HAlign, VAlign=VAlign);
        translate([Tx, Ty, PanelThick]) {
            linear_extrude(height=FontThick) {
                text(Content, size=Size, font=Font, halign=HAlign, valign=VAlign);
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
    if (OnOff) {
        echo("CText:", Tx=Tx, Ty=Ty, Font=Font, Size=Size,
             TxtRadius=TxtRadius, Turn=Turn, Content=Content);
        Angle = -Angl / (len(Content) - 1);
        translate([Tx, Ty, PanelThick]) {
            for (i= [0 : len(Content) - 1] ) {
                rotate([0, 0, i*Angle + 90 + Turn]) {
                    translate([0, TxtRadius, 0]) {
                        linear_extrude(height=FontThick) {
                            text(Content[i], size=Size, font=Font, halign="center");
                        }
                    }
                }
            }
        }
    }
}


/*  FPanL module

    Produces the front panel. No arguments are used, but this module imports
    FPanelHoles() and FPanelText() which must be edited to produce holes and
    text for your box.
*/
module FPanL() {
    translate([Length - (Thick + PanelThickGap + PanelThick),
               Thick + PanelHorizontalGap,
               Thick + PanelVerticalGap]) {
        rotate([90, 0, 90]) {
            color(Couleur2) {
                linear_extrude(height=PanelThick) {
                    difference() {
                        Panel();
                        if (PanelFeatures) {
                            FPanelHoles();
                        }
                    }
                }
            }
            color(TextColor) {
                if (PanelFeatures) {
                    FPanelText();
                }
            }
        }
    }
}


/*  BPanL module

    Produces the back panel. No arguments are used, but this module imports
    BPanelHoles() and BPanelText() which must be edited to produce holes and
    text for your box.
*/
module BPanL() {
    translate([Thick + PanelThickGap + PanelThick,
               Thick + PanelHorizontalGap + PanelWidth,
               Thick + PanelVerticalGap]) {
        rotate([90, 0, 270]) {
            color(Couleur2) {
                linear_extrude(height=PanelThick) {
                    difference() {
                        Panel();
                        if (PanelFeatures) {
                            BPanelHoles();
                        }
                    }
                }
            }
            color(TextColor) {
                if (PanelFeatures) {
                    BPanelText();
                }
            }
        }
    }
}


// Top shell
if (TShell) {
    TopShell();
}

// Bottom shell
if (BShell) {
    BottomShell();
}

// Front panel
if (FPanL) {
    FPanL();
}

// Back panel
if (BPanL) {
    BPanL();
}
