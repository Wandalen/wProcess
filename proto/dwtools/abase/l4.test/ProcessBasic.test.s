( function _ProcessBasic_test_s( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );

  require( '../l4/ProcessBasic.s' );

}

/*

qqq :

- reacts on requests ( qqq ) in the module
- use application code from test rouitne shellConcurrent for all test routines, maybe?
- make sure tests works in collection, not only in stand-alone mode

*/

var _global = _global_;
var _ = _global_.wTools;
var Self = {};

// --
// context
// --

function suiteBegin()
{
  var self = this;
  self.suitePath = _.path.pathDirTempOpen( _.path.join( __dirname, '../..' ), 'ProcessBasic' );
  self.toolsPath = _.path.nativize( _.path.resolve( __dirname, '../../Tools.s' ) );
  self.toolsPathInclude = `var _ = require( '${ _.strEscape( self.toolsPath ) }' )\n`;
}

//

function suiteEnd()
{
  var self = this;

  _.assert( _.strHas( self.suitePath, '/ProcessBasic-' ) )
  _.path.pathDirTempClose( self.suitePath );
}

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
  throw 'Expects number';

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
  _.include( 'wAppBasic' );
  _.include( 'wStringsExtra' )

  var args = _.process.args();

  if( args.map.exitWithCode )
  process.exit( args.map.exitWithCode )

  if( args.map.loop )
  return _.timeOut( 4000 )

  console.log( __filename );
}

// --
// test
// --

function appArgs( test )
{
  var _argv =  process.argv.slice( 0, 2 );
  _argv = _.path.s.normalize( _argv );

  /* */

  var argv = [];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    subject : '',
    map : Object.create( null ),
    scriptArgs : [],
    scriptString : '',
    subjects : [],
    maps : [],
  }
  test.contains( got, expected );

  /* */

  var argv = [ '' ];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    subject : '',
    map : Object.create( null ),
    scriptArgs : [''],
    scriptString : '',
    subjects : [],
    maps : [],
  }
  test.contains( got, expected );

  /* */

  var argv = [ 'x', ':', 'aa', 'bbb :' ];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    map : { x : 'aa', bbb : '' },
    subject : '',
    scriptArgs : [ 'x', ':', 'aa', 'bbb :' ]
  }
  test.contains( got, expected );

  /* */

  var argv = [ 'x', ' : ', 'y' ];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    map : { x : 'y' },
    subject : '',
    scriptArgs :[ 'x', ' : ', 'y' ]
  }
  test.contains( got, expected );

  /* */

  var argv = [ 'x', ' :', 'y', 'x', ' :', '1' ];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    map : { x : 1 },
    subject : '',
    scriptArgs : [ 'x', ' :', 'y', 'x', ' :', '1']
  }
  test.contains( got, expected );

  /* */

  var argv = [ 'a b c d', 'x', ' :', 'y', 'xyz', 'y', ' :', 1 ];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    map : { x : 'y xyz', y : 1 },
    subject : 'a b c d',
    scriptArgs : [ 'a b c d', 'x', ' :', 'y', 'xyz', 'y', ' :', 1 ]
  }
  test.contains( got, expected );

  /* */

  var argv =
  [
    'filePath',
    'a :', 1,
    'b', ' :2',
    'c :  ', 3,
    'd', ' :  4',
    'e', ' :  ', 5
  ];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    map : { a : 1, b : 2, c : 3, d : 4, e : 5 },
    subject : 'filePath',
    scriptArgs :
    [
      'filePath',
      'a :', 1,
      'b', ' :2',
      'c :  ', 3,
      'd', ' :  4',
      'e', ' :  ', 5
    ]
  }
  test.contains( got, expected );

  /* */

  var argv = [ 'a :b :c :d', 'x', ' :', 0, 'y', ' :', 1 ];
  argv.unshift.apply( argv, _argv );
  var got = _.process.args({ argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    keyValDelimeter : ':',
    map : { a : '', b : '', c : 'd', x : 0, y : 1 },
    subject : '',
    scriptArgs : [ 'a :b :c :d', 'x', ' :', 0, 'y', ' :', 1 ]
  }
  test.contains( got, expected );

  /* */

  var argv = [];
  var got = _.process.args({ argv : [ 'interpreter', 'main.js', '.set v:5 ; .build debug:1 ; .export' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    cmmandsDelimeter : ';',
    subject : '.set',
    map : { v : 5 },
    scriptArgs : [ '.set v:5 ; .build debug:1 ; .export' ],
    scriptString : '.set v:5 ; .build debug:1 ; .export',
    subjects : [ '.set', '.build', '.export' ],
    maps : [ { v : 5 }, { debug : 1 }, {} ],
  }
  test.contains( got, expected );

  /* */

  var argv = [];
  var got = _.process.args({ argv : [ 'interpreter', 'main.js', '.set v:[1 2  3 ] ; .build debug:1 ; .export' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    cmmandsDelimeter : ';',
    subject : '.set',
    map : { v : [ 1,2,3 ] },
    scriptArgs : [ '.set v:[1 2  3 ] ; .build debug:1 ; .export' ],
    scriptString : '.set v:[1 2  3 ] ; .build debug:1 ; .export',
    subjects : [ '.set', '.build', '.export' ],
    maps : [ { v : [ 1,2,3 ] }, { debug : 1 }, {} ],
  }
  test.contains( got, expected );

  /* */

  test.case = 'windows native path as option, no quotes'
  var argv = [];
  var got = _.process.args({ argv : [ 'interpreter', 'main.js', 'path:D:\\path\\to\\file' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    cmmandsDelimeter : ';',
    subject : '',
    map : { path : '', D : '\\path\\to\\file' },
    scriptArgs : [ 'path:D:\\path\\to\\file' ],
    scriptString : 'path:D:\\path\\to\\file',
    subjects : [ '' ],
    maps : [ { path : '', D : '\\path\\to\\file' } ],
  }
  test.contains( got, expected );

  test.case = 'windows native path as option, with quotes'
  var argv = [];
  var got = _.process.args({ argv : [ 'interpreter', 'main.js', 'path:"D:\\path\\to\\file"' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    cmmandsDelimeter : ';',
    subject : '',
    map : { path : 'D:\\path\\to\\file' },
    scriptArgs : [ 'path:"D:\\path\\to\\file"' ],
    scriptString : 'path:"D:\\path\\to\\file"',
    subjects : [ '' ],
    maps : [ { path : 'D:\\path\\to\\file' } ],
  }
  test.contains( got, expected );

  test.case = 'number option with quotes'
  var argv = [];
  var got = _.process.args({ argv : [ 'interpreter', 'main.js', 'v:"10"' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    cmmandsDelimeter : ';',
    subject : '',
    map : { v : 10 },
    scriptArgs : [ 'v:"10"' ],
    scriptString : 'v:"10"',
    subjects : [ '' ],
    maps : [ { v : 10 } ],
  }
  test.contains( got, expected );

  test.case = 'string option with quotes'
  var argv = [];
  var got = _.process.args({ argv : [ 'interpreter', 'main.js', 'str:"abc"' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    cmmandsDelimeter : ';',
    subject : '',
    map : { str : 'abc' },
    scriptArgs : [ 'str:"abc"' ],
    scriptString : 'str:"abc"',
    subjects : [ '' ],
    maps : [ { str : 'abc' } ],
  }
  test.contains( got, expected );

}

//

function appExitHandlerOnce( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );
  var commonDefaults =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1,
    sync : 1
  }

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.include( 'wStringsExtra' )

    var args = _.process.args();

    _.process.exitHandlerOnce( ( arg ) =>
    {
      console.log( 'appExitHandlerOnce:', arg );
    });

    _.timeOut( 1000, () =>
    {
      console.log( 'timeOut handler executed' );
      return 1;
    })

    if( args.map.terminate )
    process.exit( 'SIGINT' );

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var o;
  var con = new _.Consequence().take( null )


  /*  */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      sync : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( ( got ) =>
    {
      test.is( got.exitCode === 0 );
      test.is( _.strHas( got.output, 'timeOut handler executed' ) )
      test.is( _.strHas( got.output, 'appExitHandlerOnce: 0' ) );
      return null;
    })

  })

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath + ' terminate : 1',
      mode : 'spawn',
      stdio : 'pipe',
      sync : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( ( got ) =>
    {
      test.is( got.exitCode === 0 );
      test.is( !_.strHas( got.output, 'timeOut handler executed' ) )
      test.is( !_.strHas( got.output, 'appExitHandlerOnce: 0' ) );
      test.is( _.strHas( got.output, 'appExitHandlerOnce: SIGINT' ) );
      return null;
    });
  })

  return con;
}

//

function shell( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );
  var commonDefaults =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testAppShell.toString() + '\ntestAppShell();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var o;
  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'mode : spawn';

    o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe'
    }

    return null;
  })
  .thenKeep( function( arg )
  {
    /* mode : spawn, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, expectedOutput );
      return null;
    })
  })
  .thenKeep( function( arg )
  {
    /* mode : spawn, stdio : ignore */

    o.stdio = 'ignore';
    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output.length, 0 );
      return null;
    })
  })
  // .thenKeep( function( arg )
  // {
  //   /* mode : spawn, stdio : inherit */

  //   o.stdio = 'inherit';

  //   var options = _.mapSupplement( {}, o, commonDefaults );

  //   return _.process.start( options )
  //   .thenKeep( function()
  //   {
  //     test.identical( options.exitCode, 0 );
  //     test.identical( options.output.length, 0 );
  //   })
  // })
  .thenKeep( function( arg )
  {
    test.case = 'mode : shell';

    o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg )
  {
    /* mode : shell, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, expectedOutput );
      return null;
    })
  })
  .thenKeep( function( arg )
  {
    /* mode : shell, stdio : ignore */

    o.stdio = 'ignore'

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output.length, 0 );
      return null;
    })
  })

  // qqq : ?
  // .thenKeep( function( arg )
  // {
  //   /* mode : shell, stdio : inherit */

  //   o.stdio = 'inherit'

  //   var options = _.mapSupplement( {}, o, commonDefaults );

  //   return _.process.start( options )
  //   .thenKeep( function()
  //   {
  //     test.identical( options.exitCode, 0 );
  //     test.identical( options.output.length, 0 );
  //   })
  // })
  .thenKeep( function( arg )
  {
    test.case = 'spawn, stop process using kill';

    o =
    {
      execPath :  'node ' + testAppPath + ' loop : 1',
      mode : 'spawn',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.process.start( options );
    _.timeOut( 500, () =>
    {
      test.identical( options.process.killed, false );
      options.process.kill( 'SIGINT' );
      return null;
    })
    shell.finally(function()
    {
      test.identical( options.process.killed, true );
      test.identical( !options.exitCode, true );
      return null;
    })

    return shell;
  })
  .thenKeep( function( arg )
  {
    test.case = 'shell, stop process using kill';

    o =
    {
      execPath :  'node ' + testAppPath + ' loop : 1',
      mode : 'shell',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.process.start( options );
    _.timeOut( 500, () =>
    {
      test.identical( options.process.killed, false );
      options.process.kill( 'SIGINT' );
      return null;
    })
    shell.finally(function()
    {
      test.identical( options.process.killed, true );
      test.identical( !options.exitCode, true );
      return null;
    })

    return shell;
  })
  .thenKeep( function( arg )
  {
    test.case = 'spawn, return good code';

    o =
    {
      execPath :  'node ' + testAppPath + ' exitWithCode : 0',
      mode : 'spawn',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.mustNotThrowError( _.process.start( options ) )
    .thenKeep( () =>
    {
      test.identical( options.exitCode, 0 );
      return null;
    });
  })
  .thenKeep( function( arg )
  {
    test.case = 'spawn, return bad code';

    o =
    {
      execPath :  'node ' + testAppPath + ' exitWithCode : 1',
      mode : 'spawn',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.shouldThrowErrorOfAnyKind( _.process.start( options ) )
    .thenKeep( () =>
    {
      test.identical( options.exitCode, 1 );
      return null;
    });
  })
  .thenKeep( function( arg )
  {
    test.case = 'shell, return good code';

    o =
    {
      execPath :  'node ' + testAppPath + ' exitWithCode : 0',
      mode : 'shell',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.mustNotThrowError( _.process.start( options ) )
    .thenKeep( () =>
    {
      test.identical( options.exitCode, 0 );
      return null;
    });
  })
  .thenKeep( function( arg )
  {
    test.case = 'shell, return bad code';

    o =
    {
      execPath :  'node ' + testAppPath + ' exitWithCode : 1',
      mode : 'shell',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.shouldThrowErrorOfAnyKind( _.process.start( options ) )
    .thenKeep( () =>
    {
      test.identical( options.exitCode, 1 );
      return null;
    });
  })
  //
  // test.case = 'test';
  // test.identical( 0, 0 );

  // con
  // .thenKeep( function( arg )
  // {
  //   test.case = 'simple command';
  //   var con = _.process.start( 'exit' );
  //   return test.returnsSingleResource( con );
  // })
  // .thenKeep( function( arg )
  // {
  //   test.case = 'bad command, shell';
  //   var con = _.process.start({ code : 'xxx', throwingExitCode : 1, mode : 'shell' });
  //   return test.shouldThrowErrorSync( con );
  // })
  // .thenKeep( function( arg )
  // {
  //   test.case = 'bad command, spawn';
  //   var con = _.process.start({ code : 'xxx', throwingExitCode : 1, mode : 'spawn' });
  //   return test.shouldThrowErrorSync( con );
  // })
  // .thenKeep( function( arg )
  // {
  //   test.case = 'several arguments';
  //   var con = _.process.start( 'echo echo something' );
  //   return test.mustNotThrowError( con );
  // })
  // ;

  // con.thenKeep( () =>  _.fileProvider.fileDelete( testAppPath ) );

  .thenKeep( function( arg )
  {
    test.case = 'shell, stop using timeOut';

    o =
    {
      execPath :  'node ' + testAppPath + ' loop : 1',
      mode : 'shell',
      stdio : 'pipe',
      timeOut : 500
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.process.start( options );
    return test.shouldThrowErrorAsync( shell )
    .thenKeep( () =>
    {
      test.identical( options.process.killed, true );
      test.identical( !options.exitCode, true );
      return null;
    })
  })


  return con;
}

shell.timeOut = 30000;

//

function shellSync( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );
  var commonDefaults =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1,
    sync : 1
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + context.testAppShell.toString() + '\ntestAppShell();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var o;

  //

  test.case = 'mode : spawn';
  o =
  {
    execPath :  'node ' + testAppPath,
    mode : 'spawn',
    stdio : 'pipe'
  }

  /* mode : spawn, stdio : pipe */

  var options = _.mapSupplement( {}, o, commonDefaults );
  _.process.start( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : spawn, stdio : ignore */

  o.stdio = 'ignore';
  var options = _.mapSupplement( {}, o, commonDefaults );
  _.process.start( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'mode : shell';
  o =
  {
    execPath :  'node ' + testAppPath,
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  _.process.start( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : shell, stdio : ignore */

  o.stdio = 'ignore'
  var options = _.mapSupplement( {}, o, commonDefaults );
  _.process.start( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'shell, stop process using timeOut';
  o =
  {
    execPath :  'node ' + testAppPath + ' loop : 1',
    mode : 'shell',
    stdio : 'pipe',
    timeOut : 500
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) );

  //

  test.case = 'spawn, return good code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.mustNotThrowError( () => _.process.start( options ) )
  test.identical( options.exitCode, 0 );

  //

  test.case = 'spawn, return bad code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) )
  test.identical( options.exitCode, 1 );

  //

  test.case = 'shell, return good code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'shell',
    stdio : 'pipe'
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  test.mustNotThrowError( () => _.process.start( options ) )
  test.identical( options.exitCode, 0 );

  //

  test.case = 'shell, return bad code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) )
  test.identical( options.exitCode, 1 );

}

shellSync.timeOut = 30000;

//

function shellSyncAsync( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );
  var commonDefaults =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1,
    sync : 1,
    deasync : 1
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + context.testAppShell.toString() + '\ntestAppShell();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var o;

  //

  test.case = 'mode : fork';
  o =
  {
    execPath : testAppPath,
    mode : 'fork',
    stdio : 'pipe'
  }

  /* mode : spawn, stdio : pipe */

  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : fork, stdio : ignore */

  o.stdio = 'ignore';
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'mode : spawn';
  o =
  {
    execPath :  'node ' + testAppPath,
    mode : 'spawn',
    stdio : 'pipe'
  }

  /* mode : spawn, stdio : pipe */

  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : spawn, stdio : ignore */

  o.stdio = 'ignore';
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'mode : shell';
  o =
  {
    execPath :  'node ' + testAppPath,
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : shell, stdio : ignore */

  o.stdio = 'ignore'
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'shell, stop process using timeOut';
  o =
  {
    execPath :  'node ' + testAppPath + ' loop : 1',
    mode : 'shell',
    stdio : 'pipe',
    timeOut : 500
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) );

  //

  test.case = 'spawn, return good code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );

  //

  test.case = 'spawn, return bad code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) )
  test.identical( options.exitCode, 1 );

  //

  test.case = 'shell, return good code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'shell',
    stdio : 'pipe'
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.process.start( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );

  //

  test.case = 'shell, return bad code';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) )
  test.identical( options.exitCode, 1 );

}

shellSyncAsync.timeOut = 30000;

//

function shell2( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );
  var commonDefaults =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1
  }

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ).join( ' ' ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var o;
  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'mode : shell';

    o =
    {
      execPath :  'node ' + testAppPath,
      args : [ 'staging', 'debug' ],
      mode : 'shell',
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg )
  {
    /* mode : shell, stdio : pipe */

    var options = _.mapSupplement( {}, _.cloneJust( o ), commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, o.args.join( ' ' ) + '\n' );
      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'mode : shell, passingThrough : true, no args';

    o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      passingThrough : 1,
      stdio : 'pipe'
    }

    return null;
  })
  .thenKeep( function( arg )
  {
    /* mode : shell, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      var expectedArgs= _.arrayAppendArray( [], process.argv.slice( 2 ) );
      test.identical( options.output, expectedArgs.join( ' ' ) + '\n' );
      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'mode : spawn, passingThrough : true, only filePath in args';

    o =
    {
      execPath :  'node',
      args : [ testAppPath ],
      mode : 'spawn',
      passingThrough : 1,
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg )
  {
    /* mode : spawn, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      var expectedArgs = _.arrayAppendArray( [], process.argv.slice( 2 ) );
      test.identical( options.output, expectedArgs.join( ' ' ) + '\n' );
      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'mode : spawn, passingThrough : true, incorrect usage of o.path in spawn mode';

    o =
    {
      execPath :  'node ' + testApp,
      args : [ 'staging' ],
      mode : 'spawn',
      passingThrough : 1,
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg )
  {
    var options = _.mapSupplement( {}, o, commonDefaults );
    return test.shouldThrowErrorOfAnyKind( _.process.start( options ) );
  })

  //

  con.thenKeep( function()
  {
    test.case = 'mode : shell, passingThrough : true';

    o =
    {
      execPath :  'node ' + testAppPath,
      args : [ 'staging', 'debug' ],
      mode : 'shell',
      passingThrough : 1,
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg )
  {
    /* mode : shell, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      var expectedArgs = _.arrayAppendArray( [ 'staging', 'debug' ], process.argv.slice( 2 ) );
      test.identical( options.output, expectedArgs.join( ' ' ) + '\n');
      return null;
    })
  })

  return con;
}

shell2.timeOut = 30000;

//

function shellCurrentPath( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    debugger
    console.log( process.cwd() ); /* qqq : should not be visible if verbosity of tester is low, if possible */
    if( process.send )
    process.send({ currentPath : process.cwd() })
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  //

  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'mode : shell';

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath : __dirname,
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
    }
    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.output, expectedOutput );
      return null;
    })
  })

  /**/

  con.thenKeep( function()
  {
    test.case = 'mode : spawn';

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
    }
    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.output, expectedOutput );
      return null;
    })
  })

  /**/

  con.thenKeep( function()
  {
    test.case = 'mode : exec';

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath : __dirname,
      mode : 'exec',
      stdio : 'pipe',
      outputCollecting : 1,
    }
    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.output, expectedOutput );
      return null;
    })
  })

  /**/

  con.thenKeep( function()
  {
    test.case = 'mode : fork';

    let output;

    let o =
    {
      execPath : testAppPath,
      currentPath : __dirname,
      mode : 'fork',
    }
    let con = _.process.start( o );
    o.process.on( 'message', ( m ) =>
    {
      output = m;
    })
    con.thenKeep( function( got )
    {
      test.identical( output.currentPath, __dirname );
      return null;
    })

    return con;
  })

  return con;
}

