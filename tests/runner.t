#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "cartographer.h"

#define DEBUG 1

versionInfo: GameID
    IFID = 'F8CF2680-32CF-4C6B-BAC2-78A0AD1097E1'
    name = 'Tads 3 cartographer library test suite'
    byline = 'by Tomas Öberg'
    htmlByline = 'by <a href="mailto:tomaserikoberg@gmail.com">Tomas Öberg</a>'
    version = '1'
    authorEmail = 'Tomas Öberg tomaserikoberg@gmail.com'
    desc = 'A test suite Tads 3 cartographer library, http://github.com/toerob/t3mapper'
    htmlDesc = 'A test suite Tads 3 cartographer library, http://github.com/toerob/t3mapper'
;

gameMain: GameMainDef
    initialPlayerChar = testOperator
;

testRoom: Room 'test control';

+testOperator: Actor
    person = 2
;