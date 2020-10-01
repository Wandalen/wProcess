( function _ProcessBasic_test_s( )
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wProcessWatcher' );

  require( '../l4_process/Basic.s' );
}

/*

qqq :

- reacts on requests ( qqq ) in the module
- use application code from test rouitne shellConcurrent for all test routines, maybe?
- make sure tests works in collection, not only in stand-alone mode

*/

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

  // self.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  // self.appJsPath = _.path.nativize( _.module.resolve( 'wProcess' ) );
}

//

function suiteEnd()
{
  var self = this;

  _.assert( _.strHas( self.suiteTempPath, '/ProcessBasic-' ) )
  _.path.tempClose( self.suiteTempPath );
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

/* qqq : rewrite tests using assetFor and the best practices
*/


function processOnExitEvent( test )
{

  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( testApp );

  /* */

  a.ready.thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + programPath,
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
      test.is( _.strHas( got.output, 'processOnExit: 0' ) );
      return null;
    })

  })

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + programPath + ' terminate : 1',
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
      test.is( !_.strHas( got.output, 'processOnExit: 0' ) );
      test.is( _.strHas( got.output, 'processOnExit: SIGINT' ) );
      return null;
    });
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )

    var args = _.process.args();

    _.process.on( 'exit', ( arg ) =>
    {
      console.log( 'processOnExit:', arg );
    });

    _.time.out( 1000, () =>
    {
      console.log( 'timeOut handler executed' );
      return 1;
    })

    if( args.map.terminate )
    process.exit( 'SIGINT' );

  }
}

//

function processOffExitEvent( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( testApp );

  /*  */

  a.ready.thenKeep( () =>
  {
    test.case = 'nothing to off'
    var o =
    {
      execPath :  'node ' + programPath,
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( _.strCount( got.output, 'timeOut handler executed'  ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit1: 0' ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit2: 0' ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit3: 0' ), 0 );
      return null;
    })

  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'off single handler'
    var o =
    {
      execPath :  'node ' + programPath,
      args : 'off:handler1',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( _.strCount( got.output, 'timeOut handler executed'  ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit1: 0' ), 0 );
      test.identical( _.strCount( got.output, 'processOnExit2: 0' ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit3: 0' ), 0 );
      return null;
    })
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'off all handlers'
    var o =
    {
      execPath :  'node ' + programPath,
      args : 'off:[handler1,handler2]',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
    }

    return _.process.start( o )
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( _.strCount( got.output, 'timeOut handler executed'  ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit1: 0' ), 0 );
      test.identical( _.strCount( got.output, 'processOnExit2: 0' ), 0 );
      test.identical( _.strCount( got.output, 'processOnExit3: 0' ), 0 );
      return null;
    })
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'off unregistered handler'
    var o =
    {
      execPath :  'node ' + programPath,
      args : 'off:handler3',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    return _.process.start( o )
    .then( ( got ) =>
    {
      test.notIdentical( got.exitCode, 0 );
      test.identical( _.strCount( got.output, 'uncaught error' ), 2 );
      test.identical( _.strCount( got.output, 'processOnExit1: -1' ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit2: -1' ), 1 );
      test.identical( _.strCount( got.output, 'processOnExit3: -1' ), 0 );
      return null;
    })
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )

    var handlersMap = {};
    var args = _.process.args();

    handlersMap[ 'handler1' ] = handler1;
    handlersMap[ 'handler2' ] = handler2;
    handlersMap[ 'handler3' ] = handler3;

    _.process.on( 'exit', handler1 );
    _.process.on( 'exit', handler2 );

    if( args.map.off )
    {
      args.map.off = _.arrayAs( args.map.off );
      _.each( args.map.off, ( name ) =>
      {
        _.assert( handlersMap[ name ] );
        _.process.off( 'exit', handlersMap[ name ] );
      })
    }

    _.time.out( 1000, () =>
    {
      console.log( 'timeOut handler executed' );
      return 1;
    })

    function handler1( arg )
    {
      console.log( 'processOnExit1:', arg );
    }
    function handler2( arg )
    {
      console.log( 'processOnExit2:', arg );
    }
    function handler3( arg )
    {
      console.log( 'processOnExit3:', arg );
    }
  }
}

//

function exitReason( test )
{
  test.case = 'initial value'
  var got = _.process.exitReason();
  test.identical( got, null );

  test.case = 'set reason'
  _.process.exitReason( 'reason' );
  var got = _.process.exitReason();
  test.identical( got, 'reason' );

  test.case = 'update reason'
  _.process.exitReason( 'reason2' );
  var got = _.process.exitReason();
  test.identical( got, 'reason2' );
}

//

function exitCode( test )
{
  test.case = 'initial value'
  var got = _.process.exitCode();
  test.identical( got, 0 );

  test.case = 'set code'
  _.process.exitCode( 1 );
  var got = _.process.exitCode();
  test.identical( got, 1 );

  test.case = 'update reason'
  _.process.exitCode( 2 );
  var got = _.process.exitCode();
  test.identical( got, 2 );

  test.case = 'change to zero'
  _.process.exitCode( 0 );
  var got = _.process.exitCode();
  test.identical( got, 0 );
}

//

/* qqq : split test cases by / ** / delimeting lines */
/* qqq : split by mode */
function shell( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
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

  con
  .thenKeep( function()
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

  .thenKeep( function( arg )
  {
    test.case = 'spawn, stop process using SIGINT';

    o =
    {
      execPath :  'node ' + testAppPath + ' loop : 1',
      mode : 'spawn',
      stdio : 'pipe',
      throwingExitCode : 0
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.process.start( options );
    _.time.out( 500, () =>
    {
      test.identical( options.process.killed, false );
      options.process.kill( 'SIGINT' );
      return null;
    })
    shell.finally(function()
    {
      test.identical( options.process.killed, true );
      test.identical( options.exitCode, null ); /* qqq2 : near each such test check should be following checks */
      test.identical( options.exitSignal, 'SIGINT' );
      test.identical( options.process.exitCode, null );
      test.identical( options.process.signalCode, 'SIGINT' );
      return null;
    })

    return shell;
  })

  .thenKeep( function( arg )
  {
    test.case = 'shell, stop process using SIGINT';

    o =
    {
      execPath :  'node ' + testAppPath + ' loop : 1',
      mode : 'shell',
      stdio : 'pipe',
      throwingExitCode : 0
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.process.start( options );
    _.time.out( 500, () =>
    {
      test.identical( options.process.killed, false );
      options.process.kill( 'SIGINT' );
      return null;
    })
    shell.finally(function()
    {
      test.identical( options.process.killed, true );

      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, 'SIGINT' );
      test.identical( options.process.exitCode, null );
      test.identical( options.process.signalCode, 'SIGINT' );

      return null;
    })

    return shell;
  })

  .thenKeep( function( arg )
  {
    test.case = 'shell, stop process using SIGKILL';

    o =
    {
      execPath :  'node ' + testAppPath + ' loop : 1',
      mode : 'shell',
      stdio : 'pipe',
      throwingExitCode : 0
    }

    var options = _.mapSupplement( {}, o, commonDefaults );

    var shell = _.process.start( options );
    _.time.out( 500, () =>
    {
      test.identical( options.process.killed, false );
      options.process.kill( 'SIGKILL' );
      return null;
    })
    shell.finally(function()
    {
      test.identical( options.process.killed, true );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, 'SIGKILL' );
      test.identical( options.process.exitCode, null );
      test.identical( options.process.signalCode, 'SIGKILL' );
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

  /* - */

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

  /* - */

  return con;
}

shell.timeOut = 30000;

//

function shellSync( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

  test.case = 'spawn, return ext code 1';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 1',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) );
  test.identical( options.exitCode, 1 );

  /* - */

  test.case = 'spawn, return ext code 2';
  o =
  {
    execPath :  'node ' + testAppPath + ' exitWithCode : 2',
    mode : 'spawn',
    stdio : 'pipe'
  }
  var options = _.mapSupplement( {}, o, commonDefaults );
  test.shouldThrowErrorSync( () => _.process.start( options ) );
  test.identical( options.exitCode, 2 );

  /* - */

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

  /* - */

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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
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

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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

function shellCurrentPath( test ) /* qqq : split by mode */
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

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

  /* - */

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

  // ttt
  // con.thenKeep( function()
  // {
  //   test.case = 'mode : exec';
  //
  //   let o =
  //   {
  //     execPath :  'node ' + testAppPath,
  //     currentPath : __dirname,
  //     mode : 'exec',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //   }
  //   return _.process.start( o )
  //   .thenKeep( function( got )
  //   {
  //     test.identical( o.output, expectedOutput );
  //     return null;
  //   })
  // })

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

  /* */

  con.thenKeep( function()
  {
    test.case = 'normalized, currentPath leads to root of current drive, mode : spawn';

    let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
    let currentPath = trace[ 1 ];

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath,
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
      return null;
    })
  })

  /* */


  con.thenKeep( function()
  {
    test.case = 'normalized with slash, currentPath leads to root of current drive, mode : spawn';

    let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
    let currentPath = trace[ 1 ] + '/';

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath,
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      if( process.platform === 'win32')
      test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
      else
      test.identical( _.strStrip( got.output ), trace[ 1 ] );
      return null;
    })
  })

  /* */

  con.thenKeep( function()
  {
    test.case = 'nativized, currentPath leads to root of current drive, mode : spawn';

    let trace = _.path.traceToRoot( __dirname );
    let currentPath = _.path.nativize( trace[ 1 ] );

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath,
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( _.strStrip( got.output ), currentPath );
      return null;
    })
  })

  /*  */

  con.thenKeep( function()
  {
    test.case = 'normalized, currentPath leads to root of current drive, mode : fork';

    let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
    let currentPath = trace[ 1 ];

    let o =
    {
      execPath : testAppPath,
      currentPath,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
      return null;
    })
  })

  /* */


  con.thenKeep( function()
  {
    test.case = 'normalized with slash, currentPath leads to root of current drive, mode : fork';

    let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
    let currentPath = trace[ 1 ] + '/';

    let o =
    {
      execPath : testAppPath,
      currentPath,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      if( process.platform === 'win32')
      test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
      else
      test.identical( _.strStrip( got.output ), trace[ 1 ] );
      return null;
    })
  })

  /* */

  con.thenKeep( function()
  {
    test.case = 'nativized, currentPath leads to root of current drive, mode : fork';

    let trace = _.path.traceToRoot( __dirname );
    let currentPath = _.path.nativize( trace[ 1 ] );

    let o =
    {
      execPath : testAppPath,
      currentPath,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( _.strStrip( got.output ), currentPath );
      return null;
    })
  })

  /* */

  con.thenKeep( function()
  {
    test.case = 'normalized, currentPath leads to root of current drive, mode : shell';

    let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
    let currentPath = trace[ 1 ];

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath,
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
      return null;
    })
  })

  /* */


  con.thenKeep( function()
  {
    test.case = 'normalized with slash, currentPath leads to root of current drive, mode : shell';

    let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
    let currentPath = trace[ 1 ] + '/';

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath,
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      if( process.platform === 'win32')
      test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
      else
      test.identical( _.strStrip( got.output ), trace[ 1 ] );
      return null;
    })
  })

  /* */

  con.thenKeep( function()
  {
    test.case = 'nativized, currentPath leads to root of current drive, mode : shell';

    let trace = _.path.traceToRoot( __dirname );
    let currentPath = _.path.nativize( trace[ 1 ] )

    let o =
    {
      execPath :  'node ' + testAppPath,
      currentPath,
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
    }

    return _.process.start( o )
    .thenKeep( function( got )
    {
      test.identical( _.strStrip( got.output ), currentPath );
      return null;
    })
  })

  /* */

  // ttt
  // con.thenKeep( function()
  // {
  //   test.case = 'normalized, currentPath leads to root of current drive, mode : exec';
  //
  //   let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
  //   let currentPath = trace[ 1 ];
  //
  //   let o =
  //   {
  //     execPath :  'node ' + testAppPath,
  //     currentPath,
  //     mode : 'exec',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //   }
  //
  //   return _.process.start( o )
  //   .thenKeep( function( got )
  //   {
  //     test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
  //     return null;
  //   })
  // })
  //
  // /* */
  //
  //
  // con.thenKeep( function()
  // {
  //   test.case = 'normalized with slash, currentPath leads to root of current drive, mode : exec';
  //
  //   let trace = _.path.traceToRoot( _.path.normalize( __dirname ) );
  //   let currentPath = trace[ 1 ] + '/';
  //
  //   let o =
  //   {
  //     execPath :  'node ' + testAppPath,
  //     currentPath,
  //     mode : 'exec',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //   }
  //
  //   return _.process.start( o )
  //   .thenKeep( function( got )
  //   {
  //     if( process.platform === 'win32')
  //     test.identical( _.strStrip( got.output ), _.path.nativize( currentPath ) );
  //     else
  //     test.identical( _.strStrip( got.output ), trace[ 1 ] );
  //     return null;
  //   })
  // })
  //
  // /* */
  //
  // con.thenKeep( function()
  // {
  //   test.case = 'nativized, currentPath leads to root of current drive, mode : exec';
  //
  //   let trace = _.path.traceToRoot( __dirname );
  //   let currentPath = _.path.nativize( trace[ 1 ] );
  //
  //   let o =
  //   {
  //     execPath :  'node ' + testAppPath,
  //     currentPath,
  //     mode : 'exec',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //   }
  //
  //   return _.process.start( o )
  //   .thenKeep( function( got )
  //   {
  //     test.identical( _.strStrip( got.output ), currentPath );
  //     return null;
  //   })
  // })

  /* */

  return con;
}

shellCurrentPath.timeOut = 30000;

//

function shellCurrentPaths( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

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

  // _.process.start( _.mapSupplement( { mode : 'exec' }, o2 ) );
  //
  // ready.then( ( got ) =>
  // {
  //   let o1 = got[ 0 ];
  //   let o2 = got[ 1 ];
  //
  //   test.is( _.strHas( o1.output, _.path.nativize( routinePath ) ) );
  //   test.identical( o1.exitCode, 0 );
  //
  //   test.is( _.strHas( o2.output, __dirname ) );
  //   test.identical( o2.exitCode, 0 );
  //
  //   return got;
  // })

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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

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

  /* - */

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

  /* - */

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
      test.is( _.strHas( o.output,  `[ 'arg1', 'arg2' ]` ) );
      return null;
    })
  })

  /* - */

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

  /* - */

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

  /* - */

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
      test.is( _.strHas( o.output,  `[ 'arg1', 'arg2' ]` ) );
      test.is( _.strHas( o.output,  `key1: 'val'` ) );
      test.is( _.strHas( o.output,  _.fileProvider.path.nativize( routinePath ) ) );
      test.is( _.strHas( o.output,  `[ '--no-warnings' ]` ) );

      return null;
    })
  })

  /* - */

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
    test.is( _.strHas( o.output,  `[ 'arg1', 'arg2' ]` ) );
    test.is( _.strHas( o.output,  `key1: 'val'` ) );
    test.is( _.strHas( o.output,  _.fileProvider.path.nativize( routinePath ) ) );
    test.is( _.strHas( o.output,  `[ '--no-warnings' ]` ) );

    return null;
  })

  /* - */

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
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
    time = _.time.now();
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

function shellSpawnSyncDeasync( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    got.thenKeep( function( o )
    {
      test.identical( o.exitCode, 0 );
      return o;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 1,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got, o );
    test.identical( o.exitCode, 0 );

    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    got.thenKeep( function( o )
    {
      test.identical( o.exitCode, 0 );
      return o;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 1,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got, o );
    test.identical( o.exitCode, 0 );
    return got;
  })

  /*  */

  return ready;
}

shellSpawnSyncDeasync.timeOut = 15000;

//

function shellSpawnSyncDeasyncThrowing( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    throw new Error( 'Test error' );
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    return test.shouldThrowErrorAsync( got );
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    return test.shouldThrowErrorAsync( got );
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'spawn',
      sync : 1,
      deasync : 1
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  return ready;
}

shellSpawnSyncDeasyncThrowing.timeOut = 15000;

//

function shellShellSyncDeasync( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    got.thenKeep( function( o )
    {
      test.identical( o.exitCode, 0 );
      return o;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 1,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got, o );
    test.identical( o.exitCode, 0 );

    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    got.thenKeep( function( o )
    {
      test.identical( o.exitCode, 0 );
      return o;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 1,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got, o );
    test.identical( o.exitCode, 0 );
    return got;
  })

  /*  */

  return ready;
}

shellShellSyncDeasync.timeOut = 15000;

//

function shellShellSyncDeasyncThrowing( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    throw new Error( 'Test error' );
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    return test.shouldThrowErrorAsync( got );
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    return test.shouldThrowErrorAsync( got );
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + execPath,
      mode : 'shell',
      sync : 1,
      deasync : 1
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  return ready;
}

shellShellSyncDeasyncThrowing.timeOut = 15000;

//

function shellForkSyncDeasync( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    got.thenKeep( function( o )
    {
      test.identical( o.exitCode, 0 );
      return o;
    })
    return got;
  })

  /*  */

  if( Config.debug )
  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () => _.process.start( o ) )
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    got.thenKeep( function( o )
    {
      test.identical( o.exitCode, 0 );
      return o;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 1,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got, o );
    test.identical( o.exitCode, 0 );
    return got;
  })

  /*  */

  return ready;
}

shellForkSyncDeasync.timeOut = 15000;

//

function shellForkSyncDeasyncThrowing( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    throw new Error( 'Test error' );
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    return test.shouldThrowErrorAsync( got );
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    return test.shouldThrowErrorAsync( got );
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath,
      mode : 'fork',
      sync : 1,
      deasync : 1
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  return ready;
}

shellForkSyncDeasyncThrowing.timeOut = 15000;

//

// function shellExecSyncDeasync( test )
// {
//   let context = this;
//   var routinePath = _.path.join( context.suiteTempPath, test.name );
//
//   /* */
//
//   function testApp()
//   {
//     console.log( process.argv.slice( 2 ) );
//   }
//
//   /* */
//
//   var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
//   var testAppCode = testApp.toString() + '\ntestApp();';
//   _.fileProvider.fileWrite( execPath, testAppCode );
//
//   /* - */
//
//   var ready = new _.Consequence().take( null );
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:0,desync:0'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 0,
//       deasync : 0
//     }
//     var got = _.process.start( o );
//     test.is( _.consequenceIs( got ) );
//     test.identical( got.resourcesCount(), 0 );
//     got.thenKeep( function( o )
//     {
//       test.identical( o.exitCode, 0 );
//       return o;
//     })
//     return got;
//   })
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:1,desync:0'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 1,
//       deasync : 0
//     }
//     var got = _.process.start( o );
//     test.is( !_.consequenceIs( got ) );
//     test.identical( got, o );
//     test.identical( o.exitCode, 0 );
//
//     return got;
//   })
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:0,desync:1'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 0,
//       deasync : 1
//     }
//     var got = _.process.start( o );
//     test.is( _.consequenceIs( got ) );
//     test.identical( got.resourcesCount(), 1 );
//     got.thenKeep( function( o )
//     {
//       test.identical( o.exitCode, 0 );
//       return o;
//     })
//     return got;
//   })
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:1,desync:1'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 1,
//       deasync : 1
//     }
//     var got = _.process.start( o );
//     test.is( !_.consequenceIs( got ) );
//     test.identical( got, o );
//     test.identical( o.exitCode, 0 );
//     return got;
//   })
//
//   /*  */
//
//   return ready;
// }
//
// shellExecSyncDeasync.timeOut = 15000;
//
// //
//
// function shellExecSyncDeasyncThrowing( test )
// {
//   let context = this;
//   var routinePath = _.path.join( context.suiteTempPath, test.name );
//
//   /* */
//
//   function testApp()
//   {
//     throw new Error( 'Test error' );
//   }
//
//   /* */
//
//   var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
//   var testAppCode = testApp.toString() + '\ntestApp();';
//   _.fileProvider.fileWrite( execPath, testAppCode );
//
//   /* - */
//
//   var ready = new _.Consequence().take( null );
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:0,desync:0'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 0,
//       deasync : 0
//     }
//     var got = _.process.start( o );
//     test.is( _.consequenceIs( got ) );
//     test.identical( got.resourcesCount(), 0 );
//     return test.shouldThrowErrorAsync( got );
//   })
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:1,desync:0'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 1,
//       deasync : 0
//     }
//     test.shouldThrowErrorSync( () =>  _.process.start( o ) );
//     return null;
//   })
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:0,desync:1'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 0,
//       deasync : 1
//     }
//     var got = _.process.start( o );
//     test.is( _.consequenceIs( got ) );
//     test.identical( got.resourcesCount(), 1 );
//     return test.shouldThrowErrorAsync( got );
//   })
//
//   /*  */
//
//   ready.then( () =>
//   {
//     test.case = 'sync:1,desync:1'
//     let o =
//     {
//       execPath : 'node ' + execPath,
//       mode : 'exec',
//       sync : 1,
//       deasync : 1
//     }
//     test.shouldThrowErrorSync( () =>  _.process.start( o ) );
//     return null;
//   })
//
//   /*  */
//
//   return ready;
// }
//
// shellExecSyncDeasyncThrowing.timeOut = 15000;

//

