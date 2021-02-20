#charset "us-ascii"
#include <tads.h>
#include <strbuf.h>
#include <bignum.h>
#include "cartographer.h"

class SvgCell: object {
    name = 'Unnamed'
    abbreviatedName = '_'
    roomRef = nil
    x = 0
    y = 0
    width = nil
    height = nil
    padding = static 25
    roomListRef = nil
    textPaddingLeft = 5
    pathAnchors = [ * -> [0,0]]
    drawn = [ * -> nil ]

    construct(name, abbreviatedName, x, y, w, h) {
        self.name = name;
        self.abbreviatedName = abbreviatedName;
        self.width = width;
        self.height = height;
        self.x = x;
        self.y = y;
        self.width = w;
        self.height = h;
        setupDefaultPathAnchors();
    }
    setupDefaultPathAnchors() {
        local centerX = getCenterX();
        local centerY = getCenterY();
        local topY = py();
        local bottomY = py(getHeight());
        local rightX = px(getWidth());
        local leftX = px();
        pathAnchors[&north] = [centerX, topY];
        pathAnchors[&south] = [centerX, bottomY];
        pathAnchors[&west]  = [leftX, centerY];
        pathAnchors[&east]  = [rightX, centerY];
        pathAnchors[&northeast]  = [rightX, topY];        
        pathAnchors[&southeast]  = [rightX, bottomY];
        pathAnchors[&northwest]  = [leftX, topY];
        pathAnchors[&southwest]  = [leftX, bottomY];
        pathAnchors[&up]  = [centerX, topY];
        pathAnchors[&down]  = [centerX, bottomY];
    }

    setRoomRef(roomRef)  {
        self.roomRef = roomRef;
    }

    /**
     * px returns the pixel x position of this tile including padding. If width is supplied, the additional width is added
     */
    px(addWidth?)  { return addWidth? (x*width)+addWidth+padding    : x*width+padding;  }
    
    /**
     *py returns the pixel y position of this tile including padding. If height is supplied, the additional height is added
     */
    py(addHeight?) { return addHeight? (y*height)+addHeight+(padding) : y*height+(padding); }
    

    lineLength() {
        return padding;
    }

    getWidth() {
        return width - padding;
    }

    getHeight() {
        return height - padding;
    }

    getCenterX() {
        return px((getWidth()/2));
    }

    getCenterY() {
        return py((getHeight()/2));
    }

    /**
     * Returns the adjacent room's exitProp. If overriden in the room's pathConnectionTable,
     * we'll use that value, otherwise we'll use the mirrored exit by calling oppositeOf function
     */
   getAdjacentRoomExitProp(room, exitProp) {
        local pathConnection;
        if(room.propDefined(&pathConnectionTable) && room.pathConnectionTable) {
            pathConnection = room.pathConnectionTable[exitProp];
        }
        return pathConnection ? pathConnection : oppositeOf(exitProp);
    }

    /**
     * Returns an array of [x,y] coordinates for the particular corner specificed as a parameter
     */
    getEdgeCoords(room, exitProp, adjacentCell, nextRoomAdjacentExitProp) {
        local currentCellcoords = pathAnchors[exitProp]; 
        local nextCellCoords = adjacentCell.pathAnchors[nextRoomAdjacentExitProp]; 
        return [currentCellcoords[1],currentCellcoords[2] , nextCellCoords[1], nextCellCoords[2]];
    }
}

class SvgTileMap: Tilemap {
    tileWidth = 180
    tileHeight = 80
    renderPlayerLocation = nil
    acronymLength = nil 
    acronymizeTable = new LookupTable();     
    textMaxLength = 21 // Longer text than this will be trimmed to meet 21 if no acronymLength is set
    rowDelimiter = ''

    drawnDoors = nil  // Vector that keeps track of doors already drawn
    
    /**
     * Creates an arrow marker defintion
     */
    createMarker(id, stroke, fill) {
        return '<marker id="<<id>>" stroke="<<stroke>>" fill="<<fill>>" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse" markerUnits="strokeWidth"> <path d="M 0 0 L 10 5 L 0 10 z" /></marker>';
    }

