#charset "us-ascii"
#include <tads.h>

#define gExitProps cartographerGlobals.exitProps

#define mapCoordsN [0,-1,0]
#define mapCoordsS [0,1,0]
#define mapCoordsE [1,0,0]
#define mapCoordsW [-1,0,0]
#define mapCoordsU [0,0,1] 
#define mapCoordsD [0,0,-1]

#define mapCoordsNW [-1,-1,0]
#define mapCoordsNE [1,-1,0]
#define mapCoordsSW [-1,1,0]
#define mapCoordsSE [1,1,0]

#define mapCoordsNWBy(x) [-x,-x,0]
#define mapCoordsNEBy(x) [x,-x,0]
#define mapCoordsSWBy(x) [-x,x,0]
#define mapCoordsSEBy(x) [x,x,0]

#define mapCoordsNBy(x) [0,-x,0]
#define mapCoordsSBy(x) [0,x,0]
#define mapCoordsWBy(x) [-x,0,0]
#define mapCoordsEBy(x) [x,0,0]
