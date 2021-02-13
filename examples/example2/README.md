# Example 2 HTML map

 This example is mostly there to show how to setup a game with the svg-, html- or textrenderer. Use the command "map" to display the map in-game and depending on your choices in the beginning a different renderer will be used.


Compile and run the game typing either: 

 ``` 
    t3make && frob example2.t3

    t3make -f Makefile-web && frob -i plain -p -N 44 -S example2-web.t3
 ```

Or just run "compileAndRunWebUI.sh" for the webui verison.

If you have trouble compiling make sure the paths in Makefile-web.t3m is pointing to where tads3 is installed on your system, e.g on linux:

-I /usr/local/share/frobtads/tads3/include/
-I /usr/local/share/frobtads/tads3/lib/
-I /usr/local/share/frobtads/tads3/lib/adv3Lite
-I /usr/local/share/frobtads/tads3/lib/adv3Lite/english

(Also, make sure to create an obj directory in the same directory.)