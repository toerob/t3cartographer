# Example 5 - SVG inside webui interpreter

Svg In-Game map using Tads3 webui. This example shows how to use a map with background image underneath. It also shows how to divide the map up into separate map regions.


Compile and run the game typing: 

 ``` 
    t3make -f Makefile-web && frob -i plain -p -N 44 -S example5-web.t3
 ```

Or using the compileAndRunWebUI.sh bash script.



If you have trouble compiling make sure the paths in Makefile-web.t3m is pointing to where tads3 is installed on your system, e.g on linux:

-I /usr/local/share/frobtads/tads3/include/
-I /usr/local/share/frobtads/tads3/lib/
-I /usr/local/share/frobtads/tads3/lib/adv3Lite
-I /usr/local/share/frobtads/tads3/lib/adv3Lite/english

(Also, make sure to create an obj directory in the same directory.)