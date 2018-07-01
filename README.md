# Ultimate-Box-Maker
Ultimate Box Maker

This is copied from https://www.thingiverse.com/thing:1264391 under the creative commons license with modifications logged here.
It is publised as a remix on Thingiverse at https://www.thingiverse.com/thing:2938921

Box design originally by:
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
