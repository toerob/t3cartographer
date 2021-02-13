#charset "us-ascii"
#include <tads.h>
#include <strbuf.h>
#include "cartographer.h"


/*
class TextTile: object {
    rows = nil
    construct(rows) {
        self.rows = rows;
    }
}*/

class ScalableTextTileMap: Tilemap {

    leftSymbolForPlayerTile = static '[';
    rightSymbolForPlayerTile = static ']';
    unknownRoomSymbol = static 'U';
    doorSign = static '#';
    blank = static '\ ';
    nonBreakableBlank = static '&nbsp;';
    verticalLine = static '|';
    horizontalLine = static '_';

    diagonalLineNWSE = static '\\'; 
    diagonalLineNESW = static '/'; 

    verticalDistance = nil
    horizontalDistance = nil            
    diagonalNeSwDistance = nil
    diagonalNwSeDistance = nil

    lookupTable = static [
        &north -> verticalLine,
        &south -> verticalLine,
        &east -> horizontalLine,
        &west -> horizontalLine,
        &northwest -> diagonalLineNWSE,
        &southeast -> diagonalLineNWSE,
        &northeast -> diagonalLineNESW,
        &southwest -> diagonalLineNESW,
        '*' -> ''
    ];

    rowsPerCell  = nil
    columnsPerCell  = nil

    middleColumn = 1
    middleRow = 1

    drawnDoors = nil  // Used to know when not to draw a door again.

    rooms = nil  // Remember the list of rooms

    construct(columns, rows, rowsPerCell?, columnsPerCell?) {
        resize(rowsPerCell, columnsPerCell);
        inherited(columns, rows);
    }

    resize(rowsPerCell, columnsPerCell) {
        if(rowsPerCell==nil) { rowsPerCell = 3; }
        if(columnsPerCell==nil) { columnsPerCell = 3; }
        //"Setting new size <<rowsPerCell>> <<columnsPerCell>>\n";
        self.rowsPerCell = rowsPerCell;
        self.columnsPerCell = columnsPerCell;
        middleRow = (rowsPerCell >> 1)+1;
        middleColumn = (columnsPerCell >> 1)+1;
        verticalDistance = generateSquare(columnsPerCell, rowsPerCell, &north);
        horizontalDistance = generateSquare(columnsPerCell, rowsPerCell, &east);
        diagonalNeSwDistance = generateSquare(columnsPerCell, rowsPerCell, &northeast);
        diagonalNwSeDistance = generateSquare(columnsPerCell, rowsPerCell, &northwest);
    }

    
    zoomIn(increaseRowsBy?, increaseColumnsBy?) {
        increaseRowsBy=increaseRowsBy? increaseRowsBy : 2;
        increaseColumnsBy=increaseColumnsBy? increaseColumnsBy : 2;
        resize(rowsPerCell+increaseRowsBy, columnsPerCell+increaseColumnsBy);
        clear();
        populate(rooms);
    }

    zoomOut(decreaseRowsBy?, decreaseColumnsBy?) {
        decreaseRowsBy = decreaseRowsBy? decreaseRowsBy: 2;
        decreaseColumnsBy = decreaseColumnsBy? decreaseColumnsBy: 2;
        if(rowsPerCell-decreaseRowsBy>=3 && columnsPerCell-decreaseColumnsBy>=3) {
            resize(rowsPerCell-decreaseRowsBy, columnsPerCell-=decreaseColumnsBy);
        }
        clear();
        populate(rooms);
    }

    clear() {
        local array = new Vector();
        for(local x=0; x<rowsPerCell; x++) {
            // Creates an array looking like: ['\ \ \ ','\ \ \ ','\ \ \ ']
            array += repeatChar(blank, rowsPerCell); 
        }
        cells = new Vector(cellCount, cellCount).fillValue(array);
    }

    render() {
        local strBuf = new StringBuffer().append('<tt>');
        for(local row = rowOffset; row < getVisibleRows(); row++) {
            for(local rowIteration = 0; rowIteration < rowsPerCell; rowIteration++) {
                for(local column = columnOffset; column < getVisibleColumns(); column++) {
                    local data = getTile(column,row);
                    if(data != nil) {
                        strBuf.append(renderTile(column,row, rowIteration, data));
                    }
                }
                strBuf.append(rowDelimiter);
            }
        }    
        return strBuf.append('</tt>');
    }

    renderTile(x, y, rowIteration, data) {
        if(playerTile.length == 3 && playerTile[1] == x && playerTile[2] == y && rowIteration == 1) {
            return renderPlayerTile(x,y,rowIteration, data);
        }
        return '<<data[rowIteration+1]>>';
    }   

    renderPlayerTile(x,y,rowIteration, data) {
        local str = new StringBuffer();
        local currentRoom = libGlobal.playerChar.location;
        local roomName = getRoomName(currentRoom);
        str = leftSymbolForPlayerTile + roomName + rightSymbolForPlayerTile;
        return toString(str);
    }

