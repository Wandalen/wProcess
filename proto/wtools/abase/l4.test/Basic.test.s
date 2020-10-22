( function _Basic_test_s( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( './../../../wtools/Tools.s' );
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
  let context = this;
  context.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'Io' );
  context.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  context.appJsPath = _.path.nativize( _.module.resolve( 'wProcess' ) );
}

//

function suiteEnd()
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, '/Io' ) )
  _.path.tempClose( context.suiteTempPath );
}

//

function escapeArg( test )
{
  let isWin = process.platform === 'win32';

  var src = 'a';
  var expected = isWin ? `^"a^"`: 'a'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = 'a b';
  var expected = isWin ? '^"a^ b^"' : 'a\\ b'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = 'a b';
  var expected = isWin ?  '^"a^ b^"' : 'a\\ b'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '/a/b/';
  var expected = isWin ? '^"/a/b/^"' : '\\/a\\/b\\/'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '/a/b c/';
  var expected = isWin ? '^"/a/b^ c/^"' : '\\/a\\/b\\ c\\/'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = 'A:\\b\\';
  var expected = isWin ? '^"A:\\b\\^"' : 'A\\:\\\\b\\\\'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = 'A:\\b c\\';
  var expected = isWin ? '^"A:\\b^ c\\^"' : 'A\\:\\\\b\\ c\\\\'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '"a"';
  var expected = isWin ?  '^"\\^"a\\^"^"' : '\\"a\\"'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '\\"a\\"';
  var expected = isWin ?  '^"\\\\^"a\\\\^"^"' : '\\\\\\"a\\\\\\"'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '"/a/b/"';
  var expected = isWin ? '^"\\\\^"a\\\\^"^"' : '\\"\\/a\\/b\\/\\"'
  var got = _.process.escapeArg( src )

  var src = '"/a/b c/"';
  var expected = isWin ? '^"\\^"/a/b^ c/\\^"^"' : '\\"\\/a\\/b\\ c\\/\\"'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = 'option : value';
  var expected = isWin ? '^"option^ :^ value^"' : 'option\\ \\:\\ value'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = 'option : 123';
  var expected = isWin ? '^"option^ :^ 123^"' : 'option\\ \\:\\ 123'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '**';
  var expected = isWin ?  '^"^*^*^"' : '\\*\\*'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '"**"';
  var expected = isWin ? '^"\\^"^*^*\\^"^"' : '\\"\\*\\*\\"'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );

  var src = '&&';
  var expected = isWin ?  '^"^&^&^"' : '\\&\\&'
  var got = _.process.escapeArg( src )
  test.identical( got, expected );
}

//

function escapeProg( test )
{
  var src = 'a';
  var expected = 'a'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = 'a b';
  var expected = 'a\\ b'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = 'a b';
  var expected = 'a\\ b'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '/a/b/';
  var expected = '\\/a\\/b\\/'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '/a/b c/';
  var expected = '\\/a\\/b\\ c\\/'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = 'A:\\b\\';
  var expected = 'A\\:\\\\b\\\\'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = 'A:\\b c\\';
  var expected = 'A\\:\\\\b\\ c\\\\'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '"a"';
  var expected = '\\"a\\"'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '\\"a\\"';
  var expected = '\\\\\\"a\\\\\\"'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '"/a/b/"';
  var expected = '\\"\\/a\\/b\\/\\"'
  var got = _.process.escapeProg( src )

  var src = '"/a/b c/"';
  var expected = '\\"\\/a\\/b\\ c\\/\\"'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = 'option : value';
  var expected = 'option\\ \\:\\ value'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = 'option : 123';
  var expected = 'option\\ \\:\\ 123'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '**';
  var expected = '\\*\\*'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '"**"';
  var expected = '\\"\\*\\*\\"'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );

  var src = '&&';
  var expected = '\\&\\&'
  var got = _.process.escapeProg( src )
  test.identical( got, expected );
}

//

function escapeCmd( test )
{
  var prog = 'node'
  var args = [ '-v' ]
  var expected = 'node \\-v'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

  var prog = '/path/to/node'
  var args = [ '-v' ]
  var expected = '\\/path\\/to\\/node \\-v'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

  var prog = '/path/with space/node'
  var args = [ '-v' ]
  var expected = '\\/path\\/with\\ space\\/node \\-v'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

  var prog = '"node"'
  var args = [ '-v' ]
  var expected = '\\"node\\" \\-v'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

  var prog = 'node -v'
  var args = []
  var expected = 'node\\ \\-v'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

  var prog = '/path/to/node -v'
  var args = []
  var expected = '\\/path\\/to\\/node\\ \\-v'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

  var prog = '/path/with space/node -v'
  var args = []
  var expected = '\\/path\\/with\\ space\\/node\\ \\-v'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

  var prog = 'ls'
  var args = [ '*' ]
  var expected = 'ls \\*'
  var got = _.process.escapeCmd( prog,args )
  test.identical( got, expected );

}

//

var Proto =
{

  name : 'Tools.l4.Basic',
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

    escapeArg,
    escapeProg,
    escapeCmd

  }

}

_.mapExtend( Self, Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
