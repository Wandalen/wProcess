( function External_test_s( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{

  isBrowser = false;

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

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
  if( !isBrowser )
  context.testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'ExternalFundamentals' );
  else
  context.testRootDirectory = _.path.current();
}

//

function cleanTestDir()
{
  var context = this;
  if( !isBrowser )
  _.fileProvider.filesDelete( context.testRootDirectory );
}

// --
// test
// --

function appArgs( test )
{
  var _argv =  process.argv.slice( 0, 2 );
  _argv = _.path.s.normalize( _argv );

  /* */

  // var argv = [];
  // argv.unshift.apply( argv, _argv );
  // var got = _.appArgs({ argv : argv, caching : 0 });
  // var expected =
  // {
  //   interpreterPath : _argv[ 0 ],
  //   mainPath : _argv[ 1 ],
  //   interpreterArgs : [],
  //   delimeter : ':',
  //   subject : '',
  //   scriptArgs : [],
  //   scriptString : '',
  // }
  // test.contains( got, expected );
  // got = null;
  //
  //
  // /* */
  //
  // var argv = [ '' ];
  // argv.unshift.apply( argv, _argv );
  // var got = _.appArgs({ argv : argv, caching : 0 });
  // var expected =
  // {
  //   interpreterPath : _argv[ 0 ],
  //   mainPath : _argv[ 1 ],
  //   interpreterArgs : [],
  //   delimeter : ':',
  //   subject : '',
  //   scriptArgs : [''],
  //   scriptString : '',
  // }
  // test.contains( got, expected );

  /* */

  var argv = [ 'x', ':', 'aa', 'bbb :' ];
  argv.unshift.apply( argv, _argv );
  debugger;
  var got = _.appArgs({ argv : argv, caching : 0 });
  debugger;
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    delimeter : ':',
    // map : { x : 'aa bbb' },
    map : { x : 'aa', bbb : '' },
    subject : '',
    // scriptArgs : [ 'x', ':', 'aa', 'bbb', ':' ]
    scriptArgs : [ 'x', ':', 'aa', 'bbb :' ]
  }
  test.contains( got, expected );

  // logger.log( _.toStr( got.scriptArgs ) )

  /* */

  var argv = [ 'x', ' : ', 'y' ];
  argv.unshift.apply( argv, _argv );
  var got = _.appArgs({ argv : argv, caching : 0 });
  var expected =
  {
    interpreterPath : _argv[ 0 ],
    mainPath : _argv[ 1 ],
    interpreterArgs : [],
    delimeter : ':',
    map : { x : 'y' },
    subject : '',
    // scriptArgs :[ 'x', ':', 'y' ]
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
    delimeter : ':',
    map : { x : 1 },
    subject : '',
    // scriptArgs : [ 'x', ':', 'y', 'x', ':', '1' ]
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
    delimeter : ':',
    map : { x : 'y xyz', y : 1 },
    subject : 'a b c d',
    // scriptArgs : [ 'a b c d', 'x', ':', 'y', 'xyz', 'y', ':', 1 ]
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
    delimeter : ':',
    map : { a : 1, b : 2, c : 3, d : 4, e : 5 },
    subject : 'filePath',
    // scriptArgs :
    // [
    //   'filePath',
    //   'a', ':', 1,
    //   'b', ':', '2',
    //   'c', ':', 3,
    //   'd', ':', '4',
    //   'e', ':', 5
    // ]
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
    delimeter : ':',
    map : { a : '', b : '', c : 'd', x : 0, y : 1 },
    subject : '',
    // scriptArgs : [ 'a', ':', 'b', ':', 'c', ':', 'd', 'x', ':', 0, 'y', ':', 1 ]
    scriptArgs : [ 'a :b :c :d', 'x', ' :', 0, 'y', ' :', 1 ]
  }
  test.contains( got, expected );
}

//

