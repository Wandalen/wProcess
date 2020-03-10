if( typeof module !== 'undefined' )
require( '../..' );
require( 'wFiles' );
var _ = wTools;


console.log( 'Detached start' )

_.time.out( 10000, () => 
{ 
  var fs = require( 'fs' )
  // fs.writeFileSync( process.pid.toString(), process.pid.toString() )
  console.log( 'Detached end' )
})

// process.on( 'disconnect', () =>
// {
//   let o =
//   {
//     mode : 'spawn',
//     execPath : 'node ' + _.strQuote( _.path.join( __dirname, 'Child.js' ) ),
//     stdio : 'inherit',
//   }

//   var ready = _.shell( o )

//   console.log( 'Detached process' )

// })