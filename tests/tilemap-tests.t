#charset "us-ascii"
#include <tads.h>

grid5x6_trail_pattern: UnitTest 
    //only = true
    //skip = true
    map = nil
    run() {
        map = new Tilemap(5,6);
    
        //assertEquals(30, map.cells.length);
        //"\nConstructing a table of 2*2=<<map.cellCount>> cell(s)\n ";
        map.colDelimiter = ' ';
        map.rowDelimiter = '|';
        map.textMaxLength = 1;
        map.setTile(1,0,'a');  
        map.setTile(2,1,'b');
        map.setTile(2,2,'c');
        map.setTile(1,3,'d');
        map.setTile(0,2,'e');
        
        assertEquals(30, map.cellCount); 
        //assertEquals('\ b\ |e\ c\ |\ d\ |\ |\ |', map.render());
        map.rowDelimiter = '\n'; 
        //"<<map.render()>>";
    }
;

test_2x2_tilemap_rendering: UnitTest
    //only = true
    run() {
        local map;
        map = new Tilemap(2,2);
        
        assertEquals(4, map.cells.length);
        //"\nConstructing a table of 2*2=<<map.cellCount>> cell(s)\n ";
        map.colDelimiter = ' ';
        map.rowDelimiter = '|';
        map.setTile(0,0,'1');  
        map.setTile(1,0,'2');
        map.setTile(0,1,'3');
        map.setTile(1,1,'4');
        

        assertEquals(4, map.cellCount); 
        assertEquals('1 2 |3 4 |', map.render());
        //map.rowDelimiter = '\n'; "<<map.render()>>";
    }
;

test_3x3_tilemap_rendering: UnitTest
    run() {
        local map;
        map = new Tilemap(3,3);
        assertEquals(9, map.cells.length);
        //"\nConstructing a table of 3*3=<<map.cellCount>> cell(s)\n ";
        map.colDelimiter = ' ';
        map.rowDelimiter = '|';
        map.setTile(0,0,'1');
        map.setTile(1,0,'2');
        map.setTile(2,0,'3');
        map.setTile(0,1,'4');
        map.setTile(1,1,'5');
        map.setTile(2,1,'6');
        map.setTile(0,2,'7');
        map.setTile(1,2,'8');
        map.setTile(2,2,'9');
        assertEquals(9, map.cellCount); 
        assertEquals('1 2 3 |4 5 6 |7 8 9 |', map.render());
        //map.rowDelimiter = '\n'; "<<map.render()>>";
    }
;

test_4x7_tilemap_rendering: UnitTest
    run() {
        local map = new Tilemap(7,4);
        assertEquals(28, map.cells.length); // This might grow 

        map.colDelimiter = ' ';
        map.rowDelimiter = '|';
        map.textMaxLength = 3;
        //"\nConstructing a table of 4*7=<<map.cellCount>> cell(s)\n ";
        map.setTile(0,0,'01');
        map.setTile(1,0,'02');
        map.setTile(2,0,'03');
        map.setTile(3,0,'04');
        map.setTile(4,0,'05');
        map.setTile(5,0,'06');
        map.setTile(6,0,'07');


        map.setTile(0,1,'08');
        map.setTile(1,1,'09');
        map.setTile(2,1,'10');
        map.setTile(3,1,'11');
        map.setTile(4,1,'12');
        map.setTile(5,1,'13');
        map.setTile(6,1,'14');

        map.setTile(1-1,2,'15');
        map.setTile(2-1,2,'16');
        map.setTile(3-1,2,'17');
        map.setTile(4-1,2,'18');
        map.setTile(5-1,2,'19');
        map.setTile(6-1,2,'20');
        map.setTile(7-1,2,'21');

        map.setTile(1-1,3,'22');
        map.setTile(2-1,3,'23');
        map.setTile(3-1,3,'24');
        map.setTile(4-1,3,'25');
        map.setTile(5-1,3,'26');
        map.setTile(6-1,3,'27');
        map.setTile(7-1,3,'28');        
        assertEquals(28, map.cellCount); 
        assertEquals('01 02 03 04 05 06 07 |08 09 10 11 12 13 14 |15 16 17 18 19 20 21 |22 23 24 25 26 27 28 |',map.render(),);
        //map.rowDelimiter = '\n'; "<<map.render()>>";
    }
;


test_offsetting_columns: UnitTest
    run() {
        local map = new Tilemap(2,2); //TODO: createMap method that sets all this
        assertEquals(4, map.cells.length);
        map.colDelimiter = ' ';
        map.rowDelimiter = '|';
        map.setTile(0,0,'1');  
        map.setTile(1,0,'2');
        map.setTile(0,1,'3');
        map.setTile(1,1,'4');
        // map.maxVisibleColumns = 2;

        map.columnOffset=1;
        assertEquals(4, map.cellCount); 
        assertEquals('2 |4 |', map.render());
        assertEquals(2, map.maxVisibleColumns);
        //map.rowDelimiter = '\n'; "<<map.render()>>";
        //"maxy:<<map.maxVisibleColumns>>";
    }
;


test_offsetting_rows: UnitTest
    run() {
        local map = new Tilemap(2,2); //TODO: createMap method that sets all this
        assertEquals(4, map.cells.length);
        assertEquals(2, map.maxVisibleRows);
        map.colDelimiter = ' ';
        map.rowDelimiter = '|';
        map.setTile(0,0,'1');  
        map.setTile(1,0,'2');
        map.setTile(0,1,'3');
        map.setTile(1,1,'4');
        map.rowOffset=1;
        assertEquals(4, map.cellCount); 
        assertEquals('3 4 |', map.render());
        //map.rowDelimiter = '\n'; "<<map.render()>>";
    }
;