    /**
     * Hook to create markers, override this if you want other types of markers
     */
    createMarkers() {
        return new StringBuffer()
        .append(createMarker('arrow', 'black', 'white'))
        .append(createMarker('redArrow', 'black', 'red'))
        .append(createMarker('blackArrow', 'black', 'black'));
    }
    
    /**
     * Hook to create defintions (<defs>). Override this if you want more defintions
     */
    createDefinitions() {
        return new StringBuffer()
        .append('<defs><<createMarkers()>></defs>');
    }

    background { return ''; } 
    wordWrap = nil
    showGrid = nil
    construct(columns, rows, tileWidth?, tileHeight?) {
        inherited(columns, rows);
        if(tileWidth) {
            self.tileWidth = tileWidth;
        }
        if(tileHeight) {
            self.tileHeight = tileHeight;
        }
    }

    clear() {
        cells = new Vector(cellCount, cellCount).fillValue(nil);
    }

    renderOnlyVisitedRooms = static function(room) {
        return libGlobal.playerChar.hasSeen(room);
    }

    renderPredicates = []   // e.g: [{room: libGlobal.playerChar.hasSeen(room)}]

    isRoomToBeRendered(room) {
        foreach(local predicate in renderPredicates) {
            if(!predicate(room))
                return nil;
        }
        return true;
    }

    /**
     * populates the tilemap with rooms 
     */
    populate(rooms) {
        foreach(local r in rooms) {
            local x = r.mapCoords[1];
            local y = r.mapCoords[2];
			local roomName = 'unnamed location';
            if(r.name) {
                roomName = r.name.substr(0,20);
            }            
            local abbreviatedName = nil;

            if(acronymLength) {
                abbreviatedName = acronymize(roomName, acronymLength);
            }

            // Override hook for &mapName
            // - will replace the name used on maps when supplied in a room
            if(r.propDefined(&mapName)) {
                abbreviatedName = r.mapName;
            }
            acronymizeTable[abbreviatedName] = roomName;

            local currentLevel = libGlobal.playerChar.location.mapCoords[3];
            if(r.mapCoords[3]  == currentLevel) {
                local mapData;
                mapData = new SvgCell(
                                    roomName, 
                                    abbreviatedName, 
                                    x, y, 
                                    tileWidth, 
                                    tileHeight);

                mapData.setRoomRef(r);
                mapData.roomListRef = rooms;
                local tmp = getTile(x,y);
                if(tmp && (tmp).ofKind(SvgCell)) {
                    continue;
                }
                setTile(x, y, mapData);
                if(libGlobal.playerChar.location == r) {
                    setPlayerTile(x,y);
                }
            } 
        }
        mapHeight = (rows*tileHeight)+SvgCell.padding;
        mapWidth = (columns*tileWidth)+SvgCell.padding;
    }

    supportedExitProps = static [            
        &east,&west,
        &south,&southeast, &southwest,
        &north, &northeast,&northwest, 
        &port,&starboard,&forward,&aft
        ,&up 
        ,&down
        //,&out, &in,
    ]

    cellList = nil
    renderedSymbols = nil

    mapHeight = 0 
    mapWidth = 0
    render() {
        cellList = new Vector();
        renderedSymbols = new Vector();

        drawnDoors = new Vector();
        local str = new StringBuffer();

        // Note: it's important that the cells get rendered first
        // (via inherited render call), otherwise the mapping 
        // of connections won't work (since there won't be 
        // any cell coordinates to relate to). 
        // But we shift the rendering itself so the 
        // connections are not drawn on top of the cells.

        local renderedCells = inherited();
        local renderedConnections = drawConnections();



        str.append(createHeader(mapHeight, mapWidth));
        str.append(createDefinitions());
        str.append(background());
        str.append(renderedConnections);
        str.append(renderedCells);
        str.append(renderedSymbols);
        str.append(createFooter());
        return str;
    }

    nameWhenPlayerLocation(originalName) {
        return '[' +originalName.substr(0,19)+ ']';
    }

