let _ = require( '..' );
_.include( 'wFilesBasic' );

/* How to execute command synchronously in mode that doesn't have sync method in `ChildProcess` module */

var got = _.process.start
({
  execPath : _.path.join( __dirname, 'Args.s' ),
  mode : 'fork',
  deasync : 1,
  sync : 1
})

console.log( `Child process returned exit code: ${got.exitCode}` );
