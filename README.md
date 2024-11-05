# ECPages Server-side Barcode Rendering

Server side barcode renderer using ECPages, SQL, and JS

1. configure server to call lib_barcodes_server module to respond to a particular request (e.g. /barcode?value=&symbology=&style=&psytle=&class=)
2. call lib_barcodes_server
3. execute server_barcode function and return its output as the server response

Another function can be created. This would create an image element that has "/barcode?value=..." as the src. The server would then generate and return the barcode
file (or save as file for reuse) with pr_ is a T-SQL stored procedure. Each file with \_data represents a table in the database (.csv's are data rows and .txt's are table designs).

## A Better Solution?

Data processed directly on the server is very dynamic. However, it also takes more server resources as each barcode is individually rendered. A better solution than server side rendering, for a project like this, would be client side rendering.

1. A JSON object containing the necessary barcode data would be sent to the client.
2. An HTML placeholder would exist for each barcode. (i.e. has a value attribute and a class such as js-client-barcode).
3. A JS script would find each placeholder and, using the JSON object, create an SVG to replace the placholder.

This would take the load off of the server. It could be further optimized by setting the JS script to apply the same SVG to every identical placeholder rather than re-rendering for each placeholder.

### UPDATE
I've created a solution as described in "A Better Solution." See it [here](https://github.com/TaliBytes/js-client-barcodes) (not uploaded yet)