function shell( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testRootDirectory, test.name );
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
        require( '../../../Base.s' );
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
      _.include( 'wExternalFundamentals' );

    }
    var _global = _global_;
    var _ = _global_.wTools;

    var args = _.appArgs();
    var con = new _.Consequence().give();
    con.timeOutThen( _.numberRandomInt( [ 300, 2000 ] ), function()
    {
      if( args.map.exitWithCode )
      process.exit( args.map.exitWithCode )

      if( args.map.loop )
      while( true )
      {
      }

      console.log( __filename );
    });

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var o;
  var con = new _.Consequence().give();

  con.doThen( function()
  {
    test.case = 'mode : spawn';

    o =
    {
      path : 'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe'
    }
  })
  .ifNoErrorThen( function()
  {
    /* mode : spawn, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, testAppPath );
    })
  })
  .ifNoErrorThen( function()
  {
    /* mode : spawn, stdio : ignore */

    o.stdio = 'ignore';
    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output.length, 0 );
    })
  })
  // .ifNoErrorThen( function()
  // {
  //   /* mode : spawn, stdio : inherit */

  //   o.stdio = 'inherit';

  //   var options = _.mapSupplement( {}, o, commonDefaults );

  //   return _.shell( options )
  //   .doThen( function()
  //   {
  //     test.identical( options.exitCode, 0 );
  //     test.identical( options.output.length, 0 );
  //   })
  // })
  .ifNoErrorThen( function()
  {
    test.case = 'mode : shell';

    o =
    {
      path : 'node ' + testAppPath,
      mode : 'shell',
      stdio : 'pipe'
    }
  })
  .ifNoErrorThen( function()
  {
    /* mode : shell, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, testAppPath );
    })
  })
  .ifNoErrorThen( function()
  {
    /* mode : shell, stdio : ignore */

    o.stdio = 'ignore'

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output.length, 0 );
    })
  })
  // .ifNoErrorThen( function()
  // {
  //   /* mode : shell, stdio : inherit */

  //   o.stdio = 'inherit'

  //   var options = _.mapSupplement( {}, o, commonDefaults );

  //   return _.shell( options )
  //   .doThen( function()
  //   {
  //     test.identical( options.exitCode, 0 );
  //     test.identical( options.output.length, 0 );
  //   })
  // })
  .ifNoErrorThen( function()
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
    shell.give();
    shell.doThen(function()
    {
      test.identical( options.process.killed, false );
      options.process.kill( 'SIGINT' );

    })
    shell.got(function()
    {
      test.identical( options.process.killed, true );
      test.identical( !options.exitCode, true );
      shell.give();
    })

    return shell;
  })
  .ifNoErrorThen( function()
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
    shell.give();
    shell.doThen(function()
    {
      test.identical( options.process.killed, false );
      options.process.kill( 'SIGINT' );
    })
    shell.got(function()
    {
      test.identical( options.process.killed, true );
      test.identical( !options.exitCode, true );
      shell.give();
    })

    return shell;
  })
  .ifNoErrorThen( function()
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
    .doThen( () => test.identical( options.exitCode, 0 ) );
  })
  .ifNoErrorThen( function()
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
    .doThen( () => test.identical( options.exitCode, 1 ) );
  })
  .ifNoErrorThen( function()
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
    .doThen( () => test.identical( options.exitCode, 0 ) );
  })
  .ifNoErrorThen( function()
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
    .doThen( () => test.identical( options.exitCode, 1 ) );
  })
  //
  // test.case = 'test';
  // test.identical( 0, 0 );

  // con
  // .ifNoErrorThen( function()
  // {
  //   test.case = 'simple command';
  //   var con = _.shell( 'exit' );
  //   return test.shouldMessageOnlyOnce( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.case = 'bad command, shell';
  //   var con = _.shell({ code : 'xxx', throwingExitCode : 1, mode : 'shell' });
  //   return test.shouldThrowErrorSync( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.case = 'bad command, spawn';
  //   var con = _.shell({ code : 'xxx', throwingExitCode : 1, mode : 'spawn' });
  //   return test.shouldThrowErrorSync( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.case = 'several arguments';
  //   var con = _.shell( 'echo echo something' );
  //   return test.mustNotThrowError( con );
  // })
  // ;

  // con.doThen( () =>  _.fileProvider.fileDelete( testAppPath ) );
  return con;
}