shellCurrentPath.timeOut = 30000;

//

function shellCurrentPaths( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    debugger
    console.log( process.cwd() ); /* qqq : should not be visible if verbosity of tester is low, if possible */
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = new _.Consequence().take( null );

  let o2 =
  {
    execPath : 'node ' + testAppPath,
    ready,
    currentPath : [ routinePath, __dirname ],
    stdio : 'pipe',
    outputCollecting : 1
  }

  /* */

  _.process.start( _.mapSupplement( { mode : 'shell' }, o2 ) );

  ready.then( ( got ) =>
  {
    let o1 = got[ 0 ];
    let o2 = got[ 1 ];

    test.is( _.strHas( o1.output, _.path.nativize( routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    return got;
  })

  /* */

  _.process.start( _.mapSupplement( { mode : 'spawn' }, o2 ) );

  ready.then( ( got ) =>
  {
    let o1 = got[ 0 ];
    let o2 = got[ 1 ];

    test.is( _.strHas( o1.output, _.path.nativize( routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    return got;
  })

  /* */

  _.process.start( _.mapSupplement( { mode : 'exec' }, o2 ) );

  ready.then( ( got ) =>
  {
    let o1 = got[ 0 ];
    let o2 = got[ 1 ];

    test.is( _.strHas( o1.output, _.path.nativize( routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    return got;
  })

  /* */

  _.process.start( _.mapSupplement( { mode : 'fork', execPath : testAppPath }, o2 ) );

  ready.then( ( got ) =>
  {
    let o1 = got[ 0 ];
    let o2 = got[ 1 ];

    test.is( _.strHas( o1.output, _.path.nativize( routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    return got;
  })

  /*  */

  _.process.start( _.mapSupplement( { mode : 'spawn', execPath : [ 'node ' + testAppPath, 'node ' + testAppPath ] }, o2 ) );

  ready.then( ( got ) =>
  {
    let o1 = got[ 0 ];
    let o2 = got[ 1 ];
    let o3 = got[ 2 ];
    let o4 = got[ 3 ];

    test.is( _.strHas( o1.output, _.path.nativize( routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    test.is( _.strHas( o3.output, _.path.nativize( routinePath ) ) );
    test.identical( o3.exitCode, 0 );

    test.is( _.strHas( o4.output, __dirname ) );
    test.identical( o4.exitCode, 0 );

    return got;
  })

  return ready;
}

//

/*

  qqq : investigate please
  test routine shellFork causes

 1: node::DecodeWrite
 2: node::Start
 3: v8::RetainedObjectInfo::~RetainedObjectInfo
 4: uv_loop_size
 5: uv_disable_stdio_inheritance
 6: uv_dlerror
 7: uv_run
 8: node::CreatePlatform
 9: node::CreatePlatform
10: node::Start
11: v8_inspector::protocol::Runtime::API::StackTrace::fromJSONString
12: BaseThreadInitThunk
13: RtlUserThreadStart

*/


function shellFork( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  //

  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'no args';

    let o =
    {
      execPath :   testAppPath,
      args : null,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output, '[]' ) );
      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'args';

    let o =
    {
      execPath :   testAppPath,
      args : [ 'arg1', 'arg2' ],
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output,  "[ 'arg1', 'arg2' ]" ) );
      return null;
    })
  })

  //

  // con.thenKeep( function()
  // {
  //   test.case = 'stdio : inherit';

  //   let o =
  //   {
  //     execPath :   testAppPath,
  //     args : [ 'arg1', 'arg2' ],
  //     mode : 'fork',
  //     stdio : 'inherit',
  //     outputCollecting : 1,
  //     outputPiping : 1,
  //   }

  //   return _.process.start( o )
  //   .thenKeep( function( got )
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.output.length, 0 );
  //     return null;
  //   })
  // })

  //

  con.thenKeep( function()
  {
    test.case = 'stdio : ignore';

    let o =
    {
      execPath :   testAppPath,
      args : [ 'arg1', 'arg2' ],
      mode : 'fork',
      stdio : 'ignore',
      outputCollecting : 1,
      outputPiping : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.output.length, 0 );
      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'complex';

    function testApp2()
    {
      console.log( process.argv.slice( 2 ) );
      console.log( process.env );
      console.log( process.cwd() );
      console.log( process.execArgv );
    }

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      execPath :   testAppPath2,
      currentPath : routinePath,
      env : { 'key1' : 'val' },
      args : [ 'arg1', 'arg2' ],
      interpreterArgs : [ '--no-warnings' ],
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output,  "[ 'arg1', 'arg2' ]" ) );
      test.is( _.strHas( o.output,  "key1: 'val'" ) );
      test.is( _.strHas( o.output,  _.fileProvider.path.nativize( routinePath ) ) );
      test.is( _.strHas( o.output,  "[ '--no-warnings' ]" ) );

      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'complex + deasync';

    function testApp2()
    {
      console.log( process.argv.slice( 2 ) );
      console.log( process.env );
      console.log( process.cwd() );
      console.log( process.execArgv );
    }

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      execPath :   testAppPath2,
      currentPath : routinePath,
      env : { 'key1' : 'val' },
      args : [ 'arg1', 'arg2' ],
      interpreterArgs : [ '--no-warnings' ],
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      sync : 1,
      deasync : 1
    }

    _.process.start( o );

    test.identical( o.exitCode, 0 );
    test.is( _.strHas( o.output,  "[ 'arg1', 'arg2' ]" ) );
    test.is( _.strHas( o.output,  "key1: 'val'" ) );
    test.is( _.strHas( o.output,  _.fileProvider.path.nativize( routinePath ) ) );
    test.is( _.strHas( o.output,  "[ '--no-warnings' ]" ) );

    return null;
  })

  //

  //

  con.thenKeep( function()
  {
    test.case = 'test is ipc works';

    function testApp2()
    {
      process.on( 'message', ( got ) =>
      {
        process.send({ message : 'child received ' + got.message })
        process.exit();
      })
    }

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      execPath :   testAppPath2,
      mode : 'fork',
      stdio : 'pipe',
    }

    let gotMessage;
    let con = _.process.start( o );

    o.process.send({ message : 'message from parent' });
    o.process.on( 'message', ( got ) =>
    {
      gotMessage = got.message;
    })

    con.thenKeep( function( got )
    {
      test.identical( gotMessage, 'child received message from parent' )
      test.identical( o.exitCode, 0 );
      return null;
    })

    return con;
  })

  //

  con.thenKeep( function()
  {
    test.case = 'execPath can contain path to js file and arguments';

    let o =
    {
      execPath :   testAppPath + ' arg0',
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output,  `[ 'arg0' ]` ) );
      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'test timeOut';

    function testApp2()
    {
      setTimeout( () =>
      {
        console.log( 'timeOut' );
      }, 5000 )
    }

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      execPath :   testAppPath2,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 1,
      timeOut : 1000,
    }

    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, null );
      return null;
    })
  })

  //

  con.thenKeep( function()
  {
    test.case = 'test timeOut';

    function testApp2()
    {
      setTimeout( () =>
      {
        console.log( 'timeOut' );
      }, 5000 )
    }

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      execPath :   testAppPath2,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      timeOut : 1000,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, null );
      return null;
    })
  })

  return con;

}

