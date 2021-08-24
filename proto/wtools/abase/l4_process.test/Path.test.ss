( function _Path_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );
  _.include( 'wTesting' );
  require( '../l4_process/module/Process.s' );
}

//

const _ = _global_.wTools;
const __ = _globals_.testing.wTools;

// --
// test
// --

//

function effectiveMainDir( test )
{
  if( require.main === module )
  var file = __filename;
  else
  var file = process.argv[ 1 ];

  var expected1 = _.path.dir( file );

  test.case = 'compare with __filename path dir';
  var got = _.fileProvider.path.nativize( _.path.effectiveMainDir( ) );
  test.identical( _.path.normalize( got ), _.path.normalize( expected1 ) );

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.path.effectiveMainDir( 'package.json' );
    } );
  }
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.l4.process.Path',
  silencing : 1,

  tests :
  {
    effectiveMainDir,
  },
}

//

const Self = wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