function shellMultipleSyncDeasync( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) )
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'spawn',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    got.thenKeep( function( result )
    {
      test.identical( result.length, 2 );
      test.identical( result[ 0 ].exitCode, 0 )
      test.identical( result[ 1 ].exitCode, 0 )
      return result;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'spawn',
      sync : 1,
      returningOptionsArray : 1,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.length, 2 );
    test.identical( got[ 0 ].exitCode, 0 )
    test.identical( got[ 1 ].exitCode, 0 )
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'spawn',
      sync : 1,
      returningOptionsArray : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.exitCode, 0 )
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'spawn',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    got.thenKeep( function( result )
    {
      test.identical( result.length, 2 );
      test.identical( result[ 0 ].exitCode, 0 )
      test.identical( result[ 1 ].exitCode, 0 )
      return result;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'spawn',
      sync : 1,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.length, 2 );
    test.identical( got[ 0 ].exitCode, 0 )
    test.identical( got[ 1 ].exitCode, 0 )
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'shell',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    got.thenKeep( function( result )
    {
      test.identical( result.length, 2 );
      test.identical( result[ 0 ].exitCode, 0 )
      test.identical( result[ 1 ].exitCode, 0 )
      return result;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'shell',
      sync : 1,
      returningOptionsArray : 1,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.length, 2 );
    test.identical( got[ 0 ].exitCode, 0 )
    test.identical( got[ 1 ].exitCode, 0 )
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'shell',
      sync : 1,
      returningOptionsArray : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.exitCode, 0 )
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : [ 'node ' + execPath, 'node ' + execPath ],
      mode : 'shell',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    got.thenKeep( function( result )
    {
      test.identical( result.length, 2 );
      test.identical( result[ 0 ].exitCode, 0 )
      test.identical( result[ 1 ].exitCode, 0 )
      return result;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : [ execPath, execPath ],
      mode : 'fork',
      sync : 1,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.length, 2 );
    test.identical( got[ 0 ].exitCode, 0 )
    test.identical( got[ 1 ].exitCode, 0 )
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : [ execPath, execPath ],
      mode : 'fork',
      sync : 0,
      deasync : 0
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 0 );
    got.thenKeep( function( result )
    {
      test.identical( result.length, 2 );
      test.identical( result[ 0 ].exitCode, 0 )
      test.identical( result[ 1 ].exitCode, 0 )
      return result;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : [ execPath, execPath ],
      mode : 'fork',
      sync : 1,
      returningOptionsArray : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () => _.process.start( o ) );
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : [ execPath, execPath ],
      mode : 'fork',
      sync : 1,
      returningOptionsArray : 0,
      deasync : 0
    }
    test.shouldThrowErrorSync( () => _.process.start( o ) );
    return null;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : [ execPath, execPath ],
      mode : 'fork',
      sync : 0,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    test.identical( got.resourcesCount(), 1 );
    got.thenKeep( function( result )
    {
      test.identical( result.length, 2 );
      test.identical( result[ 0 ].exitCode, 0 )
      test.identical( result[ 1 ].exitCode, 0 )
      return result;
    })
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : [ execPath, execPath ],
      mode : 'fork',
      sync : 1,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.length, 2 );
    test.identical( got[ 0 ].exitCode, 0 )
    test.identical( got[ 1 ].exitCode, 0 )
    return got;
  })

  /*  */

  ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : [ execPath, execPath ],
      mode : 'fork',
      sync : 1,
      deasync : 1
    }
    var got = _.process.start( o );
    test.is( !_.consequenceIs( got ) );
    test.identical( got.length, 2 );
    test.identical( got[ 0 ].exitCode, 0 )
    test.identical( got[ 1 ].exitCode, 0 )
    return got;
  })

  /*  */

  // ready.then( () =>
  // {
  //   test.case = 'sync:0,desync:0'
  //   let o =
  //   {
  //     execPath : [ 'node ' + execPath, 'node ' + execPath ],
  //     mode : 'exec', /* qqq : change mode here */
  //     sync : 0,
  //     deasync : 0
  //   }
  //   var got = _.process.start( o );
  //   test.is( _.consequenceIs( got ) );
  //   test.identical( got.resourcesCount(), 0 );
  //   got.thenKeep( function( result )
  //   {
  //     test.identical( result.length, 2 );
  //     test.identical( result[ 0 ].exitCode, 0 )
  //     test.identical( result[ 1 ].exitCode, 0 )
  //     return result;
  //   })
  //   return got;
  // })
  //
  // /*  */
  //
  // ready.then( () =>
  // {
  //   test.case = 'sync:1,desync:0'
  //   let o =
  //   {
  //     execPath : [ 'node ' + execPath, 'node ' + execPath ],
  //     mode : 'exec', /* qqq : change mode here */
  //     sync : 1,
  //     returningOptionsArray : 1,
  //     deasync : 0
  //   }
  //   var got = _.process.start( o );
  //   test.is( !_.consequenceIs( got ) );
  //   test.identical( got.length, 2 )
  //   test.identical( got[ 0 ].exitCode, 0 )
  //   test.identical( got[ 1 ].exitCode, 0 )
  //   return null;
  // })
  //
  // /*  */
  //
  // ready.then( () =>
  // {
  //   test.case = 'sync:1,desync:0'
  //   let o =
  //   {
  //     execPath : [ 'node ' + execPath, 'node ' + execPath ],
  //     mode : 'exec', /* qqq : change mode here */
  //     sync : 1,
  //     returningOptionsArray : 0,
  //     deasync : 0
  //   }
  //   var got = _.process.start( o );
  //   test.is( !_.consequenceIs( got ) );
  //   test.identical( got.exitCode, 0 )
  //   return null;
  // })
  //
  // /*  */
  //
  // ready.then( () =>
  // {
  //   test.case = 'sync:0,desync:1'
  //   let o =
  //   {
  //     execPath : [ 'node ' + execPath, 'node ' + execPath ],
  //     mode : 'exec',
  //     sync : 0,
  //     deasync : 1
  //   }
  //   var got = _.process.start( o );
  //   test.is( _.consequenceIs( got ) );
  //   test.identical( got.resourcesCount(), 1 );
  //   got.thenKeep( function( result )
  //   {
  //     test.identical( result.length, 2 );
  //     test.identical( result[ 0 ].exitCode, 0 )
  //     test.identical( result[ 1 ].exitCode, 0 )
  //     return result;
  //   })
  //   return got;
  // })
  //
  // /*  */
  //
  // ready.then( () =>
  // {
  //   test.case = 'sync:1,desync:1'
  //   let o =
  //   {
  //     execPath : [ 'node ' + execPath, 'node ' + execPath ],
  //     mode : 'exec',
  //     sync : 1,
  //     deasync : 1
  //   }
  //   var got = _.process.start( o );
  //   test.is( !_.consequenceIs( got ) );
  //   test.identical( got.length, 2 );
  //   test.identical( got[ 0 ].exitCode, 0 )
  //   test.identical( got[ 1 ].exitCode, 0 )
  //   return got;
  // })

  /*  */

  return ready;
}

shellMultipleSyncDeasync.timeOut = 30000;

//

function shellDryRun( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    var fs = require( 'fs' );
    var path = require( 'path' );
    var filePath = path.join( __dirname, 'file' );
    fs.writeFileSync( filePath, filePath );
  }

  /* */

  var execPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( execPath, testAppCode );

  /* - */

  var ready = new _.Consequence().take( null );

  /*  */

  ready.then( () =>
  {
    test.case = 'trivial'
    let o =
    {
      execPath : 'node ' + execPath + ` arg1 "arg 2" "'arg3'"`,
      mode : 'spawn',
      args : [ 'arg0' ],
      sync : 0,
      dry : 1,
      deasync : 0,
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 1,
      applyingExitCode : 1,
      timeOut : 100,
      ipc : 1,
      when : { delay : 1000 }
    }
    var t1 = _.time.now();
    var got = _.process.start( o );
    test.is( _.consequenceIs( got ) );
    got.thenKeep( function( o )
    {
      var t2 = _.time.now();
      test.ge( t2 - t1, 1000 )

      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, null );
      test.identical( o.process, null );
      test.identical( o.stdio, [ 'pipe', 'pipe', 'pipe', 'ipc' ] );
      test.identical( o.fullExecPath, `node ${execPath} arg1 arg 2 'arg3' arg0` );
      test.identical( o.output, '' );

      test.is( !_.fileProvider.fileExists( _.path.join( routinePath, 'file' ) ) )

      return null;
    })
    return got;
  })

  /*  */

  return ready;
}

//

function startWithReadyDelayStructural( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( program1 );

  a.ready.timeOut( 1000 );

  /* */

  let options =
  {
    execPath : programPath,
    currentPath : a.currentPath,
    throwingExitCode : 1,
    inputMirroring : 1,
    outputCollecting : 1,
    stdio : 'pipe',
    sync : 0,
    deasync : 0,
    ready : a.ready,
  }

  _.process.startNjs( options )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.output, 'program1:begin\n' );

    let exp2 = _.mapExtend( null, exp );
    exp2.output = 'program1:begin\n';
    exp2.exitCode = 0;
    exp2.exitSignal = null;
    exp2.disconnect = options.disconnect;
    exp2.process = options.process;
    exp2.procedure = options.procedure;
    // exp2.procedureIsNew = true;
    exp2.currentPath = _.path.current();
    exp2.args = [];
    exp2.interpreterArgs = [];
    exp2.outputPiping = true;
    exp2.outputAdditive = true;
    exp2.state = 'terminated';
    exp2.terminationReason = 'normal';
    exp2.fullExecPath = programPath;
    exp2.ended = true;

    test.identical( options, exp2 );
    test.identical( !!options.process, true );
    test.is( _.routineIs( options.disconnect ) );
    test.is( options.onTerminate === options.ready );
    test.identical( options.ready.exportString(), 'Consequence::startWithReadyDelayStructural 0 / 2' );
    test.identical( options.onTerminate.exportString(), 'Consequence::startWithReadyDelayStructural 0 / 2' );
    test.identical( options.onStart.exportString(), 'Consequence:: 1 / 0' );

    return null;
  });

  var exp =
  {
    'execPath' : a.abs( 'program1.js' ),
    'currentPath' : null,
    'throwingExitCode' : 1,
    'inputMirroring' : 1,
    'outputCollecting' : 1,
    'sync' : 0,
    'deasync' : 0,
    'passingThrough' : 0,
    'maximumMemory' : 0,
    'applyingExitCode' : 1,
    'stdio' : 'pipe',
    'mode' : 'fork',
    'args' : null,
    'interpreterArgs' : '',
    'when' : 'instant',
    'dry' : 0,
    'logger' : null,
    'ipc' : 0,
    'env' : null,
    'detaching' : 0,
    'windowHiding' : 1,
    'concurrent' : 0,
    'timeOut' : null,
    'returningOptionsArray' : 1,
    'briefExitCode' : 0,
    'verbosity' : 2,
    'outputPrefixing' : 0,
    'outputPiping' : null,
    'outputAdditive' : null,
    'outputDecorating' : 0,
    'outputDecoratingStdout' : 0,
    'outputDecoratingStderr' : 0,
    'outputGraying' : 0,
    'onStart' : options.onStart,
    'onTerminate' : options.onTerminate,
    'onDisconnect' : options.onDisconnect,
    'ready' : options.ready,
    'disconnect' : options.disconnect,
    'process' : options.process,
    'logger' : options.logger,
    'state' : 'initial',
    'terminationReason' : null,
    'fullExecPath' : null,
    'output' : null,
    'exitCode' : null,
    'exitSignal' : null,
    'procedure' : null,
    // 'procedureIsNew' : null,
    'ended' : false,
    'terminationBeginEnabled' : false,
    'error' : null
  }
  test.identical( options, exp );

  test.identical( options.process, null );
  test.is( _.routineIs( options.disconnect ) );
  test.is( options.onTerminate === options.ready );
  test.identical( options.ready.exportString(), 'Consequence:: 0 / 3' );
  test.identical( options.onTerminate.exportString(), 'Consequence:: 0 / 3' );
  test.identical( options.onStart.exportString(), 'Consequence:: 0 / 0' );

  /* */

  return a.ready;

  /* */

  function program1()
  {
    let _ = require( toolsPath );
    console.log( 'program1:begin' );
  }

}

startWithReadyDelayStructural.description =
`
 - ready has delay
 - value of o-context is correct before start
 - value of o-context is correct after start
`

//