shellFork.timeOut = 30000;

//

function shellWithoutExecPath( test )
{
  let context = this;
  let counter = 0;
  let time = 0;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  let filePath = _.fileProvider.path.nativize( _.path.join( routinePath, 'file.txt' ) );
  let ready = _.Consequence().take( null );

  let testAppCode =
  [
    `let filePath = '${_.strEscape( filePath )}';\n`,
    context.toolsPathInclude,
    context.testApp.toString(),
    '\ntestApp();'
  ].join( '' );

  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single';
    time = _.timeNow();
    return null;
  })

  let singleOption =
  {
    args : [ 'node', testAppPath, '1000' ],
    ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleOption )
  .then( ( arg ) =>
  {
    test.identical( arg.exitCode, 0 );
    test.is( singleOption === arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  return ready;
}

//

function shellArgsOption( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.path.join( routinePath, 'testApp.js' );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );

  /* */

  test.case = 'args option as array, source args array should not be changed'
  var args = [ 'arg1', 'arg2' ];
  var shellOptions =
  {
    execPath : 'node ' + testAppPath,
    outputCollecting : 1,
    args : args,
    mode : 'spawn',
    ready : ready
  }

  _.process.start( shellOptions )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( got.args, [ testAppPath, 'arg1', 'arg2' ] );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    test.identical( shellOptions.args, got.args );
    test.identical( args, [ 'arg1', 'arg2' ] );
    return null;
  })

  /*  */

  return ready;
}

shellArgsOption.timeOut = 30000;

//

function shellArgumentsParsing( test )
{
  let context = this;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPathNoSpace = _.fileProvider.path.nativize( _.path.join( routinePath, 'noSpace', 'testApp.js' ) );
  let testAppPathSpace= _.fileProvider.path.nativize( _.path.join( routinePath, 'with space', 'testApp.js' ) );
  let ready = _.Consequence().take( null );

  let testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPathNoSpace, testAppCode );
  _.fileProvider.fileWrite( testAppPathSpace, testAppCode );

  /* for combination:
      path to exe file : [ with space, without space ]
      execPath : [ has arguments, only path to exe file ]
      args : [ has arguments, empty ]
      mode : [ 'fork', 'exec', 'spawn', 'shell' ]
  */

  /* - */

  ready

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args has arguments' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args has arguments' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args has arguments' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args has arguments' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathNoSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args: empty' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args: empty' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: empty' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ),
      args : null,
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args: empty' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathNoSpace ),
      args : null,
      ipc : 1,
      mode : 'fork',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  //end of fork

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args has arguments' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathSpace ),
        map : { secondArg : 1 },
        scriptArgs : [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ]
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args has arguments' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathNoSpace ),
        map : { secondArg : 1 },
        scriptArgs : [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ]
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args has arguments' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathSpace ),
        map : { secondArg : 1 },
        scriptArgs : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ]
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args has arguments' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathNoSpace ),
        map : { secondArg : 1 },
        scriptArgs : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ]
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args: empty' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathSpace ),
        map : { secondArg : 1 },
        scriptArgs : [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ]
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args: empty' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' +_.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathNoSpace ),
        map : { secondArg : 1 },
        scriptArgs : [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ]
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: empty' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : null,
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathSpace ),
        map : {},
        scriptArgs : []
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args: empty' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
      args : null,
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let expected =
      {
        mainPath : _.path.normalize( testAppPathNoSpace ),
        map : {},
        scriptArgs : []
      }
      let args = JSON.parse( o.output );
      test.contains( args, expected )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args has arguments' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args has arguments' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args has arguments' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args has arguments' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args: empty' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args: empty' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: empty' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : null,
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args: empty' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
      args : null,
      ipc : 1,
      mode : 'spawn',
      outputPiping : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args has arguments' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )
      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args has arguments' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args has arguments' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args has arguments' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
      args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: has arguments' 'args: empty' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: has arguments' 'args: empty' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
      args : null,
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: empty' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : null,
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPath: only path' 'args: empty' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
      args : null,
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  /* special case from willbe */

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: willbe args' 'fork'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ),
      args : '.imply v:1 ; .each . .resources.list about::name',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    let got;
    o.process.on( 'message', ( data ) => { got = data } )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { v : 1 } )
      test.identical( got.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: willbe args' 'spawn'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : '.imply v:1 ; .each . .resources.list about::name',
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { v : 1 } )
      test.identical( got.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: willbe args' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : '.imply v:1 ; .each . .resources.list about::name',
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { v : 1 } )
      test.identical( got.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPath: only path' 'args: willbe args' 'exec'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : '.imply v:1 ; .each . .resources.list about::name',
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { v : 1 } )
      test.identical( got.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

      return null;
    })

    return con;
  })

  /*  */

  return ready;

  /**/

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.include( 'wStringsExtra' )
    var args = _.process.args();
    if( process.send )
    process.send( args );
    else
    console.log( JSON.stringify( args ) );
  }

}

shellArgumentsParsing.timeOut = 60000;

//

function shellArgumentsParsingNonTrivial( test )
{
  let context = this;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPathNoSpace = _.fileProvider.path.nativize( _.path.join( routinePath, 'noSpace', 'testApp.js' ) );
  let testAppPathSpace= _.fileProvider.path.nativize( _.path.join( routinePath, 'with space', 'testApp.js' ) );
  let ready = _.Consequence().take( null );

  let testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPathNoSpace, testAppCode );
  _.fileProvider.fileWrite( testAppPathSpace, testAppCode );

  /*

  execPath : '"/dir with space/app.exe" `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`,
  args : '"some arg"'
  mode : 'spawn'
  ->
  execPath : '/dir with space/app.exe'
  args : [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ],

  =

  execPath : '"/dir with space/app.exe" firstArg secondArg:1',
  args : '"third arg"',
  ->
  execPath : '/dir with space/app.exe'
  args : [ 'firstArg', 'secondArg:1', '"third arg"' ]

  =

  execPath : '"first arg"'
  ->
  execPath : 'first arg'
  args : []

  =

  args : '"first arg"'
  ->
  execPath : 'first arg'
  args : []

  =

  args : [ '"first arg"', 'second arg' ]
  ->
  execPath : 'first arg'
  args : [ 'second arg' ]

  =

  args : [ '"', 'first', 'arg', '"' ]
  ->
  execPath : '"'
  args : [ 'first', 'arg', '"' ]

  =

  args : [ '', 'first', 'arg', '"' ]
  ->
  execPath : ''
  args : [ 'first', 'arg', '"' ]

  =

  args : [ '"', '"', 'first', 'arg', '"' ]
  ->
  execPath : '"'
  args : [ '"', 'first', 'arg', '"' ]

  */

  ready

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`',
      args : '"some arg"',
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, 'node' );
      test.identical( o.args, [ testAppPathSpace, 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`',
      args : '"some arg"',
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, 'node' );
      test.identical( o.args, [ testAppPathSpace, 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`',
      args : '"some arg"',
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, 'node' );
      test.identical( o.args, [ testAppPathSpace, 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`',
      args : '"some arg"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, testAppPathSpace );
      test.identical( o.args, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
      args : '"third arg"',
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, 'node' );
      test.identical( o.args, [ testAppPathSpace, 'firstArg', 'secondArg:1', '"third arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
      args : '"third arg"',
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, 'node' );
      test.identical( o.args, [ testAppPathSpace, 'firstArg', 'secondArg:1', '"third arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
      args : '"third arg"',
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, 'node' );
      test.identical( o.args, [ testAppPathSpace, 'firstArg', 'secondArg:1', '"third arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
      args : '"third arg"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.execPath, testAppPathSpace );
      test.identical( o.args, [ 'firstArg', 'secondArg:1', '"third arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : 1 } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : '"first arg"',
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0,
      ready : con
    }
    _.process.start( o );

    con.finally( ( err, got ) =>
    {
      test.is( !!err );
      test.is( _.strHas( err.message, 'first arg' ) )
      test.identical( o.execPath, 'first arg' );
      test.identical( o.args, [] );

      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      args : '"first arg"',
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0,
      ready : con
    }
    _.process.start( o );

    con.finally( ( err, got ) =>
    {
      test.is( !!err );
      test.is( _.strHas( err.message, 'first arg' ) )
      test.identical( o.execPath, 'first arg' );
      test.identical( o.args, [] );

      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      args : [ '"first arg"', 'second arg' ],
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0,
      ready : con
    }
    _.process.start( o );

    con.finally( ( err, got ) =>
    {
      test.is( !!err );
      test.is( _.strHas( err.message, 'first arg' ) )
      test.identical( o.execPath, 'first arg' );
      test.identical( o.args, [ 'second arg' ] );

      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      args : [ '"', 'first', 'arg', '"' ],
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0,
      ready : con
    }
    _.process.start( o );

    con.finally( ( err, got ) =>
    {
      test.is( !!err );
      test.is( _.strHas( err.message, '"' ) )
      test.identical( o.execPath, '"' );
      test.identical( o.args, [ 'first', 'arg', '"' ] );

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      args : [ '', 'first', 'arg', '"' ],
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0,
      ready : con
    }
    _.process.start( o );

    con.finally( ( err, got ) =>
    {
      test.is( !!err );
      test.is( _.strHas( err.message, `Received ''` ) );
      test.identical( o.execPath, '' );
      test.identical( o.args, [ 'first', 'arg', '"' ] );

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      args : [ '"', '"', 'first', 'arg', '"' ],
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0,
      ready : con
    }
    _.process.start( o );

    con.finally( ( err, got ) =>
    {
      test.is( !!err );
      test.is( _.strHas( err.message, `spawn " ENOENT` ) );
      test.identical( o.execPath, '"' );
      test.identical( o.args, [ '"', 'first', 'arg', '"' ] );

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'no execPath, empty args'

    let con = new _.Consequence().take( null );
    let o =
    {
      args : [],
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0,
      ready : con
    }

    _.process.start( o );

    return test.shouldThrowErrorOfAnyKind( con );
  })

  /*  */

  return ready;


  /**/

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.include( 'wStringsExtra' )
    var args = _.process.args();
    console.log( JSON.stringify( args ) );
  }
}

shellArgumentsParsingNonTrivial.timeOut = 60000;


//

function shellArgumentsNestedQuotes( test )
{
  let context = this;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPathNoSpace = _.fileProvider.path.nativize( _.path.join( routinePath, 'noSpace', 'testApp.js' ) );
  let testAppPathSpace= _.fileProvider.path.nativize( _.path.join( routinePath, 'with space', 'testApp.js' ) );
  let ready = _.Consequence().take( null );

  let testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPathNoSpace, testAppCode );
  _.fileProvider.fileWrite( testAppPathSpace, testAppCode );

  /* */

  ready

  .then( () =>
  {
    test.case = 'fork'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ),
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      let scriptArgs =
      [
        `'s-s'`, `"s-d"`, "`s-b`",
        `'d-s'`, `"d-d"`, "`d-b`",
        `'b-s'`, `"b-d"`, "`b-b`",
      ]
      test.identical( got.scriptArgs, scriptArgs )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'fork'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ),
      args : args.slice(),
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, args )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'spawn'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ),
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      let scriptArgs =
      [
        `'s-s'`, `"s-d"`, "`s-b`",
        `'d-s'`, `"d-d"`, "`d-b`",
        `'b-s'`, `"b-d"`, "`b-b`",
      ]
      test.identical( got.scriptArgs, scriptArgs )

      return null;
    })

    return con;

  })

  .then( () =>
  {
    test.case = 'spawn'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : args.slice(),
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, args )

      return null;
    })

    return con;

  })

  .then( () =>
  {
    test.case = 'shell'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ),
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      let scriptArgs =
      [
        `'s-s'`, `"s-d"`, "`s-b`",
        `'d-s'`, `"d-d"`, "`d-b`",
        `'b-s'`, `"b-d"`, "`b-b`",
      ]
      test.identical( got.scriptArgs, scriptArgs )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'shell'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : args.slice(),
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, args )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = 'exec'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ),
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      let scriptArgs =
      [
        `'s-s'`, `"s-d"`, "`s-b`",
        `'d-s'`, `"d-d"`, "`d-b`",
        `'b-s'`, `"b-d"`, "`b-b`",
      ]
      test.identical( got.scriptArgs, scriptArgs )

      return null;
    })

    return con;

  })

  .then( () =>
  {
    test.case = 'exec'

    let con = new _.Consequence().take( null );
    let args =
    [
      ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
      ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
      ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
    ]
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ),
      args : args.slice(),
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, args )

      return null;
    })

    return con;

  })

  /* */

  return ready;

  /**/

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.include( 'wStringsExtra' )
    var args = _.process.args();
    console.log( JSON.stringify( args ) );
  }
}

