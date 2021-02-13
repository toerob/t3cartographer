#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "cartographer.h"

/*
 *   Copyright (c) 1999, 2002 by Michael J. Roberts.  Permission is
 *   granted to anyone to copy and use this file for any purpose.  
 *   
 *   This is a starter TADS 3 source file.  This is a complete TADS game
 *   that you can compile and run.
 */

versionInfo: GameID
    IFID = 'F8CF2680-32CF-4C6B-BAC2-78A0AD1097E1'
    name = 'Tads3 Cartographer Lib Example 3'
    byline = 'by Tomas Öberg'
    htmlByline = 'by <a href="mailto:tomaserikoberg@gmail.com">Tomas Öberg</a>'
    version = '1'
    authorEmail = 'Tomas Öberg tomaserikoberg@gmail.com'
    desc = 'An example of how to use the Tads 3 cartographer library, http://github.com/toerob/t3mapper'
    htmlDesc = 'An example of how to use the Tads 3 cartographer library, http://github.com/toerob/t3mapper'
;

gameMain: GameMainDef
    initialPlayerChar = me
    showIntro() {
        local r = new IfmRenderer();
        r.populate([westOfHouse, forestW, clearingNorth]);
        "<<r.render()>>";
    }
;


forestW: Room 'Forest (w)'
    east = westOfHouse
;

westOfHouse: Room 'West of house'
    north = northOfHouse
    south = southOfHouse
    east = "The door is locked"
    west = forestW
    northwest = forestNW
    mapCoordsOverride = [&north -> mapCoordsNEBy(2), &south ->mapCoordsSEBy(2),  &northwest->[-1,-3,0]  /*, &east->[-1,-3,0]*/ ]
    pathConnectionTable = [
        &north -> &west, 
        &south -> &west
    ]
    mapConnectionShape(e, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&northwest) {
                return '<path d="M <<e[1]>> <<e[2]>> 
                             C <<e[1]-40>> <<e[2]-40>>, 
                               <<e[3]-80>> <<e[4]+75>>, 
                               <<e[3]-80>> <<e[4]+25>>" 
                    marker-end="url(#redArrow)"
                    fill="none"
                    stroke-dasharray="10 5"
                    style="stroke:red; stroke-width:2;">
                        <animate attributeName="stroke-dashoffset" values="15;0" dur="5s" repeatCount="indefinite" />
                    </path>';
        }
        if(exitProp==&south) {
            local curvature = 90;
            //return createCrookedLine(e[1], e[2], e[3], e[4], &southeast, true);
            return createBezierCurve(
                e[1], e[2],  
                e[1], e[2]+curvature,
                e[3]-curvature, e[4],
                e[3], e[4], nil, 'fill="none" stroke="black" marker-start="url(#arrow)" marker-end="url(#arrow)" ');
        }   
        return createLine(e[1], e[2], e[3], e[4]);
    }


;


clearingNorth:  Room 'Clearing (n)'
    south = forestPath
    west = forestNW
    east = forestNE
    pathConnectionTable = [&west -> &north, &east -> &north]
    mapCoordsOverride = [&west->[-3,3,0], &east->[3,3,0],  &south->mapCoordsSBy(3)  ]

    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {    
        if(exitProp==&east) {
            return createCrookedLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4], &southeast, nil, 230, 130);
        }
        if(exitProp==&west) {
            return createCrookedLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4], &southwest, nil, 230, 130);
        }        
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }
;



forestPath: Room 'Forest Path'
    south = northOfHouse
    north = clearingNorth
    up = upATree
    west = forestNW
    east = forestNE
    mapCoordsOverride = [ &up->[1,-1, 0], &north->mapCoordsNBy(3), &west->mapCoordsWBy(3), &east->mapCoordsEBy(3) ]
;

upATree: Room 'Up a tree'
    down = forestPath
    mapCoordsOverride = [&down->[-1,1, 0] ]
    mapConnectionShape(edges, cell, adjacentCell, exitProp, adjacentRoomExitProp) {    
        if(exitProp==&down) {
            return '            
            <path id="path-1"  fill="none" 
                d="M <<edges[3]>> <<edges[4]>> 
                   L <<edges[1]>> <<edges[2]>> 
                " stroke="black" stroke-dasharray="4 4"></path>

            <path id="path-2"
                d="M <<edges[3]>> <<edges[4]+12>> 
                   L <<edges[1]>> <<edges[2]+12>> 
                "></path>

            <text>
                <textPath href="#path-1" startOffset="5%">Up</textPath>
                <textPath href="#path-2" startOffset="65%" side="left">Down</textPath>
            </text>

            ';
        }
        return createLine(edges[1], edges[2], edges[3], edges[4]);
    }
