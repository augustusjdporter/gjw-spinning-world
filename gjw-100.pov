/*
    Copyright 2001 by David Leppik.

    This file is part of EarthView.

    EarthView is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    You should have received a copy of the GNU General Public License
    along with EarthView; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "./earthView.inc"
#include "/home/portera/projects/PovrayCommandLineMacV2/include/textures.inc"
#include "./worldLocations.inc"

#declare CamLook = <327, -170, -930>; // Camera's Look_at 
#declare CamLoc = <327*3.0, -170*3.0, -930*3.0>; //where the camera's location is
#declare cam_z = 1.5; //the amount of camera zoom you want
#declare back_dist = 2000; // how far away the background is
#declare cam_a = 4/3; // camera aspect ratio
#declare cam_s = <0,1,0>; // camera sky vectoy
#declare cam_d = vnormalize(CamLook-CamLoc); // camera direction vector
#declare cam_r = vnormalize(vcross(cam_s,cam_d)); // camera right vector
#declare cam_u = vnormalize(vcross(cam_d,cam_r)); // camera up vector
#declare cam_dir = cam_d * cam_z; // direction vector scaled
#declare cam_right = cam_r * cam_a; // right vector scaled

#declare fz = vlength(cam_dir);
#declare fx = vlength(cam_right)/2;
#declare fy = vlength(cam_u)/2; 

#macro OrientZ(p1,p2,cs)
  #local nz = vnormalize(p2-p1);
  #local nx = vnormalize(vcross(cs,nz)); 
  #local ny = vcross(nz,nx);
  matrix <nx.x,nx.y,nx.z, ny.x,ny.y,ny.z, nz.x,nz.y,nz.z, p1.x,p1.y,p1.z>          
#end


//  USA, 48 states fully visible, Alaska mostly over the horizon
#declare rotation = 0;
#fopen MyFile "rotation.txt" read
  #while (defined(MyFile))
  #read(MyFile, rotation)

#end
#declare EARTH_ROTATION= rotation;

camera {
	perspective
//	location geocentricToCartesian(Santiago_CL+1800*z)
	location CamLoc
	look_at CamLook
//	look_at geocentricToCartesian(Santiago_CL)
}

light_source {
	<930*3.0, -170*3.0, -327*3.0>
	White
}
//camera {
//	perspective
//	location <939+980 , 342+980, 0>
//	look_at <819, 374, 0> // 35 deg. N
//}

//light_source {
//	geocentricToCartesian(Dallas_TX_US + 1000*z)
//	White
//}

#declare dw_latitude=29.53;  // Observer's latitude.
#declare dw_startrot=65;     // Found by "hand calibrating" to a star chart
                             // for 2009-09-12T07:16 CDT at this location.


// sky_sphere {
//    pigment {
//       image_map{
//          jpeg "./MilkyWay_8mmf5p6_2x10m.RectFish_SS433.jpg" // High resolution starfield image.
//          //png "constellations.png"    // Image with constellations labeled.
//          map_type 1                   // 0=planar, 1=spherical,
//                                        // 2=cylindrical, 5=torus
//          interpolate 4                 // 0=none, 1=linear, 2=bilinear,
//                                        // 4=normalized distance
//          once                          // No repetitive tiling.
//          }
//       scale  <0.01,0.01,0.01>                  // Reverse projection handedness.
// //      scale  <-100,100,100>                  // Reverse projection handedness.
// //      rotate <20,30,-5>          // Put Polaris at +y.
//       rotate <118.5,0,-152.8>          // Put Polaris at +y.
//       rotate  y*(dw_startrot+360*clock)// Rotate around polaris.
//       rotate  x*(90-dw_latitude)       // Adjust for latitude.
//       }
//    }
box { <0,0,0> <1,1,0.1>
      pigment { image_map { jpeg "./MilkyWay_8mmf5p6_2x10m.RectFish_SS433Flipped.jpg"
                map_type 0 
                interpolate 2 } }
      finish { ambient 0.5 }
      translate <-0.5,-0.5,0>
      scale 3*<fx,2*fy,0.5>
      translate fz*z
      scale back_dist
      rotate<0,0,-90>
      OrientZ(CamLoc,CamLook,cam_s) }


// Airports

// Minneapolis & St. Paul
#declare MSP_MN_US = <decimalDegrees(44,53,"N"),decimalDegrees(93,13,"W"),0>;

// Chicago Midway
#declare MDW_IL_US = <decimalDegrees(41,47,"N"),decimalDegrees(87,45,"W"),0>;

// Los Angeles, LAX : 33deg 56' N    118deg 24' W
#declare LAX_CA_US = <decimalDegrees(33,56,"N"), decimalDegrees(118,24,"W"),0>;

#declare SaintCroix = <decimalDegrees(17,45,"N"), decimalDegrees(64,35,"W"),0>;
#declare Hancock = <decimalDegrees(42,56,"N"), decimalDegrees(71,59,"W"),0>;
#declare NLiberty = <decimalDegrees(41,46,"N"), decimalDegrees(91,34,"W"),0>;
#declare FortDavis = <decimalDegrees(30,38,"N"), decimalDegrees(103,56,"W"),0>;
#declare LosAlamos = <decimalDegrees(35,46,"N"), decimalDegrees(106,14,"W"),0>;
#declare PieTown = <decimalDegrees(34,18,"N"), decimalDegrees(108,7,"W"),0>;
#declare KittPeak = <decimalDegrees(31,57,"N"), decimalDegrees(111,36,"W"),0>;
#declare Owens = <decimalDegrees(37,13,"N"), decimalDegrees(118,16,"W"),0>;
#declare Brewster = <decimalDegrees(48,7,"N"), decimalDegrees(119,40,"W"),0>;
#declare MaunaKea = <decimalDegrees(19,48,"N"), decimalDegrees(155,27,"W"),0>;

#declare EA = <decimalDegrees(33,52,"S"), decimalDegrees(151,12,"E"),0>;
#declare WA = <decimalDegrees(31,57,"S"), decimalDegrees(115,51,"E"),0>;
#declare IN = <decimalDegrees(12,58,"N"), decimalDegrees(77,35,"E"),0>;
#declare SA = <decimalDegrees(33,56,"S"), decimalDegrees(18,25,"E"),0>;
#declare CL = <decimalDegrees(31,46,"S"), decimalDegrees(71,0,"W"),0>;


#declare T_White =
texture { 
	pigment {White} 
}
#declare T_Yellow =
texture { 
	pigment {Yellow} 
}


 Earth()

// Label a few cities...
PinMarker(EA, Polished_Brass ,5)
TextMarker(EA+0.5*x, Chrome_Metal, 14, "GJW-OZ", 90*y)
PinMarker(WA, Polished_Brass ,5)
TextMarker(WA+0.5*x, Chrome_Metal, 14, "GJW-WA", 90*y)
PinMarker(IN, Polished_Brass ,5)
TextMarker(IN+0.5*x, Chrome_Metal, 14, "GJW-IN", 90*y)
PinMarker(SA, Polished_Brass ,5)
TextMarker(SA+0.5*x, Chrome_Metal, 14, "GJW-SA", 90*y)
PinMarker(CL, Polished_Brass ,5)
TextMarker(CL+0.5*x, Chrome_Metal, 14, "GJW-CL", 90*y)

//Arc(SaintCroix, PieTown, 100, T_Yellow, 2)
//Arc(Hancock, PieTown, 50, T_Yellow, 2)
//Arc(NLiberty, PieTown, 50, T_Yellow, 2)

// PinMarker(Boston_MA_US, T_Yellow ,1)
// TextMarker(Boston_MA_US+0.5*x, T_Yellow, 1, "Boston", 90*y)

// PinMarker(Dallas_TX_US, T_Silver_2E ,1)
// TextMarker(Dallas_TX_US+0.5*y, T_Silver_2E, 1, "Dallas", 0)

// PinMarker(MSP_MN_US, T_Silver_2E ,1)
// TextMarker(MSP_MN_US+<0.5,1.5,0>, T_White, 1, "Minneapolis", -45*z)

// SaturnMarker(MDW_IL_US, T_White,1)
// TextMarker(MDW_IL_US+0.5*y, T_White,1, "Chicago", 0)

// PinMarker(LAX_CA_US, T_Yellow ,1)
// TextMarker(LAX_CA_US-1*x, T_Yellow, 1, "Los Angeles", 0)

// Example of putOnEarth:  place a silver box (4 miles on each side)
// 12 miles above Minneapolis (center is 14 miles above Minneapolis).

// box {
//	-2*MILE,2*MILE
//	rotate <45,45,10>
//	putOnEarth(MSP_MN_US + 14*MILE*z)
//	texture { T_Silver_2E }
//}



// Draw arcs all over the place

// Arc(Boston_MA_US, LAX_CA_US, 50, T_Yellow, 2)
// Arc(MSP_MN_US, Dallas_TX_US, 20, T_Silver_2E, 3)
// Arc(MSP_MN_US, MDW_IL_US, 20, T_White, 3)
