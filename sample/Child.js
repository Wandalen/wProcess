var fs = require( 'fs' );
let path = require( 'path' )
setTimeout( () =>
{
  console.log( 'Timeout in child' );
  fs.writeFileSync( path.join( __dirname, 'child' ), 'timeout' );
},6000 )