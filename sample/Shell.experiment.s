let _ = require( '..' );
_.include( 'wFilesBasic' )

var o =
{
  execPath : `node -e "console.log( 'NodePID:',process.pid, '\\n', 'ParentPID:', process.ppid)"`,
  mode : 'shell',
  stdio : 'inherit'
}
_.process.start( o );
console.log( 'ShellPID:', o.pnd.pid )
