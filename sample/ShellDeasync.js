
if( typeof module !== 'undefined' )
require( '../proto/dwtools/abase/l4/External.s' );
require( 'wConsequence' );
require( 'wLogger' );
var _ = wTools;

/**/

var o =
{
  path : 'node sample/Sample.js',
  mode : 'spawn',
  sync : 1,
  outputPiping : 1,
  deasync : 1
};
var got = _.shell( o );
console.log( 'done' )


