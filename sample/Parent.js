if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
var _ = wTools;

/* How to execute command asynchronously */

let signal = process.argv[ 2 ];

console.log( 'SIGNAL:', signal )

let o = { execPath : 'node sample/Child.js', mode : 'shell', throwingExitCode : 0, outputPiping : 1 };
var ready = _.process.start( o )

_.time.out( 1000, () => 
{
  o.process.kill( signal );
})

_.time.out( 3000, () => 
{
  if( _.process.isRunning( o.process.pid ) )
  { 
    console.log( 'Child is still running after sending:', signal )
    o.process.kill('SIGKILL');
  }
})

ready.then( ( got ) => 
{ 
  console.log( got.exitCode );
  console.log( got.exitSignal );
  console.log( _.fileProvider.fileExists( _.path.join( __dirname, 'child' ) ) )
  return null;
})