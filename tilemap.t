#charset "us-ascii"
#include <tads.h>
#include <strbuf.h>

class Tilemap: object
    rows = nil
    columns = nil
    cells = nil
    playerTile = nil

    textMaxLength = 2
    cellCount = 0

    maxVisibleColumns = nil
    maxVisibleRows = nil

    columnOffset = 0
    rowOffset = 0

    colDelimiter = ''

    rowStartDelimiter = ''
    rowDelimiter = '\n'

    construct(columns, rows) {
        self.rows = rows;
        self.columns = columns;        

        //"Constructing table of rows*cols: <<rows>>*<<columns>>\n";

        self.maxVisibleRows = rows;
        self.maxVisibleColumns = columns;

        self.cellCount = rows*columns;
        clear();
    }
    
    clear() {
        cells = new Vector(cellCount, cellCount)
                .fillValue('<<repeatChar('\ ', textMaxLength)>>');
    }

    convertToCell(col, row) {
        local index = (row * columns) + col + 1;
        //"index:<<index>> total:<<cellCount>>\n";
        return index;
    }

    setTile(col, row, value) {
        local idx = convertToCell(col, row);
        cells[idx] = value;
    } 

    getTile(col, row) {
        return cells[convertToCell(col, row)];
    } 

    testTile(col,row) {
        local cell = convertToCell(col, row);
        return (cell > 0 && cell <= cellCount);
    }
    testCell(cell) {
        return (cell > 0 && cell <= cellCount);
    }
    
    getVisibleRows() { 
        return min(rows, maxVisibleRows+rowOffset); 
    }

    getVisibleColumns() { 
        return min(columns, maxVisibleColumns+columnOffset); 
    }

    getRowOffset() {
        return rowOffset < rows? rowOffset : 0;
    }

    getColumnOffset() {
        return columnOffset < columns? columnOffset : 0;
    }

    validTile(column,row) {
        //column <= columns && row <= rows;
        local cell = convertToCell(column, row);
        //"cell:<<cell>>/<<cellCount>>\n";
        return cell <= cellCount;
    }

    render() {
        local str = new StringBuffer();
        for(local row = rowOffset; row < getVisibleRows(); row++) {
            str.append(rowStartDelimiter);
            for(local column = columnOffset; column < getVisibleColumns(); column++) {
                if(validTile(column,row)) {
                    local cell = getTile(column, row);
                    str.append(renderTile(column, row, cell))
                        .append(colDelimiter);
                }

            }
            str.append(rowDelimiter);
        }
        return str;
    }

    renderTile(column, row, cell) {
        return toString(cell);
    }   


    setPlayerTile(x,y) { 
        playerTile = [x, y]; 
    }
    
    isPlayerInTile(x,y) { 
        if(playerTile == nil) {
            return nil;
        }
        return playerTile[1]==x && playerTile[2]==y; 
    } 
;
