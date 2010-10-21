Rhino is the javascript compressor used by the dojo Toolkit.
http://dojotoolkit.org/docs/compressor_system.html

Use this tool to compress your custom javascript files. The compressed file 
will be optimized but may be difficult to read or decipher. It is advised
that you keep and the uncompressed javascript file and then rerun the compressor to get a minified
version of your javascript files.

Usage :
java -jar custom_rhino.jar -c your_script.js > your_script-min.js 2>&1

