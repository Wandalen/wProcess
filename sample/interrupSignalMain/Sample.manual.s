const _ = require('../../proto/wtools/abase/l4_process/Basic.s');

if( typeof module !== 'undefined' )
require( '../..' );

_.process._exitHandlerRepair();

console.log( 'Please enter CTRL+C combination...' );

process.on( 'exit', ( exitCode ) =>
{
  console.log( 'Exit code:', exitCode );
})

_.time.out( 10000 );
