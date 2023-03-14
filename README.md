# Server-Side-Barcode-Renderer
Server side barcode renderer using ECPages, SQL, and JS

1. configure server to call lib_barcodes_server module to respond to a particular request (e.g. /barcode?value=&symbology=&style=&psytle=&class=)
2. call lib_barcodes_server
3. execute server_barcode function and return its output as the server response

another function can be created. this would create an image element that has "/barcode?value=..." as the src. The server would then generate and return the barcode
