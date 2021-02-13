#charset "us-ascii"

#include <tads.h>
#include <file.h>
#include "cartographer.h"


modify Room
    mapCoords = [0, 0, 0] //x,y,z
    mapDistanceLengthTable = nil
;

cartographerGlobals: object
     // A list of possible exits properties 
    exitProps = static [            
        &east,&west,
        &south,&southeast, &southwest,
        &north, &northeast,&northwest, 
        &up, &down, &out, &in,
        &port,&starboard,&forward,&aft
    ]
;

function getDirectionToDoor(door) {
    local roomWithDoor = door.location;
    foreach(local exitProp in gExitProps) {
        local roomExit = roomWithDoor.(exitProp);
        if(roomExit == door) {
            return exitProp;
        }
    }
    return nil;
}

function saveStringToFile(string, fileName) {
    local f = File.openTextFile(fileName, FileAccessWrite, 'ascii');
    f.writeFile(string);
    f.closeFile();
}

function isDirectionValid(room, exitProp) {
    return room.propType(exitProp) != TypeDString 
    && room.(exitProp) != nil;
}

  // TODO: make sure this one works with adv3 also:
function getAdjacentRoom(room, ep) {
    if(!isDirectionValid(room, ep)) {
        throw new Exception('Room <<room.name>> exit <<sayDir(ep)>> is invalid!');
    }
    if(room.(ep).ofKind(Room)) {
        return room.(ep);
    }
    if(room.(ep).ofKind(TravelConnector)) {
        if(room.(ep).propDefined(&destination)) {
            //"ADV3lite specifics";
            return room.(ep).destination;
        } else {
            if(room.(ep).propDefined(&getDestination)) {
                //"ADV3 specifics";
                return room.(ep).getDestination(libGlobal.playerChar, room);
            }    
        }
    }
    if(room.(ep).ofKind(Door)) {
        if(room.(ep).propDefined(&otherSide) && room.(ep).otherSide.location) {
            return room.(ep).otherSide.location;
        }
    }

    throw new Exception('Couldn\'t find adjacent room <<room.name>> (direction <<sayDir(ep)>>)!');
}