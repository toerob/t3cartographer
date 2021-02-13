#charset "us-ascii"
#include <tads.h>
#include <strbuf.h>
#include "cartographer.h"


//TODO: invert the arrows <-- R -->
/**
 * A simple wrapper of Text-renderer that outputs the map in 
 * html-format.
 */
class HtmlTileMap: TextTileMap
    style_TABLE = '' /*'
    background-color:rgb(40,40,40); 
    
    table-layout: fixed; 
    width:100%;
    border:solid black 1px; border-radius:6px;' */
   
   
    style_TD = '' /*'margin: 20px; padding: 10px; 
    text-align: center;
    background-color:rgb(80,80,80);'*/
    
    style_innerTABLE = '
    background-color: transparent; 
    table-layout: fixed; 
    width: 200px;
    border:solid black 0px; border-radius:6px; 
    border-collapse: collapse;
    ' 

    style_innerTD = ''
    /*
    background-color:rgb(40,40,40); 
    margin: 20px; padding: 10px; 
    text-align: center;
    width:120px;
    border-collapse: collapse;'*/


    // ----------------------------------------------------------------------------------
    render() {
        return new StringBuffer()
            .append('<table BORDER="0" CELLPADDING="0" CELLSPACING="0" style="border:none;">')
            .append(inherited())
            .append('</table>');

        //return createTable();
    }
    renderTile(x, y, tileData) {
        local cellSize = 32;
        if(!tileData.ofKind(TileMapPayload)) return '<td></td>';
        local roomData = inherited(x, y, tileData);
        return new StringBuffer()
            .append('<td NOWRAP HEIGHT="<<cellSize>>" >')
            .append(tableizeRoomData(tileData.roomRef, roomData))
            .append('</td>');
    }

    //bgcolor = '#eeeeff'
    bgcolor = '#eeeeee'

    tableizeRoomData(roomRef, roomName) {
        if(libGlobal.playerChar.location==roomRef) {
            roomName = '*' + roomName +'*';
        }

        local width = 32;
        local height = 32;

        local imageWidth = 32;
        local imageHeight = 32;

        //TODO: isValidDirection
        local blankImage = '<img alt="image" src=\"images/blank.png\" width=\"<<imageWidth>>\" height=\"<<height>>\" />';

        local str = new StringBuffer()
            .append('<table style="<<style_innerTABLE>>" BORDER="0" CELLPADDING="0" CELLSPACING="0" style="table-layout: fixed; border:none;">')
            .append('<tr>')
                // ===== NORTHWEST      =============================================
                .append('<td height=<<height>> align="left" valign="top">')
                //.append(roomRef.northwest?'\\':'')
                .append(isDirectionValid(roomRef,&northwest)?'<img alt="image" src=\"images/ne_sw.png\" width="<<imageWidth>>" height="<<height>>">':blankImage)
                .append('</td>')

                // ===== NORTH      =============================================
                .append('<td height=<<height>> align="center" valign="top">')
                //.append(roomRef.north?'|':blankImage)
                .append(isDirectionValid(roomRef,&north)?'<img alt="image" src=\"images/n_s.png\" width="<<imageWidth>>" height="<<imageHeight>>">':blankImage)
                .append('</td>')

                // ===== NORTHEAST      =============================================
                .append('<td  height="<<height>>" align="right" valign="top">')
                //.append(roomRef.northeast?'/':blankImage)
                .append(isDirectionValid(roomRef,&northeast)?'<img alt="image" src=\"images/nw_se.png\" width="<<imageWidth>>" height="<<imageHeight>>">':blankImage)
                .append('</td>')

                .append('</tr>')            
            .append('<tr>')
                // ===== WEST      =============================================
                .append('<td  height=<<height>>  align="left" valign="middle">')
                //.append(roomRef.west?'-':blankImage)
                .append(isDirectionValid(roomRef,&west)?'<img alt="image" src=\"images/e_w.png\" width="<<imageWidth>>" height="<<imageHeight>>">':blankImage)
                .append('</td>')


                // ===== Middle (room name)      =============================================
                .append('<td nowrap height="<<height>>"  width="200px"  align="center" valign="middle">')
                    .append('<table border=1 bgcolor="<<bgcolor>>" cellspacing=0 cellpadding=10><tr><td nowrap width="200px" align="center">')
                    .append('<<roomName>></td></tr></table>')
                .append('</td>')

                // ===== EAST      =============================================
                .append('<td  height="<<height>>"  align="right" valign="middle">')
                //.append(roomRef.east?'-':blankImage)
                .append(isDirectionValid(roomRef,&east)?'<img alt="image" src=\"images/e_w.png\" width="<<imageWidth>>" height="<<imageHeight>>">':blankImage)
                .append('</td>')

            .append('</tr>')
            .append('<tr>')
                .append('<td height="<<height>>" align="left" valign="bottom">')
                //.append(roomRef.southwest?'/':blankImage)
                .append(isDirectionValid(roomRef,&southwest)?'<img alt="image" src=\"images/nw_se.png\" width="<<imageWidth>>" height="<<imageHeight>>">':blankImage)
                .append('</td>')

                // ===== South      =============================================
                .append('<td height="<<height>>"  align="center" valign="bottom">')
                //.append(roomRef.south?'|':blankImage)
                .append(isDirectionValid(roomRef,&south)?'<img alt="image" src=\"images/n_s.png\" width="<<imageWidth>>" height="<<imageHeight>>">':blankImage)
                .append('</td>');
                
                 // ===== Southeast =============================================
                str.append('<td height="<<height>>" align="right" valign="bottom">')
                .append(isDirectionValid(roomRef, &southeast)?'<img alt="image" src=\"images/ne_sw.png\" width=\"<<width>>\" height=\"<<imageHeight>>\" >' : '') //TODO: buffer overflow if adding blankImage here...
                .append('</td>')

            .append('</tr>')
            .append('</table>');
        return str;
    }

    rowStartDelimiter = '<tr>'
    rowDelimiter = '</tr>'
;
