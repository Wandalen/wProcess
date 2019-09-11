if( typeof module !== 'undefined' )
var _ = require( '../..' );

_.include( 'wFiles' )

while( 1 )
{
  console.log( 'read...' )
  _.fileProvider.fileRead( __filename )
}
