( function External_test_s( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );

  require( '../l4/External.s' );

}

var _global = _global_;
var _ = _global_.wTools;
var Self = {};

// --
// context
// --

function testDirMake()
{
  var context = this;
  if( Config.platform === 'nodejs' )
  context.testSuitePath = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'ExternalFundamentals' );
  else
  context.testSuitePath = _.path.current();
}

//

function cleanTestDir()
{
  var context = this;
  if( Config.platform === 'nodejs' )
  _.fileProvider.filesDelete( context.testSuitePath );
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : argv, caching : 0 });
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
  var got = _.appArgs({ argv : [ 'interpreter', 'main.js', '.set v:5 ; .build debug:1 ; .export' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    subjectsDelimeter : ';',
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
  var got = _.appArgs({ argv : [ 'interpreter', 'main.js', '.set v:[1 2  3 ] ; .build debug:1 ; .export' ], caching : 0 });
  var expected =
  {
    interpreterPath : 'interpreter',
    mainPath : 'main.js',
    interpreterArgs : [],
    keyValDelimeter : ':',
    subjectsDelimeter : ';',
    subject : '.set',
    map : { v : [ 1,2,3 ] },
    scriptArgs : [ '.set v:[1 2  3 ] ; .build debug:1 ; .export' ],
    scriptString : '.set v:[1 2  3 ] ; .build debug:1 ; .export',
    subjects : [ '.set', '.build', '.export' ],
    maps : [ { v : [ 1,2,3 ] }, { debug : 1 }, {} ],
  }
  test.contains( got, expected );

}

//

function appRegisterExitHandler( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );
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

    if( typeof module !== 'undefined' )
    {
      let _ = require( '../../../Tools.s' );

      _.include( 'wConsequence' );
      _.include( 'wStringsExtra' );
      _.include( 'wStringer' );
      _.include( 'wPathFundamentals'/*ttt*/ );
      _.include( 'wExternalFundamentals' );

    }
    var _global = _global_;
    var _ = _global_.wTools;
    var args = _.appArgs();

    _.appRegisterExitHandler( ( arg ) =>
    {
      console.log( 'appRegisterExitHandler:', arg );
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

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var o;
  var con = new _.Consequence().take( null )


  /*  */

  .thenKeep( () =>
  {
    var o =
    {
      path : 'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      sync : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.shell( o )
    .thenKeep( ( got ) =>
    {
      test.is( got.exitCode === 0 );
      test.is( _.strHas( got.output, 'timeOut handler executed' ) )
      test.is( _.strHas( got.output, 'appRegisterExitHandler: 0' ) );
      return null;
    })

  })

  .thenKeep( () =>
  {
    var o =
    {
      path : 'node ' + testAppPath + ' terminate : 1',
      mode : 'spawn',
      stdio : 'pipe',
      sync : 0,
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.shell( o )
    .thenKeep( ( got ) =>
    {
      test.is( got.exitCode === 0 );
      test.is( !_.strHas( got.output, 'timeOut handler executed' ) )
      test.is( !_.strHas( got.output, 'appRegisterExitHandler: 0' ) );
      test.is( _.strHas( got.output, 'appRegisterExitHandler: SIGINT' ) );
      return null;
    });
  })

  return con;
}

//

function shell( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );
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

    if( typeof module !== 'undefined' )
    {
      let _ = require( '../../../Tools.s' );

      _.include( 'wConsequence' );
      _.include( 'wStringsExtra' );
      _.include( 'wStringer' );
      _.include( 'wPathFundamentals'/*ttt*/ );
      _.include( 'wExternalFundamentals' );

    }
    var _global = _global_;
    var _ = _global_.wTools;

    var args = _.appArgs();
    var con = new _.Consequence().take( null );
    con.timeOut( _.numberRandomInt( [ 300, 2000 ] ), function()
    {
      if( args.map.exitWithCode )
      process.exit( args.map.exitWithCode )

      if( args.map.loop )
      return _.timeOut( 4000 )

      console.log( __filename );

      return true;
    });

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var o;
  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'mode : spawn';

    o =
    {
      path : 'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe'
    }

    return null;
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : spawn, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, expectedOutput );
      return null;
    })
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : spawn, stdio : ignore */

    o.stdio = 'ignore';
    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output.length, 0 );
      return null;
    })
  })
  // .thenKeep( function( arg/*aaa*/ )
  // {
  //   /* mode : spawn, stdio : inherit */

  //   o.stdio = 'inherit';

  //   var options = _.mapSupplement( {}, o, commonDefaults );

  //   return _.shell( options )
  //   .thenKeep( function()
  //   {
  //     test.identical( options.exitCode, 0 );
  //     test.identical( options.output.length, 0 );
  //   })
  // })
  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'mode : shell';

    o =
    {
      path : 'node ' + testAppPath,
      mode : 'shell',
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : shell, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, expectedOutput );
      return null;
    })
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : shell, stdio : ignore */

    o.stdio = 'ignore'

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output.length, 0 );
      return null;
    })
  })
  // .thenKeep( function( arg/*aaa*/ )
  // {
  //   /* mode : shell, stdio : inherit */

  //   o.stdio = 'inherit'

  //   var options = _.mapSupplement( {}, o, commonDefaults );

  //   return _.shell( options )
  //   .thenKeep( function()
  //   {
  //     test.identical( options.exitCode, 0 );
  //     test.identical( options.output.length, 0 );
  //   })
  // })
  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'spawn, stop process using kill';

    o =
    {
      path : 'node ' + testAppPath + ' loop : 1',
      mode : 'spawn',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.shell( options );
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
  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'shell, stop process using kill';

    o =
    {
      path : 'node ' + testAppPath + ' loop : 1',
      mode : 'shell',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.shell( options );
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
  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'spawn, return good code';

    o =
    {
      path : 'node ' + testAppPath + ' exitWithCode : 0',
      mode : 'spawn',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.mustNotThrowError( _.shell( options ) )
    .thenKeep( () =>
    {
      test.identical( options.exitCode, 0 );
      return null;
    });
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'spawn, return bad code';

    o =
    {
      path : 'node ' + testAppPath + ' exitWithCode : 1',
      mode : 'spawn',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.shouldThrowError( _.shell( options ) )
    .thenKeep( () =>
    {
      test.identical( options.exitCode, 1 );
      return null;
    });
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'shell, return good code';

    o =
    {
      path : 'node ' + testAppPath + ' exitWithCode : 0',
      mode : 'shell',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.mustNotThrowError( _.shell( options ) )
    .thenKeep( () =>
    {
      test.identical( options.exitCode, 0 );
      return null;
    });
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'shell, return bad code';

    o =
    {
      path : 'node ' + testAppPath + ' exitWithCode : 1',
      mode : 'shell',
      stdio : 'pipe'
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    return test.shouldThrowError( _.shell( options ) )
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
  // .thenKeep( function( arg/*aaa*/ )
  // {
  //   test.case = 'simple command';
  //   var con = _.shell( 'exit' );
  //   return test.shouldMessageOnlyOnce( con );
  // })
  // .thenKeep( function( arg/*aaa*/ )
  // {
  //   test.case = 'bad command, shell';
  //   var con = _.shell({ code : 'xxx', throwingExitCode : 1, mode : 'shell' });
  //   return test.shouldThrowErrorSync( con );
  // })
  // .thenKeep( function( arg/*aaa*/ )
  // {
  //   test.case = 'bad command, spawn';
  //   var con = _.shell({ code : 'xxx', throwingExitCode : 1, mode : 'spawn' });
  //   return test.shouldThrowErrorSync( con );
  // })
  // .thenKeep( function( arg/*aaa*/ )
  // {
  //   test.case = 'several arguments';
  //   var con = _.shell( 'echo echo something' );
  //   return test.mustNotThrowError( con );
  // })
  // ;

  // con.thenKeep( () =>  _.fileProvider.fileDelete( testAppPath ) );

  .thenKeep( function( arg/*aaa*/ )
  {
    test.case = 'shell, stop using timeOut';

    o =
    {
      path : 'node ' + testAppPath + ' loop : 1',
      mode : 'shell',
      stdio : 'pipe',
      timeOut : 500
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.shell( options );
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
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );
  var commonDefaults =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1,
    sync : 1
  }

  /* */

  function testApp()
  {

    if( typeof module !== 'undefined' )
    {
      let _ = require( '../../../Tools.s' );

      _.include( 'wConsequence' );
      _.include( 'wStringsExtra' );
      _.include( 'wStringer' );
      _.include( 'wPathFundamentals'/*ttt*/ );
      _.include( 'wExternalFundamentals' );

    }
    var _global = _global_;
    var _ = _global_.wTools;

    var args = _.appArgs();
    var con = new _.Consequence().take( null );
    con.timeOut( _.numberRandomInt( [ 300, 2000 ] ), function()
    {
      if( args.map.exitWithCode )
      process.exit( args.map.exitWithCode )

      if( args.map.loop )
      return _.timeOut( 4000 )

      console.log( __filename );

      return true;
    });

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var o;

  //

  test.case = 'mode : spawn';
  o =
  {
    path : 'node ' + testAppPath,
    mode : 'spawn',
    stdio : 'pipe'
  }

  /* mode : spawn, stdio : pipe */

  var options = _.mapSupplement( {}, o, commonDefaults );
  _.shell( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : spawn, stdio : ignore */

  o.stdio = 'ignore';
  var options = _.mapSupplement( {}, o, commonDefaults );
  _.shell( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'mode : shell';
  o =
  {
    path : 'node ' + testAppPath,
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  _.shell( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : shell, stdio : ignore */

  o.stdio = 'ignore'
  var options = _.mapSupplement( {}, o, commonDefaults );
  _.shell( options )
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'shell, stop process using timeOut';
  o =
  {
    path : 'node ' + testAppPath + ' loop : 1',
    mode : 'shell',
    stdio : 'pipe',
    timeOut : 500
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.shell( options ) );

  //

  test.case = 'spawn, return good code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.mustNotThrowError( () => _.shell( options ) )
  test.identical( options.exitCode, 0 );

  //

  test.case = 'spawn, return bad code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.shell( options ) )
  test.identical( options.exitCode, 1 );

  //

  test.case = 'shell, return good code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'shell',
    stdio : 'pipe'
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  test.mustNotThrowError( () => _.shell( options ) )
  test.identical( options.exitCode, 0 );

  //

  test.case = 'shell, return bad code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.shell( options ) )
  test.identical( options.exitCode, 1 );

}

shellSync.timeOut = 30000;

//

function shellSyncAsync( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );
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

  function testApp()
  {

    if( typeof module !== 'undefined' )
    {
      let _ = require( '../../../Tools.s' );

      _.include( 'wConsequence' );
      _.include( 'wStringsExtra' );
      _.include( 'wStringer' );
      _.include( 'wPathFundamentals'/*ttt*/ );
      _.include( 'wExternalFundamentals' );

    }
    var _global = _global_;
    var _ = _global_.wTools;

    var args = _.appArgs();
    var con = new _.Consequence().take( null );
    con.timeOut( _.numberRandomInt( [ 300, 2000 ] ), function()
    {
      if( args.map.exitWithCode )
      process.exit( args.map.exitWithCode )

      if( args.map.loop )
      return _.timeOut( 4000 )

      console.log( __filename );

      return true;
    });

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var o;

  //

  test.case = 'mode : fork';
  o =
  {
    path : testAppPath,
    mode : 'fork',
    stdio : 'pipe'
  }

  /* mode : spawn, stdio : pipe */

  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : fork, stdio : ignore */

  o.stdio = 'ignore';
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'mode : spawn';
  o =
  {
    path : 'node ' + testAppPath,
    mode : 'spawn',
    stdio : 'pipe'
  }

  /* mode : spawn, stdio : pipe */

  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : spawn, stdio : ignore */

  o.stdio = 'ignore';
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'mode : shell';
  o =
  {
    path : 'node ' + testAppPath,
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output, expectedOutput );

  /* mode : shell, stdio : ignore */

  o.stdio = 'ignore'
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );
  test.identical( options.output.length, 0 );

  //

  test.case = 'shell, stop process using timeOut';
  o =
  {
    path : 'node ' + testAppPath + ' loop : 1',
    mode : 'shell',
    stdio : 'pipe',
    timeOut : 500
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.shell( options ) );

  //

  test.case = 'spawn, return good code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );

  //

  test.case = 'spawn, return bad code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.shell( options ) )
  test.identical( options.exitCode, 1 );

  //

  test.case = 'shell, return good code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 0',
    mode : 'shell',
    stdio : 'pipe'
  }

  var options = _.mapSupplement( {}, o, commonDefaults );
  var got = _.shell( options );
  test.is( got === options );
  test.identical( got.process.constructor.name, 'ChildProcess' );
  test.identical( options.exitCode, 0 );

  //

  test.case = 'shell, return bad code';
  o =
  {
    path : 'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'shell',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.shell( options ) )
  test.identical( options.exitCode, 1 );

}

shellSyncAsync.timeOut = 30000;

//

function shell2( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );
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

    if( typeof module !== 'undefined' )
    {
      try
      {
        require( '../../../../Base.s' );
      }
      catch( err )
      {
        require( 'wTools' );
      }
      var _global = _global_;
      var _ = _global_.wTools;

      _.include( 'wConsequence' );
      _.include( 'wStringsExtra' );
      _.include( 'wStringer' );
      _.include( 'wPathFundamentals'/*ttt*/ );

    }
    var _global = _global_;
    var _ = _global_.wTools;

    var con = new _.Consequence().take( null );
    con.timeOut( _.numberRandomInt( [ 300, 2000 ] ), function()
    {
      console.log( process.argv.slice( 2 ).join( ' ' ) );
      return true;
    });

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var o;
  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'mode : shell';

    o =
    {
      path : 'node ' + testAppPath,
      args : [ 'staging', 'debug' ],
      mode : 'shell',
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : shell, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
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
      path : 'node ' + testAppPath,
      mode : 'shell',
      passingThrough : 1,
      stdio : 'pipe'
    }

    return null;
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : shell, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
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
      path : 'node',
      args : [ testAppPath ],
      mode : 'spawn',
      passingThrough : 1,
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : spawn, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
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
      path : 'node ' + testApp,
      args : [ 'staging' ],
      mode : 'spawn',
      passingThrough : 1,
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    var options = _.mapSupplement( {}, o, commonDefaults );
    return test.shouldThrowError( _.shell( options ) );
  })

  //

  con.thenKeep( function()
  {
    test.case = 'mode : shell, passingThrough : true';

    o =
    {
      path : 'node ' + testAppPath,
      args : [ 'staging', 'debug' ],
      mode : 'shell',
      passingThrough : 1,
      stdio : 'pipe'
    }
    return null;
  })
  .thenKeep( function( arg/*aaa*/ )
  {
    /* mode : shell, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
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
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );

  /* */

  function testApp()
  {
    debugger
    console.log( process.cwd() ); /* qqq : hide it from console if possible */
    if( process.send )
    process.send({ currentPath : process.cwd() })
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testApp );

  //

  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'mode : shell';

    let o =
    {
      path : 'node ' + testAppPath,
      currentPath : __dirname,
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
    }
    return _.shell( o )
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
      path : 'node ' + testAppPath,
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
    }
    return _.shell( o )
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
      path : 'node ' + testAppPath,
      currentPath : __dirname,
      mode : 'exec',
      stdio : 'pipe',
      outputCollecting : 1,
    }
    return _.shell( o )
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
      path : testAppPath,
      currentPath : __dirname,
      mode : 'fork',
    }
    let con = _.shell( o );
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

function shellFork( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testApp );

  //

  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'no args';

    let o =
    {
      path :  testAppPath,
      args : null,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.shell( o )
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
      path :  testAppPath,
      args : [ 'arg1', 'arg2' ],
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.shell( o )
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
  //     path :  testAppPath,
  //     args : [ 'arg1', 'arg2' ],
  //     mode : 'fork',
  //     stdio : 'inherit',
  //     outputCollecting : 1,
  //     outputPiping : 1,
  //   }

  //   return _.shell( o )
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
      path :  testAppPath,
      args : [ 'arg1', 'arg2' ],
      mode : 'fork',
      stdio : 'ignore',
      outputCollecting : 1,
      outputPiping : 1,
    }

    return _.shell( o )
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

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      path :  testAppPath2,
      currentPath : testRoutineDir,
      env : { 'key1' : 'val' },
      args : [ 'arg1', 'arg2' ],
      interpreterArgs : [ '--no-warnings' ],
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.shell( o )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output,  "[ 'arg1', 'arg2' ]" ) );
      test.is( _.strHas( o.output,  "key1: 'val'," ) );
      test.is( _.strHas( o.output,  _.fileProvider.path.nativize( testRoutineDir ) ) );
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

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      path :  testAppPath2,
      currentPath : testRoutineDir,
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

    _.shell( o );

    test.identical( o.exitCode, 0 );
    test.is( _.strHas( o.output,  "[ 'arg1', 'arg2' ]" ) );
    test.is( _.strHas( o.output,  "key1: 'val'," ) );
    test.is( _.strHas( o.output,  _.fileProvider.path.nativize( testRoutineDir ) ) );
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

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      path :  testAppPath2,
      mode : 'fork',
      stdio : 'pipe',
    }

    let gotMessage;
    let con = _.shell( o );

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
    test.case = 'path should contain only path to js file';

    let o =
    {
      path :  testAppPath + ' arg0',
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }

    return test.shouldThrowError( _.shell( o ) )
    .thenKeep( function( got )
    {
      test.identical( o.exitCode, 1 );
      test.is( _.strHas( o.output,  'Error: Cannot find module' ) );
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

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      path :  testAppPath2,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 1,
      timeOut : 1000,
    }

    return test.shouldThrowError( _.shell( o ) )
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

    let testAppPath2 = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp2.js' ) );
    var testApp2 = testApp2.toString() + '\ntestApp2();';
    _.fileProvider.fileWrite( testAppPath2, testApp2 );

    let o =
    {
      path :  testAppPath2,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      timeOut : 1000,
    }

    return _.shell( o )
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

function shellErrorHadling( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );

  /* */

  function testApp()
  {
    if( typeof module !== 'undefined' )
    {
      try
      {
        require( '../../../../Base.s' );
      }
      catch( err )
      {
        require( 'wTools' );
      }
    }

    var _ = _global_.wTools;

    _.include( 'wExternalFundamentals' );

    throw _.err( 'Error message from child' );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testApp );

  //

  var con = new _.Consequence().take( null );

  con.thenKeep( function()
  {
    test.case = 'collecting, verbosity and piping off';

    let o =
    {
      path :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    return test.shouldThrowError( _.shell( o ) )
    .thenKeep( function( got )
    {
      test.is( _.errIs( got ) );
      test.is( _.strHas( got.message, 'Process returned error code' ) )
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
      path :  'node ' + testAppPath,
      mode : 'shell',
      stdio : 'pipe',
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    return test.shouldThrowError( _.shell( o ) )
    .thenKeep( function( got )
    {
      test.is( _.errIs( got ) );
      test.is( _.strHas( got.message, 'Process returned error code' ) )
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
      path :  testAppPath,
      mode : 'fork',
      stdio : 'pipe',
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    return test.shouldThrowError( _.shell( o ) )
    .thenKeep( function( got )
    {
      test.is( _.errIs( got ) );
      test.is( _.strHas( got.message, 'Process returned error code' ) )
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
      path :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.shell( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned error code' ) )
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
      path :  'node ' + testAppPath,
      mode : 'shell',
      stdio : 'pipe',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.shell( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned error code' ) )
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
      path :  testAppPath,
      mode : 'fork',
      stdio : 'pipe',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.shell( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned error code' ) )
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
      path :  testAppPath,
      mode : 'fork',
      stdio : 'ignore',
      sync : 1,
      deasync : 1,
      verbosity : 0,
      outputCollecting : 0,
      outputPiping : 0
    }
    var got = test.shouldThrowErrorSync( () => _.shell( o ) )

    test.is( _.errIs( got ) );
    test.is( _.strHas( got.message, 'Process returned error code' ) )
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
  //     path :  testAppPath,
  //     mode : 'fork',
  //     stdio : 'inherit',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   var got = test.shouldThrowErrorSync( () => _.shell( o ) )

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
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );

  /* */

  function testApp()
  {
    throw 1;
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var con = new _.Consequence().take( null );

  var modes = [ 'fork', 'exec', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    con.thenKeep( () =>
    {
      var o = { path : testAppPath, mode : mode, applyingExitCode : 1, throwingExitCode : 1 };
      return _.shellNode( o )
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
      var o = { path : testAppPath, mode : mode,  applyingExitCode : 1, throwingExitCode : 0 };
      return _.shellNode( o )
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
      var o = { path : testAppPath,  mode : mode, applyingExitCode : 0, throwingExitCode : 1 };
      return _.shellNode( o )
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
      var o = { path : testAppPath,  mode : mode, applyingExitCode : 0, throwingExitCode : 0 };
      return _.shellNode( o )
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
      var o = { path : testAppPath,  mode : mode, maximumMemory : 1, applyingExitCode : 0, throwingExitCode : 0 };
      return _.shellNode( o )
      .finally( ( err, got ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        test.is( _.strHas( o.process.spawnargs.join( ' ' ), '--expose-gc --stack-trace-limit=999 --max_old_space_size' ) )
        test.is( !_.errIs( err ) );
        return true;
      })
    })
  })

  return con;

}

shellNode.timeOut = 10000;

//

function sheller( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var con = new _.Consequence().take( null )


  .thenKeep( () =>
  {
    let shell = _.sheller
    ({
      path : 'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ path : [ 'arg1', 'arg2' ] })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 3 );
      test.identical( got[ got.length - 1 ], null );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.is( _.strHas( o1.path, 'arg1' ) );
      test.is( _.strHas( o2.path, 'arg2' ) );
      test.is( _.strHas( o1.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg2' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    let shell = _.sheller
    ({
      path : 'node ' + testAppPath + ' arg0',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ path : [ 'arg1', 'arg2' ] })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 3 );
      test.identical( got[ got.length - 1 ], null );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.is( _.strHas( o1.path, 'arg0 arg1' ) );
      test.is( _.strHas( o2.path, 'arg0 arg2' ) );
      test.is( _.strHas( o1.output, "[ 'arg0', 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg0', 'arg2' ]" ) );

      return got;
    })
  })


  .thenKeep( () =>
  {
    let shell = _.sheller
    ({
      path : 'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ path : [ 'arg1', 'arg2' ], args : [ 'arg3' ] })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 3 );
      test.identical( got[ got.length - 1 ], null );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.is( _.strHas( o1.path, 'arg1' ) );
      test.is( _.strHas( o2.path, 'arg2' ) );
      test.identical( o1.args, [ 'arg3' ] );
      test.identical( o2.args, [ 'arg3' ] );
      test.is( _.strHas( o1.output, "[ 'arg1', 'arg3' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg2', 'arg3' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    let shell = _.sheller
    ({
      path : 'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ path : 'arg1' })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 2 );
      test.identical( got[ got.length - 1 ], null );

      let o1 = got[ 0 ];

      test.is( _.strHas( o1.path, 'arg1' ) );
      test.is( _.strHas( o1.output, "[ 'arg1' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    let shell = _.sheller
    ({
      path :
      [
        'node ' + testAppPath,
        'node ' + testAppPath
      ],
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ path : 'arg1' })
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 3 );
      test.identical( got[ got.length - 1 ], null );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];

      test.is( _.strHas( o1.path, 'arg1' ) );
      test.is( _.strHas( o2.path, 'arg1' ) );
      test.is( _.strHas( o1.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg1' ]" ) );

      return got;
    })
  })

  .thenKeep( () =>
  {
    let shell = _.sheller
    ({
      path :
      [
        'node ' + testAppPath,
        'node ' + testAppPath
      ],
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ path : [ 'arg1', 'arg2' ]})
    .thenKeep( ( got ) =>
    {
      test.identical( got.length, 5 );
      test.identical( got[ got.length - 1 ], null );

      let o1 = got[ 0 ];
      let o2 = got[ 1 ];
      let o3 = got[ 2 ];
      let o4 = got[ 3 ];

      test.is( _.strHas( o1.path, 'arg1' ) );
      test.is( _.strHas( o2.path, 'arg1' ) );
      test.is( _.strHas( o3.path, 'arg2' ) );
      test.is( _.strHas( o4.path, 'arg2' ) );
      test.is( _.strHas( o1.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o2.output, "[ 'arg1' ]" ) );
      test.is( _.strHas( o3.output, "[ 'arg2' ]" ) );
      test.is( _.strHas( o4.output, "[ 'arg2' ]" ) );

      return got;
    })
  })

  return con;
}

//


function outputHandling( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testSuitePath, test.name );

  /* */

  function testApp()
  {
    console.log( 'testApp-output\n' );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var con = new _.Consequence().take( null );

  var modes = [ 'shell', 'spawn', 'exec', 'fork' ];
  var loggerOutput = '';

  function onTransformEnd( o )
  {
    loggerOutput += o.outputForPrinter[ 0 ];
  }
  var logger = new _.Logger({ output : null, onTransformEnd : onTransformEnd });

  modes.forEach( ( mode ) =>
  {
    let path = testAppPath;
    if( mode !== 'fork' )
    path = 'node ' + path;

    console.log( mode )

    con.thenKeep( () =>
    {
      loggerOutput = '';
      var o = { path : path, mode : mode, outputPiping : 0, outputCollecting : 0, logger : logger };
      return _.shell( o )
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
      var o = { path : path, mode : mode, outputPiping : 1, outputCollecting : 0, logger : logger };
      return _.shell( o )
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
      var o = { path : path, mode : mode, outputPiping : 0, outputCollecting : 1, logger : logger };
      return _.shell( o )
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
      var o = { path : path, mode : mode, outputPiping : 1, outputCollecting : 1, logger : logger };
      return _.shell( o )
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

var Proto =
{

  name : 'Tools/base/l4/ExternalFundamentals',
  silencing : 1,

  onSuiteBegin : testDirMake,
  onSuiteEnd : cleanTestDir,

  context :
  {

    testSuitePath : null,
  },

  tests :
  {

    appArgs : appArgs,
    appRegisterExitHandler : appRegisterExitHandler,

    shell : shell,
    shellSync : shellSync,
    shellSyncAsync : shellSyncAsync,
    shell2 : shell2,
    shellCurrentPath : shellCurrentPath,
    shellFork : shellFork,
    shellErrorHadling : shellErrorHadling,
    shellNode : shellNode,

    sheller : sheller,

    outputHandling : outputHandling

  },

}

_.mapExtend( Self,Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
