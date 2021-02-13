# Example 3 - Advanced mapping features

 This example shows how map a game like Zork could be done with the SvgTileMap and it also has support for the scalable text tilemap. The SVG map is being rendered in the current folder under the name "mapdata.svg" and can be previewed while the game is running in the game interpreter updating in realtime as soon as you move around in the game.

Besides this it is possible to use the command: 'map' to draw the map text-wise inside the game.

This example shows off almost all the features mentioned in the manual. mapCoordsOverride is used frequently together with pathConnectionTable in order to render a complex map with not so obvious connections, especially how up and down the attic and the tree could be remapped as north<->south or northeast<->southwest in order to show all rooms in the same map. It also shows how to tap into specific places where one would pherhaps emphasize things with mapConnectionShape and draw for instance bezier curves to clarify one-way paths or a setting up dashed square around the house area to make the map easier to read.



Compile and run the game typing: 

 ``` 
    t3make && frob example3.t3
 ```


If you have trouble compiling make sure the paths in Makefile-web.t3m is pointing to where tads3 is installed on your system, e.g on linux:

-I /usr/local/share/frobtads/tads3/include/
-I /usr/local/share/frobtads/tads3/lib/
-I /usr/local/share/frobtads/tads3/lib/adv3Lite
-I /usr/local/share/frobtads/tads3/lib/adv3Lite/english

(Also, make sure to create an obj directory in the same directory.)