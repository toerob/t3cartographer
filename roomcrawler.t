#charset "us-ascii"
#include <tads.h>
#include "cartographer.h"
 
/**
 * RoomCrawler is a class that has responsibility to "crawl" through all
 * room's exit points (via a starting point). It stops once it has processed all
 * currently possibly exit connections.
 */
class RoomCrawler: object
    minX = 0
    maxX = 0    
    minY = 0
    maxY = 0
    minZ = 0
    maxZ = 0

    // flag to determine if only visited rooms should be mapped
    mapOnlyVisitedRooms = nil  

    // A list of mapped rooms will populate this property
    processed = nil

    /**
     * Setup a map to represent with directions props to represent a vector of x,y,z offsets 
     * which we can retrieve and recursively add to the next room when crawling through exits
     */                    
    exitPropCoordsMap = static [

        &north     -> [0,-1,0], 
        &south     -> [0,1,0],
        &east      -> [1,0,0],
        &west      -> [-1,0,0],
        &northeast -> [1,-1,0],
        &northwest -> [-1,-1,0],
        &southeast -> [1,1,0],
        &southwest -> [-1,1,0],  
        &up        -> [0,0,1],
        &down      -> [0,0,-1],
        &forward   ->  [0,-1,0],
        &aft       ->  [0,1,0],
        &starboard ->  [1,0,0],
        &port      ->  [-1,0,0]

    ]

    // Map regions makes sure that, if the starting point
    // of the mapping is within one a defined region, then
    // only crawl through rooms part of that region 
    // and skip the other rooms. This might be useful
    // if the game map is really large and/or hard to depict
    // proportinally.
    mapRegions = nil

    region = nil

    showDebugInfo = nil

    setupMapRegions(mapRegions) {
        self.mapRegions = mapRegions;
    }

    mapOnlyVisitedRoomsPredicate(room) {
        return (!libGlobal.playerChar.hasSeen(room));
    }

    // TODO: do a mapOnlyRoomPredicate instead and default to visited rooms
    crawl(startingPoint, mapOnlyVisitedRooms?) {
        self.mapOnlyVisitedRooms = mapOnlyVisitedRooms;
        processed = new List();
        locateRegion(startingPoint);
        try {
            crawlRoomDirections(startingPoint, [0,0,0]);
            alignWithZeroAxis();
        } catch(Exception e) {
            "Room crawler failed to map out the rooms <<e>>";
        } finally {
            return processed;
        }
    }

    locateRegion(startingPoint) {
        if(mapRegions != nil) {
            mapRegions.forEachAssoc(function(region, value) {                
                if(value && value.indexOf(startingPoint)) {
                    self.region = region;
                }
            });
        } 
    }
    crawlRoomDirections(room, coords) {

        if(room == nil || processed.indexOf(room)) {
            return;
        }

        if(mapOnlyVisitedRooms && mapOnlyVisitedRoomsPredicate(room)) {
            return;
        }

        // TODO: if(customPredicate && customPredicate(room)) {return;}


        // If using regions, make sure room is part of current
        // region, otherwise skip
        if(mapRegions && region) {
            if(!mapRegions[region].indexOf(room)) {
                return;
            }
        }
        room.mapCoords = coords;
        if(showDebugInfo) {
            "Crawling through room <<room>>  x:<<room.mapCoords[1]>> y:<<room.mapCoords[2]>> z:<<room.mapCoords[3]>>\n";
        }

        if ( room.mapCoords[1] < minX) minX = room.mapCoords[1];
        if ( room.mapCoords[1] > maxX) maxX = room.mapCoords[1];
        
        if ( room.mapCoords[2] < minY) minY = room.mapCoords[2];
        if ( room.mapCoords[2] > maxY) maxY = room.mapCoords[2];

        if ( room.mapCoords[3] < minZ) minZ = room.mapCoords[3];
        if ( room.mapCoords[3] > maxZ) maxZ = room.mapCoords[3];

        processed += room;

        foreach(local exitProp in gExitProps) {
            
            // Skip direction if it is a double quoted string
            if(room.propType(exitProp) == TypeDString) { 
                continue;
            }
            
            local nextRoom = room.(exitProp);

            if(nextRoom) {
                // TODO: refactor this
                //"Checking <<nextRoom>>\n";
                if(nextRoom.ofKind(Door)) {
                    if(nextRoom.propDefined(&otherSide) 
                    && nextRoom.otherSide.propDefined(&location)
                    && nextRoom.otherSide.location.ofKind(Room)) {
                        if(showDebugInfo) {
                            " -> Passing through door (<<nextRoom>>) to: \n \ \ ";
                        }
                        nextRoom = nextRoom.otherSide.location;

                        //"\nDoor leads to: <<nextRoom>>\n";
                    } else {
                        //"\nThe door doesn't lead to a room but to: <<nextRoom>>\n";
                        continue;
                    }
                } else if(nextRoom.ofKind(TravelConnector)) {
                    if(nextRoom.propDefined(&destination)) {
                        //"ADV3lite specifics";
                        nextRoom = nextRoom.destination;
                    } else {
                        if(nextRoom.propDefined(&getDestination)) {
                            if(showDebugInfo) {
                                "Passing through door (<<nextRoom>>)";
                            }
                            //"ADV3 specifics";
                            nextRoom = nextRoom.getDestination(libGlobal.playerChar, room);
                        }    
                    }

 
                } else if(nextRoom.ofKind(UnlistedProxyConnector)) {
                    nextRoom = nextRoom.(dir);
                } else if(nextRoom.ofKind(Room)) {
                    //"Regular room";
                    
                } else {
                    "Cannot handle connection of datatype: <<dataType(nextRoom)>> for (<<room>>) to <<nextRoom>>";
                    continue; 
                }

                local directionOffset = exitPropCoordsMap[exitProp];
                directionOffset = overrideCoordsWhenSupplied(room, exitProp, directionOffset);
                if(directionOffset && directionOffset.length == 3) {
                    directionOffset = applyExtraDistanceIfProvided(room, exitProp, directionOffset);
                    local offsets = [
                        (room.mapCoords[1]?room.mapCoords[1]:0) + directionOffset[1], 
                        (room.mapCoords[2]?room.mapCoords[2]:0) + directionOffset[2],
                        (room.mapCoords[3]?room.mapCoords[3]:0) + directionOffset[3]
                    ];
                    crawlRoomDirections(nextRoom, offsets);
                }
            } 
        }
    }

    overrideCoordsWhenSupplied(room, exitProp, directionOffset) {
        if(room.propDefined(&mapCoordsOverride) && room.mapCoordsOverride != nil) {
            local coordsOverrideArray = room.mapCoordsOverride[exitProp];
            if(coordsOverrideArray) {
                if(coordsOverrideArray.length != 3) {
                    throw new Exception('mapCoordsOverride must hold [x,y,z] ');
                }
                directionOffset = coordsOverrideArray;
            }
        }
        return directionOffset;
    }

    applyExtraDistanceIfProvided(room, exitProp, directionOffset) {
        if(room.mapDistanceLengthTable != nil) {
            local extraDistance = room.mapDistanceLengthTable[exitProp];
            if(extraDistance) {
                directionOffset = directionOffset.mapAll({x:incDirDirective(x,extraDistance)});
            }
        }
        return directionOffset;
    }

    incDirDirective(currentDistance, extraDistance) {
        if(currentDistance == 1 ) {
            return extraDistance;
        } else if(currentDistance == -1) {
            return -extraDistance;
        } else {
            return 0;
        }   
    }

    /**
     * Realigns the minX, minY to 0,0 and increases the distance to 
     * to maxX, maxY after the crawling process is done.
     * That way the top-left corner is always 0,0 after it is done
     */
    alignWithZeroAxis() {
        local translateX = abs(minX);
        local translateY = abs(minY);
        minX = 0;
        minY = 0;
        maxX += translateX + 1;
        maxY += translateY + 1;

        foreach(local room in processed) {

            room.mapCoords[1] += translateX;
            room.mapCoords[2] += translateY;
            if(showDebugInfo) {
                "Aligning room <<room>>  x:<<room.mapCoords[1]>> y: <<room.mapCoords[2]>> z: <<room.mapCoords[3]>>\n";
            }
        }
    }
;
