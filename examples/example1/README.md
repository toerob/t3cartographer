# Example 1 Text plus SVG rendered map


This example shows perhaps the most easiest way to implement the cartographer extension in your game. It defines a map command that can be used to render the text based tilemap. It also auto updates an svg map (mapdata.svg) as soon as the player moves around. (This is just an example of one way of doing it. How you want to do this is in your own game is totally up to you.)

mapDistanceLengthTable is used in this map to make certain locations depicted further away from its adjacent room, remember if you use  mapDistanceLengthTable to always "mirror" the distance in the other connected rooms, or you will have graphical glitches depending which room will get drawn first.



Compile and run the game with:

 ``` 
    t3make && frob example1.t3

 ```


If you have trouble compiling make sure the paths in Makefile-web.t3m is pointing to where tads3 is installed on your system, e.g on linux:

-I /usr/local/share/frobtads/tads3/include/
-I /usr/local/share/frobtads/tads3/lib/
-I /usr/local/share/frobtads/tads3/lib/adv3Lite
-I /usr/local/share/frobtads/tads3/lib/adv3Lite/english

(Also, make sure to create an obj directory in the same directory.)