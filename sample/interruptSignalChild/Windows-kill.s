if( typeof module !== 'undefined' )

var windowsKill = require( 'wwindowskill' )();

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

var ready = _.process.start( o )

_.time.out( 1000, () => 
{
  windowsKill( o.process.pid, 'SIGINT' )
})

ready.then( ( got ) => 
{ 
  console.log( 'Child process exitCode:', got.exitCode );
  console.log( 'Child process exitSignal:', got.exitSignal );
  return null;
})