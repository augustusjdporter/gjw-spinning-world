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

#include "colors.inc"
#include "shapes.inc"
#include "metals.inc"

#ifndef(EarthView_Inc)
#declare EarthView_Inc = 1.0;

/*
	Geocentric coordinates consist of a vector <latitude, longitude, altitude>
	where latitude and longitude are in decimal degrees:  west and north are
	positive, east and south are negative.  Altitude is 0 at the Earth's
	surface, the center of the Earth is -EARTH_SIZE.
*/

////////////////////////////////////////////////////////////////////
//  Global variables, no pun intended.
//


#declare EARTH_ROTATION=0;
#declare EARTH_IMAGE = "earthmap4k.png"
#declare EARTH_HEIGHT_IMAGE = "earthbump4k.png"

#declare EARTH_SIZE = 1000;
#declare KM = 6.378;
#declare MILE = 3.963;


////////////////////////////////////////////////////////////////////
//  Utility Macros
//

// Convert degrees and minutes to a single decimal value
#macro decimalDegrees(intDegrees, minutes, cardinalDirection)
	#local result = intDegrees + (minutes/60);
	#if (strcmp(strlwr(substr(cardinalDirection,1,1)), "s") *
		 strcmp(strlwr(substr(cardinalDirection,1,1)), "w"))
		// do nothing-- nonzero result means neither "s" nor "w"
	#else
		#local result = -result;
	#end
	
	result
#end

// Returns the coordinates for the given latitude, longitude, and altitude 
// (in 1/EARTH_SIZE of earth radius)
#macro geocentricToCartesian( g )
	#local R = EARTH_SIZE + g.z;
	#local theta = radians( EARTH_ROTATION - g.y );
	#local phi = radians(g.x);
	<
		// These are similar to textbook spherical coordinate values, 
		// but with some differences:
		//  ->  Y and Z are reversed (POV's up is Y, not Z)
		//  ->  sin and cos for phi are reversed so the equator is 0.
		R*cos(theta)*cos(phi),
		R*sin(phi),
		-R*sin(theta)*cos(phi)
	>
#end

// Translate and rotate to be facing up (relative to the Earth)
// in geocentric location g. 
#macro putOnEarth(g)
	translate (EARTH_SIZE+g.z)*x
	rotate   g.x*z // latitude
	rotate   -g.y*y // longitude
	rotate EARTH_ROTATION*y
#end



// Translate to polar coordinates:  returns the angle (in degrees) in 
// the y=0 plane which describes point p.
#macro _polarTheta(p)
	#if ( p.x )
		-degrees(atan2(p.z, p.x))
	#else
		#if (p.z > 0)
			-90
		#else
			 90
		#end 
	#end
#end

// Translate to polar coordinates:  returns the angle (in degrees) in the z=0 
// plane which describes point p when rotated by polarTheta.
#macro _polarPhi(p)
	degrees(asin(p.y))
#end


// A variation on polar coordinates:  rotate such that the ground plane
// has the given up vector.
#macro _rotatePlane(upV)
	rotate <90,90,0>
	rotate < 0, 0, _polarPhi(upV) >
	rotate < 0, _polarTheta(upV), 0 >
#end


////////////////////////////////////////////////////////////////////
//  Markers
//


#macro PinMarker(g, theTexture, theSize)
union {
	sphere {
		<15, 0, 0>, 5
		texture { theTexture }
	}
	cylinder {
		<0.0, 0, 0.0>, <15.0, 0, 0.0>, 1.0
		texture {  T_Silver_2E  }
	}

	scale theSize
	putOnEarth(g)
}
#end

#macro TextMarker(g, theTexture, theSize, the_text, theRotation)
object {
	text {
		ttf "crystal.ttf",
		the_text
		0.3, <0.0, 0.0, 0.0>
		translate -0.15*z
		rotate <-90,-90,90>
		rotate theRotation
		texture { theTexture }
		
		scale theSize*15
	}
	putOnEarth(g)
	no_shadow
}
#end

#macro SaturnMarker(g, theTexture, theSize)
union {
	sphere {
		<0, 0, 0>, 5
	}
	torus {
		10, 1 sturm
		rotate 90*z
	}
	scale theSize
	texture { theTexture }
	putOnEarth(g)

}
#end

