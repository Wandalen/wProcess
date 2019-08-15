
if( typeof module !== 'undefined' )
require( 'wappbasic' );
require( 'wConsequence' );
var _ = wTools;

/**/

// not working at all, because fork spawns node executable by default
// _.shell({ path : 'node --max_old_space_size=1024  sample/Sample.js', mode : 'fork' })

// invalid argument, because node expects only path to module
// _.shell({ path : '--max_old_space_size=1024  sample/Sample.js', mode : 'fork' })

// passing arguments for executable( node ) through execArgv and for app through args
//https://nodejs.org/api/child_process.html#child_process_child_process_fork_modulepath_args_options

var o = { path : 'sample/Sample.js', mode : 'fork', args : [ 'someArgument' ], execArgv : [ '--max_old_space_size=1024'  ] }
_.shell( o )
.doThen( () =>
{
  console.log( o.process.spawnargs );
  return o;
})
