if( typeof module !== 'undefined' )
require( '../..' );
require( 'wFiles' );
var _ = wTools;

let o =
{ mode : 'fork', execPath : _.path.join( __dirname, 'App.js' ), throwingExitCode :1 }

var ready = _.shell( o )
ready.finally( ( err, got ) =>
{
  _.errAttend( err );
  debugger
  console.log( o.exitCode )
  console.log( o.exitSignal )
  return null;
})

_.timeOut( 3000, () =>
{
  o.process.kill( 'SIGINT' );
  return null;
})