function shellArgsOption( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );

  /* */

  ready.then( () =>
  {
    test.case = 'args option as array, source args array should not be changed'
    var args = [ 'arg1', 'arg2' ];
    var shellOptions =
    {
      execPath : 'node ' + testAppPath,
      outputCollecting : 1,
      args,
      mode : 'spawn',
    }

    let con = _.process.start( shellOptions )

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.args, [ testAppPath, 'arg1', 'arg2' ] );
      test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
      test.identical( shellOptions.args, got.args );
      test.identical( args, [ 'arg1', 'arg2' ] );
      return null;
    })

    return con;
  })

  /* */

  ready.then( () =>
  {
    test.case = 'args option as string'
    var args = 'arg1'
    var shellOptions =
    {
      execPath : 'node ' + testAppPath,
      outputCollecting : 1,
      args,
      mode : 'spawn',
    }

    let con = _.process.start( shellOptions )

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.args, [ testAppPath, 'arg1' ] );
      test.identical( _.strCount( got.output, 'arg1' ), 1 );
      test.identical( shellOptions.args, got.args );
      test.identical( args, 'arg1' );
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

shellArgsOption.timeOut = 30000;

//

/*
qqq : split shellArgumentsParsing and similar test routine
a test routine per mode
*/

function shellArgumentsParsing( test )
{
  let context = this;
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPathNoSpace = _.fileProvider.path.nativize( _.path.join( routinePath, 'noSpace', 'testApp.js' ) );
  let testAppPathSpace = _.fileProvider.path.nativize( _.path.join( routinePath, 'with space', 'testApp.js' ) );
  let ready = _.Consequence().take( null );

  let testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPathNoSpace, testAppCode );
  _.fileProvider.fileWrite( testAppPathSpace, testAppCode );

  /* for combination:
      path to exe file : [ with space, without space ]
      execPath : [ has arguments, only path to exe file ]
      args : [ has arguments, empty ]
      mode : [ 'fork', 'spawn', 'shell' ]
  */

  /* - */

  ready

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : has arguments' 'args has arguments' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : has arguments' 'args has arguments' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args has arguments' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : only path' 'args has arguments' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : has arguments' 'args: empty' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : has arguments' 'args: empty' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args: empty' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : only path' 'args: empty' 'fork'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  /* - end of fork - */ /* qqq : split test routine by modes */

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : has arguments' 'args has arguments' 'exec'`

    let con = new _.Consequence().take( null );

    if( !Config.debug )
    return con;

    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
      args : [ '\'fourth arg\'',  `"fifth" arg` ],
      mode : 'exec',
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }

    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : has arguments' 'args has arguments' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : has arguments' 'args has arguments' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args has arguments' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : only path' 'args has arguments' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : has arguments' 'args: empty' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : has arguments' 'args: empty' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args: empty' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : only path' 'args: empty' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : has arguments' 'args has arguments' 'shell'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )
      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : has arguments' 'args has arguments' 'shell'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args has arguments' 'shell'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : only path' 'args has arguments' 'shell'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : has arguments' 'args: empty' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' \'"fifth" arg\'',
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : has arguments' 'args: empty' 'shell'`

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' \'"fifth" arg\'',
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, { secondArg : '1 "third arg" "fourth arg" "fifth" arg' } )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args: empty' 'shell'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  .then( () =>
  {
    test.case = `'path to exec : without space' 'execPATH : only path' 'args: empty' 'shell'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathNoSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [] )

      return null;
    })

    return con;
  })

  /* special case from willbe */

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args: willbe args' 'fork'`

    debugger;
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
      debugger;
      test.identical( o.exitCode, 0 );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) );
      test.identical( got.map, { v : 1 } );
      test.identical( got.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] );

      return null;
    })

    return con;
  })

  // xxx
  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args: willbe args' 'spawn'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { v : 1 } )
      test.identical( got.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

      return null;
    })

    return con;
  })

  //

  .then( () =>
  {
    test.case = `'path to exec : with space' 'execPATH : only path' 'args: willbe args' 'shell'`

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    debugger;
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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
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

  // xxx qqq : repair?
  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`',
  //     args : '"some arg"',
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, 'node' );
  //     test.identical( o.args, [ testAppPathSpace, 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
  //     let got = JSON.parse( o.output );
  //     test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( got.map, {} )
  //     test.identical( got.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

  //     return null;
  //   })

  //   return con;
  // })

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node ' + _.strQuote( testAppPathSpace ) + ` 'firstArg secondArg \":\" 1' "third arg" 'fourth arg'  '\"fifth\" arg'`,
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
      test.identical( o.args, [ _.strQuote( testAppPathSpace ), `'firstArg secondArg \":\" 1'`, `"third arg"`, `'fourth arg'`, `'\"fifth\" arg'`, '"some arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      if( process.platform === 'win32' )
      test.identical( got.scriptArgs, [ `'firstArg`, `secondArg`, ':', `1'`, 'third arg', `'fourth`, `arg'`, `'fifth`, `arg'`, '"some arg"' ] )
      else
      test.identical( got.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

      return null;
    })

    return con;
  })

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'
  //
  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ` 'firstArg secondArg \":\" 1' "third arg" 'fourth arg'  '\"fifth\" arg'`,
  //     args : '"some arg"',
  //     mode : 'exec', /* qqq : change mode here */
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, 'node' );
  //     test.identical( o.args, [ _.strQuote( testAppPathSpace ), `'firstArg secondArg \":\" 1'`, `"third arg"`, `'fourth arg'`, `'\"fifth\" arg'`, '"some arg"' ] );
  //     let got = JSON.parse( o.output );
  //     test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( got.map, {} )
  //     if( process.platform === 'win32' )
  //     test.identical( got.scriptArgs, [ `'firstArg`, `secondArg`, ':', `1'`, 'third arg', `'fourth`, `arg'`, `'fifth`, `arg'`, '"some arg"' ] )
  //     else
  //     test.identical( got.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )
  //
  //     return null;
  //   })
  //
  //   return con;
  // })

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : '1 "third arg"' } )
      test.identical( got.subject, 'firstArg' )
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
      test.identical( o.args, [ _.strQuote( testAppPathSpace ), 'firstArg', 'secondArg:1', '"third arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : '1 "third arg"' } )
      test.identical( got.subject, 'firstArg' )
      test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

      return null;
    })

    return con;
  })

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'
  //
  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
  //     args : '"third arg"',
  //     mode : 'exec', /* qqq : change mode here */
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, 'node' );
  //     test.identical( o.args, [ _.strQuote( testAppPathSpace ), 'firstArg', 'secondArg:1', '"third arg"' ] );
  //     let got = JSON.parse( o.output );
  //     test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( got.map, { secondArg : '1 "third arg"' } )
  //     test.identical( got.subject, 'firstArg' )
  //     test.identical( got.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )
  //
  //     return null;
  //   })
  //
  //   return con;
  // })

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { secondArg : '1 "third arg"' } )
      test.identical( got.subject, 'firstArg' )
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

    con.finally( ( err, got ) => /* qqq2 : should be ( err, op ) or ( err, arg ) not got */
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

  .then( () =>
  {
    test.case = 'args in execPath and args options'

    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : _.strQuote( testAppPathSpace ) + ` "path/key3":'val3'`,
      args : [],
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
      test.identical( o.args, [ `"path/key3":'val3'` ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { 'path/key3' : 'val3' } )
      test.identical( got.subject, '' )
      test.identical( got.scriptArgs, [ `"path/key3":'val3'` ] )

      return null;
    })

    return con;
  })

  /*  */

  return ready;


  /**/

  function testApp()
  {
    _.include( 'wProcess' );
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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      let scriptArgs =
      [
        `'s-s'`, `"s-d"`, `\`s-b\``,
        `'d-s'`, `"d-d"`, `\`d-b\``,
        `'b-s'`, `"b-d"`, `\`b-b\``,
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      let scriptArgs =
      [
        `'s-s'`, `"s-d"`, `\`s-b\``,
        `'d-s'`, `"d-d"`, `\`d-b\``,
        `'b-s'`, `"b-d"`, `\`b-b\``,
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, args )

      return null;
    })

    return con;

  })

  .then( () =>
  {
    test.case = 'shell'
    // qqq : review this case
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
      if( process.platform === 'win32' )
      {
        let got = JSON.parse( o.output );
        test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
        test.identical( got.map, {} )
        let scriptArgs =
        [
          '\'\'s-s\'\'',
          '\'s-d\'',
          '\'`s-b`\'',
          '\'d-s\'',
          'd-d',
          '`d-b`',
          '`\'b-s\'`',
          '\`b-d`',
          '``b-b``'
        ]
        test.identical( got.scriptArgs, scriptArgs )
      }
      else
      {
        test.identical( _.strCount( o.output, 'not found' ), 3 );
      }

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, args )

      return null;
    })

    return con;
  })

  // .then( () =>
  // {
  //   test.case = 'exec'
  //
  //   //qqq : review this case
  //
  //   let con = new _.Consequence().take( null );
  //   let args =
  //   [
  //     ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
  //     ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
  //     ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
  //   ]
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ),
  //     mode : 'exec',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     if( process.platform === 'win32' )
  //     {
  //       let got = JSON.parse( o.output );
  //       test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
  //       test.identical( got.map, {} )
  //       let scriptArgs =
  //       [
  //         '\'\'s-s\'\'',
  //         '\'s-d\'',
  //         '\'`s-b`\'',
  //         '\'d-s\'',
  //         'd-d',
  //         '`d-b`',
  //         '`\'b-s\'`',
  //         '\`b-d`',
  //         '``b-b``'
  //       ]
  //       test.identical( got.scriptArgs, scriptArgs )
  //     }
  //     else
  //     {
  //       test.identical( _.strCount( o.output, 'not found' ), 3 );
  //     }
  //
  //     return null;
  //   })
  //
  //   return con;
  //
  // })
  //
  // .then( () =>
  // {
  //   test.case = 'exec'
  //
  //   let con = new _.Consequence().take( null );
  //   let args =
  //   [
  //     ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
  //     ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
  //     ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
  //   ]
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ),
  //     args : args.slice(),
  //     mode : 'exec',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let got = JSON.parse( o.output );
  //     test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( got.map, {} )
  //     test.identical( got.scriptArgs, args )
  //
  //     return null;
  //   })
  //
  //   return con;
  //
  // })

  /* */

  return ready;

  /**/

  function testApp()
  {
    _.include( 'wProcess' );
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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( o.args, [ testAppPathSpace, 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' "arg"' );
      test.identical( o.args, [ _.strQuote( testAppPathSpace ), '"arg"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  // .then( () =>
  // {
  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' "arg"',
  //     mode : 'exec',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' "arg"' );
  //     test.identical( o.args, [ _.strQuote( testAppPathSpace ), '"arg"' ] );
  //     let got = JSON.parse( o.output );
  //     test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( got.map, {} )
  //     test.identical( got.scriptArgs, [ 'arg' ] )
  //
  //     return null;
  //   })
  //
  //   return con;
  // })

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( o.args, [ testAppPathSpace, 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( o.args, [ _.strQuote( testAppPathSpace ), 'arg' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, {} )
      test.identical( got.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  // .then( () =>
  // {
  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' arg',
  //     mode : 'exec',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' arg' );
  //     test.identical( o.args, [ _.strQuote( testAppPathSpace ), 'arg' ] );
  //     let got = JSON.parse( o.output );
  //     test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( got.map, {} )
  //     test.identical( got.scriptArgs, [ 'arg' ] )
  //
  //     return null;
  //   })
  //
  //   return con;
  // })

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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
    return test.mustNotThrowError( _.process.start( o ) );
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
    // _.process.start( o )

    // con.then( () =>
    // {
    //   test.identical( o.exitCode, 0 );
    //   test.identical( o.fullExecPath, testAppPathSpace + ' arg"' );
    //   test.identical( o.args, [ 'arg"' ] );
    //   let got = JSON.parse( o.output );
    //   test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
    //   test.identical( got.map, {} )
    //   test.identical( got.scriptArgs, [ 'arg"' ] )

    //   return null;
    // })

    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) );
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
    // _.process.start( o );

    // con.then( () =>
    // {
    //   test.identical( o.exitCode, 0 );
    //   test.identical( o.fullExecPath, testAppPathSpace + ' arg"arg' );
    //   test.identical( o.args, [ 'arg"arg' ] );
    //   let got = JSON.parse( o.output );
    //   test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
    //   test.identical( got.map, {} )
    //   test.identical( got.scriptArgs, [ 'arg"arg' ] )

    //   return null;
    // })

    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) );
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
    // _.process.start( o );

    // con.then( () =>
    // {
    //   test.identical( o.exitCode, 0 );
    //   test.identical( o.fullExecPath, testAppPathSpace + ' option:"value' );
    //   test.identical( o.args, [ 'option:"value' ] );
    //   let got = JSON.parse( o.output );
    //   test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
    //   test.identical( got.map, { option : '"value' } )
    //   test.identical( got.scriptArgs, [ 'option:"value' ] )

    //   return null;
    // })

    return test.shouldThrowErrorOfAnyKind( _.process.start( o ) );
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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

    con.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.fullExecPath, testAppPathSpace + ' "option: "value with space""' );
      test.identical( o.args, [ '"option: "value', 'with', 'space""' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value with space' } )
      test.identical( got.scriptArgs,  [ '"option: "value', 'with', 'space""' ] )

      return null;
    })

    return con
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
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
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
      test.identical( o.fullExecPath, 'node ' + _.strQuote( testAppPathSpace ) + ' option: \\"value with space\\"' );
      test.identical( o.args, [ _.strQuote( testAppPathSpace ), 'option:', '\\"value with space\\"' ] );
      let got = JSON.parse( o.output );
      test.identical( got.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( got.map, { option : 'value with space' } )
      test.identical( got.scriptArgs, [ 'option:', '"value', 'with', 'space"' ] )

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
    _.include( 'wProcess' );
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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPath =  _.fileProvider.path.nativize( _.path.join( routinePath, 'app.js' ) );

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

  /* - */

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

  /* - */

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

  /* -- */

  // testcase( 'quoted, mode:exec' )
  //
  // .then( () =>
  // {
  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node app.js arg1 && node app.js arg2',
  //     mode : 'exec',
  //     currentPath : routinePath,
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( ( got ) =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( _.strCount( got.output, `[ 'arg1' ]` ), 1 );
  //     test.identical( _.strCount( got.output, `[ 'arg2' ]` ), 1 );
  //     return null;
  //   })
  //
  //   return con;
  // })

  /* - */

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

  /* - */

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

  /* - */

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

  /* - */

  // testcase( 'no quotes, mode:exec' )
  //
  // .then( () =>
  // {
  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node app.js arg1 && node app.js arg2',
  //     mode : 'exec',
  //     currentPath : routinePath,
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );
  //
  //   con.then( ( got ) =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( _.strCount( got.output, `[ 'arg1' ]` ), 1 );
  //     test.identical( _.strCount( got.output, `[ 'arg2' ]` ), 1 );
  //     return null;
  //   })
  //
  //   return con;
  // })

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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
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
    ready
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
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
    outputDecorating : 1,
    logger : captureLogger,
    ready
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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    throw new Error( 'Error message from child' )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var expectedOutput = __dirname + '\n'
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* - */

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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    throw new Error( 'Error message from child' );
  }

  function testApp2()
  {
    console.log( process.argv.slice( 2 ) )
  }


  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  var testAppCode2 = testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var con = new _.Consequence().take( null );

  /* */

  con.then( () =>
  {
    test.case = 'execPath contains normalized path'
    return _.process.startNjs
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

  // let modes = [ 'fork', 'exec', 'spawn', 'shell' ];
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath, mode, applyingExitCode : 1, throwingExitCode : 1, stdio : 'ignore' };
      var con = _.process.startNjs( o );
      return test.shouldThrowErrorAsync( con )
      .finally( () =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 1 );
        process.exitCode = 0;
        return true;
      })
    })

    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath, mode,  applyingExitCode : 1, throwingExitCode : 0, stdio : 'ignore' };
      return _.process.startNjs( o )
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
      var o = { execPath : testAppPath,  mode, applyingExitCode : 0, throwingExitCode : 1, stdio : 'ignore' };
      var con = _.process.startNjs( o )
      return test.shouldThrowErrorAsync( con )
      .finally( () =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        return true;
      })
    })

    con.thenKeep( () =>
    {
      var o = { execPath : testAppPath,  mode, applyingExitCode : 0, throwingExitCode : 0, stdio : 'ignore' };
      return _.process.startNjs( o )
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
      var o = { execPath : testAppPath,  mode, maximumMemory : 1, applyingExitCode : 0, throwingExitCode : 0, stdio : 'ignore' };
      return _.process.startNjs( o )
      .finally( ( err, got ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        let spawnArgs = _.toStr( o.process.spawnargs, { levels : 99 } );
        test.is( _.strHasAll( spawnArgs, [ '--expose-gc',  '--stack-trace-limit=999', '--max_old_space_size=' ] ) )
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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPath =  _.fileProvider.path.nativize( _.path.join( routinePath, 'app.js' ) );

  function app()
  {
    var fs = require( 'fs' );
    fs.writeFileSync( 'args', JSON.stringify( process.argv.slice( 2 ) ) )
    console.log( process.argv.slice( 2 ) )
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
    ready
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

  shell({ execPath : '"node -v && node -v"', throwingExitCode : 0 })
  .then( ( got ) =>
  {
    if( process.platform ==='win32' )
    {
      test.identical( got.exitCode, 0 );
      test.identical( _.strCount( got.output, process.version ), 2 );
    }
    else
    {
      test.notIdentical( got.exitCode, 0 );
      test.identical( _.strCount( got.output, process.version ), 0 );
    }

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

  shell({ args : [ 'node -v && node -v' ] })
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
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ 'node -v', '&&', 'node -v' ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, process.version ), 2 );
    return null;
  })

  ready.then( () =>
  {
    test.close( 'two commands' );
    return null;
  })

  // /*  */

  ready.then( () =>
  {
    test.open( 'argument with space' );
    return null;
  })

  shell( 'node ' + testAppPath + ' arg with space' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg', 'with', 'space' ]` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ' "arg with space"' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg with space' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : 'arg with space' })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg with space' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : [ 'arg with space' ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.identical( _.strCount( got.output, `[ 'arg with space' ]` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ' `"quoted arg with space"`' )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    if( process.platform === 'win32' )
    test.identical( _.strCount( got.output, `[ '\`quoted arg with space\`' ]` ), 1 );
    else
    test.identical( _.strCount( got.output, `not found` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ` \\\`'quoted arg with space'\\\`` )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    // test.identical( _.strCount( got.output, `[ "'quoted arg with space'" ]` ), 1 );
    let args = _.fileProvider.fileRead({ filePath : _.path.join( routinePath, 'args' ), encoding : 'json' });
    if( process.platform === 'win32' )
    test.identical( args, [ '\\`\'quoted', 'arg', 'with', 'space\'\\`' ] );
    else
    test.identical( args, [ '`quoted arg with space`' ] );
    return null;
  })

  shell( 'node ' + testAppPath + ` '\`quoted arg with space\`'` )
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    let args = _.fileProvider.fileRead({ filePath : _.path.join( routinePath, 'args' ), encoding : 'json' });
    if( process.platform === 'win32' )
    test.identical( args, [ `\'\`quoted`, 'arg', 'with', `space\`\'` ] );
    else
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

  // /*  */

  ready.then( () =>
  {
    test.open( 'several arguments' );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath + ` arg1 "arg2" "arg 3" "'arg4'"` })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    // test.identical( _.strCount( got.output, `[ 'arg1', 'arg2', 'arg 3', "'arg4'" ]` ), 1 );
    let args = _.fileProvider.fileRead({ filePath : _.path.join( routinePath, 'args' ), encoding : 'json' });
    test.identical( args, [ 'arg1', 'arg2', 'arg 3', `'arg4'` ] );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : `arg1 "arg2" "arg 3" "'arg4'"` })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    // test.identical( _.strCount( got.output, '[ `arg1 "arg2" "arg 3" "\'arg4\'"` ]' ), 1 );
    let args = _.fileProvider.fileRead({ filePath : _.path.join( routinePath, 'args' ), encoding : 'json' });
    test.identical( args, [ `arg1 "arg2" "arg 3" "\'arg4\'"` ] );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : [ `arg1`, '"arg2"', `arg 3`, `'arg4'` ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    // test.identical( _.strCount( got.output, `[ 'arg1', '"arg2"', 'arg 3', "'arg4'" ]` ), 1 );
    let args = _.fileProvider.fileRead({ filePath : _.path.join( routinePath, 'args' ), encoding : 'json' });
    test.identical( args, [ 'arg1', '"arg2"', 'arg 3', `'arg4'` ] );
    return null;
  })

  ready.then( () =>
  {
    test.close( 'several arguments' );
    return null;
  })

  /*  */

  shell({ execPath : 'echo', args : [ 'a b', '*', 'c' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, `"a b" "*" "c"` ) );
    else
    test.is( _.strHas( op.output, `a b * c` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ 'a b', '*', 'c' ] )
    test.identical( op.fullExecPath, 'echo "a b" "*" "c"' )
    return null;
  })

  return ready;
}

shellModeShellNonTrivial.timeOut = 60000;

//

function shellArgumentsHandlingTrivial( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  _.fileProvider.fileWrite( _.path.join( routinePath, 'file' ), 'file' );

  /* */

  var con = new _.Consequence().take( null );

  let shell = _.process.starter
  ({
    currentPath : routinePath,
    mode : 'shell',
    stdio : 'pipe',
    outputPiping : 1,
    outputCollecting : 1,
    ready : con
  })

  /* */

  shell({ execPath : 'echo *' })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, `*` ) );
    else
    test.is( _.strHas( op.output, `file` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '*' ] )
    test.identical( op.fullExecPath, 'echo *' )
    return null;
  })

  /* */

  return con;
}

//

function shellArgumentsHandling( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  _.fileProvider.fileWrite( _.path.join( routinePath, 'file' ), 'file' );

  /* */

  var con = new _.Consequence().take( null );

  let shell = _.process.starter
  ({
    currentPath : routinePath,
    mode : 'shell',
    stdio : 'pipe',
    outputPiping : 1,
    outputCollecting : 1,
    ready : con
  })

  /* */

  shell({ execPath : 'echo *' })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, `*` ) );
    else
    test.is( _.strHas( op.output, `file` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '*' ] )
    test.identical( op.fullExecPath, 'echo *' )
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : '*' })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `*` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '*' ] )
    test.identical( op.fullExecPath, 'echo "*"' )
    return null;
  })

  /* */

  shell( `echo "*"` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `*` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '"*"' ] )
    test.identical( op.fullExecPath, 'echo "*"' )

    return null;
  })

  /* */

  shell({ execPath : 'echo "a b" "*" c' })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, `"a b" "*" c` ) );
    else
    test.is( _.strHas( op.output, `a b * c` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '"a b"', '"*"', 'c' ] )
    test.identical( op.fullExecPath, 'echo "a b" "*" c' )
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ 'a b', '*', 'c' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, `"a b" "*" "c"` ) );
    else
    test.is( _.strHas( op.output, `a b * c` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ 'a b', '*', 'c' ] )
    test.identical( op.fullExecPath, 'echo "a b" "*" "c"' )
    return null;
  })

  /* */

  shell( `echo '"*"'` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '"*"' ), 1 );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ `'"*"'` ] )
    test.identical( op.fullExecPath, `echo '"*"'` )
    return null;
  })

  /* */

  shell({ execPath : `echo`, args : [ `'"*"'` ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.identical( _.strCount( op.output, `"'\\"*\\"'"` ), 1 );
    else
    test.identical( _.strCount( op.output, '"*"' ), 1 );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ `'"*"'` ] )
    test.identical( op.fullExecPath, `echo "'\\"*\\"'"` )
    return null;
  })

  /* */

  shell( `echo "'*'"` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, `'*'` ), 1 );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ `"'*'"` ] )
    test.identical( op.fullExecPath, `echo "'*'"` )
    return null;
  })

  /* */

  shell({ execPath : `echo`, args : [ `"'*'"` ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, `'*'` ), 1 );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ `"'*'"` ] )
    test.identical( op.fullExecPath, `echo "\\"'*'\\""` )
    return null;
  })

  /* */

  shell( 'echo `*`' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.identical( _.strCount( op.output, '`*`' ), 1 );
    else
    test.identical( _.strCount( op.output, 'Usage:' ), 1 );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '`*`' ] )
    test.identical( op.fullExecPath, 'echo `*`' )
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ '`*`' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '`*`' ), 1 );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '`*`' ] )
    if( process.platform === 'win32' )
    test.identical( op.fullExecPath, 'echo "`*`"' )
    else
    test.identical( op.fullExecPath, 'echo "\\`*\\`"' )
    return null;
  })

  /* */

  shell({ execPath : `node -e "console.log( process.argv.slice( 1 ) )"`, args : [ 'a b c' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `a b c` ) );
    return null;
  })

  /* */

  shell({ execPath : `node -e "console.log( process.argv.slice( 1 ) )"`, args : [ '"a b c"' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `"a b c"` ) );
    test.identical( op.execPath, 'node' )
    test.identical( op.args, [ '-e', '"console.log( process.argv.slice( 1 ) )"', '"a b c"' ] )
    test.identical( op.fullExecPath, 'node -e "console.log( process.argv.slice( 1 ) )" "\\"a b c\\""' )
    return null;
  })

  /* */

  return con;
}

shellArgumentsHandling.timeOut = 30000;

//

function importantModeShell( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
  var printArguments = 'node -e "console.log( process.argv.slice( 1 ) )"'

  _.fileProvider.fileWrite( _.path.join( routinePath, 'file' ), 'file' );

  /* */

  var con = new _.Consequence().take( null );

  let shell = _.process.starter
  ({
    currentPath : routinePath,
    mode : 'shell',
    stdio : 'pipe',
    outputPiping : 1,
    outputCollecting : 1,
    ready : con
  })

  /* */

  shell({ execPath : null, args : [ 'node', '-v', '&&', 'node', '-v' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  /* */

  shell({ execPath : 'node', args : [ '-v', '&&', 'node', '-v' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, process.version ), 1 );
    return null;
  })

  /* */

  shell({ execPath : printArguments, args : [ 'a', '&&', 'node', 'b' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `[ 'a', '&&', 'node', 'b' ]` ) )
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ '-v', '&&', 'echo', '-v' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '"-v" "&&" "echo" "-v"' ) )
    else
    test.is( _.strHas( op.output, '-v && echo -v' ) )
    return null;
  })


  /* */

  shell({ execPath : 'node -v && node -v', args : [] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  /* */

  shell({ execPath : `node -v "&&" node -v`, args : [] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, process.version ), 1 );
    return null;
  })

  shell({ execPath : `echo -v "&&" node -v`, args : [] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '-v "&&" node -v'  ) );
    else
    test.is( _.strHas( op.output, '-v && node -v'  ) );
    return null;
  })


  /* */

  shell({ execPath : null, args : [ 'echo', '*' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.identical( _.strCount( op.output, '*' ), 1 );
    else
    test.identical( _.strCount( op.output, 'file' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ '*' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '*' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : 'echo *' })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.identical( _.strCount( op.output, '*' ), 1 );
    else
    test.identical( _.strCount( op.output, 'file' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : 'echo "*"' })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '*' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ printArguments, 'a b' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `[ 'a', 'b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : printArguments, args : [ 'a b' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `[ 'a b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : `${printArguments} a b` })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `[ 'a', 'b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : `${printArguments} "a b"` })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, `[ 'a b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ 'echo', '"*"' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.is( _.strHas( op.output, '*' ) );
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ '"*"' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '\\"*\\"' ) );
    else
    test.is( _.strHas( op.output, '"*"' ) );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ 'echo', '\\"*\\"' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '\\"*\\"' ) );
    else
    test.is( _.strHas( op.output, '"*"' ) );
    return null;
  })

  /* */

  shell({ execPath : 'echo "\\"*\\""', args : [] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '"\\"*\\"' ) );
    else
    test.is( _.strHas( op.output, '"*"' ) );
    return null;
  })

  /* */

  shell({ execPath : 'echo *', args : [ '*' ] })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    {
      test.is( _.strHas( op.output, '*' ) );
      test.is( _.strHas( op.output, '"*"' ) );
    }
    else
    {
      test.is( _.strHas( op.output, 'file' ) );
      test.is( _.strHas( op.output, '*' ) );
    }

    return null;
  })

  /* */

  shell({ execPath : 'echo', args : null, passingThrough : 1 })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '"' + process.argv.slice( 2 ).join( '" "' ) + '"' ) );
    else
    test.is( _.strHas( op.output, process.argv.slice( 2 ).join( ' ') ) );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ 'echo' ], passingThrough : 1 })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '"' + process.argv.slice( 2 ).join( '" "' ) + '"' ) );
    else
    test.is( _.strHas( op.output, process.argv.slice( 2 ).join( ' ') ) );
    return null;
  })

  /* */

  shell({ execPath : 'echo *', args : [ '*' ], passingThrough : 1 })
  .thenKeep( function( op )
  {
    test.identical( op.exitCode, 0 );

    if( process.platform === 'win32' )
    {
      test.is( _.strHas( op.output, '*' ) );
      test.is( _.strHas( op.output, '"*"' ) );
      test.is( _.strHas( op.output, '"' + process.argv.slice( 2 ).join( '" "' ) + '"' ) );
    }
    else
    {
      test.is( _.strHas( op.output, 'file' ) );
      test.is( _.strHas( op.output, '*' ) );
      test.is( _.strHas( op.output, process.argv.slice( 2 ).join( ' ') ) );
    }
    return null;
  })

  return con;

}

importantModeShell.description = 'core cases for mode "shell"'
importantModeShell.timeOut = 30000;

//

function startExecPathWithSpace( test )
{
  let context = this;
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPath =  _.fileProvider.path.nativize( _.path.join( routinePath, 'path with space/testApp.js' ) );

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, 2000 )
  }

  let testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = _.Consequence().take( null );

  let execPathWithSpace = 'node ' + _.path.nativize( testAppPath );

  /* - */

  ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, spawn'
    return null;
  })

  _.process.start
  ({
    execPath : execPathWithSpace,
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, shell'
    return null;
  })

  _.process.start
  ({
    execPath : execPathWithSpace,
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'shell',
    throwingExitCode : 0
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, fork'
    return null;
  })

  _.process.start
  ({
    execPath : _.path.nativize( testAppPath ),
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, spawn'
    return null;
  })

  _.process.start
  ({
    args : execPathWithSpace,
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0
  });

  ready.finally( ( err, got ) =>
  {
    _.errAttend( err );
    test.is( !!err );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( err.message, `ENOENT` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, shell'
    return null;
  })

  _.process.start
  ({
    args : execPathWithSpace,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'shell',
    ready,
    throwingExitCode : 0
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, fork'
    return null;
  })

  _.process.start
  ({
    args : _.path.nativize( testAppPath ),
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0
  });

  ready.then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space and argument, fork'
    return null;
  })

  _.process.start
  ({
    args : _.path.nativize( testAppPath ) + ' arg',
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Cannot find module` ) );
    return null;
  })

  return ready;
}

