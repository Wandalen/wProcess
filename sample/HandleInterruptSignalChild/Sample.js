if( typeof module !== 'undefined' )
require( '../..' );
require( 'wFiles' );
var _ = wTools;

let o = 
{ 
  execPath : 'node Child.js',
  currentPath : __dirname,
  mode : 'spawn', 
  throwingExitCode : 0,
  outputPiping : 1 
};

/* 
  Child process registers handler for SIGINT and waits the signal for 5 seconds
  Start child process and send SIGINT signal after short delay 
*/

/* 
  Expected behaviour:
  Windows: child process will be terminated with exitCode:null,exitSignal:SIGINT
  Unix: child process will handle received SIGINT signal, print message and exit gracefully: exitCode:0, exitSignal : null
*/

var ready = _.process.start( o )

_.time.out( 1000, () => 
{
  o.process.kill( 'SIGINT' );
})

ready.then( ( got ) => 
{ 
  console.log( 'Child process exitCode:', got.exitCode );
  console.log( 'Child process exitSignal:', got.exitSignal );
  return null;
})