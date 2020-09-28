( function _Io_test_s( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( './../../../../wtools/Tools.s' );
  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wProcessWatcher' );

  require( '../Basic.s' );

}

let _global = _global_;
let _ = _global_.wTools;
let Self = {};

// --
// context
// --

function suiteBegin()
{
  var self = this;
  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'Io' );
  self.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  self.appJsPath = _.path.nativize( _.module.resolve( 'wProcess' ) );
}

//

function suiteEnd()
{
  var self = this;

  _.assert( _.strHas( self.suiteTempPath, '/Io' ) )
  _.path.tempClose( self.suiteTempPath );
}

// --
// test
// --

function pathsRead( test )
{
  test.case = 'arrayIs';
  var got = _.process.pathsRead();
  test.is( _.arrayIs( got ) );

  test.case = 'paths are normalized'
  got.forEach( ( path ) => test.is( _.path.isNormalized( path ) ) )

}

//

function systemEntryAddBasic( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'basic';
    var src =
    {
      // entryDirPath : _.process.pathsRead()[ 0 ],
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/Index.js' ),
      allowingNotInPath : 1 //
    }
    var exp = 1;
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( a.abs( 'dir/Index' ) ) )
    test.is( _.objectIs( a.fileProvider.filesRead( a.abs( 'dir/Index' ) ) ) )

    return null;
  } );

  /* - */

  test.case = 'no arguments'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd() )
  test.case = 'extra arguments'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd( {}, 1 ) )
  test.case = 'o.entryDirPath is not provided'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd( a.abs( 'dir' ) ) )
  test.case = 'o.entryDirPath not in the PATH'
  test.shouldThrowErrorSync( () => _.process.systemEntryAdd({ appPath : a.abs( 'dir/file.txt' ), entryDirPath : a.abs( 'dir' ) }) )

  return a.ready;

}

//

function systemEntryAddOptionAllowingMissed( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'not existing file';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/fileNotExists.txt' ),
      allowingNotInPath : 1, //
      allowingMissed : 1
    }
    var exp = 1;
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( a.abs( 'dir/fileNotExists' ) ) )
    test.is( _.objectIs( a.fileProvider.filesRead( a.abs( 'dir/fileNotExists' ) ) ) )

    return null;
  } );

  return a.ready;
}

//

function systemEntryAddOptionAllowingNotInPath( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'entryDirPath not in PATH, allowingNotInPath : 1';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/file.txt' ),
      allowingNotInPath : 1
    }
    var exp = 1;
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( a.abs( 'dir/file' ) ) )
    test.is( _.objectIs( a.fileProvider.filesRead( a.abs( 'dir/file' ) ) ) )

    return null;
  } );

  return a.ready;
}

//

function systemEntryAddOptionForcing( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'entryDirPath not in PATH, forcing : 1';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/file.txt' ),
      forcing : 1
    }
    var exp = 1;
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( a.abs( 'dir/file' ) ) )
    test.is( _.objectIs( a.fileProvider.filesRead( a.abs( 'dir/file' ) ) ) )

    return null;
  } );

  a.ready.then( () =>
  {
    test.case = 'entryDirPath not in PATH, appPath doesn\'t exist, forcing : 1';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/fileNotExists.txt' ),
      forcing : 1
    }
    var exp = 1;
    var got = _.process.systemEntryAdd( src );
    test.il( got, exp );
    test.is( a.fileProvider.fileExistsAct( a.abs( 'dir/fileNotExists' ) ) )
    test.is( _.objectIs( a.fileProvider.filesRead( a.abs( 'dir/fileNotExists' ) ) ) )

    return null;
  } );

  return a.ready;
}

//

var Proto =
{

  name : 'Tools.l3.Io',
  silencing : 1,
  routineTimeOut : 60000,
  onSuiteBegin : suiteBegin,
  onSuiteEnd : suiteEnd,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,
  },

  tests :
  {
    pathsRead,

    systemEntryAddBasic,
    systemEntryAddOptionAllowingMissed,
    systemEntryAddOptionAllowingNotInPath,
    systemEntryAddOptionForcing,
  }

}

_.mapExtend( Self, Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
