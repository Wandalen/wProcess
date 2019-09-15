if( typeof module !== 'undefined' )
require( '../..' );
require( 'wFiles' );
var _ = wTools;

let o =
{
  mode : 'spawn',
  execPath : 'node ' + _.strQuote( _.path.join( __dirname, 'Detached.js' ) ),
  ipc : 1,
  detaching : 1,
  stdio : 'inherit',
}

var ready = _.shell( o )

_.timeOut( 3000, () =>
{
  console.log( 'Parent exits' )
  process.exit();
  return null;
})

