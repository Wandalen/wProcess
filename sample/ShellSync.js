if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
var _ = wTools;

/* How to execute command synchronously using sync method of `ChildProcess` module */

var got = _.shell({ execPath : 'ls', sync : 1 })

console.log( 'Command "ls" returned exit code:', got.exitCode );