shellArgumentsNestedQuotes.timeOut = 60000;

//

function shellExecPathQuotesClosing( test )
{
  let context = this;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPathSpace= _.fileProvider.path.nativize( _.path.join( routinePath, 'with space', 'testApp.js' ) );
  let ready = _.Consequence().take( null );

  let testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPathSpace, testAppCode );

  /* */

  ready

  testcase( 'quoted arg' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' "arg"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' arg' );
      test.identical( o.args, [ 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' "arg"',
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, 'node ' + testAppPathSpace + ' arg' );
      test.identical( o.args, [ testAppPathSpace,'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' "arg"',
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' arg' );
      test.identical( o.args, [ testAppPathSpace,'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' "arg"',
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' arg' );
      test.identical( o.args, [ testAppPathSpace,'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  testcase( 'unquoted arg' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' arg',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' arg' );
      test.identical( o.args, [ 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' arg',
      mode : 'spawn',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, 'node ' + testAppPathSpace + ' arg' );
      test.identical( o.args, [ testAppPathSpace,'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' arg',
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' arg' );
      test.identical( o.args, [ testAppPathSpace,'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' arg',
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' arg' );
      test.identical( o.args, [ testAppPathSpace, 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  /*  */

  testcase( 'single quote' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' " arg',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' " arg' );
      test.identical( o.args, [ '"', 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ '"', 'arg' ] )

      return null;
    })

    return con;
  })

  /*  */

  testcase( 'single quote' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' " arg',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace+ ' " arg' );
      test.identical( o.args, [ '"', 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ '"', 'arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' arg "',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' arg "' );
      test.identical( o.args, [ 'arg', '"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg', '"' ] )

      return null;
    })

    return con;
  })

  testcase( 'arg starts with quote' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' "arg',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) );
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' "arg"arg',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) );
  })

  testcase( 'arg ends with quote' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' arg"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' arg"' );
      test.identical( o.args, [ 'arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' arg"arg"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o )

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' arg"arg"' );
      test.identical( o.args, [ 'arg"arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg"arg"' ] )

      return null;
    })

    return con;
  })

  testcase( 'quoted with different symbols' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ` "arg'`,
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) );
  })

  testcase( 'quote as part of arg' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' arg"arg',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' arg"arg' );
      test.identical( o.args, [ 'arg"arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg"arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' "arg"arg"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' arg"arg' );
      test.identical( o.args, [ 'arg"arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg"arg' ] )

      return null;
    })

    return con;
  })

  testcase( 'option arg with quoted value' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' option : "value"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' option : value' );
      test.identical( o.args, [ 'option', ':', 'value' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value' } )
      test.identical( got.scriptArgs, [ 'option', ':', 'value' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' option:"value with space"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' option:"value with space"' );
      test.identical( o.args, [ 'option:"value with space"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value with space' } )
      test.identical( got.scriptArgs, [ 'option:"value with space"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' option : "value with space"',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' option : value with space' );
      test.identical( o.args, [ 'option', ':', 'value with space' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value with space' } )
      test.identical( got.scriptArgs, [ 'option', ':', 'value with space' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' option:"value',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' option:"value' );
      test.identical( o.args, [ 'option:"value' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : '"value' } )
      test.identical( got.scriptArgs, [ 'option:"value' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' "option: "value""',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' option: "value"' );
      test.identical( o.args, [ 'option: "value"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value' } )
      test.identical( got.scriptArgs, [ 'option: "value"' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' option : "value',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) );
  })

  testcase( 'double quoted with space inside, same quotes' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' "option: "value with space""',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    return test.shouldThrowErrorOfAnyKind( con );
  })

  testcase( 'double quoted with space inside, diff quotes' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ' `option: "value with space"`',
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' option: "value with space"' );
      test.identical( o.args, [ 'option: "value with space"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value with space' } )
      test.identical( got.scriptArgs, [ 'option: "value with space"' ] )

      return null;
    })

    return con;
  })

  testcase( 'escaped quotes, mode shell' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' option: \\"value with space\\"',
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' option: "\\"value with space\\""' );
      test.identical( o.args, [ testAppPathSpace, 'option:', '\\"value with space\\"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.mainPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value with space' } )
      test.identical( got.scriptArgs, [ 'option:', '"value with space"' ] )

      return null;
    })

    return con;
  })

  /*  */

  return ready;

  /*  */

  function testcase( src )
  {
    ready.then( () =>
    {
      test.case = src;
      return null;
    })
    return ready;
  }

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.include( 'wStringsExtra' )
    var args = _.process.args();
    console.log( JSON.stringify( args ) );
  }
}

shellExecPathQuotesClosing.timeOut = 60000;

//

function shellExecPathSeveralCommands( test )
{
  let context = this;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPath =  _.path.join( routinePath, 'app.js' );

  function app()
  {
    console.log( process.argv.slice( 2 ) );
  }

  let testAppCode = app.toString() + '\napp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = _.Consequence().take( null );

  /* */

  ready

  testcase( 'quoted, mode:shell' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : '"node app.js arg1 && node app.js arg2"',
      mode : 'shell',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( got.output, `[ 'arg1' ]` ), 1 );
      test.identical( _.strCount( got.output, `[ 'arg2' ]` ), 1 );
      return null;
    })

    return con;
  })

  //

  testcase( 'quoted, mode:spawn' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : '"node app.js arg1 && node app.js arg2"',
      mode : 'spawn',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorAsync( _.process.start( o ) )
  })

  //

  testcase( 'quoted, mode:fork' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : '"node app.js arg1 && node app.js arg2"',
      mode : 'fork',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorAsync( _.process.start( o ) )
  })

  //

  testcase( 'quoted, mode:exec' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : '"node app.js arg1 && node app.js arg2"',
      mode : 'exec',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( got.output, `[ 'arg1' ]` ), 1 );
      test.identical( _.strCount( got.output, `[ 'arg2' ]` ), 1 );
      return null;
    })

    return con;
  })

  //

  testcase( 'no quotes, mode:shell' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node app.js arg1 && node app.js arg2',
      mode : 'shell',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( got.output, `[ 'arg1' ]` ), 1 );
      test.identical( _.strCount( got.output, `[ 'arg2' ]` ), 1 );
      return null;
    })

    return con;
  })

  //

  testcase( 'no quotes, mode:spawn' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node app.js arg1 && node app.js arg2',
      mode : 'spawn',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( got.output, `[ 'arg1', '&&', 'node', 'app.js', 'arg2' ]` ), 1 );
      return null;
    })

    return con;
  })

  //

  testcase( 'no quotes, mode:fork' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node app.js arg1 && node app.js arg2',
      mode : 'fork',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorAsync( _.process.start( o ) );
  })

  //

  testcase( 'no quotes, mode:exec' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node app.js arg1 && node app.js arg2',
      mode : 'exec',
      currentPath : routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( got.output, `[ 'arg1' ]` ), 1 );
      test.identical( _.strCount( got.output, `[ 'arg2' ]` ), 1 );
      return null;
    })

    return con;
  })

  /*  */

  return ready;

  /*  */

  function testcase( src )
  {
    ready.then( () =>
    {
      test.case = src;
      return null;
    })
    return ready;
  }
}

shellExecPathQuotesClosing.timeOut = 60000;

//

function shellVerbosity( test )
{
  let context = this;
  let routinePath = _.path.join( context.suitePath, test.name );
  let ready = _.Consequence().take( null );

  let capturedOutput = '';
  let captureLogger = new _.Logger({ output : null, onTransformEnd, raw : 1 })

  /* */

  testCase( 'verbosity : 0' )
  _.process.start
  ({
    execPath : `node -e "console.log('message')"`,
    mode : 'spawn',
    verbosity : 0,
    outputPiping : null,
    outputCollecting : 0,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( capturedOutput, '' );
    return true;
  })

  /* */

  testCase( 'verbosity : 1' )
  _.process.start
  ({
    execPath : `node -e "console.log('message')"`,
    mode : 'spawn',
    verbosity : 1,
    outputPiping : null,
    outputCollecting : 0,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    console.log( capturedOutput )
    test.identical( _.strCount( capturedOutput, `node -e console.log('message')`), 1 );
    test.identical( _.strCount( capturedOutput, 'message' ), 1 );
    test.identical( _.strCount( capturedOutput, 'at ' + _.path.current() ), 0 );
    return true;
  })

  /* */

   testCase( 'verbosity : 2' )
   _.process.start
   ({
     execPath : `node -e "console.log('message')"`,
     mode : 'spawn',
     verbosity : 2,
     stdio : 'pipe',
     outputPiping : null,
     outputCollecting : 0,
     outputGray : 1,
     logger : captureLogger,
     ready : ready
   })
   .then( ( got ) =>
   {
     test.identical( got.exitCode, 0 );
     test.identical( _.strCount( capturedOutput, `node -e console.log('message')` ), 1 );
     test.identical( _.strCount( capturedOutput, 'message' ), 2 );
     test.identical( _.strCount( capturedOutput, 'at ' + _.path.current() ), 0 );
     return true;
   })

  /* */

  testCase( 'verbosity : 3' )
  _.process.start
  ({
    execPath : `node -e "console.log('message')"`,
    mode : 'spawn',
    verbosity : 3,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( capturedOutput, `node -e console.log('message')` ), 1 );
    test.identical( _.strCount( capturedOutput, 'message' ), 2 );
    test.identical( _.strCount( capturedOutput, 'at ' + _.path.current() ), 1 );
    return true;
  })

  /* */

  testCase( 'verbosity : 5' )
  _.process.start
  ({
    execPath : `node -e "console.log('message')"`,
    mode : 'spawn',
    verbosity : 5,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( capturedOutput, `node -e console.log('message')` ), 1 );
    test.identical( _.strCount( capturedOutput, 'message' ), 2 );
    test.identical( _.strCount( capturedOutput, 'at ' + _.path.current() ), 1 );
    return true;
  })

  /* */

  testCase( 'error, verbosity : 0' )
  _.process.start
  ({
    execPath : `node -e "process.exit(1)"`,
    mode : 'spawn',
    verbosity : 0,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    throwingExitCode : 0,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 1 );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + got.exitCode ), 0 );
    return true;
  })

  /*  */

  testCase( 'error, verbosity : 1' )
  _.process.start
  ({
    execPath : `node -e "process.exit(1)"`,
    mode : 'spawn',
    verbosity : 1,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    throwingExitCode : 0,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 1 );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + got.exitCode ), 0 );
    return true;
  })

  /*  */

  testCase( 'error, verbosity : 2' )
  _.process.start
  ({
    execPath : `node -e "process.exit(1)"`,
    mode : 'spawn',
    verbosity : 2,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    throwingExitCode : 0,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 1 );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + got.exitCode ), 0 );
    return true;
  })

  /* */

  testCase( 'error, verbosity : 3' )
  _.process.start
  ({
    execPath : `node -e "process.exit(1)"`,
    mode : 'spawn',
    verbosity : 3,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    throwingExitCode : 0,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 1 );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + got.exitCode ), 0 );
    return true;
  })

  /*  */

  testCase( 'error, verbosity : 5' )
  _.process.start
  ({
    execPath : `node -e "process.exit(1)"`,
    mode : 'spawn',
    verbosity : 5,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    throwingExitCode : 0,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 1 );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + got.exitCode ), 1 );
    return true;
  })

  /*  */

  testCase( 'execPath has quotes, verbosity : 1' )
  _.process.start
  ({
    execPath : `node -e "console.log( \"a\", 'b', \`c\` )"`,
    mode : 'spawn',
    verbosity : 5,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    throwingExitCode : 1,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( got.fullExecPath, `node -e console.log( \"a\", 'b', \`c\` )` );
    test.identical( _.strCount( capturedOutput, `node -e console.log( \"a\", 'b', \`c\` )` ), 1 );
    return true;
  })

  /* */

  testCase( 'execPath has double quotes, verbosity : 1' )
  _.process.start
  ({
    execPath : `node -e "console.log( '"a"', "'b'", \`"c"\` )"`,
    mode : 'spawn',
    verbosity : 5,
    stdio : 'pipe',
    outputPiping : null,
    outputCollecting : 0,
    throwingExitCode : 1,
    outputGray : 1,
    logger : captureLogger,
    ready : ready
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( got.fullExecPath, `node -e console.log( '"a"', "'b'", \`"c"\` )` );
    test.identical( _.strCount( capturedOutput, `node -e console.log( '"a"', "'b'", \`"c"\` )` ), 1 );
    return true;
  })

  return ready;

  /*  */

  function testCase( src )
  {
    ready.then( () =>
    {
      capturedOutput = '';
      test.case = src;
      return null
    });
  }

  function onTransformEnd( o )
  {
    capturedOutput += o.outputForPrinter[ 0 ] + '\n';
  }
}