;




northOfHouse: Room 'North of House'
    south = "The windows are all barred"
    west = westOfHouse
    east = behindHouse
    north = forestPath
    mapCoordsOverride = [ &east->mapCoordsSEBy(2), &west->mapCoordsSWBy(2) ]
    pathConnectionTable = [&west -> &north, &east -> &north]

    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&east) {
            local curvature = 90;
            return createBezierCurve(
                edgeList[1], edgeList[2],  
                edgeList[1]+curvature, edgeList[2],
                edgeList[3], edgeList[4]-curvature,
                edgeList[3], edgeList[4]);
        }
        if(exitProp==&west) {
            local curvature = 90;
            return createBezierCurve(
                edgeList[1], edgeList[2],  
                edgeList[1]-curvature, edgeList[2],
                edgeList[3], edgeList[4]-curvature,
                edgeList[3], edgeList[4]);
        }        
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }

;


forestNW: Room 'Forest (nw)'
    east = forestPath
    north = clearingNorth
    pathConnectionTable = [&north -> &west, &south->&northwest ]
    mapCoordsOverride = [ &north->[3,-3,0], &east->mapCoordsEBy(3), &south->[1,3,0] ]
    overrideMapCellProperties = [ 'shape'->'ellipse'  /*'height' -> 120, 'offsetX'->20,*/ ]
;

forestNE: Room 'Forest (ne)'
    west = forestPath
    north = clearingNorth
    south = clearingSE
    east = forestNE_E
    pathConnectionTable = [&north -> &east]
    mapCoordsOverride = [ &north->mapCoordsNWBy(3), &west->mapCoordsWBy(3), &south->mapCoordsSBy(3), &east->mapCoordsEBy(2) ]
;

forestNE_E: Room 'Forest (ne e)'
    west = forestNE
    north = forestNE
    south = forestNE
    pathConnectionTable = [&north -> &west, &south -> &west] // TODO:
    mapCoordsOverride = [ &west->mapCoordsWBy(2) , &north->[0,0,0], &south->[0,0,0] ]
    overrideMapCellProperties = [ 'shape'-> 'ellipse' ]

    mapConnectionShape(e, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&south) {
            local curvature = 90;
            return createBezierCurve(
                e[1], e[2],  
                e[1], e[2]+curvature,
                e[1]-45, e[2]+curvature,
                e[1]-190, e[2]-25, nil, 'fill="none" stroke="black" marker-end="url(#arrow)" ');
        }   
        if(exitProp==&north) {
            local curvature = 90;
            return createBezierCurve(
                e[1], e[2],  
                e[1], e[2]-curvature,
                e[1]-45, e[2]-curvature,
                e[1]-145, e[2]+25, nil, 'fill="none" stroke="black" marker-end="url(#arrow)" ');
        }   
        return createLine(e[1], e[2], e[3], e[4]);
    }
;


behindHouse: Room 'Behind house'
    north = northOfHouse
    south = southOfHouse
    east = clearingSE
    west = kitchen
    mapCoordsOverride = [&south->mapCoordsSWBy(2), &north->mapCoordsNWBy(2)]
    pathConnectionTable = [&south -> &east, &north -> &east]

    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&south) {
            local curvature = 90;
            return createBezierCurve(
                edgeList[1], edgeList[2],  
                edgeList[1], edgeList[2]+curvature,
                edgeList[3]+curvature, edgeList[4],
                edgeList[3], edgeList[4]);

        }        
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }

;

kitchen: Room 'Kitchen'
    east = behindHouse
    west = livingRoom
    up = attic
    mapCoordsOverride = [&up->[0,-1, 0]]
    svgGfx(x,y,w,h) {
        return '
        <text x="<<x+80>>" y="<<y-14>>">D</text>
        <text x="<<x+62>>" y="<<y-2>>">U</text>
        ';
    }
;

