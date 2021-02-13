#charset "us-ascii"
#include <tads.h>

generateSquaresWithMoreRowsThanColumns_ne_sw: UnitTest 
    run() {        
        local x = generateSquare(3, 5,&northeast);
        assertEquals('\ \ /',  x[1]);
        assertEquals('\ \ \ ', x[2]);
        assertEquals('\ /\ ',  x[3]);
        assertEquals('\ \ \ ', x[4]);
        assertEquals('/\ \ ',  x[5]);

        x = generateSquare(3, 5,&southwest);
        assertEquals('\ \ /',  x[1]);
        assertEquals('\ \ \ ', x[2]);
        assertEquals('\ /\ ',  x[3]);
        assertEquals('\ \ \ ', x[4]);
        assertEquals('/\ \ ',  x[5]);
    }
;

generateSquaresWithMoreRowsThanColumns_nw_se: UnitTest 
    run() {        
        local x = generateSquare(3, 5,&northwest);
        //x.forEach({y:"[<<y>>]\n"});
        assertEquals('\\\ \ ',  x[1]);
        assertEquals('\ \ \ ', x[2]);
        assertEquals('\ \\\ ', x[3]);
        assertEquals('\ \ \ ', x[4]);
        assertEquals('\ \ \\',  x[5]);

        x = generateSquare(3, 5,&southeast);
        //x.forEach({y:"[<<y>>]\n"});
        assertEquals('\\\ \ ',  x[1]);
        assertEquals('\ \ \ ', x[2]);
        assertEquals('\ \\\ ', x[3]);
        assertEquals('\ \ \ ', x[4]);
        assertEquals('\ \ \\',  x[5]);
    }
;


generateSquaresWithMoreRowsThanColumns_ew: UnitTest 
    run() {        
        local x = generateSquare(3, 5,&east);
        //x.forEach({y:"[<<y>>]\n"});
        assertEquals('\ \ \ ',  x[1]);
        assertEquals('\ \ \ ', x[2]);
        assertEquals('___', x[3]);
        assertEquals('\ \ \ ', x[4]);
        assertEquals('\ \ \ ',  x[5]);

        x = generateSquare(3, 5,&west);
        //x.forEach({y:"[<<y>>]\n"});
        assertEquals('\ \ \ ',  x[1]);
        assertEquals('\ \ \ ', x[2]);
        assertEquals('___', x[3]);
        assertEquals('\ \ \ ', x[4]);
        assertEquals('\ \ \ ',  x[5]);
    }
;



// TODO: Problems asserting "|"-token. 
/*generateSquaresWithMoreRowsThanColumns_ns: UnitTest 
    //only = true
    skip = true
    run() {        
        local x = generateSquare(3, 5,&north);

        //assertEquals(' \ \||\ ',  x[2]);
        assertEquals('\ | \ ', x[1]);
        assertEquals('\ | \ ', x[2]);
        assertEquals('\ | \ ', x[3]);
        assertEquals('\ | \ ', x[4]);
        assertEquals('\ | \ ',  x[5]);
    }
;*/



generateSquaresWithMoreColumnsThanRows_ne_sw: UnitTest 
    run() {
        local x = generateSquare(5,3,&northeast);
        assertEquals('\ \ \ \ /',  x[1]);
        assertEquals('\ \ /\ \ ',  x[2]);
        assertEquals('/\ \ \ \ ',  x[3]);

        /*generateSquare(5,3,&northwest).forEach({x:"[<<x>>]\n"});
        generateSquare(5,3,&east).forEach({x:"[<<x>>]\n"});
        generateSquare(5,3,&north).forEach({x:"[<<x>>]\n"});*/
        //assertEquals(30, map.cellCount); 
    }
;

generateSquaresWithMoreColumnsThanRows_nw_se: UnitTest 
    run() {
        local x = generateSquare(5,3,&northwest);
        //x.forEach({x:"[<<x>>]\n"});
        assertEquals('\\\ \ \ \ ',  x[1]);
        assertEquals('\ \ \\\ \ ',  x[2]);
        assertEquals('\ \ \ \ \\',  x[3]);
    }
;

generateSquaresWithMoreColumnsThanRows_ew: UnitTest 
    run() {
        local x = generateSquare(5,3,&east);
        //x.forEach({x:"[<<x>>]\n"});
        assertEquals('\ \ \ \ \ ',  x[1]);
        assertEquals('_____',  x[2]);
        assertEquals('\ \ \ \ \ ',  x[3]);
    }
;


generateSquaresWithEqualColumnsAndRows_ne_sw: UnitTest 
    run() {
        local x = generateSquare(5, 5,&northeast);
        //x.forEach({x:"[<<x>>]\n"});
        assertEquals('\ \ \ \ /',  x[1]);
        assertEquals('\ \ \ /\ ', x[2]);
        assertEquals('\ \ /\ \ ',  x[3]);
        assertEquals('\ /\ \ \ ', x[4]);
        assertEquals('/\ \ \ \ ', x[5]);

        x = generateSquare(5, 5,&southwest);
        assertEquals('\ \ \ \ /',  x[1]);
        assertEquals('\ \ \ /\ ', x[2]);
        assertEquals('\ \ /\ \ ',  x[3]);
        assertEquals('\ /\ \ \ ', x[4]);
        assertEquals('/\ \ \ \ ', x[5]);
    }
;

generateSquaresWithEqualColumnsAndRows_nw_se: UnitTest 
    run() {        
        local x = generateSquare(5, 5,&northwest);
        //x.forEach({x:"[<<x>>]\n"});
        assertEquals('\\\ \ \ \ ',  x[1]);
        assertEquals('\ \\\ \ \ ', x[2]);
        assertEquals('\ \ \\\ \ ', x[3]);
        assertEquals('\ \ \ \\\ ', x[4]);
        assertEquals('\ \ \ \ \\',  x[5]);
        x = generateSquare(5, 5,&southeast);
        //x.forEach({x:"[<<x>>]\n"});
        assertEquals('\\\ \ \ \ ',  x[1]);
        assertEquals('\ \\\ \ \ ', x[2]);
        assertEquals('\ \ \\\ \ ', x[3]);
        assertEquals('\ \ \ \\\ ', x[4]);
        assertEquals('\ \ \ \ \\',  x[5]);

    }
;

generateSquaresWithEqualColumnsAndRows_ew: UnitTest 
    run() {        
        local x = generateSquare(5, 5,&east);
        assertEquals('\ \ \ \ \ ',  x[1]);
        assertEquals('\ \ \ \ \ ', x[2]);
        assertEquals('_____', x[3]);
        assertEquals('\ \ \ \ \ ', x[4]);
        assertEquals('\ \ \ \ \ ',  x[5]);
        x = generateSquare(5, 5,&west);
        assertEquals('\ \ \ \ \ ',  x[1]);
        assertEquals('\ \ \ \ \ ', x[2]);
        assertEquals('_____', x[3]);
        assertEquals('\ \ \ \ \ ', x[4]);
        assertEquals('\ \ \ \ \ ',  x[5]);

    }
;