    getRoomName(room) {
        local abbreviatedName = (room.name != nil)? room.name.substr(0,1).toUpper() : unknownRoomSymbol;
        if(room.propDefined(&mapName)) {
            abbreviatedName = room.mapName.substr(0,1).toUpper();
        }
        return abbreviatedName;
    }

    getSymbolForDirection(room, exitProp) {
        if(!isDirectionValid(room, exitProp)) {
            return blank;
        }
        local theDoor = room.(exitProp);
        if(theDoor.ofKind(Door) 
        && theDoor.propDefined(&otherSide)
        && drawnDoors.indexOf(theDoor.otherSide) == nil) {
            drawnDoors += theDoor;
            if(!theDoor.isOpen) {
                if(exitProp == &west) {
                    return doorSign + horizontalLine;
                } else if(exitProp == &east) {
                    return horizontalLine + doorSign;
                } else {
                    return doorSign;
                }
            }
        } 
        return lookupTable[exitProp]; //verticalLine : blank;
    }

    populate(rooms) {
        self.rooms = rooms;
        drawnDoors = new Vector();
        foreach(local room in rooms) {
            local x = room.mapCoords[1];
            local y = room.mapCoords[2];
            if(room.mapCoords[3]  != libGlobal.playerChar.location.mapCoords[3]) {
                continue;
            }
            local tile = craftTile(room);
            setTile(x,y, tile);

            if(room.propDefined(&mapCoordsOverride) && room.mapCoordsOverride) {
                foreach(local exitProp in gExitProps) {
                    room.mapCoordsOverride.forEachAssoc(function(key, value) {
                        if(key==exitProp) {
                            local nextY = value[2];
                            if(nextY>1) {
                                populateTilesForExtraDistance(x,y, nextY, &south);
                            } else if(nextY<-1) {
                                populateTilesForExtraDistance(x,y, abs(nextY), &north);
                            }
                            local nextX = value[1];
                            if(nextX>1) {
                                populateTilesForExtraDistance(x,y, nextX, &east);                                
                            } else if(nextX<-1) {
                                populateTilesForExtraDistance(x,y, abs(nextX), &west);
                            }

                        }
                    });
                }
            } else {
                if(room.propDefined(&mapDistanceLengthTable) && room.mapDistanceLengthTable) {
                    foreach(local exitProp in gExitProps) {
                        local distance = room.mapDistanceLengthTable[exitProp];
                        populateTilesForExtraDistance(x,y, distance, exitProp);
                    }
                }
            }
            if(libGlobal.playerChar.location == room) {
                playerTile = [x,y, room.mapCoords[3] ];
            }
        }
    }
    playerTile = []

    
    craftTile(room) {
        local n = getSymbolForDirection(room, &north);
        local s = getSymbolForDirection(room, &south);
        local nw = getSymbolForDirection(room, &northwest);
        local ne = getSymbolForDirection(room, &northeast);
        local sw = getSymbolForDirection(room, &southwest);
        local se = getSymbolForDirection(room, &southeast);
        local w = getSymbolForDirection(room, &west);
        local e = getSymbolForDirection(room, &east);

        // Create a block of blanks with a grid of rowsPerCell * columnsPerCell
        // e.g: 5*5 blank spaces
        local array = new Vector();
        for(local x=0; x<rowsPerCell; x++) {
            array += new StringBuffer().append(repeatChar(blank, columnsPerCell));
        }

        // Chisel out top row
        array[1][1] = nw;
        array[1][middleColumn] = n;
        array[1][columnsPerCell] = ne;

        for(local m=2; m<middleRow; m++) {
            array[m] = nonBreakableBlank;
        }
        
        local middleRowOfMiddleRows = 0;

        // Chisel out middle rows
        array[middleRow - middleRowOfMiddleRows][1] = w;

        array[middleRow][middleColumn] = getRoomName(room);
        array[middleRow - middleRowOfMiddleRows][columnsPerCell] = e;

        for(local m=middleRow+1; m<rowsPerCell; m++) {
            array[m] = nonBreakableBlank;
        }

        // Chisel out bottom row
        array[rowsPerCell][1] = sw;
        array[rowsPerCell][middleColumn] = s;
        array[rowsPerCell][columnsPerCell] = se;

        return array; 
    }

    occupiedCells = new Vector();

    setTile(col, row, value) {
        local idx = convertToCell(col, row);
        occupiedCells += idx;
        cells[idx] = value;
    }

    setTileIfNotOccupied(x,y,value) {
        if(!occupiedCells.indexOf(convertToCell(x,y))) {
            setTile(x,y,value);
        }
    }