//

function shellErrorHadling( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    throw 'Error message from child'
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  //

  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'collecting, verbosity and piping off';

    let o =
    {
      execPath :   'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) )
    .thenKeep( function( got )
    {
      test.is( _.errIs( got ) );
      test.is( _.strHas( got.message, 'Process returned exit code' ) )
      test.is( _.strHas( got.message, 'Launched as' ) )
      test.is( _.strHas( got.message, 'Stderr' ) )
      test.is( _.strHas( got.message, 'Error message from child' ) )

      test.notIdentical( o.exitCode, 0 );

      return null;
    })

  })

  con.thenKeep( function()
  {
    test.case = 'collecting, verbosity and piping off';

    let o =
    {
      execPath :   'node ' + testAppPath,
      mode : 'shell',
      stdio : 'pipe',
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) )
    .thenKeep( function( got )
    {
      test.is( _.errIs( got ) );
      test.is( _.strHas( got.message, 'Process returned exit code' ) )
      test.is( _.strHas( got.message, 'Launched as' ) )
      test.is( _.strHas( got.message, 'Stderr' ) )
      test.is( _.strHas( got.message, 'Error message from child' ) )

      test.notIdentical( o.exitCode, 0 );

      return null;
    })

  })

  con.thenKeep( function()
  {
    test.case = 'collecting, verbosity and piping off';

    let o =
    {
      execPath :   testAppPath,
      mode : 'fork',
      stdio : 'pipe',
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) )
    .thenKeep( function( got )
    {
      test.is( _.errIs( got ) );
      test.is( _.strHas( got.message, 'Process returned exit code' ) )
      test.is( _.strHas( got.message, 'Launched as' ) )
      test.is( _.strHas( got.message, 'Stderr' ) )
      test.is( _.strHas( got.message, 'Error message from child' ) )

      test.notIdentical( o.exitCode, 0 );

      return null;
    })

  })

  con.thenKeep( function()
  {
    test.case = 'sync, collecting, verbosity and piping off';

    let o =
    {
      execPath :   'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.process.start( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned exit code' ) )
    test.is( _.strHas( got.message, 'Launched as' ) )
    test.is( _.strHas( got.message, 'Stderr' ) )
    test.is( _.strHas( got.message, 'Error message from child' ) )

    test.notIdentical( o.exitCode, 0 );

    return null;

  })

  con.thenKeep( function()
  {
    test.case = 'sync, collecting, verbosity and piping off';

    let o =
    {
      execPath :   'node ' + testAppPath,
      mode : 'shell',
      stdio : 'pipe',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.process.start( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned exit code' ) )
    test.is( _.strHas( got.message, 'Launched as' ) )
    test.is( _.strHas( got.message, 'Stderr' ) )
    test.is( _.strHas( got.message, 'Error message from child' ) )

    test.notIdentical( o.exitCode, 0 );

    return null;

  })

  con.thenKeep( function()
  {
    test.case = 'sync, collecting, verbosity and piping off';

    let o =
    {
      execPath :   testAppPath,
      mode : 'fork',
      stdio : 'pipe',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.process.start( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned exit code' ) )
    test.is( _.strHas( got.message, 'Launched as' ) )
    test.is( _.strHas( got.message, 'Stderr' ) )
    test.is( _.strHas( got.message, 'Error message from child' ) )

    test.notIdentical( o.exitCode, 0 );

    return null;

  })

  con.thenKeep( function()
  {
    test.case = 'stdio ignore, sync, collecting, verbosity and piping off';

    let o =
    {
      execPath :   testAppPath,
      mode : 'fork',
      stdio : 'ignore',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.process.start( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned exit code' ) )
    test.is( _.strHas( got.message, 'Launched as' ) )
    test.is( !_.strHas( got.message, 'Stderr' ) )
    test.is( !_.strHas( got.message, 'Error message from child' ) )

    test.notIdentical( o.exitCode, 0 );

    return null;

  })

  // con.thenKeep( function()
  // {
  //   test.case = 'stdio inherit, sync, collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   testAppPath,
  //     mode : 'fork',
  //     stdio : 'inherit',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   var got = test.shouldThrowErrorSync( () => _.process.start( o ) )

  //   test.is( _.errIs( got ) );
  //   test.is( _.strHas( got.message, 'Process returned error code' ) )
  //   test.is( _.strHas( got.message, 'Launched as' ) )
  //   test.is( !_.strHas( got.message, 'Stderr' ) )
  //   test.is( !_.strHas( got.message, 'Error message from child' ) )

  //   test.notIdentical( o.exitCode, 0 );

  //   return null;

  // })

  return con;

}


//

function shellNode( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    throw 'Error message from child';
  }

  function testApp2()
  {
    console.log( process.argv.slice( 2 ) )
  }


  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppPath2 = _.path.join( routinePath, 'testApp2.js' );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var testAppCode2 = testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var con = new _.Consequence().take( null );

  /* */

  con.then( () =>
  {
    test.case = 'execPath contains normalized path'
    return _.process.startNode
    ({
      execPath : testAppPath2,
      args : [ 'arg' ],
      outputCollecting : 1,
      stdio : 'pipe',
    })
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.args, [ 'arg' ] );
      console.log( got.output )
      test.is( _.strHas( got.output, `[ 'arg' ]` ) );
      return null
    })
  })

  /*  */

  var modes = [ 'fork', 'exec', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath, mode : mode, applyingExitCode : 1, throwingExitCode : 1, stdio : 'ignore' };
      return _.process.startNode( o )
      .finally( ( err, got ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 1 );
        process.exitCode = 0;
        test.is( _.errIs( err ) );
        return true;
      })
    })

    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath, mode : mode,  applyingExitCode : 1, throwingExitCode : 0, stdio : 'ignore' };
      return _.process.startNode( o )
      .finally( ( err, got ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 1 );
        process.exitCode = 0;
        test.is( !_.errIs( err ) );
        return true;
      })
    })

    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath,  mode : mode, applyingExitCode : 0, throwingExitCode : 1, stdio : 'ignore' };
      return _.process.startNode( o )
      .finally( ( err, got ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        test.is( _.errIs( err ) );
        return true;
      })
    })

    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath,  mode : mode, applyingExitCode : 0, throwingExitCode : 0, stdio : 'ignore' };
      return _.process.startNode( o )
      .finally( ( err, got ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        test.is( !_.errIs( err ) );
        return true;
      })
    })

    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath,  mode : mode, maximumMemory : 1, applyingExitCode : 0, throwingExitCode : 0, stdio : 'ignore' };
      return _.process.startNode( o )
      .finally( ( err, got ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        let spawnArgs = _.toStr( o.process.spawnargs, { levels : 99 } );
        test.is( _.strHasAll( spawnArgs, [ "--expose-gc",  "--stack-trace-limit=999", "--max_old_space_size=" ] ) )
        test.is( !_.errIs( err ) );
        return true;
      })
    })
  })

  return con;

}

shellNode.timeOut = 20000;

//

function shellModeShellNonTrivial( test )
{
  let context = this;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPath =  _.path.join( routinePath, 'app.js' );

  function app()
  {
    console.log( process.argv.slice( 2 ) );
  }

  let testAppCode = app.toString() + '\napp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = _.Consequence().take( null );

  let shell = _.process.starter
  ({
    mode : 'shell',
    currentPath : routinePath,
    outputPiping : 1,
    outputCollecting : 1,
    ready : ready
  })

  /* */

  ready.then( () =>
  {
    test.open( 'two commands' );
    return null;
  })

  shell( 'node -v && node -v' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  shell( '"node -v && node -v"' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  shell({ execPath : 'node -v && "node -v"', throwingExitCode : 0 })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 1 );
    return null;
  })

  shell({ args : 'node -v && node -v' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  shell({ args : '"node -v && node -v"' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ "node -v && node -v" ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ 'node', '-v', '&&', 'node', '-v' ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ 'node', '-v', ' && ', 'node', '-v' ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 1 );
    return null;
  })

  shell({ args : [ 'node -v', '&&', 'node -v' ], throwingExitCode : 0 })
  .then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 1 );
    return null;
  })

  ready.then( () =>
  {
    test.close( 'two commands' );
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.open( 'argument with space' );
    return null;
  })

  shell( 'node ' + testAppPath + ' arg with space' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, "[ 'arg', 'with', 'space' ]" ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ' "arg with space"' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, "[ 'arg with space' ]" ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : 'arg with space' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, "[ 'arg with space' ]" ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : [ 'arg with space' ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, "[ 'arg with space' ]" ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ' `"quoted arg with space"`' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ '"quoted arg with space"' ]` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ` \`'quoted arg with space'\` ` )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ "'quoted arg with space'" ]` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + " '`quoted arg with space`'" )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ '\`quoted arg with space\`' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : '"quoted arg with space"' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ '"quoted arg with space"' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : '`quoted arg with space`' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ '\`quoted arg with space\`' ]` ), 1 );
    return null;
  })

  ready.then( () =>
  {
    test.close( 'argument with space' );
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.open( 'several arguments' );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath + ` arg1 "arg2" "arg 3" "'arg4'"` })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2', 'arg 3', "'arg4'" ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : `arg1 "arg2" "arg 3" "'arg4'"` })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, '[ `arg1 "arg2" "arg 3" "\'arg4\'"` ]' ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : [ `arg1`, '"arg2"', "arg 3", "'arg4'" ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', '"arg2"', 'arg 3', "'arg4'" ]` ), 1 );
    return null;
  })

  ready.then( () =>
  {
    test.close( 'several arguments' );
    return null;
  })

  /*  */

  return ready;
}

shellModeShellNonTrivial.timeOut = 60000;

//

function shellTerminate( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    setTimeout( () =>
    {
      console.log( 'Timeout in child' );
    },6000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'spawn',
      throwingExitCode : 1,
      outputCollecting : 1
    }

    let con = _.process.start( o );

    _.timeOut( 2000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      test.is( _.strHas( err.message, 'killed by exit signal SIGKILL' ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      throwingExitCode : 1,
      outputCollecting : 1
    }

    let con = _.process.start( o );

    _.timeOut( 2000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      test.is( _.strHas( err.message, 'killed by exit signal SIGKILL' ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'exec',
      throwingExitCode : 1,
      outputCollecting : 1
    }

    let con = _.process.start( o );

    _.timeOut( 2000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      test.is( _.strHas( err.message, 'killed by exit signal SIGKILL' ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( _.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'spawn',
      throwingExitCode : 1,
      outputCollecting : 1
    }

    let con = _.process.start( o );

    _.timeOut( 2000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      test.is( _.strHas( err.message, 'killed by exit signal SIGINT' ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGINT' );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      throwingExitCode : 1,
      outputCollecting : 1
    }

    let con = _.process.start( o );

    _.timeOut( 2000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      test.is( _.strHas( err.message, 'killed by exit signal SIGINT' ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGINT' );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /* */

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'exec',
      throwingExitCode : 1,
      outputCollecting : 1
    }

    let con = _.process.start( o );

    _.timeOut( 2000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( _.errIs( err ) );
      test.is( _.strHas( err.message, 'killed by exit signal SIGINT' ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGINT' );
      test.is( _.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

shellTerminate.timeOut = 120000;
/* shellTerminate.description =
`
  Test app - single timeout with message

  Will test:
  - Termination of child process using SIGINT signal after small delay
  - Termination of child process using SIGKILL signal after small delay

  Expected behaviour for all platforms:
  - Child was terminated with exitCode : null, exitSignal : { kill signal from parent }
  - Time out was not raised, no message output
