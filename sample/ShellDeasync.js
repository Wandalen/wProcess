if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
var _ = wTools;

/* How to execute command synchronously in mode that doesn't have sync method in `ChildProcess` module */

var got = _.shell
({
  execPath : _.path.join( __dirname, 'AppArgs.js' ),
  mode : 'fork',
  deasync : 1,
  sync : 1
})

console.log( 'Child process returned exit code:', got.exitCode );