////////////////////////////////////////////////////////////////////
//  Earths
//


#macro Earth()
	sphere {
		<0.0, 0.0, 0.0>, EARTH_SIZE
		pigment {
			image_map {
				png EARTH_IMAGE
				map_type 1	//spherical
				interpolate 2	//bilinear
			}
			rotate 180*y
			quick_color  rgb <0.000000, 0.000000, 1.000000> 
		}
		rotate EARTH_ROTATION*y
		no_shadow
	}
#end

//  Uses a bump map to elevate the mountains.  A value of 1 is the most realistic,
// but the difference from a flat Earth is unnoticable under most conditions.
// Try a value of 10 or more to see any difference.
#macro EarthWithHeight(height)
	sphere {
		<0.0, 0.0, 0.0>, EARTH_SIZE
		pigment {
			image_map {
				png EARTH_IMAGE
				map_type 1	//spherical
				interpolate 2	//bilinear
			}
			rotate 180*y
			quick_color  rgb <0.000000, 0.000000, 1.000000> 
		}
		normal {
			bump_map {
				png EARTH_HEIGHT_IMAGE
				map_type 1	//spherical
				interpolate 2	//bilinear
				use_color 
			}
			rotate 180*y
			// The bump map is 0 at ocean and 255 at Everest's peak (not a complete pixel).
			// Since Everest is 8848 meters and the Earth has a diameter of 12756 km,
			// the most realistic bump size is 1.39.
			bump_size 1.39 * height
		}

		rotate EARTH_ROTATION*y
	}
#end



////////////////////////////////////////////////////////////////////
//  Arcs
//


// draw spheres from point A to point B
// This is an UNDOCUMENTED, EXPERIMENTAL macro-- use at your own risk.
// Later versions will probably change the arguments, if it exists at all.
#macro SphereArc(	a,
					b,
					the_height, theTexture, theSize, the_count)
	#local aCart = geocentricToCartesian(a);
	#local bCart = geocentricToCartesian(b);
	#local increment = 1/the_count;
	
	#local i = increment/2;
	#while (i < 1.0)
		#local pos = vnormalize( (aCart*i) + (bCart*(1-i)) ) * (EARTH_SIZE + the_height);
		sphere {
			pos, theSize
			texture { theTexture }
		}
		#local i = i+increment;
	#end
	
#end


// Draw an arc between two points.
#macro Arc(	a,
			b,
			maxHeight, theTexture, theSize)
	#local aCart = geocentricToCartesian(a-theSize*z);
	#local bCart = geocentricToCartesian(b-theSize*z);
	#local centerVector = vnormalize(aCart+bCart); // normalized vector halfway between a & b
	#local ctrlHeight = EARTH_SIZE + maxHeight - theSize; // height of control point
	#local ctrl = centerVector * ctrlHeight;
	
	// To simplify the problem, we do our calculations on a plane where
	// A = (0,1), B = (0,-1), and everything along centerVector has x=0.
	// In other words, we scale everything by dist(A,B)/2.  We'll call this
	// coordinate system s, for simplified.
	//
	// This has the advantage that we can do all our calculations as 
	// floats rather than vectors, which makes the math slightly easier,
	// and it exposes some symmetries.
	
	#local sUnit = vlength(aCart-bCart)/2;
	#local sIdentity = (aCart+bCart)/2; // (0,0) in s

	#local sCtrl = vlength(ctrl - sIdentity) / sUnit;
	
	#local sArcCenter = (1-(sCtrl*sCtrl))/(-2*sCtrl); // curious readers may try to prove this
	#local sArcRadius = sCtrl - sArcCenter;
	
	#local arcCenter = (centerVector * sArcCenter * sUnit) + sIdentity;
	#local arcRadius = sArcRadius * sUnit;
	
	difference {
		torus {
			arcRadius, theSize
			sturm
			_rotatePlane(vnormalize(vcross(aCart,bCart)))
			translate arcCenter
			texture { theTexture }
		}
		sphere {
			<0,0,0>, EARTH_SIZE
		}
	}
#end

#end // ifndef
