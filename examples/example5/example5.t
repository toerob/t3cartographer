#charset "us-ascii"

/*
 *   Copyright (c) 1999, 2002 by Michael J. Roberts.  Permission is
 *   granted to anyone to copy and use this file for any purpose.  
 *   
 *   This is a starter TADS 3 source file.  This is a complete TADS game
 *   that you can compile and run.
 */

#include <adv3.h>
#include <en_us.h>

gameMain: GameMainDef
    initialPlayerChar = me

    showIntro() {
        "Map example. Walk around, see how the map updates and how the map regions work. ";
        mapManager.drawMap();
    }

;

versionInfo: GameID
    IFID = '' // obtain IFID from http://www.tads.org/ifidgen/ifidgen
    name = 'Example 5'
    byline = 'by Tomas Öberg'
    htmlByline = 'by <a href="mailto:tomaserikoberg@gmail.com">Tomas Öberg</a>'
    version = '1'
    authorEmail = 'Tomas Öberg tomaserikoberg@gmail.com'
    desc = 'Example 5'
    htmlDesc = 'Example 5'
;

scarecrow: Room 'Scarecrow'
    west = outskirts
;

outskirts: Room 'The outskirts'
    south = northMarket
    east = scarecrow
    mapCoordsOverride = [&south -> [-1,6,0] ]
    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&south) {
            local x1 = edgeList[1];
            local y1 = edgeList[2];
            local x2 = edgeList[3];
            local y2 = edgeList[4];

            return '<path d="M <<x1-40>> <<y1>>  
            C <<x1>> <<y1+40>>, <<x2+70>> <<y2-100>>
            <<x2+30>> <<y2>>" 
            stroke="black" fill="none" stroke-dasharray="10 5" 
            style="stroke-width: 3;" />';
        }
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }
;

northMarket: Room 'The north market'
    south = stables
    north = outskirts
    mapCoordsOverride = [&north -> [1,-6,0] ]
    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&north) {
            local x1 = edgeList[1];
            local y1 = edgeList[2];
            local x2 = edgeList[3];
            local y2 = edgeList[4];

            return '<path d="M <<x1>> <<y1>>  
            C <<x1+120>> <<y1+20>>, <<x2>> <<y2-20>>
            <<x2>> <<y2>>" 
            stroke="red" fill="none" stroke-dasharray="10 5" 
            style="stroke-width: 3;" />';
        }
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }

;

stables: Room 'The stables'
    south = bridge
    north = northMarket
;

bridge: Room 'The bridge'
    south = townCenter
    north = stables
;

townCenter: Room 'The town center'
    north = bridge
    south = fields
    east = inn
    southeast = forge
    mapCoordsOverride = [&south ->  [1, 4, 0], &southeast ->  [1, 2, 0] ]

    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&southeast) {
            local x1 = edgeList[1];
            local y1 = edgeList[2];
            local x2 = edgeList[3];
            local y2 = edgeList[4];
            return '<path d="M <<x1>> <<y1>>  
            C <<x1+20>> <<y1+20>>, <<x2>> <<y2-20>>
            <<x2>> <<y2>>" 
            stroke="red" fill="none" stroke-dasharray="10 5" 
            style="stroke-width: 3;" />';
        }
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }
;

inn: Room 'The Inn'
    west = townCenter
    east = temple
;

forge: Room 'The forge'
    northwest = townCenter
    south = fields
    mapCoordsOverride = [&northwest ->  [-1, -2, 0], &south -> [0,2,0] ]
//    overrideMapCellProperties = [ 'offsetX'->50 ]
    
;

temple: Room 'The temple' 
    west = inn
    mapCoordsOverride = [ &south -> [-1, 4, 0]]
    south = fields
    pathConnectionTable = [ &south -> &northeast]
    
    mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        if(exitProp==&south) {
            local x1 = edgeList[1];
            local y1 = edgeList[2];
            local x2 = edgeList[3];
            local y2 = edgeList[4];

            return '<path d="M <<x1>> <<y1>>  
            C <<x1+400>> <<y1+350>>, <<x2+140>> <<y2>>
            <<x2>> <<y2>>" 
            stroke="black" fill="none" stroke-dasharray="10 5" 
            style="stroke-width: 2;" />';

        }
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }

;

