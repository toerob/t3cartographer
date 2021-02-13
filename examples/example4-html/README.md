# Example 4 - HTML

HTML in-game map using the HTML-renderer. This example shows how to render an HTML-map inside a HTML-interpreter. It won't work with for instance frob, you'll have to use for instance the Multimedia interpreter for windows that comes along with tads3 or QTads. 


Compile and run the game typing: 

 ``` 
    t3make && qtads example4.t3
 ```

If you have trouble compiling make sure the paths in Makefile.t3m is pointing to where tads3 is installed on your system, e.g on linux:

-I /usr/local/share/frobtads/tads3/include/
-I /usr/local/share/frobtads/tads3/lib/
-I /usr/local/share/frobtads/tads3/lib/adv3Lite
-I /usr/local/share/frobtads/tads3/lib/adv3Lite/english

(Also, make sure to create an obj directory in the same directory.)