    renderTile(x, y, cell) {
        local s = new StringBuffer();
            
        // Debug grid, helpful in counting the tiles when for 
        // instance manipulating the map via mapCoordsOverride
        if(showGrid) {
            s.append(
                createRect(x*tileWidth+SvgCell.padding,
                            y*tileHeight+SvgCell.padding, 
                            tileWidth-SvgCell.padding, 
                            tileHeight-SvgCell.padding, 
                            'stroke:orange; stroke-width:2; opacity: 0.3;',
                            'fill="none" '));
        }
        if(cell) {
            if(!isRoomToBeRendered(cell.roomRef)) {
                return s;
            }

            cellList += cell;

            local x1 = cell.px();
            local y1 = cell.py();

            local overrideWidth = nil;
            local overrideHeight = nil;
            local overrideOffsetX = nil;
            local overrideOffsetY = nil;
            local overrideShape = nil;

            if(cell.roomRef.propDefined(&overrideMapCellProperties)
            && cell.roomRef.overrideMapCellProperties) {
                overrideWidth = cell.roomRef.overrideMapCellProperties['width'];
                overrideHeight = cell.roomRef.overrideMapCellProperties['height'];
                overrideOffsetX = cell.roomRef.overrideMapCellProperties['offsetX'];
                overrideOffsetY = cell.roomRef.overrideMapCellProperties['offsetY'];
                overrideShape = cell.roomRef.overrideMapCellProperties['shape'];
            }

            // Decide if using overriden width and height while rendering the tile
            local useX = overrideOffsetX?overrideOffsetX+x1:x1;
            local useY = overrideOffsetY?overrideOffsetY+y1:y1;
            local useWidth = overrideWidth?overrideWidth:cell.getWidth();
            local useHeight = overrideHeight?overrideHeight:cell.getHeight();



            local name = (acronymLength == nil) ? 
                            cell.name.substr(0, textMaxLength) 
                            : cell.abbreviatedName;


            if(acronymLength == nil) {
                if(cell.roomRef.propDefined(&mapName)) {
                    name = cell.roomRef.mapName;                
                } else {
                   name = cell.name.substr(0, textMaxLength);                
                }
            } else {
                name = cell.abbreviatedName;
            }

            local isPlayerTile = cell.roomRef == libGlobal.playerChar.location;
            if(cell.roomRef.propDefined(&overrideMapCellConstruction)) {
                s.append(cell.roomRef.overrideMapCellConstruction(cell, name, useX, useY, useWidth, useHeight, isPlayerTile));
            } else {
                s.append(createTile(cell, name, overrideShape, useX, useY, useWidth, useHeight, isPlayerTile));
            }
            if(cell.roomRef.propDefined(&svgGfx)) {
                s.append(cell.roomRef.svgGfx(x1, y1, cell.width, cell.height));
            }
        }
        return s;
    }

    createTile(cell, name, shape, x,y,  width, height, isPlayerTile) {
        local s = new StringBuffer();
        local style = isPlayerTile? gMapThemes.getPlayerRectStyle() : nil;
        local attributes = isPlayerTile? gMapThemes.getPlayerRectAttributes() : nil;
        local cellCenterX = x+cell.getWidth()/2;
        local cellCenterY = y+(cell.getHeight()/2) + 3;
        if(shape=='ellipse') {
            s.append(createCenteredEllipse(x,y,  width, height, style, attributes));
        } else {
            s.append(createRect(x,y,  width, height, style, attributes));
        }
        s.append(createMiddleCentedText(cellCenterX,cellCenterY, name));
        if(isPlayerTile && self.propDefined(&stylePlayerTile)) {
            s.append(self.stylePlayerTile(cell, x,y,width, height, name) ); 
        }
        return s;
    }
    
    /** Declare the method stylePlayerTile on svgTileMap in case "sugar on top" detailing of the player tile is needed,
    e.g: an animated stroke-dasharray, like the following:

    svgTileMap.setMethod(&stylePlayerTile, method(cell,x,y,w, h, name) {
        return '<rect x="<<x>>" y="<<y>>" width="<<w>>" rx="5" ry="5" height="<<h>>" fill="none" stroke="orange" stroke-width="2" stroke-dasharray="10 10" stroke-dashoffset="0">
        <animate attributeName="stroke-dashoffset" values="0;20" dur="2s" repeatCount="indefinite" />
        </rect>';
    });
    (See example 3 for an example implementation)
    */