` */

//

function shellTerminateWithExitHandler( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.process.exitHandlerRepair();
    _.timeOut( 10000, () => { console.log( 'Timeout in child' ); return null } )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  testAppPath = _.strQuote( testAppPath );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'spawn',
      throwingExitCode : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    _.timeOut( 4000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( !_.errIs( err ) );
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.is( _.strHas( o.output, 'SIGINT' ) );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'exec',
      throwingExitCode : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    _.timeOut( 4000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( !_.errIs( err ) );
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.is( _.strHas( o.output, 'SIGINT' ) );
      test.is( _.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      throwingExitCode : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    _.timeOut( 4000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      test.is( !_.errIs( err ) );
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.is( _.strHas( o.output, 'SIGINT' ) );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /* SIGKILL */

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'spawn',
      throwingExitCode : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'exec',
      throwingExitCode : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( _.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  .then( () =>
  {
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      throwingExitCode : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.finally( ( err, got ) =>
    {
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'Timeout in child' ) );
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

shellTerminateWithExitHandler.timeOut = 120000;

/* shellTerminateWithExitHandler.description =
`
  Test app - single timeout with message and appExitHandlerRepair called at start

  Will test:
    - Termination of child process using SIGINT signal after small delay
    - Termination of child process using SIGKILL signal after small delay

  Expected behaviour:
    - For SIGINT: Child was terminated before timeout with exitCode : 0, exitSignal : null
    - For SIGKILL: Child was terminated before timeout with exitCode : null, exitSignal : SIGKILL
    - No time out message in output
` */

//

function shellTerminateHangedWithExitHandler( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.process.exitHandlerRepair();
    while( 1 )
    {
      console.log( _.timeNow() )
    }
    console.log( 'Killed' );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  testAppPath = _.strQuote( testAppPath );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'spawn',
      throwingExitCode : 0,
      outputPiping : 0,
      timeOut : 10000,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    _.timeOut( 4000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.is( _.strHas( o.output, 'SIGINT' ) );
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      throwingExitCode : 0,
      timeOut : 10000,
      outputPiping : 0,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    _.timeOut( 4000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.is( _.strHas( o.output, 'SIGINT' ) );
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

shellTerminateHangedWithExitHandler.timeOut = 20000;

/* shellTerminateHangedWithExitHandler.description =
`
  Test app - code that blocks event loop and appExitHandlerRepair called at start

  Will test:
    - Termination of child process using SIGINT signal after small delay
    - Termination of child process using SIGKILL signal after small delay

  Expected behaviour:
    - For SIGINT: Child was terminated with exitCode : 0, exitSignal : null
    - For SIGKILL: Child was terminated with exitCode : null, exitSignal : SIGKILL
    - No time out message in output
` */

//

function shellTerminateAfterLoopRelease( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    _.include( 'wAppBasic' );
    _.process.exitHandlerRepair();
    let loop = true;
    setTimeout( () =>
    {
      loop = false;
    }, 6000 )
    while( loop ){}

    console.log( 'Exit after timeout' );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  testAppPath = _.strQuote( testAppPath );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'spawn',
      throwingExitCode : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    // return test.shouldThrowErrorOfAnyKind( _.process.start( o ) )
    // .thenKeep( function( got )

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    _.timeOut( 7000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.is( _.strHas( o.output, 'Exit after timeout' ) );

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      throwingExitCode : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    // return test.shouldThrowErrorOfAnyKind( _.process.start( o ) )
    // .thenKeep( function( got )

    let con = _.process.start( o );

    _.timeOut( 3000, () =>
    {
      o.process.kill( 'SIGINT' );
      return null;
    })

    _.timeOut( 7000, () =>
    {
      o.process.kill( 'SIGKILL' );
      return null;
    })

    con.then( ( got ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.is( _.strHas( o.output, 'Exit after timeout' ) );

      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

shellTerminateAfterLoopRelease.timeOut = 20000;
// shellTerminateAfterLoopRelease.description =
// `
//   Test app - code that blocks event loop for short period of time and appExitHandlerRepair called at start

//   Will test:
//     - Termination of child process using SIGINT signal after small delay

//   Expected behaviour:
//     - Child was terminated after event loop release with exitCode : 0, exitSignal : null
//     - Child process message should be printed
// `

//

function shellStartingDelay( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    let data = { t2 : _.timeNow() };
    console.log( JSON.stringify( data ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  testAppPath = _.strQuote( testAppPath );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    let starting = { delay : 5000 };
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      when : starting
    }

    let t1 = _.timeNow();
    let con = _.process.start( o );

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      let parsed = JSON.parse( got.output );
      let diff = parsed.t2 - t1;
      test.ge( diff, starting.delay );
      return null;
    })

    return con;
  })

  return ready;
}

//

function shellStartingTime( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    let data = { t2 : _.timeNow() };
    console.log( JSON.stringify( data ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  testAppPath = _.strQuote( testAppPath );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    let t1 = _.timeNow();
    let delay = 5000;
    let starting = { time : _.timeNow() + delay };
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      when : starting
    }

    let con = _.process.start( o );

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      let parsed = JSON.parse( got.output );
      let diff = parsed.t2 - t1;
      test.ge( diff, delay );
      return null;
    })

    return con;
  })

  return ready;
}

//

function shellStartingSuspended( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    let data = { t2 : _.timeNow() };
    console.log( JSON.stringify( data ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  testAppPath = _.strQuote( testAppPath );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    let o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputPiping : 1,
      outputCollecting : 1,
      when : 'suspended'
    }

    let t1 = _.timeNow();
    let delay = 1000;
    let con = _.process.start( o );

    _.timeOut( delay, () =>
    {
      o.resume();
      return null;
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      let parsed = JSON.parse( got.output );
      let diff = parsed.t2 - t1;
      test.ge( diff, delay );
      return null;
    })

    return con;
  })

  return ready;
}

//

// function shellAfterDeath( test )
// {
//   var context = this;
//   var routinePath = _.path.join( context.suitePath, test.name );

//   function testAppParent()
//   {
//     _.include( 'wAppBasic' );
//     _.include( 'wFiles' );

//     let o =
//     {
//       execPath : 'node testAppChild.js',
//       outputCollecting : 1,
//       stdio : 'inherit',
//       mode : 'spawn',
//       when : 'afterdeath'
//     }

//     _.process.start( o );

//     process.send( o.process.pid );

//     _.timeOut( 4000, () =>
//     {
//       process.disconnect();
//       return null;
//     })
//   }

//   function testAppChild()
//   {
//     _.include( 'wAppBasic' );
//     _.include( 'wFiles' );

//     _.timeOut( 5000, () =>
//     {
//       let filePath = _.path.join( __dirname, 'testFile' );
//       _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
//     })
//   }

//   /* */

//   var testAppParentPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppParent.js' ) );
//   var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
//   var testAppParentCode = context.toolsPathInclude + testAppParent.toString() + '\ntestAppParent();';
//   var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
//   _.fileProvider.fileWrite( testAppParentPath, testAppParentCode );
//   _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
//   testAppParentPath = _.strQuote( testAppParentPath );
//   var ready = new _.Consequence().take( null );

//   let testFilePath = _.path.join( routinePath, 'testFile' );

//   ready

//   .then( () =>
//   {
//     let o =
//     {
//       execPath : 'node testAppParent.js',
//       mode : 'spawn',
//       outputCollecting : 1,
//       currentPath : routinePath,
//       ipc : 1,
//     }
//     let con = _.process.start( o );

//     let secondaryPid;

//     o.process.on( 'message', ( got ) =>
//     {
//       secondaryPid = _.numberFrom( got );
//     })

//     _.timeOut( 2500, () =>
//     {
//       test.will = 'parent is alive, secondary is alive'
//       test.is( processIsRunning( o.process.pid ) )
//       test.is( processIsRunning( secondaryPid) )
//       return null;
//     })

//     _.timeOut( 5000, () =>
//     {
//       test.will = 'parent is dead, but waits for secondary and child'
//       test.is( !processIsRunning( o.process.pid ) )
//       test.is( processIsRunning( secondaryPid) )
//       return null;
//     })

//     con.then( ( got ) =>
//     {
//       test.identical( got.exitCode, 0 );

//       test.is( !processIsRunning( o.process.pid ) );
//       test.is( !processIsRunning( secondaryPid ) );

//       test.is( _.fileProvider.fileExists( testFilePath ) );
//       let childPid = _.fileProvider.fileRead( testFilePath );
//       test.is( !processIsRunning( _.numberFrom( childPid ) ) );

//       return null;
//     })

//     return con;
//   })

//   /*  */

//   function processIsRunning( pid )
//   {
//     try
//     {
//       return process.kill( pid, 0 );
//     }
//     catch (e)
//     {
//       return e.code === 'EPERM'
//     }
//   }

//   return ready;
// }

//

// function shellAfterDeathOutput( test )
// {
//   var context = this;
//   var routinePath = _.path.join( context.suitePath, test.name );

//   function testAppParent()
//   {
//     _.include( 'wAppBasic' );
//     _.include( 'wFiles' );

//     let o =
//     {
//       execPath : 'node testAppChild.js',
//       outputCollecting : 1,
//       stdio : 'inherit',
//       mode : 'spawn',
//       when : 'afterdeath'
//     }

//     _.process.start( o );

//     _.timeOut( 4000, () =>
//     {
//       console.log( 'Parent process exit' )
//       process.disconnect();
//       return null;
//     })
//   }

//   function testAppChild()
//   {
//     _.include( 'wAppBasic' );
//     _.include( 'wFiles' );

//     console.log( 'Child process start' )

//     _.timeOut( 5000, () =>
//     {
//       console.log( 'Child process end' )
//     })
//   }

//   /* */

//   var testAppParentPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppParent.js' ) );
//   var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
//   var testAppParentCode = context.toolsPathInclude + testAppParent.toString() + '\ntestAppParent();';
//   var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
//   _.fileProvider.fileWrite( testAppParentPath, testAppParentCode );
//   _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
//   testAppParentPath = _.strQuote( testAppParentPath );
//   var ready = new _.Consequence().take( null );

//   ready

//   .then( () =>
//   {
//     let o =
//     {
//       execPath : 'node testAppParent.js',
//       mode : 'spawn',
//       outputCollecting : 1,
//       currentPath : routinePath,
//       ipc : 1,
//     }
//     let con = _.process.start( o );

//     con.then( ( got ) =>
//     {
//       test.identical( got.exitCode, 0 );

//       test.is( _.strHas( got.output, 'Parent process exit' ) )
//       test.is( _.strHas( got.output, 'Secondary: starting child process...' ) )
//       test.is( _.strHas( got.output, 'Child process start' ) )
//       test.is( _.strHas( got.output, 'Child process end' ) )

//       return null;
//     })

//     return con;
//   })

//   /*  */

//   return ready;
// }

//

function shellDetachingChildAfterParent( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  function testAppParent()
  {
    _.include( 'wAppBasic' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      outputCollecting : 1,
      detaching : true,
      mode : 'spawn',
    }

    _.process.start( o );

    process.send( o.process.pid );

    console.log( 'Parent process exit' )
  }

  function testAppChild()
  {
    _.include( 'wAppBasic' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.timeOut( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
    })
  }

  /* */

  var testAppParentPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppParent.js' ) );
  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppParentCode = context.toolsPathInclude + testAppParent.toString() + '\ntestAppParent();';
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppParentPath, testAppParentCode );
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  testAppParentPath = _.strQuote( testAppParentPath );
  var ready = new _.Consequence().take( null );

  let testFilePath = _.path.join( routinePath, 'testFile' );

  ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node testAppParent.js',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let secondaryPid;

    o.process.on( 'message', ( got ) =>
    {
      secondaryPid = _.numberFrom( got );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );

      test.will = 'parent is dead, detached child is still running'

      test.is( _.strHas( got.output, 'Parent process exit' ) )
      test.is( _.strHas( got.output, 'Child process start' ) )
      test.is( !_.strHas( got.output, 'Child process end' ) )

      test.is( !processIsRunning( o.process.pid ) );
      test.is( processIsRunning( secondaryPid ) );

      test.is( !_.fileProvider.fileExists( testFilePath ) );

      return _.timeOut( 5000, () => null );
    })

    con.then( () =>
    {
      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      test.is( !processIsRunning( _.numberFrom( childPid ) ) );
      return null;
    })

    return con;
  })

  /*  */

  function processIsRunning( pid )
  {
    try
    {
      return process.kill( pid, 0 );
    }
    catch (e)
    {
      return e.code === 'EPERM'
    }
  }

  return ready;
}

//

