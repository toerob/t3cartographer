#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/**
 * Menu is not included by default, since it is tied to the adv3lite library
 */
 
simpleMenuWindow: BannerWindow;

function menuMapBanner(map, message) {
    local flags = BannerStyleBorder | BannerStyleVScroll | BannerStyleAutoVScroll;
    simpleMenuWindow.showBanner(nil, BannerLast, nil,
                                    BannerTypeText, BannerAlignTop,
                                    100, BannerSizePercent, flags);
    local oldStr = simpleMenuWindow.setOutputStream();
    local retValue = displayMapAndMenuChoices(map, message, {:simpleMenuWindow.clearWindow()});
    outputManager.setOutputStream(oldStr);
    contentsMenuBanner.removeBanner();
    simpleMenuWindow.removeBanner();
    return retValue;
}


function displayMapAndMenuChoices(map, message, clearMethod?) {
    for(;;) {
        if(clearMethod) {
            clearMethod();
        }
        local stringBuffer = new StringBuffer()
            .append('<<map.renderDivider('=')>>')
            .append('\n<<map.render>>')
            .append('<<map.renderDivider('=')>>');
        if(message) {
            stringBuffer.append('<<message>>\n');
        }
        stringBuffer.append('\n');
        say(stringBuffer);
        local events = inputManager.getEvent(nil);
        if(events.length>0 && events[1] == InEvtKey) {
            local x = getEventAsMenuChoice(events);
            if(x==M_QUIT) return -1;

            local key = events[2];
            if(key == 'a') {
                if(map.columnOffset>0) 
                    map.columnOffset--;

            } else if(key =='d')  {
                if(map.columnOffset < map.columns-1)
                    map.columnOffset++;

            } else if(key == 'w') {
                if(map.rowOffset>0)
                    map.rowOffset--;

            } else if(key == 's') {
                if(map.rowOffset < map.rows-1)
                    map.rowOffset++;
            /* Not really usable right now since the ScalableTextTileMap doesn't yet auto expand its room name area. Feature to come
            } else if(key == '+') {
                map.zoomIn();
            } else if(key =='-')  {
                map.zoomOut();*/
            }
        }
    }
}

getEventAsMenuChoice(events) {
    if(events[1] == InEvtKey) {
        local key = events[2].toLower();
        return gLibMessages.menuKeyList.indexWhich({x: x.indexOf(key) != nil});
    }
    return nil;
}
