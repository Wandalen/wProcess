if( typeof module !== 'undefined' )
require( '../..' );
require( 'wFiles' );
var _ = wTools;



process.on( 'disconnect', () =>
{
  let o =
  {
    mode : 'spawn',
    execPath : 'node ' + _.strQuote( _.path.join( __dirname, 'Child.js' ) ),
    stdio : 'inherit',
  }

  var ready = _.shell( o )

  console.log( 'Detached process' )

})