startExecPathWithSpace.timeOut = 60000;

//

function startNjsPassingThroughExecPathWithSpace( test )
{
  let context = this;
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPath =  _.fileProvider.path.nativize( _.path.join( routinePath, 'path with space/testApp.js' ) );

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, 2000 )
  }

  let testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = _.Consequence().take( null );

  let execPathWithSpace = _.path.nativize( testAppPath );

  /* - */

  ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space'
    return null;
  })

  _.process.startNjsPassingThrough
  ({
    execPath : execPathWithSpace,
    ready,
    stdio : 'pipe',
    outputCollecting : 1,
    outputPiping : 1,
    throwingExitCode : 0,
    applyingExitCode : 0,
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args: string that contains unquoted path with space'
    return null;
  })

  test.shouldThrowErrorOfAnyKind( () =>
  {
    return _.process.startNjsPassingThrough
    ({
      args : execPathWithSpace,
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    });
  })

  /* - */

  return ready;
}

startNjsPassingThroughExecPathWithSpace.timeOut = 60000;

//

function startPassingThroughExecPathWithSpace( test )
{
  let context = this;
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPath =  _.fileProvider.path.nativize( _.path.join( routinePath, 'path with space/testApp.js' ) );

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, 2000 )
  }

  let testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = _.Consequence().take( null );

  let execPathWithSpace = 'node ' + _.path.nativize( testAppPath );

  /* - */

  ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, spawn'
    return null;
  })

  _.process.startPassingThrough
  ({
    execPath : execPathWithSpace,
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, shell'
    return null;
  })

  _.process.startPassingThrough
  ({
    execPath : execPathWithSpace,
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'shell',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, fork'
    return null;
  })

  _.process.startPassingThrough
  ({
    execPath : _.path.nativize( testAppPath ),
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, spawn'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : execPathWithSpace,
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  ready.finally( ( err, got ) =>
  {
    _.errAttend( err );
    test.is( !!err );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( err.message, `ENOENT` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, shell'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : execPathWithSpace,
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'shell',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Cannot find module` ) );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, fork'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : _.path.nativize( testAppPath ),
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  ready.then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    return null;
  })

  /* - */

  ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space and argument, fork'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : _.path.nativize( testAppPath ) + ' arg',
    ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  ready.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( got.output, `Cannot find module` ) );
    return null;
  })

  return ready;
}

startPassingThroughExecPathWithSpace.timeOut = 60000;

//

function shellProcedureTrivial( test )
{
  let context = this;
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPath =  _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, 2000 )
  }

  let testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = _.Consequence().take( null );

  let start = _.process.starter
  ({
    currentPath : routinePath,
    outputPiping : 1,
    outputCollecting : 1,
  });

  ready

  /* */

  .then( () =>
  {

    var o = { execPath : 'node ' + testAppPath, mode : 'shell' }
    var con = start( o );
    var procedure = _.procedure.find( 'PID:'+ o.process.pid );
    test.identical( procedure.length, 1 );
    test.identical( procedure[ 0 ].isAlive(), true );
    test.identical( o.procedure, procedure[ 0 ] );
    test.identical( procedure[ 0 ].object(), o.process );
    return con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( procedure[ 0 ].isAlive(), false );
      test.identical( o.procedure, procedure[ 0 ] );
      test.identical( procedure[ 0 ].object(), o.process );
      test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) );
      return null;
    })
  })

  /* */

  .then( () =>
  {

    var o = { execPath : testAppPath, mode : 'fork' }
    var con = start( o );
    var procedure = _.procedure.find( 'PID:'+ o.process.pid );
    test.identical( procedure.length, 1 );
    test.identical( procedure[ 0 ].isAlive(), true );
    test.identical( o.procedure, procedure[ 0 ] );
    test.identical( procedure[ 0 ].object(), o.process );
    return con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( procedure[ 0 ].isAlive(), false );
      test.identical( o.procedure, procedure[ 0 ] );
      test.identical( procedure[ 0 ].object(), o.process );
      test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) );
      return null;
    })
  })

  /* */

  .then( () =>
  {

    var o = { execPath : 'node ' + testAppPath, mode : 'spawn' }
    var con = start( o );
    var procedure = _.procedure.find( 'PID:'+ o.process.pid );
    test.identical( procedure.length, 1 );
    test.identical( procedure[ 0 ].isAlive(), true );
    test.identical( o.procedure, procedure[ 0 ] );
    test.identical( procedure[ 0 ].object(), o.process );
    return con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( procedure[ 0 ].isAlive(), false );
      test.identical( o.procedure, procedure[ 0 ] );
      test.identical( procedure[ 0 ].object(), o.process );
      test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) );
      return null;
    })
  })

  /* */

  // .then( () =>
  // {
  //   var o = { execPath : 'node ' + testAppPath, mode : 'exec' }
  //   var con = start( o );
  //   var procedure = _.procedure.find( 'PID:'+ o.process.pid );
  //   test.identical( procedure.length, 1 );
  //   test.identical( procedure[ 0 ].isAlive(), true );
  //   test.identical( o.procedure, procedure[ 0 ] );
  //   test.identical( procedure[ 0 ].object(), o.process );
  //   return con.then( ( got ) =>
  //   {
  //     test.identical( got.exitCode, 0 );
  //     test.identical( procedure[ 0 ].isAlive(), false );
  //     test.identical( o.procedure, procedure[ 0 ] );
  //     test.identical( procedure[ 0 ].object(), o.process );
  //     test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) );
  //     return null;
  //   })
  // })

  /* */

  return ready;
}

shellProcedureTrivial.timeOut = 60000;
shellProcedureTrivial.description =
`
  Start routine creates procedure for new child process, start it and terminates when process closes
`

//

function shellProcedureExists( test )
{
  let context = this;
  let routinePath = _.path.join( context.suiteTempPath, test.name );
  let testAppPath =  _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );

  let testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  let ready = _.Consequence().take( null );

  let start = _.process.starter
  ({
    currentPath : routinePath,
    outputPiping : 1,
    outputCollecting : 1,
  });

  _.process.watcherEnable();

  ready

  /* */

  .then( () =>
  {
    var o = { execPath : 'node ' + testAppPath, mode : 'shell' }
    var con = start( o );
    var procedure = _.procedure.find( 'PID:'+ o.process.pid );
    test.identical( procedure.length, 1 );
    test.identical( procedure[ 0 ].isAlive(), true );
    test.identical( o.procedure, procedure[ 0 ] );
    test.identical( procedure[ 0 ].object(), o.process );
    test.identical( o.procedure, procedure[ 0 ] );
    return con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( procedure[ 0 ].isAlive(), false );
      test.identical( o.procedure, procedure[ 0 ] );
      test.identical( procedure[ 0 ].object(), o.process );
      test.identical( o.procedure, procedure[ 0 ] );
      debugger
      test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) );
      return null;
    })
  })

  /* */

  // xxx
  // .then( () =>
  // {
  //
  //   var o = { execPath : testAppPath, mode : 'fork' }
  //   var con = start( o );
  //   var procedure = _.procedure.find( 'PID:'+ o.process.pid );
  //   test.identical( procedure.length, 1 );
  //   test.identical( procedure[ 0 ].isAlive(), true );
  //   test.identical( o.procedure, procedure[ 0 ] );
  //   test.identical( procedure[ 0 ].object(), o.process );
  //   test.identical( o.procedure, procedure[ 0 ] );
  //   return con.then( ( got ) =>
  //   {
  //     test.identical( got.exitCode, 0 );
  //     test.identical( procedure[ 0 ].isAlive(), false );
  //     test.identical( o.procedure, procedure[ 0 ] );
  //     test.identical( procedure[ 0 ].object(), o.process );
  //     test.identical( o.procedure, procedure[ 0 ] );
  //     test.is( _.strHas( o.procedure._sourcePath, 'ProcessWatcher.s' ) );
  //     return null;
  //   })
  // })
  //
  // /* */
  //
  // .then( () =>
  // {
  //
  //   var o = { execPath : 'node ' + testAppPath, mode : 'spawn' }
  //   var con = start( o );
  //   var procedure = _.procedure.find( 'PID:'+ o.process.pid );
  //   test.identical( procedure.length, 1 );
  //   test.identical( procedure[ 0 ].isAlive(), true );
  //   test.identical( o.procedure, procedure[ 0 ] );
  //   test.identical( procedure[ 0 ].object(), o.process );
  //   test.identical( o.procedure, procedure[ 0 ] );
  //   return con.then( ( got ) =>
  //   {
  //     test.identical( got.exitCode, 0 );
  //     test.identical( procedure[ 0 ].isAlive(), false );
  //     test.identical( o.procedure, procedure[ 0 ] );
  //     test.identical( procedure[ 0 ].object(), o.process );
  //     test.identical( o.procedure, procedure[ 0 ] );
  //     test.is( _.strHas( o.procedure._sourcePath, 'ProcessWatcher.s' ) );
  //     return null;
  //   })
  // })

  /* */

  ready.then( () => _.process.watcherDisable() ) /* qqq : ? */

  return ready;

  /* */

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, 2000 )
  }

}

shellProcedureExists.timeOut = 60000;
shellProcedureExists.description =
`
  Start routine does not create procedure for new child process if it was already created by process watcher
`

//

function shellTerminateHangedWithExitHandler( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctrly on node 14
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  /* */

  function testApp()
  {
    _.include( 'wProcess' );
    _.process._exitHandlerRepair();
    process.send( process.pid )
    while( 1 )
    {
      console.log( _.time.now() )
    }
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
      ipc : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process, timeOut : 5000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGINT' ) );

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
      outputPiping : 0,
      ipc : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process, timeOut : 5000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGINT' ) );

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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctrly on node 14
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  /* */

  function testApp()
  {
    _.include( 'wProcess' );
    _.process._exitHandlerRepair();
    let loop = true;
    setTimeout( () =>
    {
      loop = false;
    }, 5000 )
    process.send( process.pid );
    while( loop )
    {
      loop = loop;
    }
    console.log( 'Exit after release' );
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
      ipc : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process, timeOut : 10000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGINT' ) );
      test.is( !_.strHas( o.output, 'Exit after release' ) );

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
      outputPiping : 0,
      ipc : 1,
      outputCollecting : 1,
    }

    let con = _.process.start( o );

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process, timeOut : 10000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGINT' ) );
      test.is( !_.strHas( o.output, 'Exit after release' ) );

      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

shellTerminateAfterLoopRelease.timeOut = 30000;
shellTerminateAfterLoopRelease.description =
`
  Test app - code that blocks event loop for short period of time and appExitHandlerRepair called at start

  Will test:
    - Termination of child process using SIGINT signal after small delay

  Expected behaviour:
    - Child was terminated after event loop release with exitCode : 0, exitSignal : null
    - Child process message should be printed
`

//

function shellStartingDelay( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    let data = { t2 : _.time.now() };
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

    let t1 = _.time.now();
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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    let data = { t2 : _.time.now() };
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
    let t1 = _.time.now();
    let delay = 5000;
    let starting = { time : _.time.now() + delay };
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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    let data = { t2 : _.time.now() };
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

    let t1 = _.time.now();
    let delay = 1000;
    let con = _.process.start( o );

    _.time.out( delay, () =>
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

function shellAfterDeath( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      outputCollecting : 1,
      mode : 'spawn',
    }

    _.process.startAfterDeath( o );

    o.onStart.thenGive( () =>
    {
      process.send( o.process.pid );
    })

    _.time.out( 5000, () =>
    {
      console.log( 'parent termination begin' );
      _.procedure.terminationBegin();
      return null;
    })
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    _.time.out( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
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
      outputPiping : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    debugger;
    let con = _.process.start( o );
    let childPid;
    debugger;

    o.process.on( 'message', ( got ) =>
    {
      childPid = _.numberFrom( got );
    })

    o.onTerminate.then( () =>
    {
      test.identical( o.exitCode, 0 );
      test.case = 'secondary process is alive'
      test.is( _.process.isAlive( childPid ) );
      test.case = 'child of secondary process does not exit yet'
      test.is( !_.fileProvider.fileExists( testFilePath ) );
      return _.time.out( 10000 );
    })

    o.onTerminate.then( () =>
    {
      test.case = 'secondary process is dead'
      test.is( !_.process.isAlive( childPid ) );

      test.case = 'child of secondary process is executed'
      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid2 = _.fileProvider.fileRead( testFilePath );
      childPid2 = _.numberFrom( childPid2 );

      test.case = 'secondary process and child are not same'
      test.is( !_.process.isAlive( childPid2 ) );
      test.notIdentical( childPid, childPid2 );
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

//

// function shellAfterDeathOutput( test )
// {
//   let context = this;
//   var routinePath = _.path.join( context.suiteTempPath, test.name );

//   function testAppParent()
//   {
//     _.include( 'wProcess' );
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

//     _.time.out( 4000, () =>
//     {
//       console.log( 'Parent process exit' )
//       process.disconnect();
//       return null;
//     })
//   }

//   function testAppChild()
//   {
//     _.include( 'wProcess' );
//     _.include( 'wFiles' );

//     console.log( 'Child process start' )

//     _.time.out( 5000, () =>
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

function startDetachingModeSpawnResourceReady( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  var ready = new _.Consequence().take( null );
  let testFilePath = _.path.join( routinePath, 'testFile' );

  ready

  .then( () =>
  {
    test.case = 'consequence receive resources after child spawn';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      detaching : 1,
      currentPath : routinePath,
      throwingExitCode : 0
    }
    let result = _.process.start( o );

    test.identical( result, o.onStart );
    test.notIdentical( result, o.onTerminate );

    o.onStart.then( ( got ) =>
    {
      test.is( _.mapIs( got ) );
      test.identical( got, o );
      test.is( _.process.isAlive( o.process.pid ) );
      o.process.kill();
      return null;
    })

    o.onTerminate.then( ( got ) => /* qqq2 : should be not got, but op. check whole test suite, please */
    {
      test.notIdentical( got.exitCode, 0 );
      test.identical( got.exitSignal, 'SIGTERM' );
      return null;
    })

    return o.onTerminate;
  })

  return ready;
}

//

function startDetachingModeForkResourceReady( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    test.case = 'consequence receives resources after child spawn';

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      detaching : 1,
      currentPath : routinePath,
      throwingExitCode : 0
    }
    let result = _.process.start( o );

    test.identical( result, o.onStart );
    test.notIdentical( result, o.onTerminate );

    o.onStart.thenGive( ( got ) =>
    {
      test.is( _.mapIs( got ) );
      test.identical( got, o );
      test.is( _.process.isAlive( o.process.pid ) );
      o.process.kill();
    })

    o.onTerminate.then( ( got ) =>
    {
      test.notIdentical( got.exitCode, 0 );
      test.identical( got.exitSignal, 'SIGTERM' );
      return null;
    })

    return o.onTerminate;
  })

  return ready;
}

//

function startDetachingModeShellResourceReady( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    test.case = 'consequence receives resources after child spawn';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      detaching : 1,
      currentPath : routinePath,
      throwingExitCode : 0
    }
    let result = _.process.start( o );

    test.identical( result, o.onStart );
    test.notIdentical( result, o.onTerminate );

    o.onStart.thenGive( ( got ) =>
    {
      test.is( _.mapIs( got ) );
      test.identical( got, o );
      test.is( _.process.isAlive( o.process.pid ) );
      o.process.kill();
    })

    o.onTerminate.then( ( got ) =>
    {
      test.notIdentical( got.exitCode, 0 );
      test.identical( got.exitSignal, 'SIGTERM' );
      return null;
    })

    return o.onTerminate;
  })

  return ready;
}

//

function startDetachingModeSpawnNoTerminationBegin( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      ipc : 0,
      detaching : true,
    }

    _.mapExtend( o, args.map );

    _.process.start( o );

    process.send({ childPid : o.process.pid });
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
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
    test.case = 'stdio:ignore ipc:false, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore ipc : false',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'stdio:ignore ipc:true, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore ipc : true',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'stdio:pipe, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'stdio:pipe ipc:true, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe ipc : true',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

//

function startDetachingModeForkNoTerminationBegin( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      detaching : true,
    }

    _.mapExtend( o, args.map );

    _.process.start( o );

    process.send({ childPid : o.process.pid });
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
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

  /*  */

  .then( () =>
  {
    test.case = 'stdio:ignore, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'stdio:pipe, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */
  return ready;
}

//

function startDetachingModeShellNoTerminationBegin( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      ipc : 0,
      detaching : true,
    }

    _.mapExtend( o, args.map );

    _.process.start( o );

    process.send({ childPid : o.process.pid });
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
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
    test.case = 'stdio:ignore, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.is( !_.process.isAlive( childPid ) );

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'stdio:pipe, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.is( !_.process.isAlive( childPid ) );

      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

//

function startDetachingModeSpawnTerminationBegin( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      ipc : 0,
      detaching : true,
    }

    _.mapExtend( o, args.map );

    _.process.start( o );

    process.send({ childPid : o.process.pid });

    _.time.out( 1000, () =>
    {
      _.procedure.terminationBegin();
      return null;
    })
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
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
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 20000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore ipc : true',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 20000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 20000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe ipc : true',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 20000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

startDetachingModeSpawnTerminationBegin.timeOut = 120000;

//

function startDetachingModeForkTerminationBegin( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      ipc : 0,
      detaching : true,
    }

    _.mapExtend( o, args.map );

    _.process.start( o );

    process.send({ childPid : o.process.pid });

    _.time.out( 1000, () =>
    {
      _.procedure.terminationBegin();
      return null;
    })
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
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
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 10000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore ipc : true',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 10000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 10000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe ipc : true',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 10000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

startDetachingModeForkTerminationBegin.timeOut = 300000;

//

function startDetachingModeShellTerminationBegin( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      ipc : 0,
      detaching : true,
    }

    _.mapExtend( o, args.map );

    _.process.start( o );

    process.send({ childPid : o.process.pid });

    _.time.out( 1000, () =>
    {
      _.procedure.terminationBegin();
      return null;
    })
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
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
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 10000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );

      test.is( !_.process.isAlive( childPid ) );

      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( got ) =>
    {
      data = got;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.will = 'parent is dead, child is still alive';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( data.childPid ) );
      return _.time.out( 10000 );
    })

    con.then( () =>
    {
      test.will = 'both dead';

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );

      test.is( !_.process.isAlive( childPid ) );

      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

//

function startDetachingChildExitsAfterParent( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      stdio : 'ignore',
      detaching : true,
      mode : 'spawn',
    }

    _.process.start( o );

    process.send( o.process.pid );

    _.time.out( 1000, () => o.disconnect() );
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' );

    _.time.out( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' );
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
    test.case = 'parent disconnects detached child process and exits, child contiues to work'
    let o =
    {
      execPath : 'node testAppParent.js',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
      currentPath : routinePath,
      detaching : 0,
      ipc : 1,
    }
    let con = _.process.start( o );

    let childPid;

    o.process.on( 'message', ( got ) =>
    {
      childPid = _.numberFrom( got );
    })

    o.onTerminate.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );

      test.will = 'parent is dead, detached child is still running'

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( childPid ) );

      return _.time.out( 10000 );
    })

    o.onTerminate.then( () =>
    {
      let childPid2 = _.fileProvider.fileRead( testFilePath );
      childPid2 = _.numberFrom( childPid2 )
      test.is( !_.process.isAlive( childPid2 ) );
      test.identical( childPid, childPid2 )
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

startDetachingChildExitsAfterParent.description =
`
Parent starts child process in detached mode and disconnects it.
Child process continues to work for at least 5 seconds after parent exits.
After 5 seconds child process creates test file in working directory and exits.
`

//

function startDetachingChildExitsBeforeParent( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      stdio : 'ignore',
      detaching : true,
      mode : 'spawn',

    }

    _.process.start( o );

    o.onTerminate.finally( ( err, got ) =>
    {
      /* xxx qqq : add track here and in all similar place to cover entering here! */
      process.send({ exitCode : got.exitCode, err, pid : o.process.pid });
      return null;
    })

    _.time.out( 5000, () =>
    {
      console.log( 'Parent process end' )
    });
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 1000, () =>
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
    _.process.start( o );

    let child;
    let onChildTerminate = new _.Consequence();

    o.process.on( 'message', ( got ) =>
    {
      child = got;
      onChildTerminate.take( got );
    })

    onChildTerminate.then( () =>
    {
      let childPid = _.fileProvider.fileRead( testFilePath );
      test.is( _.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( _.numberFrom( childPid ) ) );
      return null;
    })

    o.onTerminate.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );

      test.will = 'parent and chid are dead';

      test.identical( child.err, undefined );
      test.identical( child.exitCode, 0 );

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( child.pid ) );

      test.is( _.fileProvider.fileExists( testFilePath ) );
      let childPid = _.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid )
      test.is( !_.process.isAlive( childPid ) );

      test.identical( child.pid, childPid );

      return null;
    })

    return _.Consequence.AndKeep_( onChildTerminate, o.onTerminate );
  })

  /*  */

  return ready;
}

startDetachingChildExitsBeforeParent.description =
`
Parent starts child process in detached mode and registers callback to wait for child process.
Child process creates test file after 1 second and exits.
Callback in parent recevies message. Parent exits.
`

//

function startDetachingDisconnectedChildExistsBeforeParent( test )
{
  let context = this;
  let track = [];
  var routinePath = _.path.join( context.suiteTempPath, test.name );
  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  let ready = new _.Consequence().take( null );

  ready

  /* Vova qqq xxx: ProcessWatcher tries to kill detached process that terminates before test ends */

  .then( () =>
  {
    test.case = 'detaching on, disconnected forked child'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : 'ignore',
      // outputPiping : 1,
      // stdio : 'pipe',
      currentPath : routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.identical( o.state, 'started' );
    o.disconnect();
    test.identical( o.state, 'disconnected' );
    test.identical( o.onStart, result );
    test.is( _.consequenceIs( o.onStart ) )

    o.onStart.finally( ( err, got ) =>
    {
      track.push( 'onStart' );
      test.identical( err, undefined );
      test.identical( got, o );
      test.is( _.process.isAlive( o.process.pid ) )
      return null;
    })

    o.onTerminate.finallyGive( ( err, got ) =>
    {
      track.push( 'onTerminate' );
      /* xxx qqq : add track here and in all similar place to cover entering here! */
      /* qqq xxx : does not enter here. why?? */
      console.log( 'onTerminate' ); debugger;
      _.errAttend( err );
      test.identical( o.state, 'terminated' );
      test.is( !_.errIs( err ) );
      test.is( got !== undefined );
      test.is( !_.process.isAlive( o.process.pid ) );
    })

    result = _.time.out( 5000, () =>
    {
      test.identical( o.onTerminate.resourcesCount(), 0 );
      test.identical( o.onTerminate.errorsCount(), 0 );
      test.identical( o.onTerminate.competitorsCount(), 0 );
      test.identical( o.state, 'terminated' );
      test.identical( track, [ 'onStart', 'onTerminate' ] );
      test.is( !_.process.isAlive( o.process.pid ) )
      return null;
    })

    return _.Consequence.AndTake_( o.onStart, result );
  })

  /* */

  return ready;

  /* */

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var args = _.process.args();
    _.time.out( 2000, () =>
    {
      console.log( 'Child process end' )
      return null;
    })
  }

}

startDetachingDisconnectedChildExistsBeforeParent.description =
`
Parent starts child process in detached mode and disconnects it right after start.
Child process creates test file after 1 second and exits.
onStart recevies message when process starts.
onTerminate recevies message when parent disconnects the child process.
Test routine waits for few seconds and checks if child is alive.
ProcessWatched should not throw any error.
`

//

function startDetachingChildExistsBeforeParentWaitForTermination( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  let ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    test.case = 'detaching on, disconnected forked child'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1
    }

    _.process.start( o );

    o.onTerminate.finally( ( err, got ) =>
    {
      /* xxx qqq : add track here and in all similar place to cover entering here! */
      test.identical( err, undefined );
      test.identical( got, o );
      test.is( !_.process.isAlive( o.process.pid ) )
      return null;
    })

    return o.onTerminate;
  })

  /* */

  return ready;

  /* */

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.args();

    _.time.out( 2000, () =>
    {
      console.log( 'Child process end' )
      return null;
    })
  }

}

//

startDetachingChildExistsBeforeParentWaitForTermination.description =
`
Parent starts child process in detached mode.
Test routine waits until o.onTerminate resolves message about termination of the child process.
`

//

function startDetachingEndCompetitorIsExecuted( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  let ready = new _.Consequence().take( null );

  ready

  /* Vova qqq xxx: close event is not emitted for disconnected detached child in fork mode*/

  .then( () =>
  {
    test.case = 'detaching on, disconnected forked child'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    // test.identical( o.onStart, result );
    test.is( _.consequenceIs( o.onStart ) )
    test.is( _.consequenceIs( o.onTerminate ) )

    o.onStart.finally( ( err, got ) =>
    {
      test.identical( o.ended, false );
      test.identical( err, undefined );
      test.identical( got, o );
      test.is( _.process.isAlive( o.process.pid ) );
      return null;
    })

    o.onTerminate.finally( ( err, got ) =>
    {
      /* xxx qqq : add track here and in all similar place to cover entering here! */
      test.identical( o.ended, true );
      test.identical( err, undefined );
      test.identical( got, o );
      test.is( !_.process.isAlive( o.process.pid ) )
      return null;
    })

    return _.Consequence.AndTake_( o.onStart, o.onTerminate );
  })

  /* */

  return ready;

  /* */

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.args();

    _.time.out( 2000, () =>
    {
      console.log( 'Child process end' )
      return null;
    })
  }

}

startDetachingEndCompetitorIsExecuted.description =

`Parent starts child process in detached mode.
Consequence onStart recevices message when process starts.
Consequence onTerminate recevices message when process ends.
o.ended is false when onStart callback is executed.
o.ended is true when onTerminate callback is executed.
`

//


function startDetachedOutputStdioIgnore( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'testAppChild.js',
      detaching : true,
      ipc : false
    }

    _.mapExtend( o, args.map );

    if( o.mode !== 'fork' )
    o.execPath = 'node ' + o.execPath;

    _.process.start( o );
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
    {
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

  ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : ignore, no output from detached child';

    let o =
    {
      execPath : 'node testAppParent.js mode : spawn stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
    }
    let con = _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 )
      test.is( !_.strHas( o.output, 'Child process start' ) )
      test.is( !_.strHas( o.output, 'Child process end' ) )
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : fork, stdio : ignore, no output from detached child';

    let o =
    {
      execPath : 'node testAppParent.js mode : fork stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
    }
    let con = _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 )
      test.is( !_.strHas( o.output, 'Child process start' ) )
      test.is( !_.strHas( o.output, 'Child process end' ) )
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : shell, stdio : ignore, no output from detached child';

    let o =
    {
      execPath : 'node testAppParent.js mode : shell stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
    }
    let con = _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 )
      test.is( !_.strHas( o.output, 'Child process start' ) )
      test.is( !_.strHas( o.output, 'Child process end' ) )
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

//

function startDetachedOutputStdioPipe( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.args();

    let o =
    {
      execPath : 'testAppChild.js',
      detaching : true,
      ipc : false
    }

    _.mapExtend( o, args.map );

    if( o.mode !== 'fork' )
    o.execPath = 'node ' + o.execPath;

    _.process.start( o );
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
    {
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

  ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : pipe';

    let o =
    {
      execPath : 'node testAppParent.js mode : spawn stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
    }
    let con = _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 )
      test.is( _.strHas( o.output, 'Child process start' ) )
      test.is( _.strHas( o.output, 'Child process end' ) )
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : fork, stdio : pipe';

    let o =
    {
      execPath : 'node testAppParent.js mode : fork stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
    }
    let con = _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 )
      test.is( _.strHas( o.output, 'Child process start' ) )
      test.is( _.strHas( o.output, 'Child process end' ) )
      return null;
    })

    return con;
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : shell, stdio : pipe';

    let o =
    {
      execPath : 'node testAppParent.js mode : shell stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : routinePath,
    }
    let con = _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 )

      //xxx: output piping doesn't work as expected in mode "shell" on windows
      //qqq: investigate if its fixed in never verions of node or implement alternative solution

      if( process.platform === 'win32' )
      return null;

      test.is( _.strHas( o.output, 'Child process start' ) )
      test.is( _.strHas( o.output, 'Child process end' ) )
      return null;
    })

    return con;
  })

  /*  */

  return ready;
}

//

function startDetachedOutputStdioInherit( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  var ready = new _.Consequence().take( null );

  test.is( true );

  if( !Config.debug )
  return ready;

  ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : inherit';
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'inherit',
      detaching : 1,
      currentPath : routinePath,
    }
    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : fork, stdio : inherit';
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : 'inherit',
      detaching : 1,
      currentPath : routinePath,
    }
    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : shell, stdio : inherit';
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      stdio : 'inherit',
      detaching : 1,
      currentPath : routinePath,
    }
    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  /*  */

  return ready;
}

//

function startDetachingModeSpawnIpc( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    process.on( 'message', ( data ) =>
    {
      process.send( data );
      process.exit();
    })

  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : ignore';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      outputCollecting : 1,
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( data ) =>
    {
      message = data;
    })

    o.onStart.thenGive( () =>
    {
      o.process.send( 'child' );
    })

    o.onTerminate.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( message, 'child' );
      return null;
    })

    return o.onTerminate;
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : pipe';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      outputCollecting : 1,
      stdio : 'pipe',
      currentPath : routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( data ) =>
    {
      message = data;
    })

    o.onStart.thenGive( () =>
    {
      o.process.send( 'child' );
    })

    o.onTerminate.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( message, 'child' );
      return null;
    })

    return o.onTerminate;
  })

  /*  */

  return ready;
}

//

function startDetachingModeForkIpc( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    process.on( 'message', ( data ) =>
    {
      process.send( data );
      process.exit();
    })

  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  var ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    test.case = 'mode : fork, stdio : ignore';

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      outputCollecting : 1,
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( data ) =>
    {
      message = data;
    })

    o.onStart.thenGive( () =>
    {
      o.process.send( 'child' );
    })

    o.onTerminate.then( ( got ) =>
    {
      debugger
      test.identical( got.exitCode, 0 );
      test.identical( message, 'child' );
      return null;
    })

    return o.onTerminate;
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : fork, stdio : pipe';

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      outputCollecting : 1,
      stdio : 'pipe',
      currentPath : routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( data ) =>
    {
      message = data;
    })

    o.onStart.thenGive( () =>
    {
      o.process.send( 'child' );
    })

    o.onTerminate.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( message, 'child' );
      return null;
    })

    return o.onTerminate;
  })

  /*  */

  return ready;
}

//

function startDetachingModeShellIpc( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    process.on( 'message', ( data ) =>
    {
      process.send( data );
      process.exit();
    })

  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );
  var ready = new _.Consequence().take( null );

  test.is( true );

  if( !Config.debug )
  return ready;

  ready

  .then( () =>
  {
    test.case = 'mode : shell, stdio : ignore';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      outputCollecting : 1,
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1,
      ipc : 1,
    }
    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  /*  */

  .then( () =>
  {
    test.case = 'mode : shell, stdio : pipe';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      outputCollecting : 1,
      stdio : 'pipe',
      currentPath : routinePath,
      detaching : 1,
      ipc : 1,
    }
    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  /*  */

  return ready;
}

//

function startDetachingThrowing( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( 5000, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  test.is( true );

  if( !Config.debug )
  return;

  var o =
  {
    execPath : 'node testAppChild.js',
    mode : 'spawn',
    stdio : 'inherit',
    currentPath : routinePath,
    detaching : 1
  }
  test.shouldThrowErrorSync( () => _.process.start( o ) )

  var o =
  {
    execPath : 'node testAppChild.js',
    mode : 'shell',
    stdio : 'inherit',
    currentPath : routinePath,
    detaching : 1
  }
  test.shouldThrowErrorSync( () => _.process.start( o ) )

  var o =
  {
    execPath : 'testAppChild.js',
    mode : 'fork',
    stdio : 'inherit',
    currentPath : routinePath,
    detaching : 1
  }
  test.shouldThrowErrorSync( () => _.process.start( o ) )

  // var o =
  // {
  //   execPath : 'node testAppChild.js',
  //   mode : 'exec',
  //   stdio : 'inherit',
  //   currentPath : routinePath,
  //   detaching : 1
  // }
  // test.shouldThrowErrorSync( () => _.process.start( o ) )
  //
  // var o =
  // {
  //   execPath : 'node testAppChild.js',
  //   mode : 'exec',
  //   stdio : 'pipe',
  //   currentPath : routinePath,
  //   detaching : 1
  // }
  // test.shouldThrowErrorSync( () => _.process.start( o ) )
  //
  // var o =
  // {
  //   execPath : 'node testAppChild.js',
  //   mode : 'exec',
  //   stdio : 'ignore',
  //   currentPath : routinePath,
  //   detaching : 1
  // }
  // test.shouldThrowErrorSync( () => _.process.start( o ) )
  //
}

//

function startNjsDetachingChildThrowing( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    setTimeout( () =>
    {
      throw new Error( 'Child process error' );
    }, 1000)
  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  test.case = 'detached child throws error, onTerminate receives resource with error';

  let o =
  {
    execPath : 'testAppChild.js',
    outputCollecting : 1,
    stdio : 'pipe',
    detaching : 1,
    applyingExitCode : 0,
    throwingExitCode : 0,
    outputPiping : 0,
    currentPath : routinePath,
  }

  _.process.startNjs( o );

  o.onTerminate.then( ( got ) =>
  {
    test.notIdentical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Child process error' ) );
    test.identical( o.exitCode, got.exitCode );
    test.identical( o.output, got.output );
    return null;
  })

  return o.onTerminate;
}

//

function startNjsDetachingTrivial( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppParent()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'testAppChild.js',
      outputCollecting : 1,
      stdio : 'pipe',
      detaching : 1,
      applyingExitCode : 0,
      throwingExitCode : 0,
      outputPiping : 1,
    }
    _.process.startNjs( o );

    o.onStart.thenGive( () =>
    {
      process.send( o.process.pid )
      o.process.send( 'data' );
      o.process.on( 'message', () =>
      {
        o.disconnect();
      })
    })
  }

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    process.on( 'message', ( data ) =>
    {
      console.log( 'from parent:', data );
      process.send( 'ready to disconnect' )
    })

    _.time.out( 5000, () =>
    {
      console.log( 'Child process end' );
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
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

  let testFilePath = _.path.join( routinePath, 'testFile' );

  test.case = 'trivial use case';

  let o =
  {
    execPath : 'testAppParent.js',
    outputCollecting : 1,
    mode : 'fork',
    stdio : 'pipe',
    detaching : 0,
    throwingExitCode : 0,
    currentPath : routinePath,
  }

  _.process.start( o );

  let childPid;
  o.process.on( 'message', ( data ) =>
  {
    childPid = _.numberFrom( data );
  })

  o.onTerminate.then( ( got ) =>
  {
    test.is( _.process.isAlive( childPid ) );

    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, 'Child process start' ) );
    test.is( _.strHas( got.output, 'from parent: data' ) );
    test.is( !_.strHas( got.output, 'Child process end' ) );
    test.identical( o.exitCode, got.exitCode );
    test.identical( o.output, got.output );
    return _.time.out( 10000 );
  })

  o.onTerminate.then( () =>
  {
    test.is( !_.process.isAlive( childPid ) );

    let childPidFromFile = _.fileProvider.fileRead( testFilePath );
    childPidFromFile = _.numberFrom( childPidFromFile )
    test.is( !_.process.isAlive( childPidFromFile ) );
    test.identical( childPid, childPidFromFile )
    return null;
  })

  return o.onTerminate;
}

//

function startOnStart( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  let ready = new _.Consequence().take( null );

  ready

  /* */

  .then( () =>
  {
    test.case = 'detaching off, no errors'
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 0
    }

    let result = _.process.start( o );

    test.notIdentical( o.onStart, result );
    test.is( _.consequenceIs( o.onStart ) )

    o.onStart.finally( ( err, got ) =>
    {
      test.identical( err, undefined );
      test.identical( got, o );
      test.is( _.process.isAlive( o.process.pid ) );
      return null;
    })

    result.then( ( got ) =>
    {
      test.identical( o, got );
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return _.Consequence.AndTake_( o.onStart, result );
  })

  /* */

  .then( () =>
  {
    test.case = 'detaching off, error on spawn'
    let o =
    {
      execPath : 'node -v',
      mode : 'spawn',
      stdio : [ null, 'something', null ],
      currentPath : routinePath,
      detaching : 0
    }

    let result = _.process.start( o );

    test.notIdentical( o.onStart, result );
    test.is( _.consequenceIs( o.onStart ) )

    return test.shouldThrowErrorAsync( o.onTerminate );
  })

  /* */

  .then( () =>
  {
    test.case = 'detaching off, error on spawn, no callback for onStart'
    let o =
    {
      execPath : 'node -v',
      mode : 'spawn',
      stdio : [ null, 'something', null ],
      currentPath : routinePath,
      detaching : 0
    }

    let result = _.process.start( o );

    test.notIdentical( o.onStart, result );
    test.is( _.consequenceIs( o.onStart ) )

    return test.shouldThrowErrorAsync( o.onTerminate );
  })

  /* */

  .then( () =>
  {
    test.case = 'detaching on, onStart and result are same and give resource on start'
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.identical( o.onStart, result );
    test.is( _.consequenceIs( o.onStart ) )

    o.onStart.then( ( got ) =>
    {
      test.identical( o, got );
      test.identical( got.exitCode, null );
      test.identical( got.exitSignal, null );
      return null;
    })

    return _.Consequence.AndTake_( o.onStart, o.onTerminate );
  })

  /* */

  .then( () =>
  {
    test.case = 'detaching on, error on spawn'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : [ 'ignore', 'ignore', 'ignore', null ],
      currentPath : routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.is( o.onStart === result );
    test.is( _.consequenceIs( o.onStart ) )

    result = test.shouldThrowErrorAsync( o.onTerminate );

    result.then( () => _.time.out( 2000 ) )
    result.then( () =>
    {
      test.identical( o.onTerminate.resourcesCount(), 0 );
      return null;
    })

    return result;
  })

  /* */

  .then( () =>
  {
    test.case = 'detaching on, disconnected child'
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.identical( o.onStart, result );

    o.onStart.finally( ( err, got ) =>
    {
      test.identical( err, undefined );
      test.identical( got, o );
      test.is( _.process.isAlive( o.process.pid ) )
      test.identical( o.state, 'started' );
      o.disconnect();
      return null;
    })

    o.onDisconnect.finally( ( err, got ) =>
    {
      test.identical( err, undefined );
      test.identical( got, o );
      test.identical( o.state, 'disconnected' );
      test.is( _.process.isAlive( o.process.pid ) );
      return null;
    })

    o.onTerminate.finally( ( err, got ) =>
    {
      /* xxx qqq : add track here and in all similar place to cover entering here! */
      test.identical( err, undefined );
      test.identical( got, o );
      test.identical( o.state, 'terminated' );
      test.is( !_.process.isAlive( o.process.pid ) )
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return _.Consequence.AndTake_( o.onStart, o.onDisconnect, o.onTerminate );
  })

  /* Vova qqq xxx: close event is not emitted for disconnected detached child in fork mode*/

  .then( () =>
  {
    test.case = 'detaching on, disconnected forked child'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.identical( o.onStart, result );

    o.onStart.finally( ( err, got ) =>
    {
      test.identical( err, undefined );
      test.identical( got, o );
      test.identical( o.state, 'started' )
      test.is( _.process.isAlive( o.process.pid ) )
      o.disconnect();
      return null;
    })

    o.onDisconnect.finally( ( err, got ) =>
    {
      test.identical( err, undefined );
      test.identical( got, o );
      test.identical( o.state, 'disconnected' )
      test.is( _.process.isAlive( o.process.pid ) )
      return null;
    })

    result = _.time.out( 2000 + context.t2, () =>
    {
      test.is( !_.process.isAlive( o.process.pid ) )
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, null );
      test.identical( o.onTerminate.resourcesCount(), 0 );
      return null;
    })

    return _.Consequence.AndTake_( o.onStart, o.onDisconnect, result );
  })

  /* */

  return ready;

  /* */

  function testAppChild()
  {
    console.log( 'Child process begin' );

    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.args();

    _.time.out( 2000, () =>
    {
      console.log( 'Child process end' );
      return null;
    })
  }

}

//

function startOnTerminate( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testAppChild()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.args();

    _.time.out( 5000, () =>
    {
      if( args.map.throwing )
      throw _.err( 'Child process error' );
      console.log( 'Child process end' )
      return null;
    })
  }

  /* */

  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  let ready = new _.Consequence().take( null );

  ready

  /* */

  .then( () =>
  {
    test.case = 'detaching off'
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 0
    }

    let result = _.process.start( o );

    test.identical( o.onTerminate, result );

    result.then( ( got ) =>
    {
      test.identical( o, got );
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return result;
  })

  /* */

  .then( () =>
  {
    test.case = 'detaching off, disconnect'
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      detaching : 0
    }

    let result = _.process.start( o );

    o.disconnect();

    test.identical( o.onTerminate, result );

    result.then( ( got ) =>
    {
      test.identical( o, got );
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return result;
  })

  /* */

  .then( () =>
  {
    test.case = 'detaching, child not disconnected, parent waits for child to exit'
    let onTerminate = new _.Consequence();
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      onTerminate,
      detaching : 1
    }

    _.process.start( o );

    onTerminate.then( ( got ) =>
    {
      test.identical( o, got );
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return onTerminate;
  })

  /* */

  .then( () =>
  {
    test.case = 'detached, child disconnected before it termination'
    let onTerminate = new _.Consequence();
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'pipe',
      currentPath : routinePath,
      onTerminate,
      detaching : 1
    }

    _.process.start( o );
    _.time.out( 1000, () => o.disconnect() );

    onTerminate.then( ( got ) =>
    {
      test.identical( o, got );
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return onTerminate;
  })

  /* */

  .then( () =>
  {
    test.case = 'detached, child disconnected after it termination'
    let onTerminate = new _.Consequence();
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      onTerminate,
      detaching : 1
    }

    _.process.start( o );

    o.onTerminate.then( ( got ) =>
    {
      o.disconnect();
      return got;
    })

    return test.mustNotThrowError( onTerminate )
    .then( ( got ) =>
    {
      test.identical( o, got );
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })
  })

  /* */

  .then( () =>
  {
    test.case = 'detached, not disconnected child throws error during execution'
    let onTerminate = new _.Consequence();
    let o =
    {
      execPath : 'node testAppChild.js throwing:1',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      onTerminate,
      throwingExitCode : 0,
      detaching : 1
    }

    _.process.start( o );

    onTerminate.then( ( got ) =>
    {
      test.notIdentical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return onTerminate;
  })

  /* */

  .then( () =>
  {
    test.case = 'detached, disconnected child throws error during execution'
    let onTerminate = new _.Consequence();
    let o =
    {
      execPath : 'node testAppChild.js throwing:1',
      mode : 'spawn',
      stdio : 'ignore',
      currentPath : routinePath,
      onTerminate,
      throwingExitCode : 0,
      detaching : 1
    }

    _.process.start( o );
    o.disconnect();

    onTerminate.then( ( got ) =>
    {
      test.notIdentical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      return null;
    })

    return onTerminate;
  })

  return ready;
}

//

function startNoEndBug1( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
  var testAppChildPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testAppChild.js' ) );
  var testAppChildCode = context.toolsPathInclude + testAppChild.toString() + '\ntestAppChild();';
  _.fileProvider.fileWrite( testAppChildPath, testAppChildCode );

  let ready = new _.Consequence().take( null );

  ready

  /* */

  .then( () =>
  {
    test.case = 'detaching on, error on spawn'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : [ 'ignore', 'ignore', 'ignore', null ],
      currentPath : routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.is( o.onStart === result );
    test.is( _.consequenceIs( o.onStart ) )

    result = test.shouldThrowErrorAsync( o.onTerminate );

    result.then( () => _.time.out( 2000 ) )
    result.then( () =>
    {
      test.identical( o.onTerminate.resourcesCount(), 0 );
      return null;
    })

    return result;
  })

  /* */

  return ready;

  /* */

  function testAppChild()
  {
    _.include( 'wProcess' );
    var args = _.process.args();
    _.time.out( 2000, () =>
    {
      console.log( 'Child process end' )
      return null;
    })
  }

}

startNoEndBug1.description =
`
Parent starts child process in detached mode.
ChildProcess throws an error on spawn.
onStart receives error message.
Parent should not try to disconnect the child.
`

//

function startOnTerminateWithDelay( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( program1 );
  let time1 = _.time.now();

  a.ready.timeOut( 1000 );

  /* */

  let options =
  {
    execPath : 'node',
    args : programPath,
    currentPath : a.currentPath,
    throwingExitCode : 1,
    applyingExitCode : 0,
    inputMirroring : 1,
    outputCollecting : 1,
    stdio : 'pipe',
    sync : 0,
    deasync : 0,
    onTerminate : a.ready,
  }

  _.process.start( options );

  test.is( _.consequenceIs( options.onStart ) );
  test.is( _.consequenceIs( options.onDisconnect ) );
  test.is( _.consequenceIs( options.onTerminate ) );
  test.is( _.consequenceIs( options.ready ) );
  test.is( options.onStart !== options.ready );
  test.is( options.onDisconnect !== options.ready );
  test.is( options.onTerminate === options.ready );
  debugger;

  options.onStart
  .then( ( op ) =>
  {
    test.is( options === op );
    test.identical( options.output, '' );
    test.identical( options.exitCode, null );
    test.identical( options.exitSignal, null );
    test.identical( options.ended, false );
    test.identical( options.terminationReason, null );
    test.is( !!options.process );
    return null;
  });

  options.onTerminate
  .finally( ( err, op ) =>
  {
    test.identical( op.output, 'program1:begin\nprogram1:end\n' );
    test.identical( op.exitCode, 0 );
    test.identical( op.exitSignal, null );
    test.identical( op.ended, true );
    test.identical( op.terminationReason, 'normal' );
    return null;
  });

  /* */

  return a.ready;

  /* */

  function program1()
  {
    let _ = require( toolsPath );
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, 15000 );
  }

}

startOnTerminateWithDelay.description =
`
  - consequence onStart has delay
`

//

function shellConcurrent( test )
{
  let context = this;
  let counter = 0;
  let time = 0;
  let routinePath = _.path.join( context.suiteTempPath, test.name ); /* qqq2 : rewrote all that using assetFor and _.program.* */
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

  logger.log( 'this is ❮foreground : bright white❯an❮foreground : default❯ experiment' ); /* qqq fix logger, please !!! */

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single';
    time = _.time.now();
    return null;
  })

  let singleOption =
  {
    execPath : 'node ' + testAppPath + ' 1000',
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

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, execPath in array';
    time = _.time.now();
    return null;
  })

  let singleExecPathInArrayOptions =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready,
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
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBeforeScalar =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleErrorBeforeScalar )
  .finally( ( err, arg ) =>
  {
    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBeforeScalar.exitCode, null );
    test.identical( singleErrorBeforeScalar.output, null );
    test.is( !_.fileProvider.fileExists( filePath ) );
    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready';
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBefore =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready,
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
    time = _.time.now();
    return null;
  })

  let subprocessesOptionsSerial =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  _.process.start( subprocessesOptionsSerial )
  .then( ( arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesError =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  _.process.start( subprocessesError )
  .finally( ( err, arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesErrorNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
    throwingExitCode : 0,
  }

  _.process.start( subprocessesErrorNonThrowing )
  .finally( ( err, arg ) =>
  {
    test.is( !err );

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrent =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( subprocessesErrorConcurrent )
  .finally( ( err, arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrentNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
    throwingExitCode : 0,
  }

  _.process.start( subprocessesErrorConcurrentNonThrowing )
  .finally( ( err, arg ) =>
  {
    test.is( !err );

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let suprocessesConcurrentOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( suprocessesConcurrentOptions )
  .then( ( arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let suprocessesConcurrentArgumentsOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    args : [ 'second', 'argument' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( suprocessesConcurrentArgumentsOptions )
  .then( ( arg ) =>
  {
    var spent = _.time.now() - time;
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
  let routinePath = _.path.join( context.suiteTempPath, test.name );
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
    time = _.time.now();
    return null;
  })

  let singleOption2 = {}
  let singleOption =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready,
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
    time = _.time.now();
    return null;
  })

  let singleOptionWithoutSecond =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready,
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
    time = _.time.now();
    return null;
  })

  let singleExecPathInArrayOptions2 = {};
  let singleExecPathInArrayOptions =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready,
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
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBeforeScalar2 = {};
  let singleErrorBeforeScalar =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready,
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
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBefore2 = {};
  let singleErrorBefore =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready,
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
    time = _.time.now();
    return null;
  })

  let subprocessesOptionsSerial2 = {};
  let subprocessesOptionsSerial =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  var shell = _.process.starter( subprocessesOptionsSerial );
  shell( subprocessesOptionsSerial2 )

  .then( ( arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesError2 = {};
  let subprocessesError =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  var shell = _.process.starter( subprocessesError );
  shell( subprocessesError2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesErrorNonThrowing2 = {};
  let subprocessesErrorNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
    throwingExitCode : 0,
  }

  var shell = _.process.starter( subprocessesErrorNonThrowing );
  shell( subprocessesErrorNonThrowing2 )

  .then( ( arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrent2 = {};
  let subprocessesErrorConcurrent =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var shell = _.process.starter( subprocessesErrorConcurrent );
  shell( subprocessesErrorConcurrent2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrentNonThrowing2 = {};
  let subprocessesErrorConcurrentNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 10' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
    throwingExitCode : 0,
  }

  var shell = _.process.starter( subprocessesErrorConcurrentNonThrowing );
  shell( subprocessesErrorConcurrentNonThrowing2 )

  .then( ( arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesConcurrentOptions2 = {};
  let subprocessesConcurrentOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var shell = _.process.starter( subprocessesConcurrentOptions );
  shell( subprocessesConcurrentOptions2 )

  .then( ( arg ) =>
  {

    var spent = _.time.now() - time;
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
    time = _.time.now();
    return null;
  })

  let subprocessesConcurrentArgumentsOptions2 = {}
  let subprocessesConcurrentArgumentsOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    args : [ 'second', 'argument' ],
    ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var shell = _.process.starter( subprocessesConcurrentArgumentsOptions );
  shell( subprocessesConcurrentArgumentsOptions2 )

  .then( ( arg ) =>
  {

    var spent = _.time.now() - time;
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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
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
      test.is( _.strHas( o1.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg2' ]` ) );

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
      test.is( _.strHas( o1.output, `[ 'arg0', 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg0', 'arg2' ]` ) );

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
      test.is( _.strHas( o1.output, `[ 'arg1', 'arg3' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg2', 'arg3' ]` ) );

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
      test.is( _.strHas( got.output, `[ 'arg1' ]` ) );

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
      test.is( _.strHas( o1.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg1' ]` ) );

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

    return shell({ execPath :  [ 'arg1', 'arg2' ] })
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
      test.is( _.strHas( o1.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o3.output, `[ 'arg2' ]` ) );
      test.is( _.strHas( o4.output, `[ 'arg2' ]` ) );

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
      test.is( _.strHas( got.output, `[ 'arg1' ]` ) );

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
      test.is( _.strHas( got.output, `[ 'arg2' ]` ) );

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
      test.is( _.strHas( got.output, `[ 'arg3' ]` ) );

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
      test.is( _.strHas( got.output, `[ 'arg2', 'arg3' ]` ) );

      return got;
    })
  })

  return con;
}

