# Example 2 HTML map

 This example is mostly here to show how to setup a regular Tads3 (not adv3lite) game with the svg-, html- or textrenderer. Use the command "map" to display the map in-game and depending on your choices in the beginning a different renderer will be used.


Compile and run the game, for the webui: 

 ``` 
    t3make -f Makefile-web && frob -i plain -p -N 44 -S example2-web.t3
 ```
Or just run the script: compileAndRunWebUI.sh

----

To compile a regular game that can be run within an html interpreter like QTads, uncomment away the rows in example2.t

```
   WebResourceResFile
      vpath = static new RexPattern('/images/')
   ;
```

And then run: 

```
    t3make 
```

to build the t3 image.


If you have trouble compiling make sure the paths in Makefile/Makefile-web.t3m is pointing to where tads3 is installed on your system, e.g on linux:

-I /usr/local/share/frobtads/tads3/include/
-I /usr/local/share/frobtads/tads3/lib/
-I /usr/local/share/frobtads/tads3/lib/adv3Lite
-I /usr/local/share/frobtads/tads3/lib/adv3Lite/english

(Also, make sure to create an obj directory in the same directory.)