    populateTilesForExtraDistance(x,y, distance, exitProp) {
        if (!distance) {
            return;
        }
        if(exitProp == &north && testTile(x, y-distance)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x,y-t, verticalDistance);
        } else if(exitProp == &south && testTile(x, y+distance)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x,y+t, verticalDistance);
        }  else if(exitProp == &west && testTile(x-distance, y)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x-t,y, horizontalDistance);
        } else if(exitProp == &east && testTile(x+distance, y)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x+t,y, horizontalDistance);
        } else if(exitProp == &northeast && testTile(x+distance, y-distance)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x+t, y-t, diagonalNeSwDistance);
        } else if(exitProp == &northwest && testTile(x-distance, y-distance)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x-t, y-t, diagonalNwSeDistance);
        } else if(exitProp == &southeast && testTile(x+distance, y+distance)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x+t, y+t, diagonalNwSeDistance);
        } else if(exitProp == &southwest && testTile(x-distance, y+distance)) {
            for(local t=1;t<distance; t++) setTileIfNotOccupied(x-t, y+t, diagonalNeSwDistance);
        } 
        
    }
}




/*
 * Usage:
        generateSquare(5).forEach({x: "[<<x>>]\n"});
        generateSquare(5, &east).forEach({x: "<<x>>\n"});
        generateSquare(5, &northwest).forEach({x: "<<x>>\n"});
        generateSquare(5, &northeast).forEach({x: "<<x>>\n"});
        generateSquare(5, &north).forEach({x: "<<x>>\n"});
*/
function generateSquare(unitsX, unitsY, dir?) {
    local row = new StringBuffer().append(repeatChar('\ ', unitsX));
    local halfX = (unitsX >> 1) + 1;  // Quick divide to find y-center
    local halfY = (unitsY >> 1) ; // + 1;  // Quick divide to find y-center

    local strVector = new Vector();
    if(dir==nil) {
        for(local x=0; x<unitsY;x++) {
            strVector += (row);
        }
        return strVector;
    }

    if(dir==&north||dir==&south) {
        local verticalLine = '|';
        row[halfX] = verticalLine;
        for(local x=0; x<unitsY;x++) {
            strVector += (row);
        }
    } else if(dir==&northeast||dir==&southwest) {
        local diagonalLineNE = '/';
        local skipOrAddRowList = [];
        local addRow = unitsY>unitsX? true : nil;
        skipOrAddRowList = addRow? createSkipList(unitsY,unitsX) : createSkipList(unitsX,unitsY);
        for(local rightMost=unitsX, local rowNr=0; rightMost>0;  rightMost--, rowNr++) {           
            local newRow = new StringBuffer();
            newRow.copyChars(1, row);
            newRow[rightMost] = diagonalLineNE;
            strVector += (newRow);            
        }
        if(!addRow) {
            // If we don't remove in reverse order the rows will become unarranged
            skipOrAddRowList.sort(true);
            skipOrAddRowList.forEach({x: strVector.removeElementAt(x) });
        } else {
            skipOrAddRowList.sort(nil);
            skipOrAddRowList.forEach({x: strVector.splice(x, 0, row) });            
        }

    } else if(dir==&southeast||dir==&northwest) {
        local diagonalLineNW = '\\';
        
        local skipOrAddRowList = [];
        local addRow = unitsY>unitsX? true : nil;
        skipOrAddRowList = addRow? createSkipList(unitsY,unitsX) : createSkipList(unitsX,unitsY);
        for(local leftMost=1; leftMost<unitsX+1; leftMost++) {
            local newRow = new StringBuffer();
            newRow.copyChars(1, row);
            newRow[leftMost] = diagonalLineNW;
            strVector += (newRow);
        }
        if(!addRow) {
            // If we don't remove in reverse order the rows will become unarranged
            skipOrAddRowList.sort(true);
            skipOrAddRowList.forEach({x: strVector.removeElementAt(x) });
        } else {
            skipOrAddRowList.sort(nil);
            skipOrAddRowList.forEach({x: strVector.splice(x, 0, row) });            
        }

    } else if(dir==&east||dir==&west) {
        local horizontalLine = '_';
        for(local x=0; x<unitsY;x++) {
            if(x==halfY) {
                strVector += (repeatChar(horizontalLine, unitsX));
            } else {
                strVector += (repeatChar('\ ', unitsX));
            }
        }
    } else {
        throw new Exception('Direction is not supported, only &north, &south, &east, &west,&northeast, &northwest, &southeast, &southwest is.');
    }
    return strVector;
}

function createSkipList(unitsX,unitsY) {
    local difference = unitsX - unitsY;
    local skipOrAddRowList = new Vector();
    for(local x=2;x<unitsX;x+=2) {
        if(difference>0) {
            skipOrAddRowList+=x;
            difference--;
        }
    }
    return skipOrAddRowList;
}