    drawConnections() {
        local s = new StringBuffer();
        foreach(local cell in cellList) {
            s.append(drawConnectionsForCell(cell));
        }
        return s;
    }

    drawConnectionsForCell(cell) {
        local stringBuffer = new StringBuffer();
        local x1 = cell.px();
        local y1 = cell.py();

        supportedExitProps.forEach(function(ep) {
            if(isDirectionValid(cell.roomRef, ep)) {
                local adjacentRoom = nil;
                try {
                    adjacentRoom = getAdjacentRoom(cell.roomRef, ep);
                } catch(Exception e) {
                    // Skip depicting this exit if no adjacent room could be evaluated.
                    return;
                }

                local adjacentCell = cellList.valWhich({x:x.roomRef == adjacentRoom});
                if(adjacentCell==nil) {
                    
                    // Handle a single door when no adjacentCells has been drawn (the case of just showing visited rooms
                    // And the adjacent cells connected to the rooms hasn't been rendered.

                    if(cell.roomRef.(ep).ofKind(Door)) {
                        //renderedSymbols.append(drawDoor(cell.pathAnchors[ep], ep, cell.roomRef.(ep).isOpen));
                        if(cell.roomRef.(ep).isOpen==nil) {
                            renderedSymbols.append(drawDoor(cell.pathAnchors[ep], ep, nil));
                        }
                    } else {
                        // We need to get all the coordinates, x1,y1 and x2,y2. We cannot use the drawLine function
                        // since that one require adjacentCell and getAdjacentRoomExitProp also. But we can get the first two coordinates from 
                        // the pathAnchors table property tied to the current cell. 
                        // We calculate the direction based on the coordinates tied to a direction by using RoomCrawler.exitPropCoordsMap[ep];
                        // Then it is easy to calculate if x,y should positive or negative by just adding the line's width/height with corresponding
                        // coordinates:
                        local edgeList = cell.pathAnchors[ep];
                        local directions =  RoomCrawler.exitPropCoordsMap[ep];
                        local x2 = edgeList[1]+directions[1]*SvgCell.padding;
                        local y2 = edgeList[2]+directions[2]*SvgCell.padding;
                        //renderedSymbols.append(createLine(edgeList[1], edgeList[2], x2, y2));
                        renderedSymbols.append(createLine(edgeList[1], edgeList[2], x2, y2));

                    }
                    return;
                }

                local adjacentRoomExitProp = cell.getAdjacentRoomExitProp(cell.roomRef, ep);


                // If drawn already from the another room's direction, skip this exitprop 
                // and continue with the rest..
                if(adjacentCell.drawn[adjacentRoomExitProp]) {
                    //"skipping cell for room <<adjacentCell.roomRef.theName>> <<sayDir(ep)>> since it is drawn\n";
                    return;
                } 
                local edge = cell.getEdgeCoords(cell.roomRef, ep, adjacentCell, adjacentRoomExitProp);
                if(edge) {
                    // If the direction is mirrored, mark this exit as done so the
                    // path doesn't get drawn twice.
                    if(cell.roomRef.(ep).ofKind(Door)) {
                        handleDoors(edge, cell, adjacentCell, ep, adjacentRoomExitProp);
                    } else {
                        stringBuffer.append(drawLine(edge, cell, adjacentCell, ep, adjacentRoomExitProp));
                        cell.drawn[ep] = true;
                    }
                }
            }
        });

        if(isDirectionValid(cell.roomRef, &up)) {
            renderedSymbols.append(createUpSymbol(x1, y1, cell.getWidth(), cell.getHeight()));
        }
        if(isDirectionValid(cell.roomRef, &down)) {
            renderedSymbols.append(createDownSymbol(x1, y1, cell.getWidth(), cell.getHeight()));
        }
        if(isDirectionValid(cell.roomRef, &in)) {
            renderedSymbols.append(createInSymbol(x1, y1, cell.getWidth(), cell.getHeight(), 'stroke: grey; font-size:8px'));
        }
        if(isDirectionValid(cell.roomRef, &out)) {
            renderedSymbols.append(createOutSymbol(x1, y1, cell.getWidth(), cell.getHeight(),'stroke: grey; font-size:8px'));
        }

        return stringBuffer;
    }

