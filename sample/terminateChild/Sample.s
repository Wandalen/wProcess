if( typeof module !== 'undefined' )
require( '../..' );
require( 'wFiles' );
let _ = wTools;

let o =
{
  execPath : 'node Child.manual.s',
  currentPath : __dirname,
  mode : 'shell',
  throwingExitCode : 0,
  outputPiping : 1,
};

/*
  Child process registers handler for SIGTERM and waits the signal for 5 seconds
  Start child process and send SIGTERM signal after short delay
*/

/*
  Expected behaviour:
  Windows: child process will be terminated with exitCode:null, exitSignal:SIGTERM
  Unix: child process will handle received SIGTERM signal, print message and exit gracefully: exitCode:0, exitSignal : null
*/

var ready = _.process.start( o )

_.time.out( 1000, () =>
{
  _.process.terminate({ pnd : o.process });
})

ready.then( ( got ) =>
{
  console.log( 'Child process exitCode:', got.exitCode );
  console.log( 'Child process exitSignal:', got.exitSignal );
  return null;
})