fields: Room 'Castle fields'
    northwest = townCenter
    northeast = temple
    north = forge
    mapCoordsOverride = [&northwest ->  [-1, -4, 0], &northeast -> [1, -4, 0],  &north -> [0,-2,0]  ]
    pathConnectionTable = [ &northeast -> &south]
;

mapManager: object
    drawMap() {
        //gMapThemes.currentTheme = 'darkmode';
        local roomCrawler = new RoomCrawler();
        roomCrawler.setupMapRegions([
            [inn, temple, forge, fields, townCenter, bridge],
            [stables, northMarket, outskirts, scarecrow]
        ]);
        local rooms = roomCrawler.crawl(gPlayerChar.location, nil); 
        local svgTileMap = new SvgTileMap(roomCrawler.maxX, roomCrawler.maxY, 170, 80);

        if(roomCrawler.region==1) {
            svgTileMap.background = '<image x="-740" y="-760" width="1800" height="1850" href="images/village.png" opacity="5.0" ></image>';
        } else  if(roomCrawler.region==2) {
            svgTileMap.background = '<image x="-700" y="-60" width="1800" height="1850" href="images/village.png" opacity="5.0" ></image>';
        }

        svgTileMap.acronymLength = nil; //20;
        svgTileMap.renderPlayerLocation = true;
        
        //svgTileMap.showGrid = true;

        svgTileMap.populate(rooms);

        svgTileMap.mapWidth = 650;
        svgTileMap.mapHeight = 700;

        gMapThemes.rectAttributes[gMapThemes.currentTheme] = 'rx="8" ry="8" stroke-width="2" stroke="black" fill="rgb(240,240,255)" ';
        gMapThemes.rectStyle[gMapThemes.currentTheme] = 'opacity: 0.7';
        gMapThemes.playerRectStyle[gMapThemes.currentTheme] = 'opacity: 0.9; stroke:blue; stroke-width:3;';

        gMapThemes.textStyleMap[gMapThemes.currentTheme] = 'font: bold 25 open-sans;';

        local svgMap =  svgTileMap.render();
        "<<svgMap>>";
        //saveStringToFile(svgMap, 'mapdata.svg');  
    }
;

me: Actor 'you' 
    location = townCenter

    afterAction() {
        mapManager.drawMap();
    }
;


WebResourceResFile
   vpath = static new RexPattern('/images/')
;



/*
DefineIAction(Map)
    execAction() {
        local roomCrawler = new RoomCrawler();
        roomCrawler.setupMapRegions([
            [inn, temple, forge, fields, townCenter, bridge],
            [stables, northMarket, outskirts, scarecrow]
        ]);
        local rooms = roomCrawler.crawl(gPlayerChar.location, nil); 
        local svgTileMap = new SvgTileMap(roomCrawler.maxX, roomCrawler.maxY, 170, 80);

        if(roomCrawler.region==1) {
            svgTileMap.background = '<image x="-740" y="-760" width="1800" height="1850" href="images/village.png" opacity="5.0" ></image>';
        } else  if(roomCrawler.region==2) {
            svgTileMap.background = '<image x="-700" y="-60" width="1800" height="1850" href="images/village.png" opacity="5.0" ></image>';
        }

        svgTileMap.acronymLength = nil; //20;
        svgTileMap.renderPlayerLocation = true;
        //svgTileMap.showGrid = true;

        svgTileMap.populate(rooms);

        svgTileMap.mapWidth = 650;
        svgTileMap.mapHeight = 700;

        gMapThemes.rectAttributes[gMapThemes.currentTheme] = 'rx="8" ry="8" stroke-width="2" stroke="black" fill="rgb(240,240,255)" ';
        gMapThemes.rectStyle[gMapThemes.currentTheme] = 'opacity: 0.7';
        gMapThemes.playerRectStyle[gMapThemes.currentTheme] = 'opacity: 0.9; stroke:blue; stroke-width:3;';

        gMapThemes.textStyleMap[gMapThemes.currentTheme] = 'font: bold 25 open-sans;';
        //gMapThemes.textStyleMap[gMapThemes.currentTheme] = 'font: bold 24 sans-serif;';

        local svgMap =  svgTileMap.render();
        "<<svgMap>>";
        //saveStringToFile(svgMap, 'mapdata.svg');
        
    }
;


VerbRule(Map) 
    'map' 
    : MapAction
    verbPhrase = 'map/mapping'
;*/
