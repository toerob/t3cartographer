#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "cartographer.h"

#define DEBUG 1

versionInfo: GameID
    IFID = 'F8CF2680-32CF-4C6B-BAC2-78A0AD1097E1'
    name = 'Tads 3 cartographer library example 4 - HTML'
    byline = 'by Tomas Öberg'
    htmlByline = 'by <a href="mailto:tomaserikoberg@gmail.com">Tomas Öberg</a>'
    version = '1'
    authorEmail = 'Tomas Öberg tomaserikoberg@gmail.com'
    desc = 'An example of how to Tads 3 cartographer library, http://github.com/toerob/t3mapper'
    htmlDesc = 'An example of how to Tads 3 cartographer library, http://github.com/toerob/t3mapper'
;

gameMain: GameMainDef
    initialPlayerChar = me
    map = nil
    showIntro() {
        "Demonstration of the Tads 3 cartographer library feature set\n";
        
    }
;



hallway: Room 'Hallway'
    out   = porch
    south = frontDoorInside
    east = kitchen
    north = livingroom
    up = landing
    //mapName = "Hallw"
;
+frontDoorInside: Door -> frontDoorOutside 'front door';

porch: Room 'Porch'
    north = frontDoorOutside
    southeast = driveway
    in = hallway
    
;
+frontDoorOutside: Door -> frontDoorInside 'front door';

driveway: Room 'On the driveway'
    //north = porch
    northwest = porch
    northeast = sideofhouse
;

sideofhouse: Room 'On the east side of the house'
    // mapName = 'east side of house'
    north = backyard
    southwest = driveway
    east = road
;

road: Room 'A long road (west end)'
    east = road2
    west = sideofhouse
    mapDistanceLengthTable = [ &east -> 2 ]

;
road2: Room 'A long road (east end)'
    west = road
    mapDistanceLengthTable = [ &west -> 2 ]
;

backyard: Room 'The back yard'
    south = sideofhouse
    north = meadow   
    northwest = gardenAreaSouth
    mapDistanceLengthTable = [ &north -> 2 ]
;

gardenAreaSouth: Room 'The garden (south)'
    southeast = backyard
    north = gardenAreaNorth
;


gardenAreaNorth: Room 'The garden (north)'
    south = gardenAreaSouth
    //southeast = meadow
    east = meadow
;

meadow: Room 'On the meadow'
    mapName = 'meadow'
    south = backyard
    west = gardenAreaNorth
    mapDistanceLengthTable = [ &south -> 2 ]

;



livingroom: Room 'Living room'
    south = hallway
;

kitchen: Room 'Kitchen'
    west = hallway
    south = "The window is just impossible to pass through without messing with the flowers... "
    //mapName = 'Thy kitchen'
;


landing: Room 'Landing'
    east = upperbathroom
    north = bedroom
    down = hallway
;

upperbathroom: Room 'Bathroom'
    west = landing
;

bedroom: Room 'Bedroom'
    south = landing
;



me: Thing 'you' @porch
    isFixed = true       
    person = 2 
    contType = Carrier 
;


/**
 * One way to trigger the map, by typing "map", which in this case will setup a menu 
 * Displaying it, in order to keep game text uncluttered.
 */
DefineIAction(Map)
    execAction(cmd) {
        local roomCrawler = new RoomCrawler();
        /*
        roomCrawler.setupMapRegions([
            [porch, driveway, sideofhouse, backyard, gardenAreaNorth, gardenAreaSouth, meadow],
            [hallway, livingroom, kitchen],
            [landing, upperbathroom, bedroom]
        ]);*/

        gMapThemes.currentTheme = 'darkmode';
        



        // TODO: works: north northwest,east??
        // TODO: doesn't work: southeast, northeast??

        local rooms = 
        roomCrawler.crawl(gPlayerChar.location, nil); 

        local dotMap = renderGraphvizDotMap(rooms);
        saveStringToFile(dotMap, 'mapdata.gv');
        
        
        
 
        local svgTileMap = new SvgTileMap(roomCrawler.maxX, roomCrawler.maxY);
        svgTileMap.acronymLength = nil; //20;
        svgTileMap.renderPlayerLocation = true;
        svgTileMap.populate(rooms);
        local svgMap = svgTileMap.render();
;
        /*local svgMap = renderSVGMap(rooms, 
            roomCrawler.maxX, roomCrawler.maxY, 
            gPlayerChar.location.mapCoords[3],
            3);*/
        saveStringToFile(svgMap, 'mapdata.svg');






        //TODO: needs isValidDirection
        //TODO: needs proper styling
        
        local htmlMap = new HtmlTileMap(roomCrawler.maxX,roomCrawler.maxY);
        htmlMap.populate(rooms);
        saveStringToFile(htmlMap.render(), 'mapdata.html');
        "\n<<htmlMap.render()>>\n";

        local textTileMap = new TextTileMap(roomCrawler.maxX,roomCrawler.maxY);
        textTileMap.acronymLength=2;

        textTileMap.renderPlayerLocation = true;
        textTileMap.populate(rooms);
        
        //textTileMap.maxVisibleColumns = 3;
        //textTileMap.columnOffset = 1;
        
        // Either just print the map into the console directly:
        //"<<textTileMap.render()>>";
        
        // Or use a menu (here with additional legend for abbreviation):
        /*local legendText = textTileMap.renderLegend('Legend');
        menuMapChoiceBanner(textTileMap, legendText, []);
        textTileMap.clear();
        textTileMap = nil;
        */
        
        
    }

;

VerbRule(Map) 
    'map' 
    : VerbProduction
    action = Map
;


#ifdef DEBUG
//Test 'test' [''];
#endif
