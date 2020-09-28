( function _Io_test_s( )
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

function processArgsBase( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( testApp );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );
  let interpreterPath = a.path.normalize( process.argv[ 0 ] );
  let scriptPath = a.path.normalize( programPath );

  /* */

  shell({ args : [] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got =   a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      subject : '',
      map : Object.create( null ),
      scriptArgs : [],
      scriptArgsString : '',
      subjects : [],
      maps : [],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ '' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      subject : '',
      map : Object.create( null ),
      scriptArgs : [ '' ],
      scriptArgsString : '',
      subjects : [],
      maps : [],
    }
    test.contains( got, expected );
    return null;
  })


  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.args({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//


function processArgsPropertiesBase( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( testApp );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })
  let filePath = a.abs( 'got' );
  let interpreterPath = a.path.normalize( process.argv[ 0 ] );
  let scriptPath = a.path.normalize( programPath );

  /* */

  shell({ args : [ 'x', ':', 'aa', 'bbb', ':', 'x' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : 'aa', bbb : 'x' },
      subject : '',
      scriptArgs : [ 'x', ':', 'aa', 'bbb', ':', 'x' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ 'x', ':', 'y' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : 'y' },
      subject : '',
      scriptArgs : [ 'x', ':', 'y' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ 'x', ':', 'y', 'x', ':', '1' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : [ 'y', 1 ] },
      subject : '',
      scriptArgs : [ 'x', ':', 'y', 'x', ':', '1' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell({ args : [ 'abcd', 'x', ':', 'y', 'xyz', 'y', ':', 1  ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { x : 'y xyz', y : 1 },
      subject : 'abcd',
      scriptArgs : [ 'abcd', 'x', ':', 'y', 'xyz', 'y', ':', '1' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell
  ({
    args :
    [
      'filePath',
      'a:', 1,
      'b', ':2',
      'c:', 3,
      'd', ':4',
      'e', ':', 5
    ]
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { a : 1, b : 2, c : 3, d : 4, e : 5 },
      subject : 'filePath',
      scriptArgs :
      [
        'filePath',
        'a:', '1',
        'b', ':2',
        'c:', '3',
        'd', ':4',
        'e', ':', '5'
      ]
    }
    test.contains( got, expected );
    return null;
  })

  shell({ args : [ 'path:c:\\some', 'x', ':', 0, 'y', ':', 1 ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath,
      scriptPath,
      interpreterArgs : [],
      keyValDelimeter : ':',
      map : { path : 'c:\\some', x : 0, y : 1 },
      subject : '',
      scriptArgs : [ 'path:c:\\some', 'x', ':', '0', 'y', ':', '1' ]
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    return null;
  })
  shell
  ({
    args : [ 'interpreter', 'main.js', 'v:"10"' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { v : 10 },
      scriptArgs : [ 'v:"10"' ],
      scriptArgsString : 'v:"10"',
      subjects : [ '' ],
      maps : [ { v : 10 } ],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    return null;
  })
  shell
  ({
    args : [ 'interpreter', 'main.js', 'str:"abc"' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { str : 'abc' },
      scriptArgs : [ 'str:"abc"' ],
      scriptArgsString : 'str:"abc"',
      subjects : [ '' ],
      maps : [ { str : 'abc' } ],
    }
    test.contains( got, expected );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.args({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//

function processArgsMultipleCommands( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( testApp );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', '.set', 'v:5', ';', '.build', 'debug:1', ';', '.export' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH },
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '.set',
      map : { v : 5 },
      scriptArgs : [ '.set', 'v:5', ';', '.build', 'debug:1', ';', '.export' ],
      scriptArgsString : '.set v:5 ; .build debug:1 ; .export',
      subjects : [ '.set', '.build', '.export' ],
      maps : [ { v : 5 }, { debug : 1 }, {} ],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', '.set', 'v', ':', '[', 1, 2, 3, ']', ';', '.build', 'debug:1', ';', '.export' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '.set',
      map : { v : [ 1, 2, 3 ] },
      scriptArgs : [ '.set', 'v', ':', '[', '1', '2', '3', ']', ';', '.build', 'debug:1', ';', '.export' ],
      scriptArgsString : '.set v : [ 1 2 3 ] ; .build debug:1 ; .export',
      subjects : [ '.set', '.build', '.export' ],
      maps : [ { v : [ 1, 2, 3 ] }, { debug : 1 }, {} ],
    }
    test.contains( got, expected );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.args({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//

function processArgsPaths( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( testApp );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', 'path:D:\\path\\to\\file' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { path : 'D:\\path\\to\\file' },
      scriptArgs : [ 'path:D:\\path\\to\\file' ],
      scriptArgsString : 'path:D:\\path\\to\\file',
      subjects : [ '' ],
      maps : [ { path : 'D:\\path\\to\\file' } ],
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  shell
  ({
    args : [ 'interpreter', 'main.js', 'path:"D:\\path\\to\\file"' ],
    env : { ignoreFirstTwoArgv : true, PATH : process.env.PATH }
  })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      interpreterPath : 'interpreter',
      scriptPath : 'main.js',
      interpreterArgs : [],
      keyValDelimeter : ':',
      commandsDelimeter : ';',
      subject : '',
      map : { path : 'D:\\path\\to\\file' },
      scriptArgs : [ 'path:"D:\\path\\to\\file"' ],
      scriptArgsString : 'path:"D:\\path\\to\\file"',
      subjects : [ '' ],
      maps : [ { path : 'D:\\path\\to\\file' } ],
    }
    test.contains( got, expected );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.args({ caching : 0 });
    a.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//

function processArgsWithSpace( test ) /* qqq : split test cases | aaa : Done. Yevhen S. */
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( testApp );

  let shell = _.process.starter
  ({
    execPath : 'node ' + programPath,
    mode : 'spawn',
    throwingExitCode : 0,
    ready : a.ready
  })

  let filePath = a.abs( 'got' );

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell( `subject option:"value with space"` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:"value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:"value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell( `subject option:'value with space'` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', `option:'value with space'` ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : `subject option:'value with space'`,
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : `subject option:'value with space'`
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell( 'subject option:`value with space`' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:`value with space`' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:`value with space`',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:`value with space`'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    test.description = 'subject + option, option value is quoted and contains space'
    test.will = 'process.args should quote arguments with space'
    return null;
  })
  shell( `subject option : "value with space"` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', 'value with space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : "value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option', ':', 'value with space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', 'value with space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : "value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is quoted and contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option', ':', '"value with space"' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', '"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : "value with space"',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is not quoted and contains space'
    return null;
  })
  shell( `subject option:value with space` )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:value with space',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is not quoted and contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option:value', 'with', 'space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option:value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option:value with space',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option:value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'subject + option, option value is not quoted and contains space'
    return null;
  })
  shell({ args : [ 'subject', 'option', ':', 'value', 'with', 'space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'subject', 'option', ':', 'value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'subject option : value with space',
      'subject' : 'subject',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ 'subject' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'subject option : value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is quoted and contains space'
    return null;
  })
  shell( 'option:"value with space"' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option:"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option:"value with space"',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option:"value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is quoted and contains space'
    return null;
  })
  shell({ args : [ 'option', ':', '"value with space"' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option', ':', '"value with space"' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option : "value with space"',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is quoted and contains space'
    return null;
  })
  shell({ args : [ 'option', ':', 'value with space' ] })
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option', ':', 'value with space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option : "value with space"',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option : "value with space"'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is not quoted and contains space'
    return null;
  })
  shell( 'option:value with space' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option:value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option:value with space',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option:value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is not quoted and contains space'
    return null;
  })
  shell( 'option : value with space' )
  .then( ( o ) =>
  {
    test.identical( o.exitCode, 0 );
    var got = a.fileProvider.fileRead({ filePath, encoding : 'json' });
    var expected =
    {
      'scriptArgs' : [ 'option', ':', 'value', 'with', 'space' ],
      'interpreterArgsStrings' : '',
      'scriptArgsString' : 'option : value with space',
      'subject' : '',
      'map' : { 'option' : 'value with space' },
      'subjects' : [ '' ],
      'maps' : [ { 'option' : 'value with space' } ],
      'original' : 'option : value with space'
    }
    test.contains( got, expected );
    return null;
  })

  /* */

  a.ready.then( () =>
  {
    /* process.args should quote arguments that contain spaces and are not quoted already */
    test.description = 'options only, option value is not quoted and contains space'
    return test.shouldThrowErrorOfAnyKind( () =>
    {
      return shell({ execPath : 'option:value with" space', ready : null })
    });
  })
  // .then( ( o ) =>
  // {
  //   test.identical( o.exitCode, 0 );
  //   var got = _.fileProvider.fileRead({ filePath, encoding : 'json' });
  //   var expected =
  //   {
  //     'scriptArgs' : [ 'option:value', 'with"', 'space' ],
  //     'interpreterArgsStrings' : '',
  //     'scriptArgsString' : 'option:value with" space',
  //     'subject' : '',
  //     'map' : { 'option' : 'value with" space' },
  //     'subjects' : [ '' ],
  //     'maps' : [ { 'option' : 'value with" space' } ],
  //     'original' : 'option:value with" space'
  //   }
  //   test.contains( got, expected );
  //   return null;
  // })
  /* qqq : ? */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    _.include( 'wFiles' )

    if( process.env.ignoreFirstTwoArgv )
    process.argv = process.argv.slice( 2 );

    var got = _.process.args({ caching : 0 });
    _.fileProvider.fileWrite( _.path.join( __dirname, 'got' ), JSON.stringify( got ) )
  }
}

//

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
  let a = test.assetFor( 'systemEntry' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'basic';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/Index.js' ),
      allowingNotInPath : 1
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
  let a = test.assetFor( 'systemEntry' );

  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'not existing file';
    var src =
    {
      entryDirPath : a.abs( 'dir' ),
      appPath : a.abs( 'dir/fileNotExists.txt' ),
      allowingNotInPath : 1,
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
  let a = test.assetFor( 'systemEntry' );

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
  let a = test.assetFor( 'systemEntry' );

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
    processArgsBase,
    processArgsPropertiesBase,
    processArgsMultipleCommands,
    processArgsPaths,
    processArgsWithSpace,

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
