let _ = require( '..' );
_.include( 'wFiles' );

/* How to execute command and collect it output */

let execPath = process.platform === 'win32' ? 'dir' : 'ls';

_.process.start
({
  execPath,
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