    handleDoors(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {
        local theDoor = cell.roomRef.(exitProp);
        if(theDoor.propDefined(&otherSide)
        && drawnDoors.indexOf(theDoor.otherSide)==nil) {
            drawnDoors += theDoor;
            local isOpen = theDoor.propDefined(&isOpen) && theDoor.isOpen;
            if(isOpen) {
                renderedSymbols.append(drawLine(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp));
            }
            renderedSymbols.append(drawDoor(edgeList, exitProp, isOpen));
        }
    }


    drawLine(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp) {

        if(cell.roomRef.propDefined(&mapConnectionShape)) {
            return cell.roomRef.mapConnectionShape(edgeList, cell, adjacentCell, exitProp, adjacentRoomExitProp);
        }
        if(cell.roomRef.propDefined(&connectionAnchorOffset)
        && cell.roomRef.connectionAnchorOffset) {
            local offsetX1=0;
            local offsetY1=0;
            local offsetX2=0;
            local offsetY2=0;
            cell.roomRef.connectionAnchorOffset.forEachAssoc(function(index,value) {
                if(index == exitProp) {
                    if(value.length != 4) {
                        throw new Exception('connectionAnchorOffset should be an array of five entries, first the direction, then four values offsetting edge with offsets for x1, y1 and x2, y2. Set value 0 for no offset. ');
                    }
                    offsetX1 = value[1];
                    offsetY1 = value[2];
                    offsetX2 = value[3];
                    offsetY2 = value[4];
                }
            });
            return createLine(edgeList[1]+offsetX1, edgeList[2]+offsetY1, edgeList[3]+offsetX2, edgeList[4]+offsetY2);
        }
        return createLine(edgeList[1], edgeList[2], edgeList[3], edgeList[4]);
    }

    drawDoor(edge, ep, isOpen) {
        return createDoor(edge, ep, isOpen);
    }   
}

createDoor(edgeArray, exitProp, open?) {
    local width = 8;
    local height = 12;

    local thirdOfADoorHeight = height/3;
    local halfADoorWidth = width/2;

    local x = edgeArray[1] - halfADoorWidth;
    local y = edgeArray[2] - height;

    if([&east, &west, &northeast, &northwest, &southeast, &southwest].indexOf(exitProp) ) {
        y += (height/2);

        if(exitProp==&east || exitProp==&northeast || exitProp==&southeast) {
            x+=12;
        } else {
            x-=13;
        }
    }

    local paddingUpDown = height/(height/4);    
    if(&south == exitProp) {
        y += (height) + paddingUpDown;
    } else if(&north == exitProp) {
        y -=  paddingUpDown;
    }

    local closedDoor = '<rect x="<<x>>" y="<<y>>" 
        width="<<width>>" height="<<height>>" 
        style = "<<gMapThemes.getStyleDoor()>>"
        rx="2" ry="2"
        />
        <circle cx="<<x+1>>" cy="<<y+(height/2)>>" r="0.5" 
        style = "<<gMapThemes.getStyleDoorKnob()>>" />
        ';

    local openedDoor = '
        <rect x="<<x>>" y="<<y>>" 
        width="<<width>>" height="<<height>>" 
        style = "<<gMapThemes.getStyleDoorDarkness()>>" 
        rx="2" ry="2"
        />
        <path d="M0,<<thirdOfADoorHeight>>  
                L <<halfADoorWidth>>,0,     
                L <<halfADoorWidth>>,<<height>>, 
                L 0,<<height+thirdOfADoorHeight>>  
                L 0,<<thirdOfADoorHeight>>" 
        transform=" translate(<<x+halfADoorWidth>> <<y>>)" 
        style = "<<gMapThemes.getStyleDoor()>>"
        />
        ';

    return (open)?openedDoor:closedDoor;
}


createHeader(maximumHeight, maximumWidth) {
    return new StringBuffer()
        .append('<?xml version="1.0" ')
        .append('encoding="UTF-8"?>\n')
        .append('<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n')
        .append('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" ')
        .append('width="').append(maximumWidth).append('" ')
        .append('height="').append(maximumHeight).append('" ')
        .append('style="<<gMapThemes.getBackgroundStyle()>>" ')
        .append('>')
        ;
}

createFooter() {
    return '</svg>';
}

function createCenteredEllipse(x,y,  width, height, style?, attr?) {
    if(style == nil) {
        style = gMapThemes.getRectStyle();
    }
    if(attr == nil) {
        attr = gMapThemes.getRectAttributes();
    }
    local halfWidth = (width>>1);
    local halfHeight = (height>>1);
    return new StringBuffer().append('<ellipse cx="<<x+halfWidth>>" cy="<<y+halfHeight>>" rx="100" ry="50" stroke="black" fill="white" style="<<style>>" />');
}

function createSquare(x,y, height, style?, attr?) {
    if(style == nil) {
        style = gMapThemes.getRectStyle();
    }
    if(attr == nil) {
        attr = gMapThemes.getRectAttributes();
    }
    local halfHalfWidth = height>>2;
    return '<rect x="<<x>>" y="<<y-halfHalfWidth>>" width="<<height>>" height="<<height>>" <<attr>> style="<<style>>" />';
}

function createRect(x,y, width, height, style?, attr?) {
    if(style == nil) {
        style = gMapThemes.getRectStyle();
    }
    if(attr == nil) {
        attr = gMapThemes.getRectAttributes();
    }
    return '<rect x="<<x>>" y="<<y>>" 
            width="<<width>>" height="<<height>>"
            <<attr>> 
            style="<<style>>" 
            />';
}

function createText(x,y,name) {
    return '<text x="<<x>>" y="<<y>>" <<gMapThemes.getTextAttributes()>> style="<<gMapThemes.getTextStyle()>>"><<name>></text>';
}

function createMiddleCentedText(x,y,name, style?, attr?) {
    if(style == nil) {
        style = gMapThemes.getTextStyle();
    }
    if(attr == nil) {
        attr = gMapThemes.getTextAttributes();
    }
    return '<text x="<<x>>" y="<<y>>" text-anchor="middle" <<attr>>  style="<<style>>"><<name>> </text>';
}

function createUpSymbol(x, y, width, height, style?, attr?) {
    if(style == nil) {
        style = gMapThemes.getLineStyle();
    }
    if(attr == nil) {
        attr = gMapThemes.getUpDownSymbolsAttributes();
    }
    return '<path <<attr>> transform="translate(<<x>> <<y+2>>)" style="<<style>>" 
            d="M10,0 L17,5 
            L12,5
            L12,13 
            L8,13 
            L8,5 
            L3,5 
            L10,0"  />';
}

function createDownSymbol(x, y, width, height, style?, attr?) {
    if(style == nil) {
        style = gMapThemes.getLineStyle();
    }
    if(attr == nil) {
        attr = gMapThemes.getUpDownSymbolsAttributes();
    }
    return '<path <<attr>>
        transform="rotate(180 <<x+width>> <<y+height-2>>) translate(<<x+width>> <<y+height-2>>)" style="<<style>>" 
            d="M10,0 L17,5 
            L12,5
            L12,13 
            L8,13 
            L8,5 
            L3,5 
            L10,0"  />';
}


function createInSymbol(x, y, width, height, style?, attr?) {
    style = style? style : gMapThemes.getRectStyle();
    attr = attr? attr : gMapThemes.getRectAttributes();
    return '<text x="<<x+width-25>>" y="<<y+15>>" style="<<style>>">[in]</text>';
}

function createOutSymbol(x, y, width, height, style?, attr?) {
    style = style? style : gMapThemes.getRectStyle();
    attr = attr? attr : gMapThemes.getRectAttributes();
    return '<text x="<<x+5>>" y="<<y+height-5>>" style="<<style>>">[out]</text>';
}

function createDashedLine(x1,y1,x2,y2, style?, attr?) {
    style = style? style : gMapThemes.getLineStyle();
    attr = attr? attr : 'stroke-dasharray="10 5"';
    return createLine(x1,y1,x2,y2, style, attr);
}

function createLine(x1,y1,x2,y2, style?, attr?) {
    style = style? style : gMapThemes.getLineStyle();
    attr = attr? attr : gMapThemes.getLineAttributes();
    return '<line x1 = "<<x1>>" y1 = "<<y1>>" x2 = "<<x2>>" y2 = "<<y2>>" style="<<style>>" <<attr>> />';
}


function createBezierCurve(x1,y1,   cx1,cy1,   cx2,cy2,   x2,y2, style?, attr?) {
    style = style? style : gMapThemes.getLineStyle();
    attr = attr? attr : gMapThemes.getLineAttributes();    
    return '<path d="M <<x1>> <<y1>> C <<cx1>> <<cy1>>, <<cx2>> <<cy2>>, <<x2>> <<y2>>" <<attr>> style="<<style>>" />';
}

function createDashedCrookedLine(x1,y1,x2,y2, direction, flipped?, xValue?, yValue?) {
    return createCrookedLine(x1,y1,x2,y2, direction, flipped, xValue, yValue, 'stroke-dasharray="10 5" fill="none"');
}  
      
function createCrookedLine(x1,y1,x2,y2, direction, flipped?, xValue?, yValue?, style?, attr?) {
    style = style? style : gMapThemes.getLineStyle();
    attr = attr? attr : gMapThemes.getLineAttributes();
    if(xValue==nil) {
        xValue = 30;
    }
    if(yValue==nil) {
        yValue = 30;
    }
    if(direction==&northeast) {
        return '<path d="M <<x1>>,<<y1>>  <<x1>>,<<y1-yValue>>  <<x2-xValue>>,<<y2>> <<x2>>,<<y2>>" <<attr>> style = "<<gMapThemes.getLineStyle()>>" />';
    }
    if(direction==&southwest) {
        if(flipped) {
            return '<path d="M <<x1>>,<<y1>>  <<x1>>,<<y1+yValue>>  <<x2+xValue>>,<<y2>> <<x2>>,<<y2>>"
                <<attr>> style = "<<style>>" />';
        }
        return '<path d="M <<x1>>,<<y1>>  <<x1-xValue>>,<<y1>>  <<x2>>,<<y2-yValue>> <<x2>>,<<y2>>"
            <<attr>> style = "<<style>>" />';
    }
    if(direction==&southeast) {
        if(flipped) {
            return '<path d="M <<x1>>,<<y1>>  <<x1>>,<<y1+yValue>>  <<x2-xValue>>,<<y2>> <<x2>>,<<y2>>"
                <<attr>> style = "<<style>>" />';
        }
        return '<path d="M <<x1>>,<<y1>>  <<x1+xValue>>,<<y1>>  <<x2>>,<<y2-yValue>> <<x2>>,<<y2>>"
            <<attr>> style = "<<style>>" />';
    }
    return createLine(x1,y1,x2,y2);
}



gMapThemes: InitObject {

    currentTheme = 'default'
    upDownSymbolsAttributes = [ * -> ''];

    rectAttributes = [ * -> '']
    rectStyle = [ * -> '']

    lineStyleMap = [ * -> '']
    
    textStyleMap = [ * -> 'font: bold 14 sans-serif;']
    textAttributesMap = [ * -> ' font-size="12" ']
    
    backgroundStyleMap = [ * -> '']
    
    styleDoor = [ * -> '']
    styleDoorKnob = [ * -> '']
    styleDoorDarkness = [ * -> '']

    playerRectStyle = [ * -> '']
    playerRectAttributes = [ * -> ' fill="none" ']
    lineAttributesMap = [* -> 'fill="none" ']
    


    execute() {
        // Default
        rectAttributes['default'] = 'rx="8" ry="8" stroke-width="1" stroke="black" fill="white"';
        playerRectAttributes['default'] = 'rx="8" ry="8" stroke-width="1" stroke="black" fill="white"';


        lineStyleMap['default'] = 'font: bold 16px sans-serif; stroke:rgb(70,70,70);stroke-width:2';
        backgroundStyleMap['default'] = 'background-color:lightgray;';
        styleDoor['default'] = 'fill:white; stroke:black;';
        styleDoorKnob['default'] = 'stroke:black; fill:black;';
        styleDoorDarkness['default'] = 'fill:black; stroke:black;';
        playerRectStyle['default'] = 'stroke:black; stroke-width:3';
        textStyleMap['default']= 'font: bold 14 sans-serif;';
        upDownSymbolsAttributes['default'] = 'stroke="black" fill="white"';


        // Darkmode
        rectAttributes['darkmode'] = 'rx="8" ry="8" stroke-width="1" stroke="white" fill="rgb(30,30,30)" ';
        playerRectAttributes['darkmode'] = 'rx="8" ry="8" stroke-width="1" stroke="white" fill="rgb(30,30,30)" ';

        lineStyleMap['darkmode'] = 'stroke:lightgray;stroke-width:2';
        textStyleMap['darkmode']= 'font: bold 16px sans-serif; fill:lightgray;';
        backgroundStyleMap['darkmode'] = 'background-color:rgb(10,10,10)';
        styleDoor['darkmode'] = 'fill:darkness; stroke:lightgray;';
        styleDoorKnob['darkmode'] = 'stroke:lightgray; fill:lightgray;';
        styleDoorDarkness['darkmode'] = 'fill:lightgray; stroke:lightgray;';
        playerRectStyle['darkmode'] = 'stroke:white; stroke-width:3';
        upDownSymbolsAttributes['darkmode'] = 'stroke="black" fill="white"';

        backgroundStyleMap['bright'] = 'background-color: rgb(255,250,230);';
        rectAttributes['bright'] = 'rx="6" ry="6" stroke-width="3" stroke="#7e4e3e" fill="#f9eedb"';
        lineStyleMap['bright'] = 'font: bold 16px sans-serif; stroke: #21151c; stroke-width:5';
        playerRectStyle['bright'] = 'stroke:rgb(20,130,130); stroke-width:4';
        textStyleMap['bright']= 'font: bold 18px sans-serif;';
        upDownSymbolsAttributes['bright'] = 'stroke="black" fill="white"';

        // Zork map style
        //rectAttributes['zork'] = 'rx="1" ry="1" stroke-width="1" stroke="brown" fill="orange"';
        //lineStyleMap['zork'] = 'font: bold 16px sans-serif; stroke:rgb(70,70,70);stroke-width:2';
        backgroundStyleMap['zork'] = 'background-color:#f7dcb9;';
        rectAttributes['zork'] = 'rx="2" ry="2" stroke-width="3" stroke="#7e4e3e" fill="#f8dcb7"';
        playerRectAttributes['zork'] = 'rx="2" ry="2" stroke-width="3" stroke="#7e4e3e" fill="#f8dcb7"';
        lineStyleMap['zork'] = 'font: bold 16px sans-serif; stroke:#21151c; stroke-width:5';
        //playerRectStyle['zork'] = 'stroke:#00aecd; stroke-width:4';
        playerRectStyle['zork'] = 'stroke:rgb(20,130,130); stroke-width:4';
        textStyleMap['zork']= 'font: bold 18px sans-serif;';

    }
    getPlayerRectStyle() {return playerRectStyle[currentTheme]; }
    getPlayerRectAttributes() {return playerRectAttributes[currentTheme]; }
    getStyleDoor() { return styleDoor[currentTheme]; }
    getStyleDoorKnob() { return styleDoorKnob[currentTheme]; }
    getStyleDoorDarkness() { return styleDoorDarkness[currentTheme]; }
    getRectAttributes() { return rectAttributes[currentTheme]; } 
    getUpDownSymbolsAttributes() { return upDownSymbolsAttributes[currentTheme]; }
    getLineAttributes() {return lineAttributesMap[currentTheme]; }
    getLineStyle() { return (lineStyleMap[currentTheme]); }
    getTextStyle() { return (textStyleMap[currentTheme]); }
    getTextAttributes() { return (textAttributesMap[currentTheme]); }
    getRectStyle() { return (rectStyle[currentTheme]); }
    getBackgroundStyle() { return (backgroundStyleMap[currentTheme]); }

}

;