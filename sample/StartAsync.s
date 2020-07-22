let _ = require( '..' );
_.include( 'wFiles' )

/* How to execute command asynchronously */

let execPath = process.platform === 'win32' ? 'dir' : 'ls';

_.process.start( execPath )
.finally( ( err, got ) =>
{
  if( err )
  throw err;

  //do something after execution of the command

  console.log( `Command "${execPath}" returned exit code: ${got.exitCode}` );

  return null;
})