sheller.timeOut = 60000;

//

function shellerArgs( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );

  let shellerOptions =
  {
    outputCollecting : 1,
    args : [ 'arg1', 'arg2' ],
    mode : 'spawn',
    ready
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

function shellerFields( test )
{

  test.case = 'defaults';
  var start = _.process.starter();

  test.contains( _.mapKeys( start ), _.mapKeys( _.process.start ) );
  test.identical( _.mapKeys( start.defaults ), _.mapKeys( _.process.start.body.defaults ) );
  test.identical( start.pre, _.process.start.pre );
  test.identical( start.body, _.process.start.body );
  test.identical( _.mapKeys( start.predefined ), _.mapKeys( _.process.start.body.defaults ) );

  test.case = 'execPath';
  var start = _.process.starter( 'node -v' );
  test.contains( _.mapKeys( start ), _.mapKeys( _.process.start ) );
  test.identical( _.mapKeys( start.defaults ), _.mapKeys( _.process.start.body.defaults ) );
  test.identical( start.pre, _.process.start.pre );
  test.identical( start.body, _.process.start.body );
  test.identical( _.mapKeys( start.predefined ), _.mapKeys( _.process.start.body.defaults ) );
  test.identical( start.predefined.execPath, 'node -v' );

  test.case = 'object';
  var ready = new _.Consequence().take( null )
  var start = _.process.starter
  ({
    execPath : 'node -v',
    args : [ 'arg1', 'arg2' ],
    ready
  });
  test.contains( _.mapKeys( start ), _.mapKeys( _.process.start ) );
  test.identical( _.mapKeys( start.defaults ), _.mapKeys( _.process.start.body.defaults ) );
  test.identical( start.pre, _.process.start.pre );
  test.identical( start.body, _.process.start.body );
  test.is( _.arraySetIdentical( _.mapKeys( start.predefined ), _.mapKeys( _.process.start.body.defaults ) ) );
  test.identical( start.predefined.execPath, 'node -v' );
  test.identical( start.predefined.args, [ 'arg1', 'arg2' ] );
  test.identical( start.predefined.ready, ready  );
}

//

function outputHandling( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

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

  // let modes = [ 'shell', 'spawn', 'exec', 'fork' ];
  let modes = [ 'shell', 'spawn', 'fork' ];
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
        test.identical( o.output, null );
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
        test.identical( o.output, null );
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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

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
  // let modes = [ 'shell', 'spawn', 'exec', 'fork' ];
  let modes = [ 'shell', 'spawn', 'fork' ];

  _.each( modes, ( mode ) =>
  {
    let execPath = testAppPath;
    if( mode !== 'fork' )
    execPath = 'node ' + execPath;

    _.process.start
    ({
      execPath,
      mode,
      outputGraying : 0,
      outputCollecting : 1,
      ready
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
      execPath,
      mode,
      outputGraying : 1,
      outputCollecting : 1,
      ready
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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( '  One tab' );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );
  // let modes = [ 'shell', 'spawn', 'exec', 'fork' ];
  let modes = [ 'shell', 'spawn', 'fork' ];

  test.case = 'custom logger with increased level'

  _.each( modes, ( mode ) =>
  {
    let execPath = testAppPath;
    if( mode !== 'fork' )
    execPath = 'node ' + execPath;

    let loggerOutput = '';

    let logger = new _.Logger({ output : null, onTransformEnd });
    logger.up();

    _.process.start
    ({
      execPath,
      mode,
      outputCollecting : 1,
      outputPiping : 1,
      outputDecorating : 1,
      logger,
      ready
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
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  /* */

  var ready = new _.Consequence().take( null );

  let shell = _.process.starter
  ({
    outputCollecting : 1,
    ready
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

  /* - */

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

  /* - */

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

  /* - */

  // shell
  // ({
  //   execPath : 'node ' + testAppPath,
  //   args : [ 'arg1', 'arg2' ],
  //   mode : 'exec'
  // })
  // .then( ( got ) =>
  // {
  //   test.identical( got.exitCode, 0 );
  //   test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
  //   return null;
  // })

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

  /* - */

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

  /* - */

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

  /* - */

  // shell
  // ({
  //   execPath : 'node',
  //   args : [ testAppPath, 'arg1', 'arg2' ],
  //   mode : 'exec'
  // })
  // .then( ( got ) =>
  // {
  //   test.identical( got.exitCode, 0 );
  //   test.identical( _.strCount( got.output, `[ 'arg1', 'arg2' ]` ), 1 );
  //   return null;
  // })

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
  var got = _.process.tempOpen({ sourceCode : _.bufferRawFrom( testAppCode ) });
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

function pidFrom( test )
{
  let o =
  {
    execPath : 'node -v',
  }
  let ready = _.process.start( o );
  let expected = o.process.pid;

  test.identical( _.process.pidFrom( o ), expected )
  test.identical( _.process.pidFrom( o.process ), expected )
  test.identical( _.process.pidFrom( o.process.pid ), expected )

  if( !Config.debug )
  return ready;

  test.shouldThrowErrorSync( () => _.process.pidFrom() );
  test.shouldThrowErrorSync( () => _.process.pidFrom( [] ) );
  test.shouldThrowErrorSync( () => _.process.pidFrom( {} ) );
  test.shouldThrowErrorSync( () => _.process.pidFrom( { process : {} } ) );
  test.shouldThrowErrorSync( () => _.process.pidFrom( '123' ) );

  return ready;
}

//

function isAlive( test )
{
  let o =
  {
    execPath : `node -e "setTimeout( () => { console.log( 'child terminate' ) }, 3000 )"`,
  }
  _.process.start( o );

  o.onStart.then( () =>
  {
    test.identical( _.process.isAlive( o ), true );
    test.identical( _.process.isAlive( o.process ), true );
    test.identical( _.process.isAlive( o.process.pid ), true );
    return null;
  })

  o.onTerminate.then( () =>
  {
    test.identical( _.process.isAlive( o ), false );
    test.identical( _.process.isAlive( o.process ), false );
    test.identical( _.process.isAlive( o.process.pid ), false );
    return null;
  })

  let ready = _.Consequence.AndKeep_( o.onStart, o.onTerminate );

  if( !Config.debug )
  return ready;

  ready.then( () =>
  {
    test.shouldThrowErrorSync( () => _.process.isAlive() );
    test.shouldThrowErrorSync( () => _.process.isAlive( [] ) );
    test.shouldThrowErrorSync( () => _.process.isAlive( {} ) );
    test.shouldThrowErrorSync( () => _.process.isAlive( { process : {} } ) );
    test.shouldThrowErrorSync( () => _.process.isAlive( '123' ) );

    return null;
  })

  return ready;
}

//

function statusOf( test )
{
  let o =
  {
    execPath : `node -e "setTimeout( () => { console.log( 'child terminate' ) }, 3000 )"`,
  }
  _.process.start( o );

  o.onStart.then( () =>
  {
    test.identical( _.process.statusOf( o ), 'alive' );
    test.identical( _.process.statusOf( o.process ), 'alive' );
    test.identical( _.process.statusOf( o.process.pid ), 'alive' );
    return null;
  })

  o.onTerminate.then( () =>
  {
    test.identical( _.process.statusOf( o ), 'dead' );
    test.identical( _.process.statusOf( o.process ), 'dead' );
    test.identical( _.process.statusOf( o.process.pid ), 'dead' );
    return null;
  })

  let ready = _.Consequence.AndKeep_( o.onStart, o.onTerminate );

  if( !Config.debug )
  return ready;

  ready.then( () =>
  {
    test.shouldThrowErrorSync( () => _.process.statusOf() );
    test.shouldThrowErrorSync( () => _.process.statusOf( [] ) );
    test.shouldThrowErrorSync( () => _.process.statusOf( {} ) );
    test.shouldThrowErrorSync( () => _.process.statusOf( { process : {} } ) );
    test.shouldThrowErrorSync( () => _.process.statusOf( '123' ) );

    return null;
  })

  return ready;
}

//

function kill( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testApp()
  {
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, 5000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1000, () => _.process.kill( o.process ) )

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, null );
      test.identical( got.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */


  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1000, () => _.process.kill( o.process.pid ) )

    ready.thenKeep( ( got ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( got.exitCode, 1 );
        test.identical( got.exitSignal, null );
      }
      else
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGKILL' );
      }

      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* fork */

  .thenKeep( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1000, () => _.process.kill( o.process ) )

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, null );
      test.identical( got.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */


  .thenKeep( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1000, () => _.process.kill( o.process.pid ) )

    ready.thenKeep( ( got ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( got.exitCode, 1 );
        test.identical( got.exitSignal, null );
      }
      else
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGKILL' );
      }

      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* shell */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1000, () => _.process.kill( o.process ) )

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, null );
      test.identical( got.exitSignal, 'SIGKILL' );
      if( process.platform === 'darwin' )
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      else
      test.is( _.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */


  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1000, () => _.process.kill( o.process.pid ) )

    ready.thenKeep( ( got ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( got.exitCode, 1 );
        test.identical( got.exitSignal, null );
      }
      else
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGKILL' );
      }

      if( process.platform === 'darwin' )
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      else
      test.is( _.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* exec */

  // .thenKeep( () =>
  // {
  //   var o =
  //   {
  //     execPath :  'node ' + testAppPath,
  //     mode : 'exec',
  //     outputCollecting : 1,
  //     throwingExitCode : 0
  //   }
  //
  //   let ready = _.process.start( o )
  //
  //   _.time.out( 1000, () => _.process.kill( o.process ) )
  //
  //   ready.thenKeep( ( got ) =>
  //   {
  //     test.identical( got.exitCode, null );
  //     test.identical( got.exitSignal, 'SIGKILL' );
  //     if( process.platform === 'darwin' )
  //     test.is( !_.strHas( got.output, 'Application timeout!' ) );
  //     else
  //     test.is( _.strHas( got.output, 'Application timeout!' ) );
  //     return null;
  //   })
  //
  //   return ready;
  // })
  //
  // /* */
  //
  // .thenKeep( () =>
  // {
  //   var o =
  //   {
  //     execPath :  'node ' + testAppPath,
  //     mode : 'exec',
  //     outputCollecting : 1,
  //     throwingExitCode : 0
  //   }
  //
  //   let ready = _.process.start( o )
  //
  //   _.time.out( 1000, () => _.process.kill( o.process.pid ) )
  //
  //   ready.thenKeep( ( got ) =>
  //   {
  //     if( process.platform === 'win32' )
  //     {
  //       test.identical( got.exitCode, 1 );
  //       test.identical( got.exitSignal, null );
  //     }
  //     else
  //     {
  //       test.identical( got.exitCode, null );
  //       test.identical( got.exitSignal, 'SIGKILL' );
  //     }
  //
  //     if( process.platform === 'darwin' )
  //     test.is( !_.strHas( got.output, 'Application timeout!' ) );
  //     else
  //     test.is( _.strHas( got.output, 'Application timeout!' ) );
  //     return null;
  //   })
  //
  //   return ready;
  // })

  // qqq Vova : find how to simulate EPERM error using process.kill and write test case

  /* */

  return con;
}

//

function killWithChildren( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testApp()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'inherit',
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o );
    process.send( o.process.pid )
  }

  function testApp2()
  {
    if( process.send )
    process.send( process.pid );
    setTimeout( () => { console.log( 'Application timeout' ) }, 5000 )
  }

  function testApp3()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let detaching = process.argv[ 2 ] === 'detached';
    var o1 =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      detaching,
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o1 );
    var o2 =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      detaching,
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o2 );
    process.send( [ o1.process.pid, o2.process.pid ] )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  var testAppPath3 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp3.js' ) );
  var testAppCode3 = context.toolsPathInclude + testApp3.toString() + '\ntestApp3();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );
  _.fileProvider.fileWrite( testAppPath3, testAppCode3 );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    test.case = 'child -> child, kill first child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid, killed;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      killed = _.process.kill({ pid : o.process.pid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return killed.then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( got.exitCode, 1 );
          test.identical( got.exitSignal, null );
        }
        else
        {
          test.identical( got.exitCode, null );
          test.identical( got.exitSignal, 'SIGKILL' );
        }
        test.identical( _.strCount( got.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( lastChildPid ) );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'child -> child, kill last child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid, killed;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      killed = _.process.kill({ pid : lastChildPid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return killed.then( () =>
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.identical( _.strCount( got.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( lastChildPid ) );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'parent -> child*'
    var o =
    {
      execPath : 'node ' + testAppPath3,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, killed;

    o.process.on( 'message', ( data ) =>
    {
      children = data.map( ( src ) => _.numberFrom( src ) )
      killed = _.process.kill({ pid : o.process.pid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return killed.then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( got.exitCode, 1 );
          test.identical( got.exitSignal, null );
        }
        else
        {
          test.identical( got.exitCode, null );
          test.identical( got.exitSignal, 'SIGKILL' );
        }
        test.identical( _.strCount( got.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( children[ 0 ] ) )
        test.is( !_.process.isAlive( children[ 1 ] ) );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'parent -> detached'
    var o =
    {
      execPath : 'node ' + testAppPath3 + ' detached',
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, killed;
    o.process.on( 'message', ( data ) =>
    {
      children = data.map( ( src ) => _.numberFrom( src ) )
      killed = _.process.kill({ pid : o.process.pid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return killed.then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( got.exitCode, 1 );
          test.identical( got.exitSignal, null );
        }
        else
        {
          test.identical( got.exitCode, null );
          test.identical( got.exitSignal, 'SIGKILL' );
        }
        test.identical( _.strCount( got.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( children[ 0 ] ) )
        test.is( !_.process.isAlive( children[ 1 ] ) );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'process is not running';
    var o =
    {
      execPath : 'node ' + testAppPath2,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o );
    o.process.kill('SIGKILL');

    return o.ready.then( () =>
    {
      let ready = _.process.kill({ pid : o.process.pid, withChildren : 1 });
      return test.shouldThrowErrorAsync( ready );
    })

  })

  /* */

  return con;
}

//

function terminate( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctrly on node 14
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  function testApp()
  {
    _.include( 'wProcess' );
    _.process._exitHandlerRepair();
    if( process.send )
    process.send( process.pid );
    else
    console.log( 'ready' );
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, 5000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process });
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.on( 'message', () =>
    {
      _.process.terminate( o.process.pid );
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* fork */

  .thenKeep( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.on( 'message', () =>
    {
      _.process.terminate( o.process.pid );
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */

  .thenKeep( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process });
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* shell */

  /*
    zzz Vova: shell,exec modes have different behaviour on Windows,OSX and Linux
    look for solution that allow to have same behaviour on each mode
  */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.stdout.on( 'data', ( data ) =>
    {
      data = data.toString();
      if( _.strHas( data, 'ready' ))
      _.process.terminate({ process : o.process, timeOut : 0 });
    })

    ready.thenKeep( ( got ) =>
    {
      if( process.platform === 'linux' )
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGINT' );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'Application timeout!' ) );
      }
      else if( process.platform === 'win32' )
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.is( _.strHas( got.output, 'SIGINT' ) );
        test.is( !_.strHas( got.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.stdout.on( 'data', ( data ) =>
    {
      data = data.toString();
      if( _.strHas( data, 'ready' ))
      _.process.terminate({ pid : o.process.pid, timeOut : 0 });
    })

    ready.thenKeep( ( got ) =>
    {
      if( process.platform === 'linux' )
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGINT' );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'Application timeout!' ) );
      }
      else if( process.platform === 'win32' )
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.is( _.strHas( got.output, 'SIGINT' ) );
        test.is( !_.strHas( got.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /*
    zzz Vova: shell,exec modes have different behaviour on Windows,OSX and Linux
    look for solution that allow to have same behaviour on each mode
  */

  /* */

  return con;
}

//

function endStructuralSigint( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( program1 );
  let time1;
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = _.Consequence().take( null );

    let options =
    {
      execPath : mode === 'fork' ? null : 'node',
      args : programPath,
      currentPath : a.currentPath,
      throwingExitCode : 1,
      applyingExitCode : 0,
      inputMirroring : 1,
      outputCollecting : 1,
      stdio : 'pipe',
      sync : 0,
      deasync : 0,
      mode,
      ready,
    }

    _.process.start( options );

    options.onStart
    .then( ( op ) =>
    {
      test.is( options === op );
      test.identical( options.output, '' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, null );
      test.identical( options.ended, false );
      test.identical( options.terminationReason, null );
      test.is( options.onStart !== options.ready );
      test.is( options.onTerminate === options.ready );
      test.is( !!options.process );
      time1 = _.time.now();
      _.time.out( context.t1, () => options.process.kill( 'SIGINT' ) );
      return null;
    });

    options.onTerminate
    .finally( ( err, op ) =>
    {
      var dtime = _.time.now() - time1;
      test.le( dtime, context.t1*2 );
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.identical( options.output, 'program1:begin\nprogram1:end\n' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, 'SIGINT' );
      test.identical( options.ended, true );
      test.identical( options.terminationReason, 'signal' );
      return null;
    });

    /* */

    return ready;
  }

  /* */

  function program1()
  {
    let _ = require( toolsPath );
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, 15000 );
  }

}

endStructuralSigint.description =
`
 - end process with SIGINT
 - should wait 1s
 - should have proper exitSignal, exitCode and terminationReason
`

//

function endStructuralSigkill( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( program1 );
  let time1;
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = _.Consequence().take( null );

    let options =
    {
      execPath : mode === 'fork' ? null : 'node',
      args : programPath,
      currentPath : a.currentPath,
      throwingExitCode : 1,
      applyingExitCode : 0,
      inputMirroring : 1,
      outputCollecting : 1,
      stdio : 'pipe',
      sync : 0,
      deasync : 0,
      mode,
      ready,
    }

    _.process.start( options );

    options.onStart
    .then( ( op ) =>
    {
      test.is( options === op );
      test.identical( options.output, '' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, null );
      test.identical( options.ended, false );
      test.identical( options.terminationReason, null );
      test.is( options.onStart !== options.ready );
      test.is( options.onTerminate === options.ready );
      test.is( !!options.process );
      time1 = _.time.now();
      _.time.out( context.t1, () => options.process.kill( 'SIGKILL' ) );
      return null;
    });

    options.onTerminate
    .finally( ( err, op ) =>
    {
      var dtime = _.time.now() - time1;
      test.le( dtime, context.t1*2 );
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.identical( options.output, 'program1:begin\n' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, 'SIGKILL' );
      test.identical( options.ended, true );
      test.identical( options.terminationReason, 'signal' );
      return null;
    });

    /* */

    return ready;
  }

  /* */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, 15000 );
  }

}

endStructuralSigkill.description =
`
 - end process with SIGKILL
 - should wait 1s
 - should have proper exitSignal, exitCode and terminationReason
`

//

function endStructuralTerminate( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( program1 );
  let time1;
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = _.Consequence().take( null );

    let options =
    {
      execPath : mode === 'fork' ? null : 'node',
      args : programPath,
      currentPath : a.currentPath,
      throwingExitCode : 1,
      applyingExitCode : 0,
      inputMirroring : 1,
      outputCollecting : 1,
      stdio : 'pipe',
      sync : 0,
      deasync : 0,
      mode,
      ready,
    }

    _.process.start( options );

    options.onStart
    .then( ( op ) =>
    {
      test.is( options === op );
      test.identical( options.output, '' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, null );
      test.identical( options.ended, false );
      test.identical( options.terminationReason, null );
      test.is( options.onStart !== options.ready );
      test.is( options.onTerminate === options.ready );
      test.is( !!options.process );
      time1 = _.time.now();
      _.time.out( context.t1, () => _.process.terminate({ process : options.process, timeOut : 5000 }) );
      return null;
    });

    options.onTerminate
    .finally( ( err, op ) =>
    {
      var dtime = _.time.now() - time1;
      test.le( dtime, context.t1*2 );
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.identical( options.output, 'program1:begin\n' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, 'SIGINT' );
      test.identical( options.ended, true );
      test.identical( options.terminationReason, 'signal' );
      return null;
    });

    /* */

    return ready;
  }

  /* */

  function program1()
  {
    let _ = require( toolsPath );
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, 15000 );
  }

}

endStructuralTerminate.description =
`
 - end process with _.process.terminate()
 - should wait 1s
 - should have proper exitSignal, exitCode and terminationReason
`

//

function endStructuralKill( test )
{
  let context = this;
  let a = test.assetFor( false );
  let programPath = a.program( program1 );
  let time1;
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  function run( mode )
  {
    let ready = _.Consequence().take( null );

    let options =
    {
      execPath : mode === 'fork' ? null : 'node',
      args : programPath,
      currentPath : a.currentPath,
      throwingExitCode : 1,
      applyingExitCode : 0,
      inputMirroring : 1,
      outputCollecting : 1,
      stdio : 'pipe',
      sync : 0,
      deasync : 0,
      mode,
      ready,
    }

    test.case = `mode:${mode}`;

    _.process.start( options );

    options.onStart
    .then( ( op ) =>
    {
      test.is( options === op );
      test.identical( options.output, '' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, null );
      test.identical( options.ended, false );
      test.identical( options.terminationReason, null );
      test.is( options.onStart !== options.ready );
      test.is( options.onTerminate === options.ready );
      test.is( !!options.process );
      time1 = _.time.now();
      _.time.out( context.t1, () => _.process.kill( options.process ) );
      return null;
    });

    options.onTerminate
    .finally( ( err, op ) =>
    {
      var dtime = _.time.now() - time1;
      test.le( dtime, context.t1*2 );
      _.errAttend( err );
      test.is( _.errIs( err ) );
      test.identical( options.output, 'program1:begin\n' );
      test.identical( options.exitCode, null );
      test.identical( options.exitSignal, 'SIGKILL' );
      test.identical( options.ended, true );
      test.identical( options.terminationReason, 'signal' );
      return null;
    });

    /* */

    return ready;
  }

  /* */

  function program1()
  {
    let _ = require( toolsPath );
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, 15000 );
  }

}

endStructuralKill.description =
`
 - end process with _.process.kill()
 - should wait 1s
 - should have proper exitSignal, exitCode and terminationReason
`

//

function terminateComplex( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctly in all scenarios
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  function testApp()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let detaching = process.argv[ 2 ] === 'detached';
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'inherit',
      detaching,
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o );
    _.time.out( 1000, () =>
    {
      console.log( o.process.pid )
      if( process.send )
      process.send( o.process.pid )
    })
  }

  function testApp2()
  {
    process.on( 'SIGINT', () =>
    {
      console.log( 'second child SIGINT' )
      var fs = require( 'fs' );
      var path = require( 'path' )
      fs.writeFileSync( path.join( __dirname, process.pid.toString() ), process.pid.toString() )
      process.exit( 0 );
    })
    if( process.send )
    process.send( process.pid );
    setTimeout( () => {}, 5000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    test.case = 'Sending signal to other process'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      _.process.terminate({ pid : lastChildPid });
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.identical( _.strCount( got.output, 'SIGINT' ), 1 );
      test.identical( _.strCount( got.output, 'second child SIGINT' ), 1 );
      test.is( !_.process.isAlive( o.process.pid ) )
      test.is( !_.process.isAlive( lastChildPid ) );
      return null;
    })

    return ready;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'Sending signal to child process has regular child process that should exit with parent'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      _.process.terminate({ pid : o.process.pid });
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.identical( _.strCount( got.output, 'SIGINT' ), 1 );
      test.is( !_.process.isAlive( o.process.pid ) )
      test.is( !_.process.isAlive( lastChildPid ) );
      return null;
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'Sending signal to child process has regular child process that should exit with parent'
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      _.process.terminate({ pid : o.process.pid });
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.identical( _.strCount( got.output, 'SIGINT' ), 1 );
      test.is( !_.process.isAlive( o.process.pid ) )
      test.is( !_.process.isAlive( lastChildPid ) );
      return null;
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'Sending signal to child process has regular child process that should exit with parent'
    var o =
    {
      execPath : 'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid;

    o.process.stdout.on( 'data', ( data ) =>
    {
      data = data.toString();
      lastChildPid = _.numberFrom( data );
      _.process.terminate({ pid : o.process.pid });
    })

    ready.thenKeep( ( got ) =>
    {
      if( process.platform === 'linux' )
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGINT' );
      }
      else
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
      }
      test.is( !_.process.isAlive( o.process.pid ) )
      test.is( !_.process.isAlive( lastChildPid ) );
      return null;
    })

    return ready;
  })

  /* - */

  // .thenKeep( () =>
  // {
  //   test.case = 'Sending signal to child process has regular child process that should exit with parent'
  //   var o =
  //   {
  //     execPath : 'node ' + testAppPath,
  //     mode : 'exec',
  //     outputCollecting : 1,
  //     throwingExitCode : 0
  //   }
  //
  //   let ready = _.process.start( o );
  //   let lastChildPid;
  //
  //   o.process.stdout.on( 'data', ( data ) =>
  //   {
  //     data = data.toString();
  //     lastChildPid = _.numberFrom( data );
  //     _.process.terminate({ pid : o.process.pid });
  //   })
  //
  //   ready.thenKeep( ( got ) =>
  //   {
  //     if( process.platform === 'linux' )
  //     {
  //       test.identical( got.exitCode, null );
  //       test.identical( got.exitSignal, 'SIGINT' );
  //     }
  //     else
  //     {
  //       test.identical( got.exitCode, 0 );
  //       test.identical( got.exitSignal, null );
  //     }
  //     test.is( !_.process.isAlive( o.process.pid ) )
  //     test.is( !_.process.isAlive( lastChildPid ) );
  //     return null;
  //   })
  //
  //   return ready;
  // })

  /* - */

  return con;
}

terminateComplex.timeOut = 150000;

//

function terminateDetachedComplex( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );


  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctly with detached processes
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  function testApp()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let detaching = process.argv[ 2 ] === 'detached';
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'ignore',
      detaching,
      inputMirroring : 0,
      outputPiping : 0,
      throwingExitCode : 0
    }
    _.process.start( o );
    o.onTerminate.catch( ( err ) =>
    {
      _.errAttend( err );
      return null;
    })
    if( process.send )
    process.send( o.process.pid )
    else
    {
      console.log( 'ready' )
      _.fileProvider.fileWrite( _.path.join( __dirname, 'pid' ), o.process.pid.toString() )
    }
    _.time.out( 10000, () =>
    {
      console.log( 'TerminationBegin' )
      _.procedure.terminationBegin()
      return null;
    })
  }

  function testApp2()
  {
    process.on( 'SIGINT', () =>
    {
      console.log( 'second child SIGINT' )
      process.exit( 0 );
    })
    if( process.send )
    process.send( process.pid );
    setTimeout( () =>
    {
      console.log( 'second child timeout' )
      var fs = require( 'fs' );
      var path = require( 'path' )
      fs.writeFileSync( path.join( __dirname, process.pid.toString() ), process.pid.toString() )
    }, 5000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    test.case = 'Sending signal to child process that has detached child, detached child should continue to work'
    var o =
    {
      execPath : 'node ' + testAppPath + ' detached',
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let childPid;
    o.process.on( 'message', ( data ) =>
    {
      childPid = data;
      _.process.terminate( o.process );
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'TerminationBegin' ) );
      test.is( !_.process.isAlive( o.process.pid ) )
      test.is( _.process.isAlive( _.numberFrom( childPid ) ) )
      return _.time.out( 9000, () =>
      {
        var files = _.fileProvider.dirRead( routinePath );
        test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
        test.identical( _.numberFrom( files[ 0 ] ), _.numberFrom( childPid ) );
        _.fileProvider.fileDelete( _.path.join( routinePath, files[ 0 ] ) );
        return null;
      });
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'Sending signal to child process that has detached child, detached child should continue to work'
    var o =
    {
      execPath : testAppPath + ' detached',
      mode : 'fork',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let childPid;
    o.process.on( 'message', ( data ) =>
    {
      childPid = data;
      _.process.terminate( o.process );
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'TerminationBegin' ) );
      test.is( !_.process.isAlive( o.process.pid ) )
      test.is( _.process.isAlive( _.numberFrom( childPid ) ) )
      return _.time.out( 9000, () =>
      {
        var files = _.fileProvider.dirRead( routinePath );
        test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
        test.identical( _.numberFrom( files[ 0 ] ), _.numberFrom( childPid ) );
        _.fileProvider.fileDelete( _.path.join( routinePath, files[ 0 ] ) );
        return null;
      });
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'Sending signal to child process that has detached child, detached child should continue to work'
    var o =
    {
      execPath : 'node ' + testAppPath + ' detached',
      mode : 'shell',
      outputPiping : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let childPid;
    o.process.stdout.on( 'data', ( data ) =>
    {
      data = data.toString();
      if( _.strHas( data, 'ready' ) )
      _.process.terminate({ process : o.process, timeOut : 0 });
    })

    ready.thenKeep( ( got ) =>
    {
      childPid = _.numberFrom( _.fileProvider.fileRead( _.path.join( routinePath, 'pid' ) ) );

      if( process.platform === 'linux' )
      {
        test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGINT' );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'TerminationBegin' ) );
      }
      else if( process.platform === 'win32' )
      {
        test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'TerminationBegin' ) );
      }
      else
      {
        test.is( _.process.isAlive( _.numberFrom( childPid ) ) )
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.is( _.strHas( got.output, 'SIGINT' ) );
        test.is( !_.strHas( got.output, 'TerminationBegin' ) );
      }
      return _.time.out( 9000, () =>
      {
        var files = _.fileProvider.dirRead( routinePath );
        test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
        test.identical( _.numberFrom( files[ 0 ] ), _.numberFrom( childPid ) );
        _.fileProvider.fileDelete( _.path.join( routinePath, files[ 0 ] ) );
        return null;
      });
    })

    return ready;
  })

  /* - */

  // .thenKeep( () =>
  // {
  //   test.case = 'Sending signal to child process that has detached child, detached child should continue to work'
  //   var o =
  //   {
  //     execPath : 'node ' + testAppPath + ' detached',
  //     mode : 'exec',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0
  //   }
  //
  //   let ready = _.process.start( o );
  //   let childPid;
  //   o.process.stdout.on( 'data', ( data ) =>
  //   {
  //     data = data.toString();
  //     if( _.strHas( data, 'ready' ) )
  //     _.process.terminate({ process : o.process, timeOut : 0 });
  //   })
  //
  //   ready.thenKeep( ( got ) =>
  //   {
  //     childPid = _.numberFrom( _.fileProvider.fileRead( _.path.join( routinePath, 'pid' ) ) );
  //
  //     if( process.platform === 'linux' )
  //     {
  //       test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
  //       test.identical( got.exitCode, null );
  //       test.identical( got.exitSignal, 'SIGINT' );
  //       test.is( !_.strHas( got.output, 'SIGINT' ) );
  //       test.is( _.strHas( got.output, 'TerminationBegin' ) );
  //     }
  //     else if( process.platform === 'win32' )
  //     {
  //       test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
  //       test.identical( got.exitCode, 0 );
  //       test.identical( got.exitSignal, null );
  //       test.is( !_.strHas( got.output, 'SIGINT' ) );
  //       test.is( _.strHas( got.output, 'TerminationBegin' ) );
  //     }
  //     else
  //     {
  //       test.is( _.process.isAlive( _.numberFrom( childPid ) ) )
  //       test.identical( got.exitCode, 0 );
  //       test.identical( got.exitSignal, null );
  //       test.is( _.strHas( got.output, 'SIGINT' ) );
  //       test.is( !_.strHas( got.output, 'TerminationBegin' ) );
  //     }
  //     return _.time.out( 9000, () =>
  //     {
  //       var files = _.fileProvider.dirRead( routinePath );
  //       test.is( !_.process.isAlive( _.numberFrom( childPid ) ) )
  //       test.identical( _.numberFrom( files[ 0 ] ), _.numberFrom( childPid ) );
  //       _.fileProvider.fileDelete( _.path.join( routinePath, files[ 0 ] ) );
  //       return null;
  //     });
  //   })
  //
  //   return ready;
  // })

  /* - */

  return con;
}

terminateDetachedComplex.timeOut = 150000;

//

function terminateWithChildren( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctly with detached processes
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  function testApp()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'inherit',
      ipc : 1,
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o );
    o.process.on( 'message', () => process.send( o.process.pid ) )
    setTimeout( () => {}, 5000 )
  }

  function testApp2()
  {
    process.on( 'SIGINT', () =>
    {
      console.log( 'SIGINT CHILD' )
      var fs = require( 'fs' );
      var path = require( 'path' )
      fs.writeFileSync( path.join( __dirname, process.pid.toString() ), process.pid.toString() )
      process.exit( 0 );
    })
    if( process.send )
    process.send( process.pid );
    setTimeout( () => {}, 5000 )
  }

  function testApp3()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let detaching = process.argv[ 2 ] === 'detached';
    let c1 = new _.Consequence();
    let c2 = new _.Consequence();

    var o1 =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      detaching,
      ipc : 1,
      stdio : 'inherit',
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o1 );
    o1.process.on( 'message', () => c1.take( o1.process.pid ) )

    var o2 =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      detaching,
      ipc : 1,
      stdio : 'inherit',
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o2 );
    o2.process.on( 'message', () => c2.take( o2.process.pid ) )

    _.Consequence.AndKeep_( c1, c2 )
    .then( () =>
    {
      process.send([ o1.process.pid, o2.process.pid ]);
      return null;
    })
    setTimeout( () => {}, 5000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  var testAppPath3 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp3.js' ) );
  var testAppCode3 = context.toolsPathInclude + testApp3.toString() + '\ntestApp3();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );
  _.fileProvider.fileWrite( testAppPath3, testAppCode3 );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    test.case = 'child -> child, kill first child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid, terminated;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      terminated = _.process.terminate({ pid : o.process.pid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return terminated.then( () =>
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.identical( _.strCount( got.output, 'SIGINT' ), 2 );
        test.identical( _.strCount( got.output, 'SIGINT CHILD' ), 1 );
        test.is( !_.process.isAlive( o.process.pid ) )
        test.is( !_.process.isAlive( lastChildPid ) );
        var file = _.fileProvider.fileRead( _.path.join( routinePath, lastChildPid.toString() ) );
        test.identical( file, lastChildPid.toString() )
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'child -> child, kill last child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let lastChildPid, terminated;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      terminated = _.process.terminate({ pid : lastChildPid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return terminated.then( () =>
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.identical( _.strCount( got.output, 'SIGINT' ), 1 );
        test.identical( _.strCount( got.output, 'SIGINT CHILD' ), 1 );
        test.is( !_.process.isAlive( o.process.pid ) )
        test.is( !_.process.isAlive( lastChildPid ) );
        var file = _.fileProvider.fileRead( _.path.join( routinePath, lastChildPid.toString() ) );
        test.identical( file, lastChildPid.toString() )
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'parent -> child*'
    var o =
    {
      execPath : 'node ' + testAppPath3,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, terminated;
    o.process.on( 'message', ( data ) =>
    {
      children = data.map( ( src ) => _.numberFrom( src ) )
      terminated = _.process.terminate({ pid : o.process.pid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return terminated.then( () =>
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.identical( _.strCount( got.output, 'SIGINT' ), 3 );
        test.identical( _.strCount( got.output, 'SIGINT CHILD' ), 2 );
        test.is( !_.process.isAlive( o.process.pid ) )
        test.is( !_.process.isAlive( children[ 0 ] ) );
        test.is( !_.process.isAlive( children[ 1 ] ) );
        var file = _.fileProvider.fileRead( _.path.join( routinePath, children[ 0 ].toString() ) );
        test.identical( file, children[ 0 ].toString() )
        var file = _.fileProvider.fileRead( _.path.join( routinePath, children[ 1 ].toString() ) );
        test.identical( file, children[ 1 ].toString() )
        return null;
      })

    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'process is not running';
    var o =
    {
      execPath : 'node ' + testAppPath2,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o );
    o.process.kill('SIGKILL');

    return o.ready.then( () =>
    {
      let ready = _.process.terminate({ pid : o.process.pid, withChildren : 1 });
      return test.shouldThrowErrorAsync( ready );
    })

  })

  /* */

  return con;
}

//

function terminateWithDetachedChildren( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctly with detached processes
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  function testApp()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'inherit',
      inputMirroring : 0,
      throwingExitCode : 0
    }
    _.process.start( o );
    _.time.out( 1000, () =>
    {
      process.send( o.process.pid )
    })
  }

  function testApp2()
  {
    process.on( 'SIGINT', () =>
    {
      console.log( 'SIGINT' )
      var fs = require( 'fs' );
      var path = require( 'path' )
      fs.writeFileSync( path.join( __dirname, process.pid.toString() ), process.pid.toString() )
      process.exit( 0 );
    })
    if( process.send )
    process.send( process.pid );
    setTimeout( () => {}, 5000 )
  }

  function testApp3()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let detaching = process.argv[ 2 ] === 'detached';
    var o1 =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      detaching : 1,
      stdio : 'ignore',
      outputPiping : 0,
      inputMirroring : 0,
      outputCollecting : 0,
      throwingExitCode : 0
    }
    _.process.start( o1 );
    o1.onTerminate.catch( ( err ) =>
    {
      _.errAttend( err )
      return null;
    })
    var o2 =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      detaching : 1,
      stdio : 'ignore',
      outputPiping : 0,
      inputMirroring : 0,
      outputCollecting : 0,
      throwingExitCode : 0
    }
    _.process.start( o2 );
    o2.onTerminate.catch( ( err ) =>
    {
      _.errAttend( err )
      return null;
    })
    _.time.out( 1000, () =>
    {
      process.send( [ o1.process.pid, o2.process.pid ] )
    })
    _.time.out( 4000, () =>
    {
      _.procedure.terminationBegin();
    })

  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  var testAppPath3 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp3.js' ) );
  var testAppCode3 = context.toolsPathInclude + testApp3.toString() + '\ntestApp3();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );
  _.fileProvider.fileWrite( testAppPath3, testAppCode3 );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    test.case = 'parent -> detached'
    var o =
    {
      execPath : 'node ' + testAppPath3 + ' detached',
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, terminated;
    o.process.on( 'message', ( data ) =>
    {
      children = data.map( ( src ) => _.numberFrom( src ) )
      terminated = _.process.terminate({ pid : o.process.pid, withChildren : 1 });
    })

    ready.thenKeep( ( got ) =>
    {
      return terminated.then( () =>
      {
        test.identical( got.exitCode, 0 );
        test.identical( got.exitSignal, null );
        test.is( _.strHas( got.output, 'SIGINT' ) );
        return _.time.out( 9000, () =>
        {
          /* xxx Vova : problem with termination of detached proces on Windows, child process does't receive SIGINT */
          test.is( _.fileProvider.fileExists( _.path.join( routinePath, children[ 0 ].toString() ) ) )
          test.is( _.fileProvider.fileExists( _.path.join( routinePath, children[ 1 ].toString() ) ) )
          test.is( !_.process.isAlive( o.process.pid ) )
          test.is( !_.process.isAlive( children[ 0 ] ) );
          test.is( !_.process.isAlive( children[ 1 ] ) );
          return null;
        })
      })
    })

    return ready;
  })

  /* */

  return con;
}

//

function terminateTimeOut( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctly on node14
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  function testApp()
  {
    process.on( 'SIGINT', () =>
    {
      console.log( 'SIGINT' )
    })
    if( process.send )
    process.send( process.pid );
    else
    console.log( 'ready' );
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, 10000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process, timeOut : 1000 });
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, null );
      test.identical( got.exitSignal, 'SIGKILL' );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /*  */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  testAppPath,
      mode : 'fork',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.on( 'message', () =>
    {
      _.process.terminate({ process : o.process, timeOut : 1000 });
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, null );
      test.identical( got.exitSignal, 'SIGKILL' );
      test.is( _.strHas( got.output, 'SIGINT' ) );
      test.is( !_.strHas( got.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /*  */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    o.process.stdout.on( 'data', ( data ) =>
    {
      data = data.toString();
      if( _.strHas( data, 'ready' ))
      _.process.terminate({ process : o.process });
    })

    ready.thenKeep( ( got ) =>
    {
      if( process.platform === 'linux' )
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'Application timeout!' ) );
      }
      else if( process.platform === 'darwin' )
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGKILL' );
        test.is( _.strHas( got.output, 'SIGINT' ) );
        test.is( !_.strHas( got.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( got.exitCode, null );
        test.identical( got.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( got.output, 'SIGINT' ) );
        test.is( _.strHas( got.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* - */

  // .thenKeep( () =>
  // {
  //   var o =
  //   {
  //     execPath :  'node ' + testAppPath,
  //     mode : 'exec',
  //     outputCollecting : 1,
  //     throwingExitCode : 0
  //   }
  //
  //   let ready = _.process.start( o )
  //
  //   o.process.stdout.on( 'data', ( data ) =>
  //   {
  //     data = data.toString();
  //     if( _.strHas( data, 'ready' ))
  //     _.process.terminate({ process : o.process });
  //   })
  //
  //   ready.thenKeep( ( got ) =>
  //   {
  //     if( process.platform === 'linux' )
  //     {
  //       test.identical( got.exitCode, null );
  //       test.identical( got.exitSignal, 'SIGKILL' );
  //       test.is( !_.strHas( got.output, 'SIGINT' ) );
  //       test.is( _.strHas( got.output, 'Application timeout!' ) );
  //     }
  //     else if( process.platform === 'darwin' )
  //     {
  //       test.identical( got.exitCode, null );
  //       test.identical( got.exitSignal, 'SIGKILL' );
  //       test.is( _.strHas( got.output, 'SIGINT' ) );
  //       test.is( !_.strHas( got.output, 'Application timeout!' ) );
  //     }
  //     else
  //     {
  //       test.identical( got.exitCode, null );
  //       test.identical( got.exitSignal, 'SIGKILL' );
  //       test.is( !_.strHas( got.output, 'SIGINT' ) );
  //       test.is( _.strHas( got.output, 'Application timeout!' ) );
  //     }
  //     return null;
  //   })
  //
  //   return ready;
  // })

  /*  */

  return con;
}

//

function terminateDifferentStdio( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  if( process.platform === 'win32' )
  {
    //xxx: windows-kill doesn't work correctly on node14
    //qqq: investigate if its possible to use process.kill instead of windows-kill
    test.identical( 1, 1 )
    return;
  }

  function testApp()
  {
    process.on( 'SIGINT', () =>
    {
      var fs = require( 'fs' );
      var path = require( 'path' )
      fs.writeFileSync( path.join( __dirname, process.pid.toString() ), process.pid.toString() );
      process.exit( 0 );
    })
    setTimeout( () =>
    {
      process.exit( -1 );
    }, 5000 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var expectedOutput = testAppPath + '\n';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'inherit',
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1500, () =>
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.fileProvider.fileExists( _.path.join( routinePath, o.process.pid.toString() ) ) );
      return null;
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'ignore',
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1500, () =>
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.fileProvider.fileExists( _.path.join( routinePath, o.process.pid.toString() ) ) );
      return null;
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1500, () =>
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.fileProvider.fileExists( _.path.join( routinePath, o.process.pid.toString() ) ) );
      return null;
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      ipc : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1500, () =>
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.fileProvider.fileExists( _.path.join( routinePath, o.process.pid.toString() ) ) );
      return null;
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'inherit',
      ipc : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1500, () =>
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.fileProvider.fileExists( _.path.join( routinePath, o.process.pid.toString() ) ) );
      return null;
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'ignore',
      ipc : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( 1500, () =>
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.is( _.fileProvider.fileExists( _.path.join( routinePath, o.process.pid.toString() ) ) );
      return null;
    })

    return ready;
  })

  /* */

  return con;
}

