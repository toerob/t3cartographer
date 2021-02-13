#charset "us-ascii"

/*
 *   Copyright (c) 1999, 2002 by Michael J. Roberts.  Permission is
 *   granted to anyone to copy and use this file for any purpose.  
 *   
 *   This is a starter TADS 3 source file.  This is a complete TADS game
 *   that you can compile and run.
 */

#include <adv3.h>
#include <en_us.h>




gameMain: GameMainDef
    initialPlayerChar = me
    usingWebUi = nil
    usingHTMLInterpreter = nil
    showIntro() {
        "Using webui? >";
        usingWebUi = yesOrNo();
        "OK!";

        if(!usingWebUi) {
            "You want the map in html? >";
            usingHTMLInterpreter = yesOrNo();
        }

    }
;

versionInfo: GameID
    IFID = '' // obtain IFID from http://www.tads.org/ifidgen/ifidgen
    name = 'Example 2 - WebUI Tads3 - adv3 library'
    byline = 'by Tomas Öberg'
    htmlByline = 'by <a href="mailto:tomaserikoberg@gmail.com">Tomas Öberg</a>'
    version = '1'
    authorEmail = 'Tomas Öberg tomaserikoberg@gmail.com'
    desc = 'Example 2'
    htmlDesc = 'Example 2'
;

firstRoom: Room 'Starting Room'
    "Add your description here. "
    south = nextRoom
;

+me: Actor
;

nextRoom: Room 'Next room'
    "Not much here"
    north = firstRoom
    east = nextRoomInnerDoor
;

+nextRoomInnerDoor: Door -> nextRoomOuterDoor 'door' 'door';

eastOfNextRoom: Room 'East of next room'
    "Not much here either"
    west = nextRoomOuterDoor
;
+nextRoomOuterDoor: Door -> nextRoomInnerDoor 'door' 'door';

DefineIAction(Map)
    execAction() {
        local roomCrawler = new RoomCrawler();
        local rooms = roomCrawler.crawl(gPlayerChar.location, true); 
        
        if(gameMain.usingWebUi) {

            local svgTileMap = new SvgTileMap(roomCrawler.maxX, roomCrawler.maxY);
            svgTileMap.acronymLength = nil; //20;
            svgTileMap.renderPlayerLocation = true;
            svgTileMap.populate(rooms);
            local svgMap =  svgTileMap.render();
            //saveStringToFile(svgMap.render, 'mapdata.svg');
            "<<svgMap>>";

        } else if(gameMain.usingHTMLInterpreter) {

            local htmlMap = new HtmlTileMap(roomCrawler.maxX,roomCrawler.maxY);
            htmlMap.populate(rooms);
            saveStringToFile(htmlMap.render(), 'mapdata.html');
            "\n<<htmlMap.render()>>\n";

        } else {

            local textTileMap = new TextTileMap(roomCrawler.maxX,roomCrawler.maxY);
            textTileMap.acronymLength=2;
            textTileMap.renderPlayerLocation = true;
            textTileMap.populate(rooms);
            "<<textTileMap.render()>>";
            
        }
    }
;

//Comment away this when not compiling for webui
WebResourceResFile
   vpath = static new RexPattern('/images/')
;

VerbRule(Map) 
    'map' 
    : MapAction
    verbPhrase = 'map/mapping'
;
