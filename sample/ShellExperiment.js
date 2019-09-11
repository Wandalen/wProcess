if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
var _ = wTools;

/* How to execute command asynchronously */

let o =
{ mode : 'fork', execPath : _.path.join( __dirname, 'ShellUnrestricted.js' ), throwingExitCode :0 }

var ready = _.shell( o )
ready.then( ( got ) =>
{
  debugger
  console.log( got.exitCode )
  console.log( got.exitSignal )
  return null;
})

_.timeOut( 100, () =>
{
  o.process.kill( 'SIGKILL' );
  return null;
})