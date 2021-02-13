#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "cartographer.h"

#define DEBUG 1

versionInfo: GameID
    IFID = 'F8CF2680-32CF-4C6B-BAC2-78A0AD1097E1'
    name = 'Tads3 Cartographer Lib Example'
    byline = 'by Tomas Öberng'
    htmlByline = 'by <a href="mailto:tomaserikoberg@gmail.com">Tomas Öberg</a>'
    version = '1'
    authorEmail = 'Tomas Öberg tomaserikoberg@gmail.com'
    desc = 'An example of how to use the Tads 3 cartographer library, http://github.com/toerob/t3mapper'
    htmlDesc = 'An example of how to use the Tads 3 cartographer library, http://github.com/toerob/t3mapper'
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
    down = basement
    //mapName = "Hallw"
;
+frontDoorInside: Door -> frontDoorOutside 'front door';

porch: Room 'Porch'
    north = frontDoorOutside
    southeast = driveway
    southwest = lawn
    in = hallway
;
+frontDoorOutside: Door -> frontDoorInside 'front door';




basement: Room 'basement'
    up = hallway
    northeast = storageNEDoorInside
    northwest = storageNWDoorInside
    southeast = storageSEDoorInside
    southwest = storageSWDoorInside
;
+storageNEDoorInside: Door -> storageNEDoorOutside 'door';
+storageNWDoorInside: Door -> storageNWDoorOutside 'door';
+storageSEDoorInside: Door -> storageSEDoorOutside 'door';
+storageSWDoorInside: Door -> storageSWDoorOutside 'door';


storageNE: Room 'storage (NE)'
    southwest = storageNEDoorOutside
    west = storageNW
    south = storageSE
    mapDistanceLengthTable = [ &west -> 2, &south ->2]
;
+storageNEDoorOutside: Door -> storageNEDoorInside 'door';



storageNW: Room 'storage (NW)'
    southeast = storageNWDoorOutside
    east = storageNE
    south = storageSW
    mapDistanceLengthTable = [ &east -> 2, &south ->2]
;
+storageNWDoorOutside: Door -> storageNWDoorInside 'door';


storageSW: Room 'storage (SW)'
    northeast = storageSWDoorOutside
    east = storageSE
    north = storageNW
    mapDistanceLengthTable = [ &east -> 2, &north ->2]
;
+storageSWDoorOutside: Door -> storageSWDoorInside 'door';


storageSE: Room 'storage (SE)'
    northwest = storageSEDoorOutside
    west = storageSW
    north = storageNE
    mapDistanceLengthTable = [ &west -> 2, &north ->2]
;
+storageSEDoorOutside: Door -> storageSEDoorInside 'door';


lawn: Room 'lawn'
    northeast = porch
    east = driveway
    northwest = westSideofhouse
    mapDistanceLengthTable = [ &east -> 2]
;

westSideofhouse: Room 'side of the house (west)'
    southeast = lawn
    north = forest
    mapDistanceLengthTable = [ &north -> 3]
;   

forest: Room 'edge of the forest'
    south = westSideofhouse
    mapDistanceLengthTable = [ &south -> 3,  &northwest -> 3]
    northwest = shoreNextToJetty
 ;

shoreNextToJetty: Room 'Next to a jetty'
    mapDistanceLengthTable = [ &southeast -> 3, &northeast ->3]
    southeast = forest
    northeast = northernShore
    east = jetty
;

jetty: Room 'On the jetty'
    mapName = 'jetty'
    west = shoreNextToJetty
    north = "You would get all wet. "
    south asExit(south)
;

northernShore: Room 'Northern shore'
    mapDistanceLengthTable = [ &southwest -> 3]
    southwest = shoreNextToJetty
    south = "There's a lake in that direction"
;

driveway: Room 'On the driveway'
    //north = porch
    northwest = porch
    northeast = sideofhouse
    west = lawn
    mapDistanceLengthTable = [ &west -> 2]

;

sideofhouse: Room 'On the east side of the house'
    // mapName = 'east side of house'
    north = backyard
    southwest = driveway
    east = road
    in = doghouse
;

doghouse: Room 'doghouse'
    out = sideofhouse
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
    
    // Fetches an image from pexels.com and displays it just above this tile
    /*svgGfx(x,y, width, height) {
        local href = 'https://images.pexels.com/photos/5865/healthy-spring-young-green-5865.jpg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260';
        return '<image x=<<x+18>> y="<<y-165>>" width="120px" height="240px" href="<<href>>" />';
    }*/
;



livingroom: Room 'Living room'
    south = hallway
;

kitchen: Room 'Kitchen'
    west = hallway
    south = "The window is just impossible to pass through without messing with the flowers... "
    
    mapName = 'La cuisine' // Override map names with this property, it will only affect the rendered output and nothing in the game
;


landing: Room 'Landing'
    east = upperbathroomDoorOutside
    north = bedroom
    down = hallway
;
+upperbathroomDoorOutside: Door -> upperbathroomDoorInside 'bathroom door';

upperbathroom: Room 'Bathroom'
    west = upperbathroomDoorInside
;
+upperbathroomDoorInside: Door -> upperbathroomDoorOutside 'bathroom door';

bedroom: Room 'Bedroom'
    south = landing
;

me: Thing 'you' @porch
    isFixed = true       
    person = 2 
    contType = Carrier 
    afterAction() {
        //gMapThemes.currentTheme = 'darkmode';
        local roomCrawler = new RoomCrawler();
        local rooms = roomCrawler.crawl(gPlayerChar.location, true); 
        local svgTileMap = new SvgTileMap(roomCrawler.maxX, roomCrawler.maxY);
        svgTileMap.acronymLength = nil;  //20;
        svgTileMap.renderPlayerLocation = true;
        svgTileMap.populate(rooms);
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
        
        // Uncomment to set up map regions to display only certain areas at a time, e.g indoors, outdoors etc...
        roomCrawler.setupMapRegions([
            [hallway, livingroom, kitchen],
            [
                porch, driveway, sideofhouse, backyard, lawn, westSideofhouse, road, road2,
                gardenAreaNorth, gardenAreaSouth, meadow
            ], 
            [landing, upperbathroom, bedroom],
            [forest, shoreNextToJetty, jetty, northernShore]

        ]);

        local rooms = roomCrawler.crawl(gPlayerChar.location, true);         
        local map = new ScalableTextTileMap(roomCrawler.maxX,roomCrawler.maxY);
        map.populate(rooms);
        "<<map.render()>>";
        "<<repeatChar('=', (map.getVisibleColumns())*3)>>";
        "<<renderLegendGeneric('Legend', rooms, 3, 26)>>";


        // Use a menu to display map (here with additional legend for 
        // the room name abbreviations):
        menuMapBanner(map, renderLegendGeneric('Legend', rooms, 3, 26));
    }

;

VerbRule(Map) 
    'map' 
    : VerbProduction
    action = Map
;
