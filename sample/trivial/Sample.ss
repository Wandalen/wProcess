let _ = require( 'wprocess' );

/* execute command synchronously */

var result = _.process.start({ execPath : process.platform === 'win32' ? 'dir' : 'ls', sync : 1 });

console.log( 'Command "ls" returned exit code:', result.exitCode );