shell.timeOut = 30000;

//

function shell2( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testRootDirectory, test.name );
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
        require( '../../../Base.s' );
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

    var con = new _.Consequence().give();
    con.timeOutThen( _.numberRandomInt( [ 300, 2000 ] ), function()
    {
      console.log( process.argv.slice( 2 ).join( ' ' ) );
    });

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testApp );

  var o;
  var con = new _.Consequence().give();

  con.doThen( function()
  {
    test.case = 'mode : shell';

    o =
    {
      path : 'node ' + testAppPath,
      args : [ 'staging', 'debug' ],
      mode : 'shell',
      stdio : 'pipe'
    }
  })
  .ifNoErrorThen( function()
  {
    /* mode : shell, stdio : pipe */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, o.args.join( ' ' ) );
    })
  })

  //

  con.doThen( function()
  {
    test.case = 'mode : shell, passingThrough : true, no args';

    o =
    {
      path : 'node ' + testAppPath,
      mode : 'shell',
      passingThrough : 1,
      stdio : 'pipe'
    }
  })
  .ifNoErrorThen( function()
  {
    /* mode : shell, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      var expectedArgs= _.arrayAppendArray( [], process.argv.slice( 2 ) );
      test.identical( options.output, expectedArgs.join( ' ' ) );
    })
  })

  //

  con.doThen( function()
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
  })
  .ifNoErrorThen( function()
  {
    /* mode : spawn, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      var expectedArgs = _.arrayAppendArray( [], process.argv.slice( 2 ) );
      test.identical( options.output, expectedArgs.join( ' ' ) );
    })
  })

  //

  con.doThen( function()
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
  })
  .ifNoErrorThen( function()
  {
    var options = _.mapSupplement( {}, o, commonDefaults );
    return test.shouldThrowError( _.shell( options ) );
  })

  //

  con.doThen( function()
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
  })
  .ifNoErrorThen( function()
  {
    /* mode : shell, stdio : pipe, passingThrough : true */

    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.shell( options )
    .doThen( function()
    {
      test.identical( options.exitCode, 0 );
      var expectedArgs = _.arrayAppendArray( [ 'staging', 'debug' ], process.argv.slice( 2 ) );
      test.identical( options.output, expectedArgs.join( ' ' ) );
    })
  })

  return con;
}

shell2.timeOut = 30000;

//

function shellCurrentPath( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testRootDirectory, test.name );

  /* */

  function testApp()
  {
    console.log( process.cwd() ); /* qqq : hide it from console if possible */
    if( process.send )
    process.send({ currentPath : process.cwd() })
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( testRoutineDir, 'testApp.js' ) );
  var testApp = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testApp );

  //

  var con = new _.Consequence().give();

  con.doThen( function()
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
    .doThen( function( err, got )
    {
      test.identical( o.output, __dirname );
    })
  })

  /**/

  con.doThen( function()
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
    .doThen( function( err, got )
    {
      test.identical( o.output, __dirname );
    })
  })

  /**/

  con.doThen( function()
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
    .doThen( function( err, got )
    {
      test.identical( o.output, __dirname );
    })
  })

  /**/

  con.doThen( function()
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
    con.doThen( function( err, got )
    {
      test.identical( output.currentPath, __dirname );
    })

    return con;
  })

  return con;
}

shellCurrentPath.timeOut = 30000;

//

var Proto =
{

  name : 'Tools/base/l4/ExternalFundamentals',
  silencing : 1,

  onSuiteBegin : testDirMake,
  onSuiteEnd : cleanTestDir,

  context :
  {

    testRootDirectory : null,

  },

  tests :
  {

    appArgs : appArgs,

    shell : shell,
    shell2 : shell2,
    shellCurrentPath : shellCurrentPath,

  },

}

_.mapExtend( Self,Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
/*_.*/wTester.test( Self )

})();
