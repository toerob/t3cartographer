#charset "us-ascii"
#include <tads.h>
#include <strbuf.h>
#include "cartographer.h"

/**
 * Renders a map in graphviz dot format and saves it in the 
 * same directory as the gamefile. 
 * listOfRooms - the list of rooms to be rendered
 * level - optional parameter that sets which z-wise level 
 *        to render. If not set, all levels will be rendered.
 */
renderGraphvizDotMap(listOfRooms, mapOnlyVisitedRooms?, level?) { 
    listOfRooms = listOfRooms.sort(true, {a, b: a.mapCoords[1] - b.mapCoords[1] });
    listOfRooms = listOfRooms.sort(nil, {a, b: a.mapCoords[2]  - b.mapCoords[2] });    
    
    if(mapOnlyVisitedRooms) {
        listOfRooms = listOfRooms.subset({r:r.visited});
    }

    if(level!=nil) {
        listOfRooms = listOfRooms.subset({r:r.mapCoords[3] == level});
    }
    
    local indent = '  ';

    local mapData = 'digraph Map {\n' +
    indent + 'node [shape=box,width=1.0,height=.1];\n'+
    indent + 'node [style="rounded"];\n'+
    indent + 'edge [dir=none];\n'+
    indent + 'splines=line;\n'+
    indent + 'concentrate=true\n'+
    //'splines=ortho;\n'+
    //'ranksep=1;\n'+
    //'nodesep=1;\n'+
    indent + 'subgraph map {\n'+
    indent + indent + '<<populateRoomDotGraphics(listOfRooms, mapOnlyVisitedRooms)>>'+
    indent + '}\n'+
    '}';
    return mapData;
}

populateRoomDotGraphics(listOfRooms, mapOnlyVisitedRooms?) {
    local str = new StringBuffer();
    foreach(local r in listOfRooms) {
        gExitProps
            .subset({x: x != (&up) || x!= (&down)})
            .subset({x: !([&west, &north, &northwest, &northeast].indexOf(x) ) })
            .forEach({exitProp: handleDirection(r, exitProp, str, mapOnlyVisitedRooms)});
    }
    return toString(str);
}

function handleDirection(r, dirProp, stringBuffer, mapOnlyVisitedRooms?) {
    
    // Important: if we don't validate the direction (with propType)
    // before checking if exists, the value will be evaluated, causing a 
    // text to be printed. This is caused by new convenience feature in 
    // adv3Lite where you can effecively define room exits with strings. 
    // Therefore always check with isDirectionValid first (which will also 
    // make a nil check) before doing anything with it.
    if(!isDirectionValid(r,dirProp)) {
        return;
    }

    local connectedRoom = r.(dirProp);

    if(connectedRoom) {
        if(mapOnlyVisitedRooms && !connectedRoom.visited) {
            return;
        }
        if(!handleDoor(r, connectedRoom, dirProp, stringBuffer)) {


            local reversedBack = r.(dirProp).(oppositeOf(dirProp));
            local reversible = r == reversedBack;
            local dirStr = transformDirection(dirProp);
            local revDirStr = transformDirection(oppositeOf(dirProp));             
            local rankSame = (dirProp==(&east) || dirProp == (&west) )? 'rank=same;' : '';
            rankSame = (dirStr=='e' || dirStr == 'w')?  'rank=same;' : '';

            stringBuffer
                .append('  { <<rankSame>> \"<<r.name>>\":<<dirStr>> ')
                .append('-> \"<<connectedRoom.name>>\"<<if reversible>>:<<revDirStr>><<end>> [dir=back arrowtail=none] }\n');
        }
    }
}


function handleDoor(roomLocation, roomExit, dirTo, stringBuffer) {
    if(roomExit.ofKind(Door)) {
        // Get the other door 
        local otherDoor = roomExit.otherSide;
        //Get the other door's location
        //local otherLocation = otherDoor.location;
        local x = getDirectionToDoor(otherDoor);
        local dd = otherDoor.location;
        //"****The direction from <<roomLocation>> to <<otherDoor>> is <<sayDirection(dirTo)>>/<<sayDirection(x)>> leading to <<dd>>\n";
        local dTo = transformDirection(dirTo);
        local dToRev = transformDirection(x);
        //"That means: <<dTo>> and <<dToRev>>";
        local rankSame = (dTo=='e' || dTo == 'w')?  'rank=same;' : '';

        //floor = 'upper'
        //stringBuffer.append('subgraph ').append(roomLocation.floor).append(' {\n');

        stringBuffer.append('  { <<rankSame>> \"<<roomLocation.name>>\":<<dTo>> -> \"<<dd.name>>\":<<dToRev>> [dir=back arrowtail=none color=red penwidth=3.0] }\n');

        //stringBuffer.append('}\n');
        return true;
    }
    return nil;
}


function transformDirection(dirType) {
    switch(dirType) {
        case &north: return 'n';
        case &south: return 's';
        case &east: return 'e';
        case &west: return 'w';
        case &northeast:  return 'ne';
        case &northwest:  return 'nw';
        case &southeast:  return 'se';
        case &southwest:  return 'sw';
        case &up: return '_';
        case &down: return 'c';
        case &in: return 'c';
        case &out: return '_';
        default: return '';
    }
}

