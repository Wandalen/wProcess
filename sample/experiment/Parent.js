if( typeof module !== 'undefined' )
require( '../..' );
require( 'wFiles' );
var _ = wTools;

let o =
{
  execPath : _.path.join( __dirname, 'Detached.js' ),
  stdio : 'ignore',
  mode : 'fork',
  detaching : 1,
}

var ready = _.process.start( o );

ready.then( ( got ) => 
{
  console.log( got.process.pid )
  return null;
})

