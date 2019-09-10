if( typeof module !== 'undefined' )
require( 'wappbasic' );
require( 'wFiles' );
var _ = wTools;

/* How to execute command and collect it output */

_.shell
({
  execPath : 'ls',
  outputCollecting : 1
})
.finally( ( err, got ) =>
{
  if( err )
  throw err;

  console.log( got.output )

  return null;
})

