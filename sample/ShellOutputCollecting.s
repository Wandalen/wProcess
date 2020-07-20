if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
let _ = wTools;

/* How to execute command and collect it output */

_.shell
({
  execPath : 'ls',
  outputPiping : 0,
  outputCollecting : 1
})
.finally( ( err, got ) =>
{
  if( err )
  throw err;

  console.log( got.output.split( '\n' ) )

  return null;
})