livingRoom: Room 'Living room'
    east = kitchen
    svgGfx(x,y,w,h) {
        return '<rect x="<<x-132>>" y="<<y-90>>" width="<<w+300>>" rx="5" ry="5" height="<<h+130>>" stroke-width="2" fill="none" stroke="rgb(30,30,30)" stroke-dasharray="10 10" stroke-dashoffset="0">
            </rect>
        ';
    }
;

clearingSE: Room 'Clearing'
    west = behindHouse
    north = forestNE
    mapCoordsOverride = [&north->mapCoordsNBy(3)]

;

attic: Room 'Attic'
    down = kitchen
    mapCoordsOverride = [&down->[0,1, 0] ]
;


southOfHouse: Room 'South of house'
    west = westOfHouse
    south = forestS
    east = behindHouse //se  sw
    //mapCoordsOverride = [&east->[1,-1,0], &west->[-1,-1,0]]
    mapCoordsOverride = [&east->mapCoordsNEBy(2), &west->mapCoordsNWBy(2) ]
    pathConnectionTable = [&east -> &south, &west->&south]
   
    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&west) {
            return createCrookedLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4], 0);
        }
        if(exitProp==&east) {
            return createCrookedLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4], 0);
        }        
        return createDashedLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }

;
  


forestS: Room 'forest'
    north = southOfHouse
;

mailbox: Thing 'mailbox;;mail box boxes[pl]' @westOfHouse
    isOpenable = true
    isContainer = true
    isFixed = true
    isListed = true
    contType = In
;

+leaflet: Thing 'leaflet'
    readDesc = 'Welcome to another cartographer example, this time with a more complex map. '
;


me: Thing 'you' @westOfHouse
    isFixed = true 
    person = 2 
    contType = Carrier 
    beforeAction() {
        inherited();
    }
    afterAction() {
        local roomCrawler = new RoomCrawler();
        local rooms = roomCrawler.crawl(gPlayerChar.location); 
        local svgTileMap = new SvgTileMap(roomCrawler.maxX, roomCrawler.maxY);

        // Uncomment to display a background image fetched from images.pexels.com, could equally well be a local image. Se example5 for this.
        // svgTileMap.background = '<image href="https://images.pexels.com/photos/242236/pexels-photo-242236.jpeg?auto=compress" style="background-repeat: repeat-x, repeat-y;" />';

        svgTileMap.acronymLength = nil;  //20;
        svgTileMap.renderPlayerLocation = true;
        
        
        
        //svgTileMap.showGrid = true; // Useful when applying mapCoordsOverride
        
        //svgTileMap.tileHeight = 120; 
        
        svgTileMap.populate(rooms);
        svgTileMap.setMethod(&stylePlayerTile, method(cell,x,y,w, h, name) {
            return '<rect x="<<x>>" y="<<y>>" width="<<w>>" rx="5" ry="5" height="<<h>>" fill="none" stroke="orange" stroke-width="2" stroke-dasharray="10 10" stroke-dashoffset="0">
            <animate attributeName="stroke-dashoffset" values="0;20" dur="2s" repeatCount="indefinite" />
            </rect>';
        });

        //gMapThemes.currentTheme = 'bright';
        //gMapThemes.currentTheme = 'darkmode';
        gMapThemes.textAttributesMap[gMapThemes.currentTheme] = ' font-size="12" ';
        gMapThemes.rectAttributes[gMapThemes.currentTheme] = ' rx="8" ry="8" stroke-width="1" stroke="black" fill="white" fill-opacity="1.0" ';
        gMapThemes.playerRectAttributes[gMapThemes.currentTheme] = ' rx="8" ry="8" stroke-width="1" stroke="black" fill="white" fill-opacity="1.0" ';

        local svgMap = svgTileMap.render();


        saveStringToFile(svgMap, 'mapdata.svg');
    }
;


/**
 * One way to trigger the map, by typing "map", which in this case will setup a menu 
 * Displaying it, in order to keep game text uncluttered.
 */
DefineIAction(Map)
    execAction(cmd) {
        local roomCrawler = new RoomCrawler();
        local rooms = roomCrawler.crawl(gPlayerChar.location, nil);
        local textMap = new ScalableTextTileMap(roomCrawler.maxX, roomCrawler.maxY);
        textMap.populate(rooms);
        "<<textMap.render()>>";
    }
;

VerbRule(Map) 
    'map' 
    : VerbProduction
    action = Map
;