//

function children( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testApp()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      inputMirroring : 0
    }
    _.process.start( o );
    process.send( o.process.pid )
  }

  function testApp2()
  {
    if( process.send )
    process.send( process.pid );
    setTimeout( () => {}, 1500 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    test.case = 'parent -> child -> child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, lastChildPid;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      children = _.process.children( process.pid )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      var expected =
      {
        [ process.pid ] :
        {
          [ o.process.pid ] :
          {
            [ lastChildPid ] : {}
          }
        }
      }
      return children.then( ( got ) =>
      {
        test.contains( got, expected );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'parent -> child -> child, search from fist child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, lastChildPid;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data )
      children = _.process.children( o.process.pid )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      var expected =
      {
        [ o.process.pid ] :
        {
          [ lastChildPid ] : {}
        }
      }
      return children.then( ( got ) =>
      {
        test.contains( got, expected );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'parent -> child -> child, start from last child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, lastChildPid;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data )
      children = _.process.children( lastChildPid )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      var expected =
      {
        [ lastChildPid ] : {}
      }
      return children.then( ( got ) =>
      {
        test.contains( got, expected );
        return null;
      })

    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'parent -> child*'
    var o =
    {
      execPath : 'node ' + testAppPath2,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let o1 = _.mapExtend( null, o );
    let o2 = _.mapExtend( null, o );

    let r1 = _.process.start( o1 );
    let r2 = _.process.start( o2 );
    let children;

    let ready = _.Consequence.AndTake_( r1, r2 );

    o1.process.on( 'message', () =>
    {
      children = _.process.children( process.pid )
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got[ 0 ].exitCode, 0 );
      test.identical( got[ 1 ].exitCode, 0 );
      var expected =
      {
        [ process.pid ] :
        {
          [ got[ 0 ].process.pid ] : {},
          [ got[ 1 ].process.pid ] : {},
        }
      }
      return children.then( ( got ) =>
      {
        test.contains( got, expected );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'only parent'
    return _.process.children( process.pid )
    .then( ( got ) =>
    {
      test.contains( got, { [ process.pid ] : {} })
      return null;
    })
  })

  /* - */

  .thenKeep( () =>
  {
    test.case = 'process is not running';
    var o =
    {
      execPath : 'node ' + testAppPath2,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o );
    o.process.kill('SIGKILL');

    return o.ready.then( () =>
    {
      let ready = _.process.children( o.process.pid );
      return test.shouldThrowErrorAsync( ready );
    })

  })

  /* */

  return con;
}

//

function childrenAsList( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testApp()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      inputMirroring : 0
    }
    _.process.start( o );
    process.send( o.process.pid )
  }

  function testApp2()
  {
    if( process.send )
    process.send( process.pid );
    setTimeout( () => {}, 1500 )
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var con = new _.Consequence().take( null )

  /* */

  .thenKeep( () =>
  {
    test.case = 'parent -> child -> child'
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );
    let children, lastChildPid;

    o.process.on( 'message', ( data ) =>
    {
      lastChildPid = _.numberFrom( data );
      children = _.process.children({ pid : process.pid, asList : 1 })
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      return children.then( ( got ) =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( got.length, 5 );

          test.identical( got[ 0 ].pid, process.pid );
          test.identical( got[ 1 ].pid, o.process.pid );

          test.is( _.numberIs( got[ 2 ].pid ) );
          test.identical( got[ 2 ].name, 'conhost.exe' );

          test.identical( got[ 3 ].pid, lastChildPid );

          test.is( _.numberIs( got[ 4 ].pid ) );
          test.identical( got[ 4 ].name, 'conhost.exe' );

        }
        else
        {
          var expected =
          [
            process.pid,
            o.process.pid,
            lastChildPid
          ]
          test.contains( got, expected );
        }
        return null;
      })
    })

    return ready;
  })

  /*  */

  return con;
}

//

function experiment( test )
{
  let self = this;

  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

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

  /* */

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
      _.time.out( 1 ).finallyDeasyncGive();
      return null;
    })

    return con;
  }
}

