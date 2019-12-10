if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
var _ = wTools;

/* How to execute command asynchronously */

let o = { execPath : 'node sample/Child.js', mode : 'shell', throwingExitCode : 0, outputPiping : 1 };
var ready = _.process.start( o )

_.time.out( 1000, () => 
{
  o.process.kill( 'SIGINT' );
})

ready.then( ( got ) => 
{ 
  console.log( got.exitCode );
  console.log( got.exitSignal );
  console.log( _.fileProvider.fileExists( _.path.join( __dirname, 'child' ) ) )
  return null;
})