function shellDetachingChildBeforeParent( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  function testAppParent()
  {
    _.include( 'wAppBasic' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      outputCollecting : 1,
      detaching : true,
      mode : 'spawn',
    }

    let ready = _.process.start( o );

    ready.finally( ( err, got ) =>
    {
      process.send({ exitCode : got.exitCode, err : err, pid : o.process.pid });
      return null;
    })

    _.timeOut( 5000, () =>
    {
      console.log( 'Parent process exit' )
      return null;
    })
  }

  function testAppChild()
  {
    _.include( 'wAppBasic' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.timeOut( 1000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

  /* */

  var testAppParentPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppParent.js' ) );
  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppParentCode = context.toolsPathInclude + testAppParent.toString() + '\ntestAppParent();';
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppParentPath, testAppParentCode );
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  testAppParentPath = _.strQuote( testAppParentPath );
  var ready = new _.Consequence().take( null );

  let testFilePath = _.path.join( routinePath, 'testFile' );

  ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node testAppParent.js',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let child;

    o.process.on( 'message', ( got ) =>
    {
      child = got;
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );

      test.will = 'parent and chid are dead';

      test.identical( child.err, undefined );
      test.identical( child.exitCode, 0 );

      test.is( _.strHas( got.output, 'Parent process exit' ) )
      test.is( _.strHas( got.output, 'Child process start' ) )
      test.is( _.strHas( got.output, 'Child process end' ) )

      test.is( !processIsRunning( o.process.pid ) );
      test.is( !processIsRunning( child.pid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      test.is( !processIsRunning( _.numberFrom( childPid ) ) );
      return null;
    })

    return con;
  })

  /*  */

  function processIsRunning( pid )
  {
    try
    {
      return process.kill( pid, 0 );
    }
    catch (e)
    {
      return e.code === 'EPERM'
    }
  }

  return ready;
}

//

function shellConcurrent( test )
{
  let context = this;
  let counter = 0;
  let time = 0;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  let filePath = _.fileProvider.path.nativize( _.path.join( routinePath, 'file.txt' ) );
  let ready = _.Consequence().take( null );

  let testAppCode =
  [
    `let filePath = '${_.strEscape( filePath )}';\n`,
     context.testApp.toString(),
     '\ntestApp();'
  ].join( '' );

  _.fileProvider.fileWrite( testAppPath, testAppCode );

  logger.log( 'this is #foreground : bright white#an#foreground : default# experiment' ); /* qqq fix logger, please !!! */

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single';
    time = _.timeNow();
    return null;
  })

  let singleOption =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleOption )
  .then( ( arg ) =>
  {

    test.identical( arg.exitCode, 0 );
    test.is( singleOption === arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, execPath in array';
    time = _.timeNow();
    return null;
  })

  let singleExecPathInArrayOptions =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleExecPathInArrayOptions )
  .then( ( arg ) =>
  {

    test.identical( arg.length, 1 );
    test.identical( arg[ 0 ].exitCode, 0 );
    test.is( singleExecPathInArrayOptions !== arg[ 0 ] );
    test.is( _.strHas( arg[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( arg[ 0 ].output, 'end 1000' ) );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready';
    time = _.timeNow();
    throw _.err( 'Error!' );
  })

  let singleErrorBeforeScalar =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleErrorBeforeScalar )
  .finally( ( err, arg ) =>
  {

    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBeforeScalar.exitCode, null );
    test.identical( singleErrorBeforeScalar.output, undefined );
    test.is( !_.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready';
    time = _.timeNow();
    throw _.err( 'Error!' );
  })

  let singleErrorBefore =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleErrorBefore )
  .finally( ( err, arg ) =>
  {

    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBefore.exitCode, null );
    test.identical( singleErrorBefore.output, undefined );
    test.is( !_.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial';
    time = _.timeNow();
    return null;
  })

  let subprocessesOptionsSerial =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  _.process.start( subprocessesOptionsSerial )
  .then( ( arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesOptionsSerial.exitCode, 0 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 0 );
    test.is( _.strHas( arg[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( arg[ 0 ].output, 'end 1000' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 10' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 10' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 1';
    time = _.timeNow();
    return null;
  })

  let subprocessesError =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  _.process.start( subprocessesError )
  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesError.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( arg === undefined );
    test.is( !_.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 0';
    time = _.timeNow();
    return null;
  })

  let subprocessesErrorNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
    throwingExitCode : 0,
  }

  _.process.start( subprocessesErrorNonThrowing )
  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorNonThrowing.exitCode, 1 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 1 );
    test.is( _.strHas( arg[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( arg[ 0 ].output, 'end x' ) );
    test.is( _.strHas( arg[ 0 ].output, 'Expects number' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 10' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 10' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 1';
    time = _.timeNow();
    return null;
  })

  let subprocessesErrorConcurrent =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( subprocessesErrorConcurrent )
  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrent.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( arg === undefined );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 0';
    time = _.timeNow();
    return null;
  })

  let subprocessesErrorConcurrentNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
    throwingExitCode : 0,
  }

  _.process.start( subprocessesErrorConcurrentNonThrowing )
  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrentNonThrowing.exitCode, 1 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 1 );
    test.is( _.strHas( arg[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( arg[ 0 ].output, 'end x' ) );
    test.is( _.strHas( arg[ 0 ].output, 'Expects number' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 10' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 10' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1';
    time = _.timeNow();
    return null;
  })

  let suprocessesConcurrentOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( suprocessesConcurrentOptions )
  .then( ( arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( suprocessesConcurrentOptions.exitCode, 0 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 0 );
    test.is( _.strHas( arg[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( arg[ 0 ].output, 'end 1000' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 100' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 100' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'args';
    time = _.timeNow();
    return null;
  })

  let suprocessesConcurrentArgumentsOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    args : [ 'second', 'argument' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( suprocessesConcurrentArgumentsOptions )
  .then( ( arg ) =>
  {
    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( suprocessesConcurrentArgumentsOptions.exitCode, 0 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 0 );
    test.is( _.strHas( arg[ 0 ].output, 'begin 1000, second, argument' ) );
    test.is( _.strHas( arg[ 0 ].output, 'end 1000, second, argument' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 100, second, argument' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 100, second, argument' ) );

    counter += 1;
    return null;
  });

  /* - */

  return ready.finally( ( err, arg ) =>
  {
    debugger;
    test.identical( counter, 11 );
    if( err )
    throw err;
    return arg;
  });
}

shellConcurrent.timeOut = 100000;

//

function shellerConcurrent( test )
{
  let context = this;
  let counter = 0;
  let time = 0;
  let routinePath = _.path.join( context.suitePath, test.name );
  let testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  let filePath = _.fileProvider.path.nativize( _.path.join( routinePath, 'file.txt' ) );
  let ready = _.Consequence().take( null );

  let testAppCode =
  [
    `let filePath = '${_.strEscape( filePath )}';\n`,
     context.testApp.toString(),
     '\ntestApp();'
  ].join( '' );

  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single';
    time = _.timeNow();
    return null;
  })

  let singleOption2 = {}
  let singleOption =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var shell = _.process.starter( singleOption );
  shell( singleOption2 )

  .then( ( arg ) =>
  {
    test.identical( arg.exitCode, 0 );
    test.is( singleOption !== arg );
    test.is( singleOption2 === arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, no second options';
    time = _.timeNow();
    return null;
  })

  let singleOptionWithoutSecond =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var shell = _.process.starter( singleOptionWithoutSecond );
  shell()

  .then( ( arg ) =>
  {

    test.identical( arg.exitCode, 0 );
    test.is( singleOptionWithoutSecond !== arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, execPath in array';
    time = _.timeNow();
    return null;
  })

  let singleExecPathInArrayOptions2 = {};
  let singleExecPathInArrayOptions =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var shell = _.process.starter( singleExecPathInArrayOptions );
  shell( singleExecPathInArrayOptions2 )

  .then( ( arg ) =>
  {
    test.identical( arg.exitCode, 0 );
    test.is( singleExecPathInArrayOptions2 === arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready, exec is scalar';
    time = _.timeNow();
    throw _.err( 'Error!' );
  })

  let singleErrorBeforeScalar2 = {};
  let singleErrorBeforeScalar =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var shell = _.process.starter( singleErrorBeforeScalar );
  shell( singleErrorBeforeScalar2 )

  .finally( ( err, arg ) =>
  {

    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBeforeScalar.exitCode, undefined );
    test.identical( singleErrorBeforeScalar.output, undefined );
    test.is( !_.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready, exec is single-element vector';
    time = _.timeNow();
    throw _.err( 'Error!' );
  })

  let singleErrorBefore2 = {};
  let singleErrorBefore =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready : ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var shell = _.process.starter( singleErrorBefore );
  shell( singleErrorBefore2 )

  .finally( ( err, arg ) =>
  {

    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBefore.exitCode, undefined );
    test.identical( singleErrorBefore.output, undefined );
    test.is( !_.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial';
    time = _.timeNow();
    return null;
  })

  let subprocessesOptionsSerial2 = {};
  let subprocessesOptionsSerial =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  var shell = _.process.starter( subprocessesOptionsSerial );
  shell( subprocessesOptionsSerial2 )

  .then( ( arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesOptionsSerial2.exitCode, 0 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 0 );
    test.is( _.strHas( arg[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( arg[ 0 ].output, 'end 1000' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 10' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 10' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 1';
    time = _.timeNow();
    return null;
  })

  let subprocessesError2 = {};
  let subprocessesError =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  var shell = _.process.starter( subprocessesError );
  shell( subprocessesError2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesError2.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( arg === undefined );
    test.is( !_.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 0';
    time = _.timeNow();
    return null;
  })

  let subprocessesErrorNonThrowing2 = {};
  let subprocessesErrorNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
    throwingExitCode : 0,
  }

  var shell = _.process.starter( subprocessesErrorNonThrowing );
  shell( subprocessesErrorNonThrowing2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorNonThrowing2.exitCode, 1 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 1 );
    test.is( _.strHas( arg[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( arg[ 0 ].output, 'end x' ) );
    test.is( _.strHas( arg[ 0 ].output, 'Expects number' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 10' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 10' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 1';
    time = _.timeNow();
    return null;
  })

  let subprocessesErrorConcurrent2 = {};
  let subprocessesErrorConcurrent =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var shell = _.process.starter( subprocessesErrorConcurrent );
  shell( subprocessesErrorConcurrent2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrent2.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( arg === undefined );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 0';
    time = _.timeNow();
    return null;
  })

  let subprocessesErrorConcurrentNonThrowing2 = {};
  let subprocessesErrorConcurrentNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
    throwingExitCode : 0,
  }

  var shell = _.process.starter( subprocessesErrorConcurrentNonThrowing );
  shell( subprocessesErrorConcurrentNonThrowing2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrentNonThrowing2.exitCode, 1 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 10' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 1 );
    test.is( _.strHas( arg[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( arg[ 0 ].output, 'end x' ) );
    test.is( _.strHas( arg[ 0 ].output, 'Expects number' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 10' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 10' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1';
    time = _.timeNow();
    return null;
  })

  let subprocessesConcurrentOptions2 = {};
  let subprocessesConcurrentOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var shell = _.process.starter( subprocessesConcurrentOptions );
  shell( subprocessesConcurrentOptions2 )

  .then( ( arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesConcurrentOptions2.exitCode, 0 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 0 );
    test.is( _.strHas( arg[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( arg[ 0 ].output, 'end 1000' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 100' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 100' ) );

    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'args';
    time = _.timeNow();
    return null;
  })

  let subprocessesConcurrentArgumentsOptions2 = {}
  let subprocessesConcurrentArgumentsOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    args : [ 'second', 'argument' ],
    ready : ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var shell = _.process.starter( subprocessesConcurrentArgumentsOptions );
  shell( subprocessesConcurrentArgumentsOptions2 )

  .then( ( arg ) =>
  {

    var spent = _.timeNow() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesConcurrentArgumentsOptions2.exitCode, 0 );
    test.identical( arg.length, 2 );
    test.identical( _.fileProvider.fileRead( filePath ), 'written by 1000' );
    _.fileProvider.fileDelete( filePath );

    test.identical( arg[ 0 ].exitCode, 0 );
    test.is( _.strHas( arg[ 0 ].output, 'begin 1000, second, argument' ) );
    test.is( _.strHas( arg[ 0 ].output, 'end 1000, second, argument' ) );

    test.identical( arg[ 1 ].exitCode, 0 );
    test.is( _.strHas( arg[ 1 ].output, 'begin 100, second, argument' ) );
    test.is( _.strHas( arg[ 1 ].output, 'end 100, second, argument' ) );

    counter += 1;
    return null;
  });

  /* - */

  return ready.finally( ( err, arg ) =>
  {
    debugger;
    test.identical( counter, 12 );
    if( err )
    throw err;
    return arg;
  });
}

shellerConcurrent.timeOut = 100000;

//

function sheller( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );
  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var con = new _.Consequence().take( null )

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    debugger;
    return shell({ execPath :  [ 'arg1', 'arg2' ] })
    .thenKeep( ( got ) =>
    {
      debugger;
      test.identical( got.length, 2 );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.is( _.strHas( o1.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg2' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath + ' arg0',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  [ 'arg1', 'arg2' ] })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 2 );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.is( _.strHas( o1.output, "[ 'arg0', 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg0', 'arg2' ]" ) );

      return got;
    })
  })


  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  [ 'arg1', 'arg2' ], args : [ 'arg3' ] })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 2 );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.identical( o1.args, [ testAppPath, 'arg1', 'arg3' ] );
      test.identical( o2.args, [ testAppPath, 'arg2', 'arg3' ] );
      test.is( _.strHas( o1.output, "[ 'arg1', 'arg3' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg2', 'arg3' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  'arg1' })
    .thenKeep( ( got ) =>
    {
      test.identical( got.execPath, 'node' );
      test.is( _.strHas( got.output, "[ 'arg1' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath :
      [
        'node ' + testAppPath,
        'node ' + testAppPath
      ],
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  'arg1' })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 2 );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.is( _.strHas( o1.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg1' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath :
      [
        'node ' + testAppPath,
        'node ' + testAppPath
      ],
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  [ 'arg1', 'arg2' ]})
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 4 );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];
      let o3 = got[ 2 ];
      let o4 = got[ 3 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.identical( o3.execPath, 'node' );
      test.identical( o4.execPath, 'node' );
      test.is( _.strHas( o1.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o3.output, "[ 'arg2' ]" ) );
      test.is( _.strHas( o4.output, "[ 'arg2' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : 'arg1',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath })
    .thenKeep( ( got ) =>
    {
      test.identical( got.execPath, 'node' );
      test.is( _.strHas( got.output, "[ 'arg1' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : 'arg1',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath, args : 'arg2' })
    .thenKeep( ( got ) =>
    {
      test.identical( got.execPath, 'node' );
      test.is( _.strHas( got.output, "[ 'arg2' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : [ 'arg1', 'arg2' ],
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath, args : 'arg3' })
    .thenKeep( ( got ) =>
    {
      test.identical( got.execPath, 'node' );
      test.is( _.strHas( got.output, "[ 'arg3' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : 'arg1',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath, args : [ 'arg2', 'arg3' ] })
    .thenKeep( ( got ) =>
    {
      test.identical( got.execPath, 'node' );
      test.is( _.strHas( got.output, "[ 'arg2', 'arg3' ]" ) );

      return got;
    })
  })

  return con;
}

sheller.timeOut = 60000;

//

function shellerArgs( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.path.join( routinePath, 'testApp.js' );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );

  let shellerOptions =
  {
    outputCollecting : 1,
    args : [ 'arg1', 'arg2' ],
    mode : 'spawn',
    ready : ready
  }

  let shell = _.process.starter( shellerOptions )

  /* */

  shell
  ({
    execPath : 'node ' + testAppPath + ' arg3',
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( got.args, [ testAppPath, 'arg3', 'arg1', 'arg2' ] );
    test.identical( _.strCount( got.output, `[ 'arg3', 'arg1', 'arg2' ]` ), 1 );
    test.identical( shellerOptions.args, [ 'arg1', 'arg2' ] );
    return null;
  })

  shell
  ({
    execPath : 'node ' + testAppPath,
    args : [ 'arg3' ]
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( got.args, [ testAppPath, 'arg3' ] );
    test.identical( _.strCount( got.output, `[ 'arg3' ]` ), 1 );
    test.identical( shellerOptions.args, [ 'arg1', 'arg2' ] );
    return null;
  })

  shell
  ({
    execPath : 'node',
    args : [ testAppPath, 'arg3' ]
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( got.args, [ testAppPath, 'arg3' ] );
    test.identical( _.strCount( got.output, `[ 'arg3' ]` ), 1 );
    test.identical( shellerOptions.args, [ 'arg1', 'arg2' ] );
    return null;
  })

  /* */

  return ready;
}

shellerArgs.timeOut = 30000;

//

function outputHandling( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    console.log( 'testApp-output\n' );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var con = new _.Consequence().take( null );

  var modes = [ 'shell', 'spawn', 'exec', 'fork' ];
  var loggerOutput = '';

  function onTransformEnd( o )
  {
    loggerOutput += o.outputForPrinter[ 0 ];
  }
  var logger = new _.Logger({ output : null, onTransformEnd });

  modes.forEach( ( mode ) =>
  {
    let path = testAppPath;
    if( mode !== 'fork' )
    path = 'node ' + path;

    console.log( mode )

    con.thenKeep( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 0, outputCollecting : 0, logger };
      return _.process.start( o )
      .thenKeep( () =>
      {
        test.identical( o.output, undefined );
        test.is( !_.strHas( loggerOutput, 'testApp-output') );
        console.log( loggerOutput )
        return true;
      })
    })

    con.thenKeep( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 1, outputCollecting : 0, logger };
      return _.process.start( o )
      .thenKeep( () =>
      {
        test.identical( o.output, undefined );
        test.is( _.strHas( loggerOutput, 'testApp-output') );
        return true;
      })
    })

    con.thenKeep( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 0, outputCollecting : 1, logger };
      return _.process.start( o )
      .thenKeep( () =>
      {
        test.identical( o.output, 'testApp-output\n\n' );
        test.is( !_.strHas( loggerOutput, 'testApp-output') );
        return true;
      })
    })

    con.thenKeep( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 1, outputCollecting : 1, logger };
      return _.process.start( o )
      .thenKeep( () =>
      {
        test.identical( o.output, 'testApp-output\n\n' );
        test.is( _.strHas( loggerOutput, 'testApp-output') );
        return true;
      })
    })
  })

  return con;
}

outputHandling.timeOut = 10000;

//

function shellOutputStripping( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    console.log( '\u001b[31m\u001b[43mColored message1\u001b[49;0m\u001b[39;0m' )
    console.log( '\u001b[31m\u001b[43mColored message2\u001b[49;0m\u001b[39;0m' )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );
  var modes = [ 'shell', 'spawn', 'exec', 'fork' ];

  _.each( modes,( mode ) =>
  {
    let execPath = testAppPath;
    if( mode != 'fork' )
    execPath = 'node ' + execPath;

    _.process.start
    ({
      execPath : execPath,
      mode : mode,
      outputStripping : 0,
      outputCollecting : 1,
      ready : ready
    })
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      let output = _.strSplitNonPreserving({ src : got.output, delimeter : '\n' });
      test.identical( output.length, 2 );
      test.identical( output[ 0 ], '\u001b[31m\u001b[43mColored message1\u001b[49;0m\u001b[39;0m' );
      test.identical( output[ 1 ], '\u001b[31m\u001b[43mColored message2\u001b[49;0m\u001b[39;0m' );
      return null;
    })

    _.process.start
    ({
      execPath : execPath,
      mode : mode,
      outputStripping : 1,
      outputCollecting : 1,
      ready : ready
    })
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      let output = _.strSplitNonPreserving({ src : got.output, delimeter : '\n' });
      test.identical( output.length, 2 );
      test.identical( output[ 0 ], 'Colored message1' );
      test.identical( output[ 1 ], 'Colored message2' );
      return null;
    })
  })

  return ready;
}

shellOutputStripping.timeOut = 15000;

//

function shellLoggerOption( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    console.log( '  One tab' );
  }

  /* */

  var testAppPath = _.path.join( routinePath, 'testApp.js' );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );
  var modes = [ 'shell', 'spawn', 'exec', 'fork' ];

  test.case = 'custom logger with increased level'

  _.each( modes,( mode ) =>
  {
    let execPath = testAppPath;
    if( mode != 'fork' )
    execPath = 'node ' + execPath;

    let loggerOutput = '';

    let logger = new _.Logger({ output : null, onTransformEnd });
    logger.up();

    _.process.start
    ({
      execPath : execPath,
      mode : mode,
      outputCollecting : 1,
      outputPiping : 1,
      outputGray : 1,
      logger : logger,
      ready : ready
    })
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, '  One tab' ) )
      test.is( _.strHas( loggerOutput, '    One tab' ) )
      return null;
    })

    /*  */

    function onTransformEnd( o )
    {
      loggerOutput += o.outputForPrinter[ 0 ] + '\n';
    }
  })

  /* */

  return ready;
}