experiment.experimental = 1;

//

/* qqq Vova : extend, cover kill of group of processes */

function killComplex( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );

  function testApp()
  {
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, 2500 )
  }

  function testApp2()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var testAppPath = _.fileProvider.path.nativize( _.path.join( __dirname, 'testApp.js' ) );
    var o = { execPath : 'node ' + testAppPath, throwingExitCode : 0  }
    var ready = _.process.start( o )
    process.send( o.process.pid );
    ready.then( ( got ) =>
    {
      process.send({ exitCode : o.exitCode, pid : o.process.pid, exitSignal : o.exitSignal })
      return null;
    })
    return ready;
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = context.toolsPathInclude + testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var con = new _.Consequence().take( null )

  .thenKeep( () =>
  {
    test.case = 'Kill child of child process'
    var o =
    {
      execPath :  'node ' + testAppPath2,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );

    let pid = null;
    let childOfChild = null;
    o.process.on( 'message', ( data ) =>
    {
      if( !pid )
      {
        pid = _.numberFrom( data )
        _.process.kill( pid );
      }
      else
      {
        childOfChild = data;
      }
    })

    ready.thenKeep( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.identical( got.exitSignal, null );
      test.identical( childOfChild.pid, pid );
      if( process.platform === 'win32' )
      {
        test.identical( childOfChild.exitCode, 1 );
        test.identical( childOfChild.exitSignal, null );
      }
      else
      {
        test.identical( childOfChild.exitCode, null );
        test.identical( childOfChild.exitSignal, 'SIGKILL' );
      }

      return null;
    })

    return ready;
  })

  /* */

  return con;
}

