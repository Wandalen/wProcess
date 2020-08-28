let _ = require( '..' );
_.include( 'wFiles' );

/* How to execute command synchronously using sync method of `ChildProcess` module */

var got = _.process.start({ execPath : 'ls', sync : 1 })

console.log( 'Command "ls" returned exit code:', got.exitCode );
