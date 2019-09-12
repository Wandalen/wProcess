if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
var _ = wTools;

/* How to execute command asynchronously */

_.shell( 'ls' )
.finally( ( err, got ) =>
{
  if( err )
  throw err;

  //do something after execution of "ls" command

  console.log( 'Command "ls" returned exit code:', got.exitCode );

  return null;
})