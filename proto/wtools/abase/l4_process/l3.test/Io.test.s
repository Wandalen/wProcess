( function _Io_test_s( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../../wtools/Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wProcessWatcher' );

  require( '../l4_process/Basic.s' );

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
  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'ProcessBasic' );
  self.toolsPath = _.path.nativize( _.path.resolve( __dirname, '../../../wtools/Tools.s' ) );
  self.toolsPathInclude = `let _ = require( '${ _.strEscape( self.toolsPath ) }' )\n`;
}

//

function suiteEnd()
{
  var self = this;

  _.assert( _.strHas( self.suiteTempPath, '/ProcessBasic-' ) )
  _.path.tempClose( self.suiteTempPath );
}

//

//

function testApp()
{
  var ended = 0;
  var fs = require( 'fs' );
  var path = require( 'path' );
  var filePath = path.join( __dirname, 'file.txt' );
  console.log( 'begin', process.argv.slice( 2 ).join( ', ' ) );
  var time = parseInt( process.argv[ 2 ] );
  if( isNaN( time ) )
  throw new Error( 'Expects number' );

  setTimeout( end, time );
  function end()
  {
    ended = 1;
    fs.writeFileSync( filePath, 'written by ' + process.argv[ 2 ] );
    console.log( 'end', process.argv.slice( 2 ).join( ', ' ) );
  }

  setTimeout( periodic, 50 );
  function periodic()
  {
    console.log( 'tick', process.argv.slice( 2 ).join( ', ' ) );
    if( !ended )
    setTimeout( periodic, 50 );
  }

}

//

function testAppShell()
{
  let process = _global_.process;

  _.include( 'wProcess' );
  _.include( 'wStringsExtra' )

  process.removeAllListeners( 'SIGINT' );
  process.removeAllListeners( 'SIGTERM' );
  process.removeAllListeners( 'exit' );

  var args = _.process.args();

  if( args.map.exitWithCode )
  process.exit( args.map.exitWithCode )

  if( args.map.loop )
  return _.time.out( 4000 )

  console.log( __filename );
}

// --
// test
// --

function pathsRead( test )
{
  test.case = 'test';
  var got = pathsRead();
  test.il( got, '11' );

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
    testApp,
    testAppShell,
    toolsPath : null,
    toolsPathInclude : null,
  },

  tests :
  {
    pathsRead,
  }

}

_.mapExtend( Self, Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
