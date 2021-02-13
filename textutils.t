#charset "us-ascii"
#include <tads.h>
#include <strbuf.h>

function acronymize(string, abbreviateToCharLength?) {    

    if(string.length == 1) {
        return string;
    }
    
    local stringList = string.split(' ');
    local wordCount = (stringList.length);
    local lengthPerWord = (abbreviateToCharLength/wordCount);    
    local rest = abbreviateToCharLength - (lengthPerWord*wordCount);
    local stringBuffer = new StringBuffer();
    
    foreach(local str in stringList) {
        local a = new StringBuffer();

        // Add a possible rest of words if the previous word didn't use all.
        local word = str.substr(1, lengthPerWord + rest);
        a.append(word);

        //Add the unused length to variable rest, so it can be used by next word.
        if(word.length<lengthPerWord) {
            rest += lengthPerWord- word.length; 
            //"<<word>> didn't use all words, adding a rest to next word: <<rest>>";
        } else {
            rest = 0;
        }
        if(a.length>0) {
            a[1] = a[1].toUpper();
            stringBuffer.append(a);
        }
    }
    local acronymizedStr = toString(stringBuffer);
    return acronymizedStr;
}

function sayTimes(text, times) {
    say(repeatChar(text,times));
}

function fillUpStringWithBlanks(string, stringLength) {
    if(string.length < stringLength) {
        local blanksToAdd = stringLength - string.length;
        string = '<<string>><<repeatChar('\ ', blanksToAdd)>>';
    }
    return string;
}

function repeatChar(text, times) {
    local str = new StringBuffer();
    for(local x=0; x<times;x++) str.append(text);
    return toString(str);
}

function oppositeOf(dirType) {
    switch(dirType) {
        case &north: return &south;
        case &south: return &north;
        case &east: return &west;
        case &west: return &east;
        case &northeast:  return &southwest;
        case &northwest:  return &southeast;
        case &southeast:  return &northwest;
        case &southwest:  return &northeast;
        case &up: return &down;
        case &down: return &up;
        case &in: return &out;
        case &out: return &in;
        case &forward: return &aft;
        case &aft: return &forward;
        case &starboard: return &port;
        case &port: return &starboard;
        default: throw new Exception('The direction cannot be reversed');
    }
}

function sayDir(dirType) {
    switch(dirType) {
        case &north: "north"; break;
        case &south: "south"; break;
        case &east: "east"; break;
        case &west: "west"; break;
        case &northeast: "northeast"; break;
        case &northwest: "northwest"; break;
        case &southeast: "southeast"; break;
        case &southwest: "southwest"; break;
        case &up: "up"; break;
        case &down: "down"; break;
        case &in: "in"; break;
        case &out: "out"; break;
        case &forward: "forward"; break;
        case &aft: "aft"; break;
        case &starboard: "starboard"; break;
        case &port: "port"; break;
        default: throw new Exception('A direction hard to define');
    }
}



function dirToText(dirType,abbr) {
    switch(dirType) {
        case &north: return abbr?'n':'north'; 
        case &south: return  abbr?'s':'south'; 
        case &east: return  abbr?'e':'east'; 
        case &west: return  abbr?'w':'west'; 
        case &northeast: return  abbr?'ne':'northeast'; 
        case &northwest: return  abbr?'nw':'northwest'; 
        case &southeast: return  abbr?'se':'southeast'; 
        case &southwest: return  abbr?'sw':'southwest'; 
        case &up: return  abbr?'u':'up'; 
        case &down: return  abbr?'d':'down'; 
        case &in: return  abbr?'i':'in'; 
        case &out: return  abbr?'o':'out'; 
        case &forward: return  abbr?'f':'forward'; 
        case &aft: return  abbr?'a':'aft'; 
        case &starboard: return  abbr?'s':'starboard'; 
        case &port: return  abbr?'p':'port'; 
        default: throw new Exception('A direction hard to define');
    }
}




function renderLegendGeneric(legendHeader, rooms, legendColumns?, legendWidth?) {
    rooms = rooms.subset({x:x.mapCoords[3]==libGlobal.playerChar.location.mapCoords[3]});
    if(legendColumns==nil) {
        legendColumns = 2;
    }
    if(legendWidth==nil) {
        legendWidth = 40;
    }
    local stringBuffer = new StringBuffer();    
    local idx = 0;
    stringBuffer.append('\n<<legendHeader>>\b');
    foreach(local r in rooms) {
        local keyValueStr;
        if((r.name == nil)) {
            keyValueStr = 'U = Unnamed location';
        } else if(r.propDefined(&mapName)) {
            //keyValueStr = '<<r.mapName>> = <<r.name>>';
            local abbrev = r.mapName.substr(0,1).toUpper();
            keyValueStr = '<<abbrev>> = <<r.mapName>>';
        } else {
            local abbrev = r.name.substr(0,1).toUpper();
            keyValueStr = '<<abbrev>> = <<r.name>>';
        }
        keyValueStr = fillUpStringWithBlanks(keyValueStr, legendWidth);
        stringBuffer.append(keyValueStr);
        if(++idx % legendColumns==0) {
            stringBuffer.append('\n');
        }
    }
    return toString(stringBuffer.append('\b'));
}