//

function realMainFile( test )
{
  if( require.main === module )
  var expected1 = __filename;
  else
  var expected1 = require.main.filename;

  test.case = 'compare with __filename path for main file';
  var got = _.fileProvider.path.nativize( _.process.realMainFile( ) );
  test.identical( got, expected1 );
};

//

function realMainDir( test )
{

  if( require.main === module )
  var file = __filename;
  else
  var file = require.main.filename;

  var expected1 = _.path.dir( file );

  test.case = 'compare with __filename path dir';
  var got = _.fileProvider.path.nativize( _.process.realMainDir( ) );
  test.identical( _.path.normalize( got ), _.path.normalize( expected1 ) );

  /* */

  test.case = 'absolute paths';
  var from = _.process.realMainDir();
  var to = _.process.realMainFile();
  var expected = _.path.name({ path : _.process.realMainFile(), full : 1 });
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  /* */

  test.case = 'absolute paths, from === to';
  var from = _.process.realMainDir();
  var to = _.process.realMainDir();
  var expected = '.';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

}

//

function effectiveMainFile( test )
{
  if( require.main === module )
  var expected1 = __filename;
  else
  var expected1 = process.argv[ 1 ];

  test.case = 'compare with __filename path for main file';
  var got = _.path.nativize( _.process.effectiveMainFile() );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.process.effectiveMainFile( 'package.json' );
    });
  }
};

//

function shellExperiment( test )
{
  let context = this;
  var routinePath = _.path.join( context.suiteTempPath, test.name );
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
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    _.process.start
    ({
      execPath : 'node testApp2.js',
      mode : 'shell',
      passingThrough : 1,
      stdio : 'inherit',
      inputMirroring : 0
    })
  }

  function testApp2()
  {
    console.log( process.argv.slice( 2 ) );
  }

  /* */

  var testAppPath = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp.js' ) );
  var testAppCode = context.toolsPathInclude + testApp.toString() + '\ntestApp();';
  _.fileProvider.fileWrite( testAppPath, testAppCode );

  var testAppPath2 = _.fileProvider.path.nativize( _.path.join( routinePath, 'testApp2.js' ) );
  var testAppCode2 = testApp2.toString() + '\ntestApp2();';
  _.fileProvider.fileWrite( testAppPath2, testAppCode2 );

  var o;
  var con = new _.Consequence().take( null );

  /* - */

  con.thenKeep( function()
  {
    test.case = 'mode : shell, passingThrough : true, no args';

    o =
    {
      execPath :  'node testApp.js *',
      currentPath : routinePath,
      mode : 'spawn',
      stdio : 'pipe'
    }

    return null;
  })
  .thenKeep( function( arg )
  {
    var options = _.mapSupplement( {}, o, commonDefaults );

    return _.process.start( options )
    .thenKeep( function()
    {
      test.identical( options.exitCode, 0 );
      test.is( _.strHas( options.output, `[ '*' ]` ) );
      return null;
    })
  })

  return con;
}

shellExperiment.timeOut = 30000;

//

var Proto =
{

  name : 'Tools.l4.ProcessBasic',
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

    t0 : 100,
    t1 : 1000,
    t2 : 5000,

  },

  tests :
  {

    //processArgsPropertiesBase,
    //processArgsMultipleCommands,
    //processArgsPaths,
    //processArgsWithSpace,

    processOnExitEvent,
    processOffExitEvent,

    exitReason,
    exitCode,

    shell,
    shellSync,
    shellSyncAsync,
    shell2,
    shellCurrentPath,
    shellCurrentPaths,
    shellFork,
    shellWithoutExecPath,

    shellSpawnSyncDeasync,
    shellSpawnSyncDeasyncThrowing,
    shellShellSyncDeasync,
    shellShellSyncDeasyncThrowing,
    shellForkSyncDeasync,
    shellForkSyncDeasyncThrowing,
    // shellExecSyncDeasync, /* qqq : ? */
    // shellExecSyncDeasyncThrowing, /* qqq : ? */

    shellMultipleSyncDeasync,
    shellDryRun,
    startWithReadyDelayStructural,

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
    shellArgumentsHandlingTrivial,
    shellArgumentsHandling,
    importantModeShell,

    startExecPathWithSpace,
    startNjsPassingThroughExecPathWithSpace,
    startPassingThroughExecPathWithSpace,

    shellProcedureTrivial,
    shellProcedureExists,

    shellTerminateHangedWithExitHandler,
    shellTerminateAfterLoopRelease,

    shellStartingDelay,
    shellStartingTime,
    // shellStartingSuspended, /* qqq : ? */
    shellAfterDeath,
    // shellAfterDeathOutput, /* qqq : ? */

    /*  */

    startDetachingModeSpawnResourceReady,
    startDetachingModeForkResourceReady,
    startDetachingModeShellResourceReady,

    startDetachingModeSpawnNoTerminationBegin,
    startDetachingModeForkNoTerminationBegin,
    startDetachingModeShellNoTerminationBegin,

    startDetachingModeSpawnTerminationBegin,
    startDetachingModeForkTerminationBegin,
    startDetachingModeShellTerminationBegin,

    startDetachingChildExitsAfterParent,
    startDetachingChildExitsBeforeParent,
    // startDetachingDisconnectedChildExistsBeforeParent, /* qqq xxx : ? */
    startDetachingChildExistsBeforeParentWaitForTermination,
    startDetachingEndCompetitorIsExecuted,

    startDetachedOutputStdioIgnore,
    startDetachedOutputStdioPipe,
    startDetachedOutputStdioInherit,

    startDetachingModeSpawnIpc,
    startDetachingModeForkIpc,
    startDetachingModeShellIpc,

    startDetachingThrowing,
    startNjsDetachingChildThrowing,
    startNjsDetachingTrivial,

    startOnStart,
    startOnTerminate,
    startNoEndBug1,
    startOnTerminateWithDelay,

    /*  */

    shellConcurrent,
    shellerConcurrent,

    sheller,
    shellerArgs,
    shellerFields,

    outputHandling,
    shellOutputStripping,
    shellLoggerOption,

    shellNormalizedExecPath,

    appTempApplication,

    pidFrom,
    isAlive,
    statusOf,

    kill,
    killWithChildren,
    terminate,
    // endStructuralSigint,
    // endStructuralSigkill,
    // endStructuralTerminate,
    // endStructuralKill,
    terminateComplex,
    terminateDetachedComplex,
    terminateWithChildren,
    terminateWithDetachedChildren, // qqq Vova:investigate and fix termination of deatched process on Windows
    terminateTimeOut,
    terminateDifferentStdio,
    children,
    childrenAsList,

    killComplex,

    realMainFile,
    realMainDir,
    effectiveMainFile,

    shellExperiment,

    /* qqq : group test routines */

  }

}

_.mapExtend( Self, Proto );

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