shellLoggerOption.timeOut = 30000;

//

function shellNormalizedExecPath( test )
{
  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.path.join( routinePath, 'testApp.js' );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );

  let shell = _.process.starter
  ({
    outputCollecting : 1,
    ready : ready
  })

  /* */

  shell
  ({
    execPath : testAppPath,
    args : [ 'arg1', 'arg2' ],
    mode : 'fork'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  //

  shell
  ({
    execPath : 'node ' + testAppPath,
    args : [ 'arg1', 'arg2' ],
    mode : 'spawn'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  //

  shell
  ({
    execPath : 'node ' + testAppPath,
    args : [ 'arg1', 'arg2' ],
    mode : 'shell'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  //

  shell
  ({
    execPath : 'node ' + testAppPath,
    args : [ 'arg1', 'arg2' ],
    mode : 'exec'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* app path in arguments */

  shell
  ({
    args : [ testAppPath, 'arg1', 'arg2' ],
    mode : 'fork'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  //

  shell
  ({
    execPath : 'node',
    args : [ testAppPath, 'arg1', 'arg2' ],
    mode : 'spawn'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  //

  shell
  ({
    execPath : 'node',
    args : [ testAppPath, 'arg1', 'arg2' ],
    mode : 'shell'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  //

  shell
  ({
    execPath : 'node',
    args : [ testAppPath, 'arg1', 'arg2' ],
    mode : 'exec'
  })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* */

  return ready;
}

shellNormalizedExecPath.timeOut = 60000;

//

function appTempApplication( test )
{
  let context = this;

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  let testAppCode = testApp.toString() + '\ntestApp();';

  /* */

  test.case = 'string';
  var got = _.process.tempOpen( testAppCode );
  var read = _.fileProvider.fileRead( got );
  test.identical( read, testAppCode );
  _.process.tempClose( got );
  test.is( !_.fileProvider.fileExists( got ) );

  test.case = 'string';
  var got = _.process.tempOpen({ sourceCode : testAppCode });
  var read = _.fileProvider.fileRead( got );
  test.identical( read, testAppCode );
  _.process.tempClose( got );
  test.is( !_.fileProvider.fileExists( got ) );

  test.case = 'raw buffer';
  var got = _.process.tempOpen( _.bufferRawFrom( testAppCode ) );
  var read = _.fileProvider.fileRead( got );
  test.identical( read, testAppCode );
  _.process.tempClose( got );
  test.is( !_.fileProvider.fileExists( got ) );

  test.case = 'raw buffer';
  var got = _.process.tempOpen({ sourceCode :_.bufferRawFrom( testAppCode ) });
  var read = _.fileProvider.fileRead( got );
  test.identical( read, testAppCode );
  _.process.tempClose( got );
  test.is( !_.fileProvider.fileExists( got ) );

  test.case = 'remove all';
  var got1 = _.process.tempOpen( testAppCode );
  var got2 = _.process.tempOpen( testAppCode );
  test.is( _.fileProvider.fileExists( got1 ) );
  test.is( _.fileProvider.fileExists( got2 ) );
  _.process.tempClose();
  test.is( !_.fileProvider.fileExists( got1 ) );
  test.is( !_.fileProvider.fileExists( got2 ) );
  test.mustNotThrowError( () => _.process.tempClose() )

  if( !Config.debug )
  return;

  test.case = 'unexpected type of sourceCode option';
  test.shouldThrowErrorSync( () =>
  {
    _.process.tempOpen( [] );
  })

  test.case = 'unexpected option';
  test.shouldThrowErrorSync( () =>
  {
    _.process.tempOpen({ someOption : true });
  })

  test.case = 'try to remove file that does not exist in registry';
  var got = _.process.tempOpen( testAppCode );
  _.process.tempClose( got );
  test.shouldThrowErrorSync( () =>
  {
    _.process.tempClose( got );
  })
}

//

function experiment( test )
{
  let self = this;

  var context = this;
  var routinePath = _.path.join( context.suitePath, test.name );

  /* */

  function testApp()
  {
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ChildProcess = require( 'child_process' );

  let ready = new _.Consequence().take( null )
  for( var i = 0; i < 1000; i++ )
  ready.then( () => f() );

  return ready;

  /*  */

  function f()
  {
    var con = new _.Consequence().take( null );

    con.thenKeep( function()
    {
      test.case = 'no args';

      let r = new _.Consequence();
      var process = ChildProcess.fork( testAppPath, [], {} );
      process.on( 'close', () =>
      {
        r.take( 1 );
      });

      return r;
    })

    con.thenKeep( function()
    {
      test.case = 'deasync';
      _.timeOut( 1 ).finallyDeasyncGive();
      return null;
    })

    return con;
  }
}

experiment.experimental = 1;

//

var Proto =
{

  name : 'Tools.base.l4.ProcessBasic',
  silencing : 1,
  routineTimeOut : 60000,
  onSuiteBegin : suiteBegin,
  onSuiteEnd : suiteEnd,

  context :
  {
    suitePath : null,
    testApp,
    testAppShell,
    toolsPath : null,
    toolsPathInclude : null
  },

  tests :
  {

    appArgs,
    appExitHandlerOnce,

    shell,
    shellSync,
    shellSyncAsync,
    shell2,
    shellCurrentPath,
    shellCurrentPaths,
    shellFork,
    shellWithoutExecPath,

    shellArgsOption,
    shellArgumentsParsing,
    shellArgumentsParsingNonTrivial,
    shellArgumentsNestedQuotes,
    shellExecPathQuotesClosing,
    shellExecPathSeveralCommands,
    shellVerbosity,
    shellErrorHadling,
    shellNode,
    shellModeShellNonTrivial,

    shellTerminate,
    shellTerminateWithExitHandler,
    shellTerminateHangedWithExitHandler,
    shellTerminateAfterLoopRelease,

    shellStartingDelay,
    shellStartingTime,
    // shellStartingSuspended,
    // shellAfterDeath,
    // shellAfterDeathOutput,

    // shellDetachingChildAfterParent,
    // shellDetachingChildBeforeParent,

    shellConcurrent,
    shellerConcurrent,

    sheller,
    shellerArgs,

    outputHandling,
    shellOutputStripping,
    shellLoggerOption,

    shellNormalizedExecPath,

    appTempApplication

  },

}

_.mapExtend( Self,Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
