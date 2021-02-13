#charset "us-ascii"
#include <tads.h>
#include <strbuf.h>

class TileMapPayload: object 
    name = 'Unnamed'
    abbreviatedName = '_'
    roomDirections = ''
    roomRef = nil
    construct(name, abbreviatedName) {
        self.name = name;
        self.abbreviatedName = abbreviatedName;
    }
;

class TextTileMap: Tilemap {
    maxVisibleColumns = 4
    maxVisibleRows = 8
    columnOffset = 0
    rowOffset = 0
    textMaxLength = 10
    //columnDelimiterLeft = '' // Unicode supported? '─ ═ |┃⌇╏┊┇║
    colDelimiter = ''
    rowDelimiter = '\n'

    renderPlayerLocation = nil
    acronymLength = nil 

    // A table containing the mapping between acronymized 
    // texts and original names, useful for legends if 
    // names are abbreviated really short.
    acronymizeTable = new LookupTable();     

    drawDivider(dividerChar) {
        "\n<<sayTimes(dividerChar,(getVisibleColumns())*textMaxLength)>>\n";
    }

    renderDivider(dividerChar) {
        return repeatChar(dividerChar,(getVisibleColumns())*textMaxLength);
    }

    rightAlign(text) {
        local maxRight = (getVisibleColumns()+1)*textMaxLength;
        local offset = maxRight - text.length;
        return repeatChar('\ ', offset) + text;
    }

    renderTile(x, y, tileData) {
        local output = new StringBuffer();
        if(tileData==nil) {
            return output.append(''); //'nil(<<x>>/<<y>>)');
        }
        if(tileData.abbreviatedName) {
            local totalLength = tileData.abbreviatedName.length();
            if(renderPlayerLocation && isPlayerInTile(x,y)) {
                output.append('*<<tileData.abbreviatedName>>*');
                totalLength+=2;
            } else {
                output.append('<<tileData.abbreviatedName>>'); 
            }
        
            if(totalLength<textMaxLength) {
                output.append(repeatChar('\ ', textMaxLength-totalLength));
            }
        } else if(tileData.name) {

            local totalLength = tileData.name.length();
            if(renderPlayerLocation && isPlayerInTile(x,y)) {
                output.append('*<<tileData.name>>*');
                totalLength+=2;
            } else {
                output.append('<<tileData.name>>'); 
            }
        
            if(totalLength<textMaxLength) {
                output.append(repeatChar('\ ', textMaxLength-totalLength));
            }

        } else {
            
            output.append(repeatChar('\ ', textMaxLength));
        }

        return toString(output);
    }

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

            // Override name if supplied
            if(r.propDefined(&mapName)) {
                abbreviatedName = r.mapName;
            }
            acronymizeTable[abbreviatedName] = roomName;

            local currentLevel = libGlobal.playerChar.location.mapCoords[3];
            if(r.mapCoords[3]  == currentLevel) {
                local mapData = new TileMapPayload(roomName, abbreviatedName);
                mapData.roomRef = r;
                // TODO: If tile already busy, skip drawing it for now.
                //"cols:<<cols>>, rows:<<rows>> x:<<x>> y:<<y>>\n";
                local tmp = getTile(x,y);
                if(tmp && (tmp).ofKind(TileMapPayload)) {
                    //"skip\n";
                    continue;
                }
                //"x/y: <<x>>/<<y>>\n";
                setTile(x,y, mapData);
                if(libGlobal.playerChar.location == r) {
                    setPlayerTile(x,y);
                }
            }
        }
    }

    renderLegend(legendHeader) {
        local legendColumns = 2;
        local legendRows = (acronymizeTable.getEntryCount()/legendColumns);
        local legend = new Tilemap(legendRows, legendColumns);
        legend.textMaxLength = 30;

        local stringBuffer = new StringBuffer();    
        local idx = 0;

        stringBuffer
        .append('\n')
        .append('<<legendHeader>>\b')
        ;

        acronymizeTable.forEachAssoc(function(key, value) {
            local keyValueStr = '<<key>> = <<value>>';
            keyValueStr = fillUpStringWithBlanks(keyValueStr,40);
            stringBuffer.append(keyValueStr);
            if(++idx % 2==0) {
                stringBuffer.append('\n');
            }
        });
        //stringBuffer.append(legend.renderDivider('='));
        stringBuffer.append('\b');
        return toString(stringBuffer);
    }
}