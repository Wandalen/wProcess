( function _ProcessBasic_test_s( )
{

'use strict';

let Stream;

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wProcessWatcher' );

  require( '../l4_process/Basic.s' );
  Stream = require( 'stream' );
}

let _global = _global_;
let _ = _global_.wTools;
let Self = {};

/*

reset && RET=0
until [ ${RET} -ne 0 ]; do
    node wtools/abase/l4.test/ProcessBasic.test.s n:1 v:5 s:0 r:terminateDetachedComplex
    RET=$?
    sleep 1
done

reset && RET=0
until [ ${RET} -ne 0 ]; do
    node wtools/abase/l4.test/ProcessBasic.test.s n:1 v:5 s:0 r:terminateWithChildren
    RET=$?
    sleep 1
done

reset && RET=0
until [ ${RET} -ne 0 ]; do
    node wtools/abase/l4.test/ProcessBasic.test.s n:1 v:5 s:0 r:endSignalsBasic
    RET=$?
    sleep 1
done

*/

/*
### Modes in which child process terminates after signal:

| Signal  |  Windows   |   Linux    |       Mac        |
| ------- | ---------- | ---------- | ---------------- |
| SIGINT  | spawn,fork | spawn,fork | shell,spawn,fork |
| SIGKILL | spawn,fork | spawn,fork | shell,spawn,fork |

### Test routines and modes that pass test checks:

|        Routine         |  Windows   | Windows + windows-kill |   Linux    |       Mac        |
| ---------------------- | ---------- | ---------------------- | ---------- | ---------------- |
| endStructuralSigint    | spawn,fork | spawn,fork             | spawn,fork | shell,spawn,fork |
| endStructuralSigkill   | spawn,fork | spawn,fork             | spawn,fork | shell,spawn,fork |
| endStructuralTerminate |          |                      | spawn,fork | shell,spawn,fork |
| endStructuralKill      | spawn,fork | spawn,fork             | spawn,fork | shell,spawn,fork |

#### endStructuralTerminate on Windows, without windows-kill

For each mode:
exitCode : 1, exitSignal : null

Child process terminates in modes spawn and fork
Child process continues to work in mode spawn

See: doc/ProcessKillMethodsDifference.md

#### endStructuralTerminate on Windows, with windows-kill

For each mode:
exitCode : 3221225725, exitSignal : null

Child process terminates in modes spawn and fork
Child process continues to work in mode spawn

### Shell mode termination results:

| Signal  | Windows | Linux | MacOS |
| ------- | ------- | ----- | ----- |
| SIGINT  | 0       | 0     | 1     |
| SIGKILL | 0       | 0     | 1     |

0 - Child continues to work
1 - Child is terminated
*/

/*

### Info about event `close`
╔════════════════════════════════════════════════════════════════════════╗
║       mode               ipc          disconnecting      close event ║
╟────────────────────────────────────────────────────────────────────────╢
║       spawn             false             false             true     ║
║       spawn             false             true              true     ║
║       spawn             true              false             true     ║
║       spawn             true              true              false    ║
║       fork              true              false             true     ║
║       fork              true              true              false    ║
║       shell             false             false             true     ║
║       shell             false             true              true     ║
╚════════════════════════════════════════════════════════════════════════╝

Summary:

* Options `stdio` and `detaching` don't affect `close` event.
* Mode `spawn`: IPC is optionable. Event close is not called if disconnected process had IPC enabled.
* Mode `fork` : IPC is always enabled. Event close is not called if process is disconnected.
* Mode `shell` : IPC is not available. Event close is always called.
*/

/*
## Event exit

This section shows when event `exit` of child process is called. The behavior is the same for Windows,Linux and Mac.

╔════════════════════════════════════════════════════════════════════════╗
║       mode               ipc          disconnecting      event exit  ║
╟────────────────────────────────────────────────────────────────────────╢
║       spawn             false             false             true     ║
║       spawn             false             true              true     ║
║       spawn             true              false             true     ║
║       spawn             true              true              true     ║
║       fork              true              false             true     ║
║       fork              true              true              true     ║
║       shell             false             false             true     ║
║       shell             false             true              true     ║
╚════════════════════════════════════════════════════════════════════════╝

Event 'exit' is aways called. Options `stdio` and `detaching` also don't affect `exit` event.
*/

/* qqq for Yevhen : find all tests with passingThrough:1, separate them from the rest of the test
and rewrite to run process which run process to avoid influence of arguments of tester on testing
aaa : Done
*/

/*
qqq for Yevhen : remove all
`... a.path.nativize( a.program ...` -> `... a.program ...`
*/

/* qqq for Yevhen : parametrize all time delays, don't forget to leave comment of old value

use no more than one parameter in test routine

hint :
time.out
setTimeout
*/

/* qqq for Yevhen : implement for 3 modes where test routine is not implemented for 3 modes */

// --
// context
// --

function suiteBegin()
{
  let context = this;
  context.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'ProcessBasic' );
}

//

function suiteEnd()
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, '/ProcessBasic-' ) )
  _.path.tempClose( context.suiteTempPath );
}

//

function assetFor( test, name )
{
  let context = this;
  let a = test.assetFor( name );

  _.assert( _.routineIs( a.program.head ) );
  _.assert( _.routineIs( a.program.body ) );

  let oprogram = a.program;
  program_body.defaults = a.program.defaults;
  a.program = _.routineUnite( a.program.head, program_body );
  return a;

  /* */

  function program_body( o )
  {
    let locals =
    {
      context : { t0 : context.t0, t1 : context.t1, t2 : context.t2, t3 : context.t3 },
      toolsPath : _.module.resolve( 'wTools' ),
    };
    o.locals = o.locals || locals;
    _.mapSupplement( o.locals, locals );
    _.mapSupplement( o.locals.context, locals.context );
    let programPath = a.path.nativize( oprogram.body.call( a, o ) ); /* zzz : modify a.program()? */
    return programPath;
  }

}

// --
// basic
// --

function startBasic( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  /* - */

  function run( mode )
  {
    let ready = _.Consequence().take( null );
    let o2;
    let o3 =
    {
      outputPiping : 1,
      outputCollecting : 1,
      applyingExitCode : 0,
      throwingExitCode : 1
    }

    let expectedOutput =
`${programPath}:begin
${programPath}:end
`
    ready

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode} only execPath`;

      o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return _.process.start( options )
      .then( function()
      {
        test.identical( options.exitCode, 0 );
        test.identical( options.output, expectedOutput );
        return null;
      })
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode} execPath+args, null`;

      o2 =
      {
        execPath : mode === `fork` ? null : `node`,
        args : `${programPath}`,
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return _.process.start( options )
      .then( function()
      {
        test.identical( options.exitCode, 0 );
        test.identical( options.output, expectedOutput );
        return null;
      })
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode} execPath+args, empty string`;

      o2 =
      {
        execPath : mode === `fork` ? `` : `node`,
        args : `${programPath}`,
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return _.process.start( options )
      .then( function()
      {
        test.identical( options.exitCode, 0 );
        test.identical( options.output, expectedOutput );
        return null;
      })
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode} execPath+args, null, array`;

      o2 =
      {
        execPath : mode === `fork` ? null : `node`,
        args : [ `${programPath}` ],
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return _.process.start( options )
      .then( function()
      {
        test.identical( options.exitCode, 0 );
        test.identical( options.output, expectedOutput );
        return null;
      })
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode} execPath+args empty string array`;

      o2 =
      {
        execPath : mode === `fork` ? `` : `node`,
        args : [ `${programPath}` ],
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return _.process.start( options )
      .then( function()
      {
        test.identical( options.exitCode, 0 );
        test.identical( options.output, expectedOutput );
        return null;
      })
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, stdio:pipe`;

      o2 =
      {
        execPath : mode === `fork` ? null : `node`,
        args : `${programPath}`,
        mode,
        stdio : 'pipe'
      }

      var options = _.mapSupplement( null, o2, o3 );

      return _.process.start( options )
      .then( function()
      {
        test.identical( options.exitCode, 0 );
        test.identical( options.output, expectedOutput );
        return null;
      })
    })

    /* */

    .then( function( arg )
    {
      test.case = 'mode : shell, stdio : ignore';

      o2 =
      {
        execPath : mode === `fork` ? `` : `node`,
        args : `${programPath}`,
        mode,
        stdio : 'ignore',
        outputCollecting : 0,
        outputPiping : 0,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return _.process.start( options )
      .then( function()
      {
        test.identical( options.exitCode, 0 );
        test.identical( options.output, null );
        return null;
      })
    })

    /* */

    .then( function( arg )
    {
      test.case = 'shell, return good code';

      o2 =
      {
        execPath : mode === `fork` ? `${programPath} exitWithCode : 0` : `node ${programPath} exitWithCode:0`,
        outputCollecting : 1,
        stdio : 'pipe',
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return test.mustNotThrowError( _.process.start( options ) )
      .then( () =>
      {
        test.is( !options.error );
        test.identical( options.process.killed, false );
        test.identical( options.exitCode, 0 );
        test.identical( options.exitSignal, null );
        test.identical( options.process.exitCode, 0 );
        test.identical( options.process.signalCode, null );
        test.identical( options.state, 'terminated' );
        test.identical( _.strCount( options.output, ':begin' ), 1 );
        test.identical( _.strCount( options.output, ':end' ), 0 );
        return null;
      });
    })

    /* */

    .then( function( arg )
    {
      test.case = 'shell, return good code';

      o2 =
      {
        execPath : mode === `fork` ? `${programPath} exitWithCode : 1` : `node ${programPath} exitWithCode:1`,
        outputCollecting : 1,
        stdio : 'pipe',
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return test.shouldThrowErrorAsync( _.process.start( options ),
      ( err, arg ) =>
      {
        test.is( _.errIs( err ) );
        test.identical( err.reason, 'exit code' );
      })
      .then( () =>
      {
        test.is( !!options.error );
        test.identical( options.process.killed, false );
        test.identical( options.exitCode, 1 );
        test.identical( options.exitSignal, null );
        test.identical( options.process.exitCode, 1 );
        test.identical( options.process.signalCode, null );
        test.identical( options.state, 'terminated' );
        test.identical( _.strCount( options.output, ':begin' ), 1 );
        test.identical( _.strCount( options.output, ':end' ), 0 );
        return null;
      });
    })

    /* */

    .then( function( arg )
    {
      test.case = 'bad args';

      o2 =
      {
        execPath : mode === `fork` ? null : `node`,
        args : `${programPath} exitWithCode : 0`,
        outputCollecting : 1,
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );

      return test.shouldThrowErrorAsync( _.process.start( options ),
      ( err, arg ) =>
      {
        test.is( _.errIs( err ) );
        test.identical( err.reason, 'exit code' );
      })
      .then( () =>
      {
        test.is( !!options.error );
        test.identical( options.exitCode, 1 );
        test.identical( options.exitSignal, null );
        test.identical( options.state, 'terminated' );
        test.identical( _.strCount( options.output, ':begin' ), 0 );
        test.identical( _.strCount( options.output, ':end' ), 0 );
        return null;
      });
    })

    /* - */

    return ready;
  }

  /* - */

  function program1()
  {
    console.log( `${__filename}:begin` );
    let _ = require( toolsPath );
    let process = _global_.process;

    _.include( 'wProcess' );

    var args = _.process.input();

    if( args.map.exitWithCode !== undefined )
    process.exit( args.map.exitWithCode )

    if( args.map.loop )
    _.time.out( context.t2 ); /* 5000 */

    console.log( `${__filename}:end` );
  }
}

//

function startBasic2( test ) /* qqq for Evhen : merge with test routine startBasic */
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let o3 =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1
  }

  let o2;

  a.ready.then( function()
  {
    test.case = 'mode : shell';

    o2 =
    {
      execPath :  'node ' + programPath,
      args : [ 'staging', 'debug' ],
      mode : 'shell',
      stdio : 'pipe'
    }
    return null;
  })
  .then( function( arg )
  {
    /* mode : shell, stdio : pipe */

    var options = _.mapSupplement( null, o2, o3 );

    return _.process.start( options )
    .then( function()
    {
      test.identical( options.exitCode, 0 );
      test.identical( options.output, o2.args.join( ' ' ) + '\n' );
      return null;
    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'mode : spawn, passingThrough : true, incorrect usage of o.path in spawn mode';

    o2 =
    {
      execPath :  'node ' + testApp,
      args : [ 'staging' ],
      mode : 'spawn',
      passingThrough : 1,
      stdio : 'pipe'
    }
    return null;
  })
  .then( function( arg )
  {
    var options = _.mapSupplement( null, o2, o3 );
    return test.shouldThrowErrorAsync( _.process.start( options ) );
  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ).join( ' ' ) );
  }
}

//

/*

  zzz : investigate please
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


function startFork( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program1 );

  /* */

  a.ready.then( function()
  {
    test.case = 'no args';

    let o =
    {
      execPath : programPath,
      args : null,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.process.start( o )
    .then( function( op )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output, '[]' ) );
      return null;
    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'args';

    let o =
    {
      execPath : programPath,
      args : [ 'arg1', 'arg2' ],
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.process.start( o )
    .then( function( op )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output,  `[ 'arg1', 'arg2' ]` ) );
      return null;
    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'stdio : ignore';

    let o =
    {
      execPath : programPath,
      args : [ 'arg1', 'arg2' ],
      mode : 'fork',
      stdio : 'ignore',
      outputCollecting : 0,
      outputPiping : 0,
    }

    return _.process.start( o )
    .then( function( op )
    {
      test.identical( o.exitCode, 0 );
      test.identical( o.output, null );
      return null;
    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'complex';

    function testApp2()
    {
      console.log( process.argv.slice( 2 ) );
      console.log( process.env );
      console.log( process.cwd() );
      console.log( process.execArgv );
    }

    let programPath = a.program( testApp2 );

    let o =
    {
      execPath : programPath,
      currentPath : a.routinePath,
      env : { 'key1' : 'val' },
      args : [ 'arg1', 'arg2' ],
      interpreterArgs : [ '--no-warnings' ],
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }
    return _.process.start( o )
    .then( function( op )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output,  `[ 'arg1', 'arg2' ]` ) );
      test.is( _.strHas( o.output,  `key1: 'val'` ) );
      test.is( _.strHas( o.output,  a.path.nativize( a.routinePath ) ) );
      test.is( _.strHas( o.output,  `[ '--no-warnings' ]` ) );

      return null;
    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'complex + deasync';

    function testApp3()
    {
      console.log( process.argv.slice( 2 ) );
      console.log( process.env );
      console.log( process.cwd() );
      console.log( process.execArgv );
    }

    let programPath = a.program( testApp3 );

    let o =
    {
      execPath :   programPath,
      currentPath : a.routinePath,
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
    debugger
    test.identical( o.exitCode, 0 );
    test.is( _.strHas( o.output,  `[ 'arg1', 'arg2' ]` ) );
    test.is( _.strHas( o.output,  `key1: 'val'` ) );
    test.is( _.strHas( o.output,  a.path.nativize( a.routinePath ) ) );
    test.is( _.strHas( o.output,  `[ '--no-warnings' ]` ) );

    return null;
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'test is ipc works';

    function testApp4()
    {
      process.on( 'message', ( e ) =>
      {
        process.send({ message : 'child received ' + e.message })
        process.exit();
      })
    }

    let programPath = a.program( testApp4 );

    let o =
    {
      execPath :   programPath,
      mode : 'fork',
      stdio : 'pipe',
    }

    let gotMessage;
    let con = _.process.start( o );

    o.process.send({ message : 'message from parent' });
    o.process.on( 'message', ( e ) =>
    {
      gotMessage = e.message;
    })

    con.then( function( op )
    {
      test.identical( gotMessage, 'child received message from parent' )
      test.identical( o.exitCode, 0 );
      return null;
    })

    return con;
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'execPath can contain path to js file and arguments';

    let o =
    {
      execPath :   programPath + ' arg0',
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
    }

    return _.process.start( o )
    .then( function( op )
    {
      test.identical( o.exitCode, 0 );
      test.is( _.strHas( o.output,  `[ 'arg0' ]` ) );
      return null;
    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'test timeOut';

    function testApp5()
    {
      setTimeout( () =>
      {
        console.log( 'timeOut' );
      }, context.t2 ) /* 5000 */
    }

    let programPath = a.program( testApp5 );

    let o =
    {
      execPath :   programPath,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 1,
      timeOut : 1000,
    }

    return test.shouldThrowErrorAsync( _.process.start( o ) )
    .then( function( op )
    {
      test.identical( o.exitCode, null );
      return null;
    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = 'test timeOut';

    function testApp6()
    {
      setTimeout( () =>
      {
        console.log( 'timeOut' );
      }, context.t2 ) /* 5000 */
    }

    let programPath = a.program( testApp6 );

    let o =
    {
      execPath :   programPath,
      mode : 'fork',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      timeOut : 1000,
    }

    return _.process.start( o )
    .then( function( op )
    {
      test.identical( o.exitCode, null );
      return null;
    })
  })

  return a.ready;

  /* - */

  function program1()
  {
    console.log( process.argv.slice( 2 ) );
  }

}

//

function startErrorHandling( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( function()
    {
      test.case = `mode : ${ mode }; collecting, verbosity and piping off`;

      let o =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        stdio : 'pipe',
        verbosity : 0,
        outputCollecting : 0,
        outputPiping : 0
      }
      return test.shouldThrowErrorAsync( _.process.start( o ) )
      .then( function( op )
      {
        test.is( _.errIs( op ) );
        test.is( _.strHas( op.message, 'Process returned exit code' ) )
        test.is( _.strHas( op.message, 'Launched as' ) )
        test.is( _.strHas( op.message, 'Stderr' ) )
        test.is( _.strHas( op.message, 'Error message from child' ) )

        test.notIdentical( o.exitCode, 0 );

        return null;
      })

    })

    /* */

    ready.then( function()
    {
      test.case = `mode : ${ mode }; sync, collecting, verbosity and piping off`;

      let o =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        stdio : 'pipe',
        sync : 1,
        deasync : mode === 'fork' ? 1 : 0,
        verbosity : 0,
        outputCollecting : 0,
        outputPiping : 0
      }
      var returned = test.shouldThrowErrorSync( () => _.process.start( o ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, 'Process returned exit code' ) )
      test.is( _.strHas( returned.message, 'Launched as' ) )
      test.is( _.strHas( returned.message, 'Stderr' ) )
      test.is( _.strHas( returned.message, 'Error message from child' ) )

      test.notIdentical( o.exitCode, 0 );

      return null;

    })

    /* */

    ready.then( function()
    {
      test.case = `mode : ${ mode }; stdio ignore, sync, collecting, verbosity and piping off`;

      let o =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        stdio : 'ignore',
        sync : 1,
        deasync : mode === 'fork' ? 1 : 0,
        verbosity : 0,
        outputCollecting : 0,
        outputPiping : 0
      }
      var returned = test.shouldThrowErrorSync( () => _.process.start( o ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, 'Process returned exit code' ) )
      test.is( _.strHas( returned.message, 'Launched as' ) )
      test.is( !_.strHas( returned.message, 'Stderr' ) )
      test.is( !_.strHas( returned.message, 'Error message from child' ) )

      test.notIdentical( o.exitCode, 0 );

      return null;

    })

    /* */

    ready.then( function()
    {
      test.case = `mode : ${ mode }; stdio inherit, sync, collecting, verbosity and piping off`;

      let o =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        stdio : 'inherit',
        sync : 1,
        deasync : mode === 'fork' ? 1 : 0,
        verbosity : 0,
        outputCollecting : 0,
        outputPiping : 0
      }

      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : mode === 'fork' ? testAppPath2 : 'node ' + testAppPath2,
        mode,
        stdio : 'pipe',
        sync : 1,
        deasync : mode === 'fork' ? 1 : 0,
        verbosity : 0,
        outputPiping : 1,
        outputPrefixing : 1,
        outputCollecting : 1,
      }
      var returned = test.shouldThrowErrorSync( () => _.process.start( o2 ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, 'Process returned exit code' ) )
      test.is( _.strHas( returned.message, 'Launched as' ) )
      test.is( _.strHas( returned.message, 'Stderr' ) )
      test.is( _.strHas( returned.message, 'Error message from child' ) )

      test.is( _.strHas( o2.output, 'Process returned exit code' ) )
      test.is( _.strHas( o2.output, 'Launched as' ) )
      test.is( !_.strHas( o2.output, 'Stderr' ) )
      test.is( _.strHas( o2.output, 'Error message from child' ) )

      test.notIdentical( o2.exitCode, 0 );

      return null;

    })

    return ready;
  }

  /* */

  /* ORIGINAL */
  // a.ready.then( function()
  // {
  //   test.case = 'collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   'node ' + testAppPath,
  //     mode : 'spawn',
  //     stdio : 'pipe',
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   return test.shouldThrowErrorAsync( _.process.start( o ) )
  //   .then( function( op )
  //   {
  //     test.is( _.errIs( op ) );
  //     test.is( _.strHas( op.message, 'Process returned exit code' ) )
  //     test.is( _.strHas( op.message, 'Launched as' ) )
  //     test.is( _.strHas( op.message, 'Stderr' ) )
  //     test.is( _.strHas( op.message, 'Error message from child' ) )

  //     test.notIdentical( o.exitCode, 0 );

  //     return null;
  //   })

  // })

  // /* */

  // a.ready.then( function()
  // {
  //   test.case = 'collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   'node ' + testAppPath,
  //     mode : 'shell',
  //     stdio : 'pipe',
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   return test.shouldThrowErrorAsync( _.process.start( o ) )
  //   .then( function( op )
  //   {
  //     test.is( _.errIs( op ) );
  //     test.is( _.strHas( op.message, 'Process returned exit code' ) )
  //     test.is( _.strHas( op.message, 'Launched as' ) )
  //     test.is( _.strHas( op.message, 'Stderr' ) )
  //     test.is( _.strHas( op.message, 'Error message from child' ) )

  //     test.notIdentical( o.exitCode, 0 );

  //     return null;
  //   })

  // })

  // /* */

  // a.ready.then( function()
  // {
  //   test.case = 'collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   testAppPath,
  //     mode : 'fork',
  //     stdio : 'pipe',
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   return test.shouldThrowErrorAsync( _.process.start( o ) )
  //   .then( function( op )
  //   {
  //     test.is( _.errIs( op ) );
  //     test.is( _.strHas( op.message, 'Process returned exit code' ) )
  //     test.is( _.strHas( op.message, 'Launched as' ) )
  //     test.is( _.strHas( op.message, 'Stderr' ) )
  //     test.is( _.strHas( op.message, 'Error message from child' ) )

  //     test.notIdentical( o.exitCode, 0 );

  //     return null;
  //   })

  // })

  // /* */

  // a.ready.then( function()
  // {
  //   test.case = 'sync, collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   'node ' + testAppPath,
  //     mode : 'spawn',
  //     stdio : 'pipe',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   var returned = test.shouldThrowErrorSync( () => _.process.start( o ) )

  //   test.is( _.errIs( returned ) );
  //   test.is( _.strHas( returned.message, 'Process returned exit code' ) )
  //   test.is( _.strHas( returned.message, 'Launched as' ) )
  //   test.is( _.strHas( returned.message, 'Stderr' ) )
  //   test.is( _.strHas( returned.message, 'Error message from child' ) )

  //   test.notIdentical( o.exitCode, 0 );

  //   return null;

  // })

  // /* */

  // a.ready.then( function()
  // {
  //   test.case = 'sync, collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   'node ' + testAppPath,
  //     mode : 'shell',
  //     stdio : 'pipe',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   var returned = test.shouldThrowErrorSync( () => _.process.start( o ) )

  //   test.is( _.errIs( returned ) );
  //   test.is( _.strHas( returned.message, 'Process returned exit code' ) )
  //   test.is( _.strHas( returned.message, 'Launched as' ) )
  //   test.is( _.strHas( returned.message, 'Stderr' ) )
  //   test.is( _.strHas( returned.message, 'Error message from child' ) )

  //   test.notIdentical( o.exitCode, 0 );

  //   return null;

  // })

  // /* */

  // a.ready.then( function()
  // {
  //   test.case = 'sync, collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   testAppPath,
  //     mode : 'fork',
  //     stdio : 'pipe',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   var returned = test.shouldThrowErrorSync( () => _.process.start( o ) )

  //   test.is( _.errIs( returned ) );
  //   test.is( _.strHas( returned.message, 'Process returned exit code' ) )
  //   test.is( _.strHas( returned.message, 'Launched as' ) )
  //   test.is( _.strHas( returned.message, 'Stderr' ) )
  //   test.is( _.strHas( returned.message, 'Error message from child' ) )

  //   test.notIdentical( o.exitCode, 0 );

  //   return null;

  // })

  // /* */

  // a.ready.then( function()
  // {
  //   test.case = 'stdio ignore, sync, collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath :   testAppPath,
  //     mode : 'fork',
  //     stdio : 'ignore',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }
  //   var returned = test.shouldThrowErrorSync( () => _.process.start( o ) )

  //   test.is( _.errIs( returned ) );
  //   test.is( _.strHas( returned.message, 'Process returned exit code' ) )
  //   test.is( _.strHas( returned.message, 'Launched as' ) )
  //   test.is( !_.strHas( returned.message, 'Stderr' ) )
  //   test.is( !_.strHas( returned.message, 'Error message from child' ) )

  //   test.notIdentical( o.exitCode, 0 );

  //   return null;

  // })

  // /* */

  // a.ready.then( function()
  // {
  //   test.case = 'stdio inherit, sync, collecting, verbosity and piping off';

  //   let o =
  //   {
  //     execPath : testAppPath,
  //     mode : 'fork',
  //     stdio : 'inherit',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputCollecting : 0,
  //     outputPiping : 0
  //   }

  //   a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

  //   let o2 =
  //   {
  //     execPath : testAppPath2,
  //     mode : 'fork',
  //     stdio : 'pipe',
  //     sync : 1,
  //     deasync : 1,
  //     verbosity : 0,
  //     outputPiping : 1,
  //     outputPrefixing : 1,
  //     outputCollecting : 1,
  //   }
  //   var returned = test.shouldThrowErrorSync( () => _.process.start( o2 ) )

  //   test.is( _.errIs( returned ) );
  //   test.is( _.strHas( returned.message, 'Process returned exit code' ) )
  //   test.is( _.strHas( returned.message, 'Launched as' ) )
  //   test.is( _.strHas( returned.message, 'Stderr' ) )
  //   test.is( _.strHas( returned.message, 'Error message from child' ) )

  //   test.is( _.strHas( o2.output, 'Process returned exit code' ) )
  //   test.is( _.strHas( o2.output, 'Launched as' ) )
  //   test.is( !_.strHas( o2.output, 'Stderr' ) )
  //   test.is( _.strHas( o2.output, 'Error message from child' ) )

  //   test.notIdentical( o2.exitCode, 0 );

  //   return null;

  // })

  // /* */

  // return a.ready;

  /* - */

  function program1()
  {
    throw new Error( 'Error message from child' )
  }

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wProcess' );

    let op = _.fileProvider.fileRead
    ({
      filePath : _.path.join( __dirname, 'op.json'),
      encoding : 'json'
    });

    _.process.start( op );

  }

}

// --
// sync
// --

function startSync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );

  let modes = [ 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* - */

  function run( mode )
  {
    let o3 =
    {
      outputPiping : 1,
      outputCollecting : 1,
      applyingExitCode : 0,
      throwingExitCode : 1,
      sync : 1,
    }

    /* */

    var expectedOutput = programPath + '\n';
    var o2;

    test.case = `mode : ${ mode }`;
    o2 =
    {
      execPath : 'node ' + programPath,
      mode,
      stdio : 'pipe'
    }

    /* stdio : pipe */

    var options = _.mapSupplement( {}, o2, o3 );
    _.process.start( options );
    debugger;
    test.identical( options.exitCode, 0 );
    test.identical( options.output, expectedOutput );

    /* stdio : ignore */

    o2.stdio = 'ignore';
    o2.outputCollecting = 0;
    o2.outputPiping = 0;

    var options = _.mapSupplement( {}, o2, o3 );
    _.process.start( options )
    test.identical( options.exitCode, 0 );
    test.identical( options.output, null );

    /* */

    test.case = `mode : ${ mode }, timeOut`;
    o2 =
    {
      execPath : 'node ' + programPath + ' loop : 1',
      mode,
      stdio : 'pipe',
      timeOut : 2*context.t1
    }

    var options = _.mapSupplement( {}, o2, o3 );
    test.shouldThrowErrorSync( () => _.process.start( options ) );

    /* */

    test.case = `mode : ${ mode }, return good code`;
    o2 =
    {
      execPath : 'node ' + programPath + ' exitWithCode : 0',
      mode,
      stdio : 'pipe'
    }
    var options = _.mapSupplement( {}, o2, o3 );
    test.mustNotThrowError( () => _.process.start( options ) )
    test.identical( options.exitCode, 0 );

    /* */

    test.case = `mode : ${ mode }, return exit code 1`;
    o2 =
    {
      execPath : 'node ' + programPath + ' exitWithCode : 1',
      mode,
      stdio : 'pipe'
    }
    var options = _.mapSupplement( {}, o2, o3 );
    test.shouldThrowErrorSync( () => _.process.start( options ) );
    test.identical( options.exitCode, 1 );

    /* */

    test.case = `mode : ${ mode }, return exit code 2`;
    o2 =
    {
      execPath : 'node ' + programPath + ' exitWithCode : 2',
      mode,
      stdio : 'pipe'
    }
    var options = _.mapSupplement( {}, o2, o3 );
    test.shouldThrowErrorSync( () => _.process.start( options ) );
    test.identical( options.exitCode, 2 );

    return null;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    let process = _global_.process;

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )

    process.removeAllListeners( 'SIGHUP' );
    process.removeAllListeners( 'SIGINT' );
    process.removeAllListeners( 'SIGTERM' );
    process.removeAllListeners( 'exit' );

    var args = _.process.input();

    if( args.map.exitWithCode )
    process.exit( args.map.exitWithCode )

    if( args.map.loop )
    _.time.out( context.t2 ) /* 5000 */

    console.log( __filename );
  }

  /* ORIGINAL */
  // let o3 =
  // {
  //   outputPiping : 1,
  //   outputCollecting : 1,
  //   applyingExitCode : 0,
  //   throwingExitCode : 1,
  //   sync : 1
  // }

  // /* */

  // var expectedOutput = programPath + '\n';
  // var o2;

  // /* - */

  // test.case = 'mode : spawn';
  // o2 =
  // {
  //   execPath :  'node ' + programPath,
  //   mode : 'spawn',
  //   stdio : 'pipe'
  // }

  // /* mode : spawn, stdio : pipe */

  // var options = _.mapSupplement( null, o2, o3 );
  // _.process.start( options );
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, expectedOutput );

  // /* mode : spawn, stdio : ignore */

  // o2.stdio = 'ignore';
  // o2.outputCollecting = 0;
  // o2.outputPiping = 0;

  // var options = _.mapSupplement( null, o2, o3 );
  // _.process.start( options )
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, null );

  // /* */

  // test.case = 'mode : shell';
  // o2 =
  // {
  //   execPath :  'node ' + programPath,
  //   mode : 'shell',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // _.process.start( options )
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, expectedOutput );

  // /* mode : shell, stdio : ignore */

  // o2.stdio = 'ignore'
  // o2.outputCollecting = 0;
  // o2.outputPiping = 0;

  // var options = _.mapSupplement( null, o2, o3 );
  // _.process.start( options )
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, null );

  // /* */

  // test.case = 'shell, timeOut';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' loop : 1',
  //   mode : 'shell',
  //   stdio : 'pipe',
  //   timeOut : 2*context.t1
  // }

  // var options = _.mapSupplement( null, o2, o3 );
  // test.shouldThrowErrorSync( () => _.process.start( options ) );

  // /* */

  // test.case = 'spawn, return good code';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 0',
  //   mode : 'spawn',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // test.mustNotThrowError( () => _.process.start( options ) )
  // test.identical( options.exitCode, 0 );

  // /* */

  // test.case = 'spawn, return ext code 1';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 1',
  //   mode : 'spawn',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // test.shouldThrowErrorSync( () => _.process.start( options ) );
  // test.identical( options.exitCode, 1 );

  // /* */

  // test.case = 'spawn, return ext code 2';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 2',
  //   mode : 'spawn',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // test.shouldThrowErrorSync( () => _.process.start( options ) );
  // test.identical( options.exitCode, 2 );

  // /* */

  // test.case = 'shell, return good code';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 0',
  //   mode : 'shell',
  //   stdio : 'pipe'
  // }

  // var options = _.mapSupplement( null, o2, o3 );
  // test.mustNotThrowError( () => _.process.start( options ) )
  // test.identical( options.exitCode, 0 );

  // /* */

  // test.case = 'shell, return bad code';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 1',
  //   mode : 'shell',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // test.shouldThrowErrorSync( () => _.process.start( options ) )
  // test.identical( options.exitCode, 1 );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    let process = _global_.process;

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )

    process.removeAllListeners( 'SIGHUP' );
    process.removeAllListeners( 'SIGINT' );
    process.removeAllListeners( 'SIGTERM' );
    process.removeAllListeners( 'exit' );

    var args = _.process.input();

    if( args.map.exitWithCode )
    process.exit( args.map.exitWithCode )

    if( args.map.loop )
    _.time.out( context.t2 ) /* 5000 */

    console.log( __filename );
  }
}

//

function startSyncDeasync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let o3 =
    {
      outputPiping : 1,
      outputCollecting : 1,
      applyingExitCode : 0,
      throwingExitCode : 1,
      sync : 1,
      deasync : 1
    }
    let expectedOutput = programPath + '\n';
    let o2;

    /* - */

    test.case = `mode : ${ mode }`;
    o2 =
    {
      execPath : mode === 'fork' ? programPath : 'node ' + programPath,
      mode,
      stdio : 'pipe'
    }

    /* stdio : pipe */

    var options = _.mapSupplement( {}, o2, o3 );
    var returned = _.process.start( options );
    test.is( returned === options );
    test.identical( returned.process.constructor.name, 'ChildProcess' );
    test.identical( options.exitCode, 0 );
    test.identical( options.output, expectedOutput );

    /* stdio : ignore */

    o2.stdio = 'ignore';
    o2.outputCollecting = 0;
    o2.outputPiping = 0;

    var options = _.mapSupplement( {}, o2, o3 );
    var returned = _.process.start( options );
    test.is( returned === options );
    test.identical( returned.process.constructor.name, 'ChildProcess' );
    test.identical( options.exitCode, 0 );
    test.identical( options.output, null );

    /* */

    test.case = `mode : ${ mode }, timeOut`;
    o2 =
    {
      execPath : mode === 'fork' ? programPath + ' loop : 1' : 'node ' + programPath + ' loop : 1',
      mode,
      stdio : 'pipe',
      timeOut : 2*context.t1,
    }

    var options = _.mapSupplement( {}, o2, o3 );
    test.shouldThrowErrorSync( () => _.process.start( options ) );

    /* */

    test.case = `mode : ${ mode }, return good code`;
    o2 =
    {
      execPath : mode === 'fork' ? programPath + ' exitWithCode : 0' : 'node ' + programPath + ' exitWithCode : 0',
      mode,
      stdio : 'pipe'
    }
    var options = _.mapSupplement( {}, o2, o3 );
    var returned = _.process.start( options );
    test.is( returned === options );
    test.identical( returned.process.constructor.name, 'ChildProcess' );
    test.identical( options.exitCode, 0 );

    /* */

    test.case = `mode : ${ mode }, return bad code`;
    o2 =
    {
      execPath : mode === 'fork' ? programPath + ' exitWithCode : 1' : 'node ' + programPath + ' exitWithCode : 1',
      mode,
      stdio : 'pipe'
    }
    var options = _.mapSupplement( {}, o2, o3 );
    test.shouldThrowErrorSync( () => _.process.start( options ) )
    test.identical( options.exitCode, 1 );

    return null;
  }

  // let o3 =
  // {
  //   outputPiping : 1,
  //   outputCollecting : 1,
  //   applyingExitCode : 0,
  //   throwingExitCode : 1,
  //   sync : 1,
  //   deasync : 1
  // }
  // let expectedOutput = programPath + '\n';
  // let o2;

  // /* - */

  // test.case = 'mode : fork';
  // o2 =
  // {
  //   execPath : programPath,
  //   mode : 'fork',
  //   stdio : 'pipe'
  // }

  // /* mode : spawn, stdio : pipe */

  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, expectedOutput );

  // /* mode : fork, stdio : ignore */

  // o2.stdio = 'ignore';
  // o2.outputCollecting = 0;
  // o2.outputPiping = 0;

  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, null );

  // /* */

  // test.case = 'mode : spawn';
  // o2 =
  // {
  //   execPath :  'node ' + programPath,
  //   mode : 'spawn',
  //   stdio : 'pipe'
  // }

  // /* mode : spawn, stdio : pipe */

  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, expectedOutput );

  // /* mode : spawn, stdio : ignore */

  // o2.stdio = 'ignore';
  // o2.outputCollecting = 0;
  // o2.outputPiping = 0;

  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, null );

  // /* */

  // test.case = 'mode : shell';
  // o2 =
  // {
  //   execPath :  'node ' + programPath,
  //   mode : 'shell',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, expectedOutput );

  // /* mode : shell, stdio : ignore */

  // o2.stdio = 'ignore'
  // o2.outputCollecting = 0;
  // o2.outputPiping = 0;

  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );
  // test.identical( options.output, null );

  // /* */

  // test.case = 'shell, timeOut';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' loop : 1',
  //   mode : 'shell',
  //   stdio : 'pipe',
  //   timeOut : 2*context.t1,
  // }

  // var options = _.mapSupplement( null, o2, o3 );
  // test.shouldThrowErrorSync( () => _.process.start( options ) );

  // /* */

  // test.case = 'spawn, return good code';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 0',
  //   mode : 'spawn',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );

  // /* */

  // test.case = 'spawn, return bad code';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 1',
  //   mode : 'spawn',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // test.shouldThrowErrorSync( () => _.process.start( options ) )
  // test.identical( options.exitCode, 1 );

  // /* */

  // test.case = 'shell, return good code';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 0',
  //   mode : 'shell',
  //   stdio : 'pipe'
  // }

  // var options = _.mapSupplement( null, o2, o3 );
  // var returned = _.process.start( options );
  // test.is( returned === options );
  // test.identical( returned.process.constructor.name, 'ChildProcess' );
  // test.identical( options.exitCode, 0 );

  // /* */

  // test.case = 'shell, return bad code';
  // o2 =
  // {
  //   execPath :  'node ' + programPath + ' exitWithCode : 1',
  //   mode : 'shell',
  //   stdio : 'pipe'
  // }
  // var options = _.mapSupplement( null, o2, o3 );
  // test.shouldThrowErrorSync( () => _.process.start( options ) )
  // test.identical( options.exitCode, 1 );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    let process = _global_.process;

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )

    process.removeAllListeners( 'SIGINT' );
    process.removeAllListeners( 'SIGTERM' );
    process.removeAllListeners( 'exit' );

    var args = _.process.input();

    if( args.map.exitWithCode )
    process.exit( args.map.exitWithCode )

    if( args.map.loop )
    _.time.out( context.t2 ) /* 5000 */

    console.log( __filename );
  }

}

//

function startSpawnSyncDeasync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( testApp ) );

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 0,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 0 );
    returned.then( function( op )
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      return op;
    })
    return returned;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 1,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( !_.consequenceIs( returned ) );
    test.is( returned === o );
    test.identical( returned, o );
    test.identical( o.exitCode, 0 );

    return returned;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 0,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 1 );
    returned.then( function( op )
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      return op;
    })
    return returned;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 1,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( !_.consequenceIs( returned ) );
    test.is( returned === o );
    test.identical( returned, o );
    test.identical( o.exitCode, 0 );
    return returned;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

startSpawnSyncDeasync.timeOut = 15000;

//

function startSpawnSyncDeasyncThrowing( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( testApp );

  /* */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 0,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 0 );
    return test.shouldThrowErrorAsync( returned );
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 0,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 1 );
    return test.shouldThrowErrorAsync( returned );
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'spawn',
      sync : 1,
      deasync : 1
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  return a.ready;

  /* - */

  function testApp()
  {
    throw new Error( 'Test error' );
  }
}

startSpawnSyncDeasyncThrowing.timeOut = 15000;

//

function startShellSyncDeasync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( testApp ) );

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 0,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 0 );
    returned.then( function( op )
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      return op;
    })
    return returned;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 1,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( !_.consequenceIs( returned ) );
    test.is( returned === o );
    test.identical( returned, o );
    test.identical( o.exitCode, 0 );

    return returned;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 0,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 1 );
    returned.then( function( op )
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      return op;
    })
    return returned;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 1,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( !_.consequenceIs( returned ) );
    test.is( returned === o );
    test.identical( returned, o );
    test.identical( o.exitCode, 0 );
    return returned;
  })

  /*  */

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

startShellSyncDeasync.timeOut = 15000;

//

function startShellSyncDeasyncThrowing( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( testApp );

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 0,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 0 );
    return test.shouldThrowErrorAsync( returned );
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 0,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 1 );
    return test.shouldThrowErrorAsync( returned );
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : 'node ' + programPath,
      mode : 'shell',
      sync : 1,
      deasync : 1
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  return a.ready;

  /* - */

  function testApp()
  {
    throw new Error( 'Test error' );
  }

}

startShellSyncDeasyncThrowing.timeOut = 15000;

//

function startForkSyncDeasync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( testApp );

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 0,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 0 );
    returned.then( function( op )
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      return op;
    })
    return returned;
  })

  /*  */

  if( Config.debug )
  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () => _.process.start( o ) )
    return null;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 0,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 1 );
    returned.then( function( op )
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      return op;
    })
    return returned;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 1,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( !_.consequenceIs( returned ) );
    test.is( returned === o );
    test.identical( returned, o );
    test.identical( o.exitCode, 0 );
    return returned;
  })

  /*  */

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

startForkSyncDeasync.timeOut = 15000;

//

function startForkSyncDeasyncThrowing( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( testApp );

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:0'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 0,
      deasync : 0
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 0 );
    return test.shouldThrowErrorAsync( returned );
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:0'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 1,
      deasync : 0
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:0,desync:1'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 0,
      deasync : 1
    }
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    test.identical( returned.resourcesCount(), 1 );
    return test.shouldThrowErrorAsync( returned );
  })

  /*  */

  a.ready.then( () =>
  {
    test.case = 'sync:1,desync:1'
    let o =
    {
      execPath : programPath,
      mode : 'fork',
      sync : 1,
      deasync : 1
    }
    test.shouldThrowErrorSync( () =>  _.process.start( o ) );
    return null;
  })

  /*  */

  return a.ready;

  function testApp()
  {
    throw new Error( 'Test error' );
  }
}

startForkSyncDeasyncThrowing.timeOut = 15000;

//

function startSyncDeasyncMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( testApp ) );
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 1, mode ) ) );

  return a.ready;

  /* - */

  function run( sync, deasync, mode )
  {
    test.case = `mode : ${ mode }; sync : ${ sync }; deasync : ${ deasync }`;

    let con = new _.Consequence().take( null );

    if( sync && !deasync && mode === 'fork' )
    return test.shouldThrowErrorSync( () =>
    {
      _.process.start
      ({ execPath : [ programPath, programPath ],
        mode,
        sync,
        deasync
      })
    });

    con.then( () =>
    {
      let execPath = mode === 'fork' ? [ programPath, programPath ] : [ 'node ' + programPath, 'node ' + programPath ];
      let o =
      {
        execPath,
        mode,
        sync,
        deasync
      }
      var returned = _.process.start( o );

      if( sync )
      {
        test.is( !_.consequenceIs( returned ) );
        test.is( returned === o );
        test.identical( returned.runs.length, 2 );
        test.identical( o.runs[ 0 ].exitCode, 0 );
        test.identical( o.runs[ 0 ].exitSignal, null );
        test.identical( o.runs[ 0 ].exitReason, 'normal' );
        test.identical( o.runs[ 0 ].ended, true );
        test.identical( o.runs[ 0 ].state, 'terminated' );

        test.identical( o.runs[ 1 ].exitCode, 0 );
        test.identical( o.runs[ 1 ].exitSignal, null );
        test.identical( o.runs[ 1 ].exitReason, 'normal' );
        test.identical( o.runs[ 1 ].ended, true );
        test.identical( o.runs[ 1 ].state, 'terminated' );

        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );

        return returned;
      }
      else
      {
        test.is( _.consequenceIs( returned ) );

        if( deasync )
        test.identical( returned.resourcesCount(), 1 );
        else
        test.identical( returned.resourcesCount(), 0 );

        returned.then( function( result )
        {
          // debugger;
          test.is( result === o );
          test.identical( o.runs.length, 2 );
          test.identical( o.runs[ 0 ].exitCode, 0 );
          test.identical( o.runs[ 0 ].exitSignal, null );
          test.identical( o.runs[ 0 ].exitReason, 'normal' );
          test.identical( o.runs[ 0 ].ended, true );
          test.identical( o.runs[ 0 ].state, 'terminated' );

          test.identical( o.runs[ 1 ].exitCode, 0 );
          test.identical( o.runs[ 1 ].exitSignal, null );
          test.identical( o.runs[ 1 ].exitReason, 'normal' );
          test.identical( o.runs[ 1 ].ended, true );
          test.identical( o.runs[ 1 ].state, 'terminated' );

          test.identical( o.exitCode, 0 );
          test.identical( o.exitSignal, null );
          test.identical( o.exitReason, 'normal' );
          test.identical( o.ended, true );
          test.identical( o.state, 'terminated' );

          return result;
        })
      }

      return returned;
    })

    return con;
  }

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) )
  }}

// --
// arguments
// --

function startWithoutExecPath( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( testApp ) );
  let counter = 0;
  let time = 0;
  let filePath = a.path.nativize( a.abs( a.routinePath, 'file.txt' ) );

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single';
    time = _.time.now();
    return null;
  })

  let singleOption =
  {
    args : [ 'node', programPath, '1000' ],
    ready : a.ready,
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
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
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

    setTimeout( periodic, context.t0 / 2 ); /* 50 */
    function periodic()
    {
      console.log( 'tick', process.argv.slice( 2 ).join( ', ' ) );
      if( !ended )
      setTimeout( periodic, context.t0 / 2 ); /* 50 */
    }
  }
}

//

function startArgsOption( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, args option as array, source args array should not be changed`;
      var args = [ 'arg1', 'arg2' ];
      var startOptions =
      {
        execPath : mode === 'fork' ? programPath : 'node ' + programPath,
        outputCollecting : 1,
        args,
        mode,
      }

      let con = _.process.start( startOptions )

      con.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        if( mode === 'fork' )
        test.identical( op.args, [ 'arg1', 'arg2' ] );
        else
        test.identical( op.args, [ programPath, 'arg1', 'arg2' ] );
        test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
        test.identical( startOptions.args, op.args );
        test.identical( args, [ 'arg1', 'arg2' ] );
        return null;
      })

      return con;
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, args option as string`;
      var args = 'arg1'
      var startOptions =
      {
        execPath : mode === 'fork' ? programPath : 'node ' + programPath,
        outputCollecting : 1,
        args,
        mode,
      }

      let con = _.process.start( startOptions )

      con.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        if( mode === 'fork' )
        test.identical( op.args, [ 'arg1' ] );
        else
        test.identical( op.args, [ programPath, 'arg1' ] );
        test.identical( _.strCount( op.output, 'arg1' ), 1 );
        test.identical( startOptions.args, op.args );
        test.identical( args, 'arg1' );
        return null;
      })

      return con;
    })

    return ready;
  }

  /* ORIGINAL */
  // a.ready.then( () =>
  // {
  //   test.case = 'args option as array, source args array should not be changed'
  //   var args = [ 'arg1', 'arg2' ];
  //   var startOptions =
  //   {
  //     execPath : 'node ' + programPath,
  //     outputCollecting : 1,
  //     args,
  //     mode : 'spawn',
  //   }

  //   let con = _.process.start( startOptions )

  //   con.then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( op.ended, true );
  //     test.identical( op.args, [ programPath, 'arg1', 'arg2' ] );
  //     test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
  //     test.identical( startOptions.args, op.args );
  //     test.identical( args, [ 'arg1', 'arg2' ] );
  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // a.ready.then( () =>
  // {
  //   test.case = 'args option as string'
  //   var args = 'arg1'
  //   var startOptions =
  //   {
  //     execPath : 'node ' + programPath,
  //     outputCollecting : 1,
  //     args,
  //     mode : 'spawn',
  //   }

  //   let con = _.process.start( startOptions )

  //   con.then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( op.ended, true );
  //     test.identical( op.args, [ programPath, 'arg1' ] );
  //     test.identical( _.strCount( op.output, 'arg1' ), 1 );
  //     test.identical( startOptions.args, op.args );
  //     test.identical( args, 'arg1' );
  //     return null;
  //   })

  //   return con;
  // })

  // /*  */

  // return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

//

/*
qqq for Yevhen : split shellArgumentsParsing and similar test routine by mode
*/

/* qqq for Yevhen : try to introduce subroutine for modes | aaa : Done */

function startArgumentsParsing( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPathNoSpace = a.path.nativize( a.program({ routine : testApp, dirPath : a.abs( 'noSpace' ) }) );
  let testAppPathSpace = a.path.nativize( a.program({ routine : testApp, dirPath : a.abs( 'with space' ) }) );

  /* for combination:
      path to exe file : [ with space, without space ]
      execPath : [ has arguments, only path to exe file ]
      args : [ has arguments, empty ]
      mode : [ 'fork', 'spawn', 'shell' ]
  */


  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* - */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : with space' 'execPATH : has arguments' 'args has arguments'`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"' : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
        args : [ '\'fourth arg\'',  `"fifth" arg` ],
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;

      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )
          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

          return null;
        })
      }

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : without space' 'execPATH : has arguments' 'args has arguments'`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"' : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
        args : [ '\'fourth arg\'',  `"fifth" arg` ],
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;
      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

          return null;
        })
      }

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : with space' 'execPATH : only path' 'args has arguments'`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathSpace ) : 'node ' + _.strQuote( testAppPathSpace ),
        args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;
      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) );
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } );
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] );
          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

          return null;
        })
      }

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : without space' 'execPATH : only path' 'args has arguments'`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathNoSpace ) : 'node ' + _.strQuote( testAppPathNoSpace ),
        args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;
      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

          return null;
        })
      }

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : with space' 'execPATH : has arguments' 'args: empty'`

      let con = new _.Consequence().take( null );

      let execPathStr = mode === 'shell' ? _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' \'"fifth" arg\'' : _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`';

      let o =
      {
        execPath : mode === 'fork' ? execPathStr : 'node ' + execPathStr,
        args : null,
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;
      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          /* Windows cmd supports only double quotes as grouping char, single quotes are treated as regular char*/
          if( process.platform === 'win32' )
          {
            test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' 'fifth arg'` } )
            test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', `'fourth`, `arg'`, `'fifth`, `arg'` ] )
          }
          else
          {
            test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
            test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )
          }

          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

          return null;
        })
      }

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : without space' 'execPATH : has arguments' 'args: empty'`

      let con = new _.Consequence().take( null );
      let execPathStr = mode === 'shell' ? _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' \'"fifth" arg\'' : _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`';
      let o =
      {
        execPath : mode === 'fork' ? execPathStr : 'node ' + execPathStr,
        args : null,
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;
      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          /* Windows cmd supports only double quotes as grouping char, single quotes are treated as regular char*/
          if( process.platform === 'win32' )
          {
            test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' 'fifth arg'` } )
            test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', `'fourth`, `arg'`, `'fifth`, `arg'` ] )
          }
          else
          {
            test.identical( op.map, { secondArg : '1 "third arg" "fourth arg" "fifth" arg' } )
            test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )
          }

          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
          test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

          return null;
        })
      }

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : with space' 'execPATH : only path' 'args: empty'`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathSpace ) : 'node ' + _.strQuote( testAppPathSpace ),
        args : null,
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;
      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, {} )
          test.identical( op.scriptArgs, [] )

          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, {} )
          test.identical( op.scriptArgs, [] )

          return null;
        })
      }

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, 'path to exec : without space' 'execPATH : only path' 'args: empty'`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathNoSpace ) : 'node ' + _.strQuote( testAppPathNoSpace ),
        args : null,
        ipc : mode === 'shell' ? null : 1,
        mode,
        outputPiping : 1,
        outputCollecting : mode === 'shell' ? 1 : 0,
        ready : con
      }
      _.process.start( o );

      let op;

      if( mode === 'shell' )
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          test.identical( op.map, {} )
          test.identical( op.scriptArgs, [] )

          return null;
        })
      }
      else
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
          test.identical( op.map, {} )
          test.identical( op.scriptArgs, [] )

          return null;
        })
      }

      return con;
    })

    /* */

    /* special case from willbe */

    .then( () =>
    {
      test.case = `mode : ${ mode }, 'path to exec : with space' 'execPATH : only path' 'args: willbe args'`

      debugger;
      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathSpace ) : 'node ' + _.strQuote( testAppPathSpace ),
        args : '.imply v:1 ; .each . .resources.list about::name',
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        ready : con
      }
      _.process.start( o );

      let op;
      if( mode === 'fork' )
      {
        o.process.on( 'message', ( e ) => { op = e } )

        con.then( () =>
        {
          debugger;
          test.identical( o.exitCode, 0 );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) );
          test.identical( op.map, { v : 1 } );
          test.identical( op.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] );

          return null;
        })
      }
      else
      {
        con.then( () =>
        {
          test.identical( o.exitCode, 0 );
          op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, { v : 1 } )
          test.identical( op.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

          return null;
        })
      }

      return con;
    })

    return ready;
  }

  /* ORIGINAL */
  // a.ready

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : has arguments' 'args has arguments' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
  //     args : [ '\'fourth arg\'',  `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : has arguments' 'args has arguments' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
  //     args : [ '\'fourth arg\'',  `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args has arguments' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ),
  //     args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : only path' 'args has arguments' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathNoSpace ),
  //     args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : has arguments' 'args: empty' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
  //     args : null,
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : has arguments' 'args: empty' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
  //     args : null,
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args: empty' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ),
  //     args : null,
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : only path' 'args: empty' 'fork'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathNoSpace ),
  //     args : null,
  //     ipc : 1,
  //     mode : 'fork',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* - */

  // /* - end of fork - */ /* qqq for Yevhen : split test routine by modes */

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : has arguments' 'args has arguments' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
  //     args : [ '\'fourth arg\'',  `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : has arguments' 'args has arguments' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
  //     args : [ '\'fourth arg\'',  `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args has arguments' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ),
  //     args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : only path' 'args has arguments' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
  //     args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : has arguments' 'args: empty' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
  //     args : null,
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : has arguments' 'args: empty' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' `"fifth" arg`',
  //     args : null,
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args: empty' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ),
  //     args : null,
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : only path' 'args: empty' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
  //     args : null,
  //     ipc : 1,
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : has arguments' 'args has arguments' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1 "third arg"',
  //     args : [ '\'fourth arg\'',  `"fifth" arg` ],
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )
  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : has arguments' 'args has arguments' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg"',
  //     args : [ '\'fourth arg\'',  `"fifth" arg` ],
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args has arguments' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ),
  //     args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) );
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } );
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] );
  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : only path' 'args has arguments' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
  //     args : [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', `"fifth" arg` ],
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" 'fourth arg' "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"', '\'fourth arg\'', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : has arguments' 'args: empty' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' \'"fifth" arg\'',
  //     args : null,
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : `1 "third arg" "fourth arg" "fifth" arg` } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : has arguments' 'args: empty' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ) + ' firstArg secondArg:1 "third arg" \'fourth arg\' \'"fifth" arg\'',
  //     args : null,
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, { secondArg : '1 "third arg" "fourth arg" "fifth" arg' } )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', 'third arg', 'fourth arg', '"fifth" arg' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args: empty' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ),
  //     args : null,
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : without space' 'execPATH : only path' 'args: empty' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathNoSpace ),
  //     args : null,
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathNoSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // /* special case from willbe */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args: willbe args' 'fork'`

  //   debugger;
  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ),
  //     args : '.imply v:1 ; .each . .resources.list about::name',
  //     mode : 'fork',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   let op;
  //   o.process.on( 'message', ( e ) => { op = e } )

  //   con.then( () =>
  //   {
  //     debugger;
  //     test.identical( o.exitCode, 0 );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) );
  //     test.identical( op.map, { v : 1 } );
  //     test.identical( op.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] );

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args: willbe args' 'spawn'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ),
  //     args : '.imply v:1 ; .each . .resources.list about::name',
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { v : 1 } )
  //     test.identical( op.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* - */

  // .then( () =>
  // {
  //   test.case = `'path to exec : with space' 'execPATH : only path' 'args: willbe args' 'shell'`

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ),
  //     args : '.imply v:1 ; .each . .resources.list about::name',
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { v : 1 } )
  //     test.identical( op.scriptArgs, [ '.imply v:1 ; .each . .resources.list about::name' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /*  */

  // return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    debugger;
    var args = _.process.input();
    if( process.send )
    process.send( args );
    else
    console.log( JSON.stringify( args ) );
  }

}

//

function startArgumentsParsingNonTrivial( test )
{
  let context = this;

  let a = context.assetFor( test, false );

  let testAppPathNoSpace = a.path.nativize( a.program({ routine : testApp, dirPath : a.abs( 'noSpace' ) }) );
  let testAppPathSpace = a.path.nativize( a.program({ routine : testApp, dirPath : a.abs( 'with space' ) }) );

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

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

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready

    .then( () =>
    {
      test.case = `mode : ${ mode }, args in execPath and args options`

      let con = new _.Consequence().take( null );
      let execPathStr = mode === 'shell' ? _.strQuote( testAppPathSpace ) + ` 'firstArg secondArg \":\" 1' "third arg" 'fourth arg'  '\"fifth\" arg'` : _.strQuote( testAppPathSpace ) + ' `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`';
      let o =
      {
        execPath : mode === 'fork' ? execPathStr : 'node ' + execPathStr,
        args : '"some arg"',
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        ready : con
      }
      _.process.start( o );

      con.then( () =>
      {
        test.identical( o.exitCode, 0 );
        if( mode === 'fork' )
        {
          test.identical( o.execPath, testAppPathSpace );
          test.identical( o.args, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
        }
        else if( mode === 'shell' )
        {
          test.identical( o.execPath, 'node' );
          test.identical( o.args, [ _.strQuote( testAppPathSpace ), `'firstArg secondArg \":\" 1'`, `"third arg"`, `'fourth arg'`, `'\"fifth\" arg'`, '"some arg"' ] );
        }
        else
        {
          test.identical( o.execPath, 'node' );
          test.identical( o.args, [ testAppPathSpace, 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
        }
        let op = JSON.parse( o.output );
        test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
        test.identical( op.map, {} )
        if( mode === 'shell' )
        {
          if( process.platform === 'win32' )
          test.identical( op.scriptArgs, [ `'firstArg`, `secondArg`, ':', `1'`, 'third arg', `'fourth`, `arg'`, `'fifth`, `arg'`, '"some arg"' ] )
          else
          test.identical( op.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )
        }
        else
        {
          test.identical( op.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )
        }

        return null;
      })

      return con;
    })


    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, args in execPath and args options`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1' : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
        args : '"third arg"',
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        ready : con
      }
      _.process.start( o );

      con.then( () =>
      {
        test.identical( o.exitCode, 0 );
        if( mode === 'fork' )
        {
          test.identical( o.execPath, testAppPathSpace );
          test.identical( o.args, [ 'firstArg', 'secondArg:1', '"third arg"' ] );
        }
        else if ( mode === 'shell' )
        {
          test.identical( o.execPath, 'node' );
          test.identical( o.args, [ _.strQuote( testAppPathSpace ), 'firstArg', 'secondArg:1', '"third arg"' ] );
        }
        else
        {
          test.identical( o.args, [ testAppPathSpace, 'firstArg', 'secondArg:1', '"third arg"' ] );
          test.identical( o.execPath, 'node' );
        }

        let op = JSON.parse( o.output );
        test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
        test.identical( op.map, { secondArg : '1 "third arg"' } )
        test.identical( op.subject, 'firstArg' )
        test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

        return null;
      })

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, args in execPath and args options`

      if( mode === 'shell' && process.platform === 'win32' )
      return null; /* not for windows */

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : '"first arg"',
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        throwingExitCode : 0,
        ready : con
      }
      _.process.start( o );

      con.finally( ( err, op ) =>
      {

        if( mode === 'spawn' )
        {
          test.is( !!err );
          test.is( _.strHas( err.message, 'first arg' ) )
          test.identical( o.execPath, 'first arg' );
          test.identical( o.args, [] );
        }
        else if( mode === 'fork' )
        {
          test.ni( op.exitCode, 0 );
          test.is( _.strHas( op.output, 'Error: Cannot find module' ) );
          test.identical( o.execPath, mode === 'shell' ? '"first arg"' : 'first arg' );
          test.identical( o.args, [] );
        }
        else
        {
          test.ni( op.exitCode, 0 );
          if( process.platform === 'darwin' )
          test.is( _.strHas( op.output, 'first arg: command not found' ) );
          // else if( process.platform === 'win32' )
          // test.identical
          // (
          //   op.output,
          //   `'"first arg"' is not recognized as an internal or external command,\noperable program or batch file.\n`
          // );
          // test.is( _.strHas( op.output, '"first arg"' ) );
          else
          test.identical( op.output, 'sh: 1: first arg: not found\n' )
        }
        test.identical( o.execPath, mode === 'shell' ? '"first arg"' : 'first arg' );
        test.identical( o.args, [] );

        return null;
      })

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, args in execPath and args options`

      if( mode === 'shell' && process.platform === 'win32' )
      return null; /* not for windows */

      let con = new _.Consequence().take( null );
      let o =
      {
        args : [ '"first arg"', 'second arg' ],
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        throwingExitCode : 0,
        ready : con
      }
      _.process.start( o );

      con.finally( ( err, op ) =>
      {

        if( mode === 'spawn' )
        {
          test.is( !!err );
          test.is( _.strHas( err.message, 'first arg' ) )
        }
        else if( mode === 'fork' )
        {
          test.ni( op.exitCode, 0 );
          test.is( _.strHas( op.output, 'Error: Cannot find module' ) );
        }
        else
        {
          test.ni( op.exitCode, 0 );
          if( process.platform === 'darwin' )
          test.is( _.strHas( op.output, 'first: command not found' ) );
          // else if( process.platform === 'win32' )
          // test.identical
          // (
          //   op.output,
          //   `'first' is not recognized as an internal or external command,\noperable program or batch file.\n`
          // );
          else
          test.identical( op.output, 'sh: 1: first: not found\n' )
        }
        test.identical( o.execPath, 'first arg' );
        test.identical( o.args, [ 'second arg' ] );

        return null;
      })

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, args in execPath and args options`

      /* qqq for Vova : investigate. can conditions be removed? */
      if( mode === 'shell' && process.platform === 'win32' )
      return null;
      if( mode === 'fork' )
      return null;

      let con = new _.Consequence().take( null );
      let o =
      {
        args : [ '"', 'first', 'arg', '"' ],
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        throwingExitCode : 0,
        ready : con
      }
      _.process.start( o );

      con.finally( ( err, op ) =>
      {

        if( mode === 'spawn' )
        {
          test.is( !!err );
          test.is( _.strHas( err.message, '"' ) )
        }
        else if( mode === 'fork' )
        {
          test.ni( op.exitCode, 0 );
          test.is( _.strHas( op.output, ': command not found' ) );
        }
        else
        {
          test.ni( op.exitCode, 0 );
          if( process.platform === 'darwin' )
          test.is( _.strHas( op.output, ': command not found' ) );
          // else if( process.platform === 'win32' )
          // test.identical
          // (
          //   op.output,
          //   `'" first arg "' is not recognized as an internal or external command,\noperable program or batch file.\n`
          // );
          else
          test.identical( op.output, 'sh: 1:  first arg : not found\n' );
          // test.is( _.strHas( op.output, '" first arg "' ) );
        }

        test.identical( o.execPath, '"' );
        test.identical( o.args, [ 'first', 'arg', '"' ] );

        return null;
      })

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, args in execPath and args options`

      if( mode === 'shell' && process.platform === 'win32' )
      return null; /* not for windows */
      if( mode === 'fork' )
      return null;

      let con = new _.Consequence().take( null );
      let o =
      {
        args : [ '', 'first', 'arg', '"' ],
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        throwingExitCode : 0,
        ready : con
      }
      _.process.start( o );

      con.finally( ( err, op ) =>
      {

        if( mode === 'spawn' )
        {
          test.is( !!err );
          test.identical( o.execPath, '' );
        }
        else if( mode === 'fork' )
        {
          test.ni( op.exitCode, 0 );
          test.is( _.strHas( op.output, 'unexpected EOF while looking for matching' ) );
        }
        else
        {
          test.ni( op.exitCode, 0 );
          if( process.platform === 'darwin' )
          test.is( _.strHas( op.output, 'unexpected EOF while looking for matching' ) );
          // else if( process.platform === 'win32' )
          // test.identical
          // (
          //   op.output,
          //   `'first' is not recognized as an internal or external command,\noperable program or batch file.\n`
          // );
          else
          test.identical( op.output, 'sh: 1: Syntax error: Unterminated quoted string\n' );
        }

        test.identical( o.args, [ 'first', 'arg', '"' ] );

        return null;
      })

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, args in execPath and args options`

      if( mode === 'shell' && process.platform === 'win32' )
      return null; /* not for windows */
      if( mode === 'fork' )
      return null;

      let con = new _.Consequence().take( null );
      let o =
      {
        args : [ '"', '"', 'first', 'arg', '"' ],
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        throwingExitCode : 0,
        ready : con
      }
      _.process.start( o );

      con.finally( ( err, op ) =>
      {

        if( mode === 'spawn' )
        {
          test.is( !!err );
          test.is( _.strHas( err.message, `spawn " ENOENT` ) );
        }
        else if( mode === 'fork' )
        {
          test.ni( op.exitCode, 0 );
          test.is( _.strHas( op.output, 'unexpected EOF while looking for matching' ) );
        }
        else
        {
          test.ni( op.exitCode, 0 );
          if( process.platform === 'darwin' )
          test.is( _.strHas( op.output, 'unexpected EOF while looking for matching' ) );
          // else if( process.platform === 'win32' )
          // test.identical
          // (
          //   op.output,
          //   `'" "' is not recognized as an internal or external command,\noperable program or batch file.\n`
          // );
          else
          test.identical( op.output, 'sh: 1: Syntax error: Unterminated quoted string\n' );
          // test.is( _.strHas( op.output, '" "' ) );
        }

        test.identical( o.execPath, '"' );
        test.identical( o.args, [ '"', 'first', 'arg', '"' ] );

        return null;
      })

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${mode}, no execPath, empty args`

      let con = new _.Consequence().take( null );
      let o =
      {
        args : [],
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        throwingExitCode : 0,
        ready : con
      }

      _.process.start( o );

      return test.shouldThrowErrorAsync( con );
    })

    /*  */

    .then( () =>
    {
      test.case = `mode : ${mode}, args in execPath and args options`

      let con = new _.Consequence().take( null );
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathSpace ) + ` "path/key3":'val3'` : 'node ' + _.strQuote( testAppPathSpace ) + ` "path/key3":'val3'`,
        args : [],
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        ready : con
      }
      _.process.start( o );

      con.then( () =>
      {
        test.identical( o.exitCode, 0 );
        let op = JSON.parse( o.output );
        if( mode === 'shell' )
        {
          test.identical( o.execPath, 'node' );
          test.identical( o.args, [ _.strQuote( testAppPathSpace ), `"path/key3":'val3'` ] );
          if( process.platform === 'win32' )
          test.identical( op.scriptArgs, [ `path/key3:'val3'` ] )
          else
          test.identical( op.scriptArgs, [ 'path/key3:val3' ] )
        }
        else if( mode === 'spawn' )
        {
          test.identical( o.execPath, 'node' );
          test.identical( o.args, [ testAppPathSpace, `"path/key3":'val3'` ] );
          test.identical( op.scriptArgs, [ `"path/key3":'val3'` ] )
        }
        else
        {
          test.identical( o.execPath, testAppPathSpace );
          test.identical( o.args, [ `"path/key3":'val3'` ] );
          test.identical( op.scriptArgs, [ `"path/key3":'val3'` ] )
        }
        test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
        test.identical( op.map, { 'path/key3' : 'val3' } )
        test.identical( op.subject, '' )

        return null;
      })

      return con;
    })

    /*  */

    return ready;
  }


  /* ORIGINAL */
  // a.ready

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
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ` 'firstArg secondArg \":\" 1' "third arg" 'fourth arg'  '\"fifth\" arg'`,
  //     args : '"some arg"',
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, 'node' );
  //     test.identical( o.args, [ _.strQuote( testAppPathSpace ), `'firstArg secondArg \":\" 1'`, `"third arg"`, `'fourth arg'`, `'\"fifth\" arg'`, '"some arg"' ] );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     if( process.platform === 'win32' )
  //     test.identical( op.scriptArgs, [ `'firstArg`, `secondArg`, ':', `1'`, 'third arg', `'fourth`, `arg'`, `'fifth`, `arg'`, '"some arg"' ] )
  //     else
  //     test.identical( op.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ) + ' `firstArg secondArg ":" 1` "third arg" \'fourth arg\'  `"fifth" arg`',
  //     args : '"some arg"',
  //     mode : 'fork',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, testAppPathSpace );
  //     test.identical( o.args, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, [ 'firstArg secondArg ":" 1', 'third arg', 'fourth arg', '"fifth" arg', '"some arg"' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /*  */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
  //     args : '"third arg"',
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
  //     test.identical( o.args, [ testAppPathSpace, 'firstArg', 'secondArg:1', '"third arg"' ] );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : '1 "third arg"' } )
  //     test.identical( op.subject, 'firstArg' )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : 'node ' + _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
  //     args : '"third arg"',
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, 'node' );
  //     test.identical( o.args, [ _.strQuote( testAppPathSpace ), 'firstArg', 'secondArg:1', '"third arg"' ] );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : '1 "third arg"' } )
  //     test.identical( op.subject, 'firstArg' )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ) + ' firstArg secondArg:1',
  //     args : '"third arg"',
  //     mode : 'fork',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, testAppPathSpace );
  //     test.identical( o.args, [ 'firstArg', 'secondArg:1', '"third arg"' ] );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { secondArg : '1 "third arg"' } )
  //     test.identical( op.subject, 'firstArg' )
  //     test.identical( op.scriptArgs, [ 'firstArg', 'secondArg:1', '"third arg"' ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : '"first arg"',
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.finally( ( err, op ) =>
  //   {
  //     test.is( !!err );
  //     test.is( _.strHas( err.message, 'first arg' ) )
  //     test.identical( o.execPath, 'first arg' );
  //     test.identical( o.args, [] );

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     args : '"first arg"',
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.finally( ( err, op ) =>
  //   {
  //     test.is( !!err );
  //     test.is( _.strHas( err.message, 'first arg' ) )
  //     test.identical( o.execPath, 'first arg' );
  //     test.identical( o.args, [] );

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     args : [ '"first arg"', 'second arg' ],
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.finally( ( err, op ) =>
  //   {
  //     test.is( !!err );
  //     test.is( _.strHas( err.message, 'first arg' ) )
  //     test.identical( o.execPath, 'first arg' );
  //     test.identical( o.args, [ 'second arg' ] );

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     args : [ '"', 'first', 'arg', '"' ],
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.finally( ( err, op ) =>
  //   {
  //     test.is( !!err );
  //     test.is( _.strHas( err.message, '"' ) )
  //     test.identical( o.execPath, '"' );
  //     test.identical( o.args, [ 'first', 'arg', '"' ] );

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     args : [ '', 'first', 'arg', '"' ],
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.finally( ( err, op ) =>
  //   {
  //     test.is( !!err );
  //     test.identical( o.execPath, '' );
  //     test.identical( o.args, [ 'first', 'arg', '"' ] );

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     args : [ '"', '"', 'first', 'arg', '"' ],
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.finally( ( err, op ) =>
  //   {
  //     test.is( !!err );
  //     test.is( _.strHas( err.message, `spawn " ENOENT` ) );
  //     test.identical( o.execPath, '"' );
  //     test.identical( o.args, [ '"', 'first', 'arg', '"' ] );
  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'no execPath, empty args'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     args : [],
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     throwingExitCode : 0,
  //     ready : con
  //   }

  //   _.process.start( o );

  //   return test.shouldThrowErrorAsync( con );
  // })

  // /*  */

  // .then( () =>
  // {
  //   test.case = 'args in execPath and args options'

  //   let con = new _.Consequence().take( null );
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ) + ` "path/key3":'val3'`,
  //     args : [],
  //     mode : 'fork',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     test.identical( o.execPath, testAppPathSpace );
  //     test.identical( o.args, [ `"path/key3":'val3'` ] );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, { 'path/key3' : 'val3' } )
  //     test.identical( op.subject, '' )
  //     test.identical( op.scriptArgs, [ `"path/key3":'val3'` ] )

  //     return null;
  //   })

  //   return con;
  // })

  // /*  */

  // return a.ready;


  /**/

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    var args = _.process.input();
    console.log( JSON.stringify( args ) );
  }
}

//

function startArgumentsNestedQuotes( test )
{
  let context = this;

  let a = context.assetFor( test, false );

  let testAppPathSpace = a.path.nativize( a.program({ routine : testApp, dirPath : a.abs( 'with space' ) }) );

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready

    .then( () =>
    {
      test.case = `mode : ${ mode }`;

      let con = new _.Consequence().take( null );

      let args =
      [
        ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
        ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
        ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
      ]
      let o =
      {
        execPath : mode === 'fork' ? _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ) : 'node ' + _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ),
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        ready : con
      }
      _.process.start( o );

      con.then( () =>
      {
        test.identical( o.exitCode, 0 );
        if( mode === 'shell' )
        {
          /*
          This case shows how shell is interpreting backquote on different platforms.
          It can't be used for arguments wrapping on linux/mac:
          https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html
          */
          if( process.platform === 'win32' )
          {
            let op = JSON.parse( o.output );
            test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
            test.identical( op.map, {} )
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
            test.identical( op.scriptArgs, scriptArgs )
          }
          else
          {
            test.identical( _.strCount( o.output, 'not found' ), 3 );
          }
        }
        else
        {
          test.identical( o.exitCode, 0 );
          let op = JSON.parse( o.output );
          test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
          test.identical( op.map, {} )
          let scriptArgs =
          [
            `'s-s'`, `"s-d"`, `\`s-b\``,
            `'d-s'`, `"d-d"`, `\`d-b\``,
            `'b-s'`, `"b-d"`, `\`b-b\``,
          ]
          test.identical( op.scriptArgs, scriptArgs )
        }
        return null;
      })

      return con;
    })

    /* */

    .then( () =>
    {
      test.case = `mode : ${ mode }`;

      let con = new _.Consequence().take( null );
      let args =
      [
        ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
        ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
        ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
      ]
      let o =
      {
        execPath :  mode === 'fork' ? _.strQuote( testAppPathSpace ) : 'node ' + _.strQuote( testAppPathSpace ),
        args : args.slice(),
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        ready : con
      }
      _.process.start( o );

      con.then( () =>
      {
        test.identical( o.exitCode, 0 );
        let op = JSON.parse( o.output );
        test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
        test.identical( op.map, {} )
        test.identical( op.scriptArgs, args )

        return null;
      })

      return con;
    })

    return ready;
  }

  /* */

  /* ORIGINAL */
  // a.ready

  // .then( () =>
  // {
  //   test.case = 'fork'

  //   let con = new _.Consequence().take( null );
  //   let args =
  //   [
  //     ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
  //     ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
  //     ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
  //   ]
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ) + ' ' + args.join( ' ' ),
  //     mode : 'fork',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     let scriptArgs =
  //     [
  //       `'s-s'`, `"s-d"`, `\`s-b\``,
  //       `'d-s'`, `"d-d"`, `\`d-b\``,
  //       `'b-s'`, `"b-d"`, `\`b-b\``,
  //     ]
  //     test.identical( op.scriptArgs, scriptArgs )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'fork'

  //   let con = new _.Consequence().take( null );
  //   let args =
  //   [
  //     ` '\'s-s\''  '\"s-d\"'  '\`s-b\`'  `,
  //     ` "\'d-s\'"  "\"d-d\""  "\`d-b\`"  `,
  //     ` \`\'b-s\'\`  \`\"b-d\"\`  \`\`b-b\`\` `,
  //   ]
  //   let o =
  //   {
  //     execPath : _.strQuote( testAppPathSpace ),
  //     args : args.slice(),
  //     mode : 'fork',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, args )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'spawn'

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
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     let scriptArgs =
  //     [
  //       `'s-s'`, `"s-d"`, `\`s-b\``,
  //       `'d-s'`, `"d-d"`, `\`d-b\``,
  //       `'b-s'`, `"b-d"`, `\`b-b\``,
  //     ]
  //     test.identical( op.scriptArgs, scriptArgs )

  //     return null;
  //   })

  //   return con;

  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'spawn'

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
  //     mode : 'spawn',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, args )

  //     return null;
  //   })

  //   return con;

  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'shell'
  //   /*
  //    This case shows how shell is interpreting backquote on different platforms.
  //    It can't be used for arguments wrapping on linux/mac:
  //    https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html
  //   */

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
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     if( process.platform === 'win32' )
  //     {
  //       let op = JSON.parse( o.output );
  //       test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //       test.identical( op.map, {} )
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
  //       test.identical( op.scriptArgs, scriptArgs )
  //     }
  //     else
  //     {
  //       test.identical( _.strCount( o.output, 'not found' ), 3 );
  //     }

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // .then( () =>
  // {
  //   test.case = 'shell'

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
  //     mode : 'shell',
  //     outputPiping : 1,
  //     outputCollecting : 1,
  //     ready : con
  //   }
  //   _.process.start( o );

  //   con.then( () =>
  //   {
  //     test.identical( o.exitCode, 0 );
  //     let op = JSON.parse( o.output );
  //     test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
  //     test.identical( op.map, {} )
  //     test.identical( op.scriptArgs, args )

  //     return null;
  //   })

  //   return con;
  // })

  // /* */

  // return a.ready;

  /**/

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    var args = _.process.input();
    console.log( JSON.stringify( args ) );
  }
}

//

function startExecPathQuotesClosing( test )
{
  let context = this;

  let a = context.assetFor( test, false );

  let testAppPathSpace = a.path.nativize( a.path.normalize( a.program({ routine : testApp, dirPath : a.abs( 'with space' ) }) ) );

  /* */

  a.ready

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg' ] )

      return null;
    })

    return con;
  })

  /* */

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ '"', 'arg' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ '"', 'arg' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg', '"' ] )

      return null;
    })

    return con;
  })

  /* */

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
    return test.shouldThrowErrorAsync( _.process.start( o ) );
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

  /* */

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
    //   let op = JSON.parse( o.output );
    //   test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
    //   test.identical( op.map, {} )
    //   test.identical( op.scriptArgs, [ 'arg"' ] )

    //   return null;
    // })

    return test.shouldThrowErrorAsync( _.process.start( o ) );
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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg"arg"' ] )

      return null;
    })

    return con;
  })

  /* */

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
    return test.shouldThrowErrorAsync( _.process.start( o ) );
  })

  /* */

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
    //   let op = JSON.parse( o.output );
    //   test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
    //   test.identical( op.map, {} )
    //   test.identical( op.scriptArgs, [ 'arg"arg' ] )

    //   return null;
    // })

    return test.shouldThrowErrorAsync( _.process.start( o ) );
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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, {} )
      test.identical( op.scriptArgs, [ 'arg"arg' ] )

      return null;
    })

    return con;
  })

  /* */

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, { option : 'value' } )
      test.identical( op.scriptArgs, [ 'option', ':', 'value' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, { option : 'value with space' } )
      test.identical( op.scriptArgs, [ 'option:"value with space"' ] )

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, { option : 'value with space' } )
      test.identical( op.scriptArgs, [ 'option', ':', 'value with space' ] )

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

    return test.shouldThrowErrorAsync( _.process.start( o ) );
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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, { option : 'value' } )
      test.identical( op.scriptArgs, [ 'option: "value"' ] )
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
    return test.shouldThrowErrorAsync( _.process.start( o ) );
  })

  /* */

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, { option : 'value with space' } )
      test.identical( op.scriptArgs,  [ '"option: "value', 'with', 'space""' ] )

      return null;
    })

    return con
  })

  /* */

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, { option : 'value with space' } )
      test.identical( op.scriptArgs, [ 'option: "value with space"' ] )

      return null;
    })

    return con;
  })

  /* */

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
      let op = JSON.parse( o.output );
      test.identical( op.scriptPath, _.path.normalize( testAppPathSpace ) )
      test.identical( op.map, { option : 'value with space' } )
      test.identical( op.scriptArgs, [ 'option:', '"value', 'with', 'space"' ] )

      return null;
    })

    return con;
  })

  /*  */

  return a.ready;

  /*  */

  function testcase( src )
  {
    a.ready.then( () =>
    {
      test.case = src;
      return null;
    })
    return a.ready;
  }

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wStringsExtra' )
    var args = _.process.input();
    console.log( JSON.stringify( args ) );
  }
}

//

function startExecPathSeveralCommands( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( app );

  a.ready

  testcase( 'quoted, mode:shell' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node app.js arg1 && node app.js arg2',
      mode : 'shell',
      currentPath : a.routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( op ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( op.output, `[ 'arg1' ]` ), 1 );
      test.identical( _.strCount( op.output, `[ 'arg2' ]` ), 1 );
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
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorAsync( _.process.start( o ) )
  })

  /* -- */

  testcase( 'no quotes, mode:shell' )

  .then( () =>
  {
    let con = new _.Consequence().take( null );
    let o =
    {
      execPath : 'node app.js arg1 && node app.js arg2',
      mode : 'shell',
      currentPath : a.routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( op ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( op.output, `[ 'arg1' ]` ), 1 );
      test.identical( _.strCount( op.output, `[ 'arg2' ]` ), 1 );
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
      currentPath : a.routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    _.process.start( o );

    con.then( ( op ) =>
    {
      test.identical( o.exitCode, 0 );
      test.identical( _.strCount( op.output, `[ 'arg1', '&&', 'node', 'app.js', 'arg2' ]` ), 1 );
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
      currentPath : a.routinePath,
      outputPiping : 1,
      outputCollecting : 1,
      ready : con
    }
    return test.shouldThrowErrorAsync( _.process.start( o ) );
  })

  /*  */

  return a.ready;

  /*  */

  function testcase( src )
  {
    a.ready.then( () =>
    {
      test.case = src;
      return null;
    })
    return a.ready;
  }

  function app()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

//

function startExecPathNonTrivialModeShell( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.path.normalize( a.program( app ) ) );

  let shell = _.process.starter
  ({
    mode : 'shell',
    currentPath : a.routinePath,
    outputPiping : 1,
    outputCollecting : 1,
    ready : a.ready
  })

  /* */

  a.ready.then( () =>
  {
    test.open( 'two commands' );
    return null;
  })

  shell( 'node -v && node -v' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  //Vova: same behaviour on win and linux now
  shell({ execPath : '"node -v && node -v"', throwingExitCode : 0 })
  .then( ( op ) =>
  {
    // if( process.platform ==='win32' )
    // {
    //   test.identical( op.exitCode, 0 );
    //   test.identical( op.ended, true );
    //   test.identical( _.strCount( op.output, process.version ), 2 );
    // }
    // else
    // {
      test.notIdentical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( _.strCount( op.output, process.version ), 0 );
    // }
    return null;
  })

  shell({ execPath : 'node -v && "node -v"', throwingExitCode : 0 })
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 1 );
    return null;
  })

  shell({ args : 'node -v && node -v' })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  shell({ args : '"node -v && node -v"' })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ 'node -v && node -v' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ 'node', '-v', '&&', 'node', '-v' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ 'node', '-v', ' && ', 'node', '-v' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  shell({ args : [ 'node -v', '&&', 'node -v' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  a.ready.then( () =>
  {
    test.close( 'two commands' );
    return null;
  })

  /*  */

  a.ready.then( () =>
  {
    test.open( 'argument with space' );
    return null;
  })

  shell( 'node ' + testAppPath + ' arg with space' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg', 'with', 'space' ]` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ' "arg with space"' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg with space' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : 'arg with space' })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg with space' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : [ 'arg with space' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg with space' ]` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ' `"quoted arg with space"`' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.identical( _.strCount( op.output, `[ '\`quoted arg with space\`' ]` ), 1 );
    else
    test.identical( _.strCount( op.output, `not found` ), 1 );
    return null;
  })

  shell( 'node ' + testAppPath + ` \\\`'quoted arg with space'\\\`` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    // test.identical( _.strCount( op.output, `[ "'quoted arg with space'" ]` ), 1 );
    let args = a.fileProvider.fileRead({ filePath : a.abs( a.routinePath, 'args' ), encoding : 'json' });
    if( process.platform === 'win32' )
    test.identical( args, [ '\\`\'quoted', 'arg', 'with', 'space\'\\`' ] );
    else
    test.identical( args, [ '`quoted arg with space`' ] );
    return null;
  })

  shell( 'node ' + testAppPath + ` '\`quoted arg with space\`'` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    let args = a.fileProvider.fileRead({ filePath : a.abs( a.routinePath, 'args' ), encoding : 'json' });
    if( process.platform === 'win32' )
    test.identical( args, [ `\'\`quoted`, 'arg', 'with', `space\`\'` ] );
    else
    test.identical( _.strCount( op.output, `[ '\`quoted arg with space\`' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : '"quoted arg with space"' })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ '"quoted arg with space"' ]` ), 1 );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : '`quoted arg with space`' })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ '\`quoted arg with space\`' ]` ), 1 );
    return null;
  })

  a.ready.then( () =>
  {
    test.close( 'argument with space' );
    return null;
  })

  /*  */

  a.ready.then( () =>
  {
    test.open( 'several arguments' );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath + ` arg1 "arg2" "arg 3" "'arg4'"` })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    // test.identical( _.strCount( op.output, `[ 'arg1', 'arg2', 'arg 3', "'arg4'" ]` ), 1 );
    let args = a.fileProvider.fileRead({ filePath : a.abs( a.routinePath, 'args' ), encoding : 'json' });
    test.identical( args, [ 'arg1', 'arg2', 'arg 3', `'arg4'` ] );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : `arg1 "arg2" "arg 3" "'arg4'"` })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    // test.identical( _.strCount( op.output, '[ `arg1 "arg2" "arg 3" "\'arg4\'"` ]' ), 1 );
    let args = a.fileProvider.fileRead({ filePath : a.abs( a.routinePath, 'args' ), encoding : 'json' });
    test.identical( args, [ `arg1 "arg2" "arg 3" "\'arg4\'"` ] );
    return null;
  })

  shell({ execPath : 'node ' + testAppPath, args : [ `arg1`, '"arg2"', `arg 3`, `'arg4'` ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    // test.identical( _.strCount( op.output, `[ 'arg1', '"arg2"', 'arg 3', "'arg4'" ]` ), 1 );
    let args = a.fileProvider.fileRead({ filePath : a.abs( a.routinePath, 'args' ), encoding : 'json' });
    test.identical( args, [ 'arg1', '"arg2"', 'arg 3', `'arg4'` ] );
    return null;
  })

  a.ready.then( () =>
  {
    test.close( 'several arguments' );
    return null;
  })

  /*  */

  shell({ execPath : 'echo', args : [ 'a b', '*', 'c' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, `"a b" "*" "c"` ) );
    else
    test.is( _.strHas( op.output, `a b * c` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ 'a b', '*', 'c' ] )
    test.identical( op.fullExecPath, 'echo "a b" "*" "c"' )
    return null;
  })

  return a.ready;

  /* - */

  function app()
  {
    var fs = require( 'fs' );
    fs.writeFileSync( 'args', JSON.stringify( process.argv.slice( 2 ) ) )
    console.log( process.argv.slice( 2 ) )
  }
}

//

function startArgumentsHandlingTrivial( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  a.fileProvider.fileWrite( a.abs( a.routinePath, 'file' ), 'file' );

  /* */

  let shell = _.process.starter
  ({
    currentPath : a.routinePath,
    mode : 'shell',
    stdio : 'pipe',
    outputPiping : 1,
    outputCollecting : 1,
    ready : a.ready
  })

  /* */

  shell({ execPath : 'echo *' })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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

  return a.ready;
}

//

function startArgumentsHandling( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  a.fileProvider.fileWrite( a.abs( a.routinePath, 'file' ), 'file' );

  /* */

  let shell = _.process.starter
  ({
    currentPath : a.routinePath,
    mode : 'shell',
    stdio : 'pipe',
    outputPiping : 1,
    outputCollecting : 1,
    ready : a.ready
  })

  /* */

  shell({ execPath : 'echo *' })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `*` ) );
    test.identical( op.execPath, 'echo' )
    test.identical( op.args, [ '"*"' ] )
    test.identical( op.fullExecPath, 'echo "*"' )

    return null;
  })

  /* */

  shell({ execPath : 'echo "a b" "*" c' })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
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
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `a b c` ) );
    return null;
  })

  /* */

  shell({ execPath : `node -e "console.log( process.argv.slice( 1 ) )"`, args : [ '"a b c"' ] })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `"a b c"` ) );
    test.identical( op.execPath, 'node' )
    test.identical( op.args, [ '-e', '"console.log( process.argv.slice( 1 ) )"', '"a b c"' ] )
    test.identical( op.fullExecPath, 'node -e "console.log( process.argv.slice( 1 ) )" "\\"a b c\\""' )
    return null;
  })

  /* */

  return a.ready;
}

//

function startImportantExecPath( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  var printArguments = 'node -e "console.log( process.argv.slice( 1 ) )"'

  a.fileProvider.fileWrite( a.abs( a.routinePath, 'file' ), 'file' );

  /* */

  let shell = _.process.starter
  ({
    currentPath : a.routinePath,
    mode : 'shell',
    stdio : 'pipe',
    outputPiping : 1,
    outputCollecting : 1,
    ready : a.ready
  })

  /* */

  shell({ execPath : null, args : [ 'node', '-v', '&&', 'node', '-v' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  /* */

  shell({ execPath : 'node', args : [ '-v', '&&', 'node', '-v' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 1 );
    return null;
  })

  /* */

  shell({ execPath : printArguments, args : [ 'a', '&&', 'node', 'b' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `[ 'a', '&&', 'node', 'b' ]` ) )
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ '-v', '&&', 'echo', '-v' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '"-v" "&&" "echo" "-v"' ) )
    else
    test.is( _.strHas( op.output, '-v && echo -v' ) )
    return null;
  })

  /* */

  shell({ execPath : 'node -v && node -v', args : [] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 2 );
    return null;
  })

  /* */

  shell({ execPath : `node -v "&&" node -v`, args : [] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, process.version ), 1 );
    return null;
  })

  /* */

  shell({ execPath : `echo -v "&&" node -v`, args : [] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '-v "&&" node -v'  ) );
    else
    test.is( _.strHas( op.output, '-v && node -v'  ) );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ 'echo', '*' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.identical( _.strCount( op.output, '*' ), 1 );
    else
    test.identical( _.strCount( op.output, 'file' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ '*' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, '*' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : 'echo *' })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.identical( _.strCount( op.output, '*' ), 1 );
    else
    test.identical( _.strCount( op.output, 'file' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : 'echo "*"' })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, '*' ), 1 );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ printArguments, 'a b' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `[ 'a', 'b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : printArguments, args : [ 'a b' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `[ 'a b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : `${printArguments} a b` })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `[ 'a', 'b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : `${printArguments} "a b"` })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, `[ 'a b' ]` ) );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ 'echo', '"*"' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, '*' ) );
    return null;
  })

  /* */

  shell({ execPath : 'echo', args : [ '"*"' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '\\"*\\"' ) );
    else
    test.is( _.strHas( op.output, '"*"' ) );
    return null;
  })

  /* */

  shell({ execPath : null, args : [ 'echo', '\\"*\\"' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '\\"*\\"' ) );
    else
    test.is( _.strHas( op.output, '"*"' ) );
    return null;
  })

  /* */

  shell({ execPath : 'echo "\\"*\\""', args : [] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    if( process.platform === 'win32' )
    test.is( _.strHas( op.output, '"\\"*\\"' ) );
    else
    test.is( _.strHas( op.output, '"*"' ) );
    return null;
  })

  /* */

  shell({ execPath : 'echo *', args : [ '*' ] })
  .then( function( op )
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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

  /* qqq for Yevhen : separate test routine startImportantExecPathPassingThrough and run it from separate process */
  /* zzz */

  return a.ready;
}

startImportantExecPath.description =
`
exec paths with special chars
`

//

function startImportantExecPathPassingThrough( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  /* */

  a.ready.then( () =>
  {
    test.open( '0 args to parent' );
    return null;
  } )

  a.ready.then( function()
  {
    test.case = `execPath : 'echo', args : null`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : 'echo', args : null, passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = `execPath : null, args : [ 'echo' ]`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : null, args : [ 'echo' ], passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = `shell({ execPath : 'echo *', args : [ '*' ], passingThrough : 1 })`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : 'echo *', args : [ '*' ], passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo * "*"\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  a.ready.then( () =>
  {
    test.close( '0 args to parent' );
    return null;
  } )

  /* - */

  a.ready.then( () =>
  {
    test.open( '1 arg to parent' );
    return null;
  } )

  /* ORIGINAL */
  // shell({ execPath : 'echo', args : null, passingThrough : 1 })
  // .then( function( op )
  // {
  //   test.identical( op.exitCode, 0 );
  //   test.identical( op.ended, true );
  //   if( process.platform === 'win32' )
  //   test.is( _.strHas( op.output, '"' + process.argv.slice( 2 ).join( '" "' ) + '"' ) );
  //   else
  //   test.is( _.strHas( op.output, process.argv.slice( 2 ).join( ' ') ) );
  //   return null;
  // })

  /* REWRITTEN */
  /* PASSING */
  a.ready.then( function()
  {
    test.case = `execPath : 'echo', args : null`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : 'echo', args : null, passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
      args : 'argFromParent',
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo "argFromParent"\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  /* ORIGINAL */
  // shell({ execPath : null, args : [ 'echo' ], passingThrough : 1 })
  // .then( function( op )
  // {
  //   test.identical( op.exitCode, 0 );
  //   test.identical( op.ended, true );
  //   if( process.platform === 'win32' )
  //   test.is( _.strHas( op.output, '"' + process.argv.slice( 2 ).join( '" "' ) + '"' ) );
  //   else
  //   test.is( _.strHas( op.output, process.argv.slice( 2 ).join( ' ') ) );
  //   return null;
  // })

  /* REWRITTEN */
  /* PASSING */
  a.ready.then( function()
  {
    test.case = `execPath : null, args : [ 'echo' ]`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : null, args : [ 'echo' ], passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
      args : 'argFromParent',
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo "argFromParent"\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  /* ORIGINAL */
  // shell({ execPath : 'echo *', args : [ '*' ], passingThrough : 1 })
  // .then( function( op )
  // {
  //   test.identical( op.exitCode, 0 );
  //   test.identical( op.ended, true );
  //   if( process.platform === 'win32' )
  //   {
  //     test.is( _.strHas( op.output, '*' ) );
  //     test.is( _.strHas( op.output, '"*"' ) );
  //     test.is( _.strHas( op.output, '"' + process.argv.slice( 2 ).join( '" "' ) + '"' ) );
  //   }
  //   else
  //   {
  //     test.is( _.strHas( op.output, 'file' ) );
  //     test.is( _.strHas( op.output, '*' ) );
  //     test.is( _.strHas( op.output, process.argv.slice( 2 ).join( ' ') ) );
  //   }
  //   return null;
  // })

  /* REWRITTEN */
  a.ready.then( function()
  {
    test.case = `execPath : 'echo *', args : *`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : 'echo *', args : [ '*' ], passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
      args : 'argFromParent',
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo * "*" "argFromParent"\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  a.ready.then( () =>
  {
    test.close( '1 arg to parent' );
    return null;
  } )

  /* - */

  a.ready.then( () =>
  {
    test.open( '2 args to parent' );
    return null;
  } )

  a.ready.then( function()
  {
    test.case = `execPath : 'echo', args : null`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : 'echo', args : null, passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
      args : [ 'argFromParent1', 'argFromParent2' ],
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo "argFromParent1" "argFromParent2"\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = `execPath : null, args : [ 'echo' ]`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : null, args : [ 'echo' ], passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
      args : [ 'argFromParent1', 'argFromParent2' ],
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo "argFromParent1" "argFromParent2"\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  /* */

  a.ready.then( function()
  {
    test.case = `execPath : 'echo *', args : *`;

    let locals =
    {
      routinePath : a.routinePath,
      options : { execPath : 'echo *', args : [ '*' ], passingThrough : 1 }
    }

    let programPath = a.path.nativize( a.program({ routine : testAppParent, locals }) );

    let options =
    {
      execPath :  'node ' + programPath,
      outputCollecting : 1,
      args : [ 'argFromParent1', 'argFromParent2' ],
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, 'echo * "*" "argFromParent1" "argFromParent2"\n' ) );

      a.fileProvider.fileDelete( programPath );
      return null;

    })
  })

  a.ready.then( () =>
  {
    test.close( '2 args to parent' );
    return null;
  } )

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wProcess' );

    let shell = _.process.starter
    ({
      currentPath : routinePath,
      mode : 'shell',
      stdio : 'pipe',
      outputPiping : 0,
    })
    return shell( options )
  }


}

//

function startNjsPassingThroughDifferentTypesOfPaths( test )
{
  let context = this;
  let a = context.assetFor( test, 'basic' );
  let testAppPath = a.program( testApp );

  /* */

  a.ready.then( () =>
  {
    test.case = 'execute simple js program with normalized path'

    let execPath = _.path.normalize( testAppPath );
    let o =
    {
      execPath : _.strQuote( execPath ),
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    };

    return _.process.startNjsPassingThrough( o )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( a.fileProvider.fileExists( testAppPath ) );
      test.is( !_.strHas( op.output, `Error: Cannot find module` ) );
      return null;
    })

  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'execute simple js program with nativized path'

    let execPath = _.path.nativize( testAppPath );
    let o =
    {
      execPath : _.strQuote( execPath ),
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    };

    return _.process.startNjsPassingThrough( o )
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( a.fileProvider.fileExists( testAppPath ) );
      test.is( !_.strHas( op.output, `Error: Cannot find module` ) );
      return null;
    })

  })

  /* */

  return a.ready;

  /* */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

//


function startPassingThroughExecPathWithSpace( test ) /* qqq for Yevhen : subroutine for modes */
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program({ routine : testApp, dirPath : 'path with space' });
  let execPathWithSpace = 'node ' + _.path.nativize( testAppPath );

  /* - */

  a.ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, spawn'
    return null;
  })

  _.process.startPassingThrough
  ({
    execPath : execPathWithSpace,
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, shell'
    return null;
  })

  _.process.startPassingThrough
  ({
    execPath : execPathWithSpace,
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'shell',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, fork'
    return null;
  })

  _.process.startPassingThrough
  ({
    execPath : a.path.nativize( testAppPath ),
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, spawn'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : execPathWithSpace,
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  a.ready.finally( ( err, op ) =>
  {
    _.errAttend( err );
    test.is( !!err );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( err.message, `ENOENT` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, shell'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : execPathWithSpace,
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'shell',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, fork'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : a.path.nativize( testAppPath ),
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space and argument, fork'
    return null;
  })

  _.process.startPassingThrough
  ({
    args : a.path.nativize( testAppPath ) + ' arg',
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0,
    applyingExitCode : 0,
    stdio : 'pipe'
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Cannot find module` ) );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, context.t1 * 2 ) /* 2000 */
  }
}

//

function startNormalizedExecPath( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.path.normalize( a.program( testApp ) ) );

  /* */

  let shell = _.process.starter
  ({
    outputCollecting : 1,
    ready : a.ready
  })

  /* */

  shell
  ({
    execPath : testAppPath,
    args : [ 'arg1', 'arg2' ],
    mode : 'fork'
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* */

  shell
  ({
    execPath : 'node ' + testAppPath,
    args : [ 'arg1', 'arg2' ],
    mode : 'spawn'
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* */

  shell
  ({
    execPath : 'node ' + testAppPath,
    args : [ 'arg1', 'arg2' ],
    mode : 'shell'
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* app path in arguments */

  shell
  ({
    args : [ testAppPath, 'arg1', 'arg2' ],
    mode : 'fork'
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* */

  shell
  ({
    execPath : 'node',
    args : [ testAppPath, 'arg1', 'arg2' ],
    mode : 'spawn'
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* */

  shell
  ({
    execPath : 'node',
    args : [ testAppPath, 'arg1', 'arg2' ],
    mode : 'shell'
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( _.strCount( op.output, `[ 'arg1', 'arg2' ]` ), 1 );
    return null;
  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

//

function startExecPathWithSpace( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( { routine : testApp, dirPath : 'path with space' } );

  let execPathWithSpace = 'node ' + testAppPath;

  /* - */

  a.ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, spawn'
    return null;
  })

  _.process.start
  ({
    execPath : execPathWithSpace,
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, shell'
    return null;
  })

  _.process.start
  ({
    execPath : execPathWithSpace,
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'shell',
    throwingExitCode : 0
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space, fork'
    return null;
  })

  _.process.start
  ({
    execPath : a.path.nativize( testAppPath ),
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, spawn'
    return null;
  })

  _.process.start
  ({
    args : execPathWithSpace,
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'spawn',
    throwingExitCode : 0
  });

  a.ready.finally( ( err, op ) =>
  {
    _.errAttend( err );
    test.is( !!err );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( err.message, `ENOENT` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
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
    ready : a.ready,
    throwingExitCode : 0
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space, fork'
    return null;
  })

  _.process.start
  ({
    args : a.path.nativize( testAppPath ),
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0
  });

  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args is a string with unquoted path with space and argument, fork'
    return null;
  })

  _.process.start
  ({
    args : a.path.nativize( testAppPath ) + ' arg',
    ready : a.ready,
    outputCollecting : 1,
    outputPiping : 1,
    mode : 'fork',
    throwingExitCode : 0
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Cannot find module` ) );
    return null;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, context.t1 * 2 ) /* 2000 */
  }
}

//

function startDifferentTypesOfPaths( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let execPath = a.program({ routine : testApp });
  let execPathWithSpace = a.program({ routine : testApp, dirPath : 'path with space' });
  execPathWithSpace = a.fileProvider.path.normalize( execPathWithSpace );
  let execPathWithSpaceNative = a.fileProvider.path.nativize( execPathWithSpace );
  let nodeWithSpace = a.abs( 'path with space', _.path.name({ path : process.argv[ 0 ], full : 1 }) );
  a.fileProvider.softLink( nodeWithSpace, process.argv[ 0 ] );

  /* - */

  a.ready

  // .then( () =>
  // {
  //   test.case = 'mode : fork, path with space'
  //   let o =
  //   {
  //     args : execPathWithSpace,
  //     mode : 'fork',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //     outputPiping : 1,
  //     throwingExitCode : 0,
  //     applyingExitCode : 0,
  //   }

  //   _.process.start( o );

  //   o.conTerminate.then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( op.ended, true );
  //     test.is( _.strHas( op.output, execPathWithSpace ) );
  //     return null;
  //   })

  //   return o.conTerminate;

  // })

  // .then( () =>
  // {
  //   test.case = 'mode : fork, quoted path with space'
  //   let o =
  //   {
  //     execPath : _.strQuote( execPathWithSpace ),
  //     mode : 'fork',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //     outputPiping : 1,
  //     throwingExitCode : 0,
  //     applyingExitCode : 0,
  //   }

  //   _.process.start( o );

  //   o.conTerminate.then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( op.ended, true );
  //     test.is( _.strHas( op.output, execPathWithSpace ) );
  //     return null;
  //   })

  //   return o.conTerminate;

  // })

  /* zzz for Vova : fix it? */

  // .then( () =>
  // {
  //   test.case = 'mode : fork, double quoted path with space'
  //   let o =
  //   {
  //     execPath : `""${execPathWithSpace}""`,
  //     mode : 'fork',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //     outputPiping : 1,
  //     throwingExitCode : 0,
  //     applyingExitCode : 0,
  //   }

  //   _.process.start( o );

  //   o.conTerminate.then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( op.ended, true );
  //     test.is( _.strHas( op.output, execPathWithSpace ) );
  //     return null;
  //   })

  //   return o.conTerminate;

  // })

  /* */

  .then( () =>
  {
    test.case = 'mode : spawn, path to node with space'
    let o =
    {
      args : [ nodeWithSpace, '-v' ],
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, process.version ) );
      return null;
    })

    return o.conTerminate;

  })

  .then( () =>
  {
    test.case = 'mode : spawn, path to node with space'
    let o =
    {
      args : [ _.strQuote( nodeWithSpace ), '-v' ],
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, process.version ) );
      return null;
    })

    return o.conTerminate;

  })

  /* */

  .then( () =>
  {
    test.case = 'mode : spawn, path to node with space'
    let o =
    {
      execPath : _.strQuote( nodeWithSpace ),
      args : [ '-v' ],
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, process.version ) );
      return null;
    })

    return o.conTerminate;

  })

  /* zzz for Vova : fix it */

  // .then( () =>
  // {
  //   test.case = 'mode : spawn, path to node with space'
  //   let o =
  //   {
  //     execPath : `""${nodeWithSpace}""`,
  //     args : [ '-v' ],
  //     mode : 'spawn',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //     outputPiping : 1,
  //     throwingExitCode : 0,
  //     applyingExitCode : 0,
  //   }

  //   _.process.start( o );

  //   o.conTerminate.then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( op.ended, true );
  //     test.is( _.strHas( op.output, process.version ) );
  //     return null;
  //   })

  //   return o.conTerminate;

  // })

  /* */

  .then( () =>
  {
    test.case = 'mode : spawn, path to node with space, path to program with space'
    let o =
    {
      execPath : _.strQuote( nodeWithSpace ) + ' ' + _.strQuote( execPathWithSpaceNative ),
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, execPathWithSpace ) );
      return null;
    })

    return o.conTerminate;

  })

  /* */

  .then( () =>
  {
    test.case = 'mode : spawn, path to node with space, path to program with space'
    let o =
    {
      execPath : _.strQuote( nodeWithSpace ),
      args : [ execPathWithSpaceNative ],
      mode : 'spawn',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, execPathWithSpace ) );
      return null;
    })

    return o.conTerminate;

  })

  /* zzz for Vova : fix it? */

  // .then( () =>
  // {
  //   test.case = 'mode : shell, path to node with space'
  //   let o =
  //   {
  //     args : [ _.strQuote( nodeWithSpace ), '-v' ],
  //     mode : 'shell',
  //     stdio : 'pipe',
  //     outputCollecting : 1,
  //     outputPiping : 1,
  //     throwingExitCode : 0,
  //     applyingExitCode : 0,
  //   }

  //   _.process.start( o );

  //   o.conTerminate.then( ( op ) =>
  //   {
  //     test.identical( op.exitCode, 0 );
  //     test.identical( op.ended, true );
  //     test.is( _.strHas( op.output, process.version ) );
  //     return null;
  //   })

  //   return o.conTerminate;

  // })

  /* */

  .then( () =>
  {
    test.case = 'mode : shell, path to node with space'
    let o =
    {
      execPath : _.strQuote( nodeWithSpace ),
      args : [ '-v' ],
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, process.version ) );
      return null;
    })

    return o.conTerminate;

  })

  /* */

  .then( () =>
  {
    test.case = 'mode : shell, path to node with space, program path with space'
    let o =
    {
      execPath : _.strQuote( nodeWithSpace ),
      args : [ execPathWithSpaceNative ],
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, execPathWithSpace ) );
      return null;
    })

    return o.conTerminate;

  })

  /* */

  .then( () =>
  {
    test.case = 'mode : shell, path to node with space, program path with space'
    let o =
    {
      execPath : _.strQuote( nodeWithSpace ) + ' ' + _.strQuote( execPathWithSpaceNative ),
      mode : 'shell',
      stdio : 'pipe',
      outputCollecting : 1,
      outputPiping : 1,
      throwingExitCode : 0,
      applyingExitCode : 0,
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, execPathWithSpace ) );
      return null;
    })

    return o.conTerminate;

  })

  /* - */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    console.log( _.path.normalize( __filename ) );
  }
}

//


function startNjsPassingThroughExecPathWithSpace( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program({ routine : testApp, dirPath : 'path with space' });
  let execPathWithSpace = testAppPath;

  /* - */

  a.ready.then( () =>
  {
    test.case = 'execPath contains unquoted path with space'
    return null;
  })

  _.process.startNjsPassingThrough
  ({
    execPath : execPathWithSpace,
    ready : a.ready,
    stdio : 'pipe',
    outputCollecting : 1,
    outputPiping : 1,
    throwingExitCode : 0,
    applyingExitCode : 0,
  });

  a.ready.then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( a.fileProvider.fileExists( testAppPath ) );
    test.is( _.strHas( op.output, `Error: Cannot find module` ) );
    return null;
  })

  /* - */

  a.ready.then( () =>
  {
    test.case = 'args: string that contains unquoted path with space'
    return null;
  })

  test.shouldThrowErrorSync( () =>
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

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, context.t1 * 2 ) /* 2000 */
  }
}

//

// --
// procedures / chronology / structural
// --

function startProcedureTrivial( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );

  let start = _.process.starter
  ({
    currentPath : a.routinePath,
    outputPiping : 1,
    outputCollecting : 1,
  });

  a.ready

  /* */

  .then( () =>
  {

    var o = { execPath : 'node ' + testAppPath, mode : 'shell' }
    var con = start( o );
    var procedure = _.procedure.find( 'PID:' + o.process.pid );
    test.identical( procedure.length, 1 );
    test.identical( procedure[ 0 ].isAlive(), true );
    test.identical( o.procedure, procedure[ 0 ] );
    test.identical( procedure[ 0 ].object(), o.process );
    return con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( procedure[ 0 ].isAlive(), false );
      test.identical( o.procedure, procedure[ 0 ] );
      test.identical( procedure[ 0 ].object(), o.process );
      test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) ); debugger;
      return null;
    })
  })

  /* */

  .then( () =>
  {

    var o = { execPath : testAppPath, mode : 'fork' }
    var con = start( o );
    var procedure = _.procedure.find( 'PID:' + o.process.pid );
    test.identical( procedure.length, 1 );
    test.identical( procedure[ 0 ].isAlive(), true );
    test.identical( o.procedure, procedure[ 0 ] );
    test.identical( procedure[ 0 ].object(), o.process );
    return con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
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
    var procedure = _.procedure.find( 'PID:' + o.process.pid );
    test.identical( procedure.length, 1 );
    test.identical( procedure[ 0 ].isAlive(), true );
    test.identical( o.procedure, procedure[ 0 ] );
    test.identical( procedure[ 0 ].object(), o.process );
    return con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( procedure[ 0 ].isAlive(), false );
      test.identical( o.procedure, procedure[ 0 ] );
      test.identical( procedure[ 0 ].object(), o.process );
      test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) );
      return null;
    })
  })

  /* */


  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.pid )
    setTimeout( () => {}, context.t1 * 2 ) /* 2000 */
  }
}

startProcedureTrivial.description =
`
  Start routine creates procedure for new child process, start it and terminates when process closes
`

//

function startProcedureExists( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( program1 ) );

  let start = _.process.starter
  ({
    currentPath : a.routinePath,
    outputPiping : 1,
    outputCollecting : 1,
  });

  _.process.watcherEnable();

  let modes = [ 'spawn', 'shell', 'fork' ];

  modes.forEach( mode =>
  {
    a.ready.tap( () => test.open( mode ) );
    a.ready.then( () => run( mode ) );
    a.ready.tap( () => test.close( mode ) );
  })

  a.ready.then( () => _.process.watcherDisable() );

  return a.ready

  /* */

  function run( mode )
  {
    let ready = _.Consequence().take( null );

    ready.then( () =>
    {
      var o = { execPath : 'node ' + testAppPath, mode }
      if( mode === 'fork' )
      o.execPath = testAppPath;
      var con = start( o );
      var procedure = _.procedure.find( 'PID:' + o.process.pid );
      test.identical( procedure.length, 1 );
      test.identical( procedure[ 0 ].isAlive(), true );
      test.identical( o.procedure, procedure[ 0 ] );
      test.identical( procedure[ 0 ].object(), o.process );
      test.identical( o.procedure, procedure[ 0 ] );
      return con.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( procedure[ 0 ].isAlive(), false );
        test.identical( o.procedure, procedure[ 0 ] );
        test.identical( procedure[ 0 ].object(), o.process );
        test.identical( o.procedure, procedure[ 0 ] );
        debugger
        test.is( _.strHas( o.procedure._sourcePath, 'Execution.s' ) );
        return null;
      })
    })

    return ready;
  }

  /* */


  function program1()
  {
    console.log( process.pid )
    setTimeout( () => {}, context.t1 * 2 ) /* 2000 */
  }

}

startProcedureExists.description =
`
  Start routine does not create procedure for new child process if it was already created by process watcher
`

//

function startProcedureStack( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 1, mode ) ) );
  return a.ready;

  /*  */

  function run( sync, deasync, mode )
  {
    let ready = new _.Consequence().take( null )

    if( sync && !deasync && mode === 'fork' )
    return null;

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:implicit`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath} id:1` : `${programPath} id:1`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
        test.identical( _.strCount( op.procedure._sourcePath, 'case1' ), 1 );
        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:true`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath} id:1` : `${programPath} id:1`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : true,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
        test.identical( _.strCount( op.procedure._sourcePath, 'case1' ), 1 );
        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:0`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath} id:1` : `${programPath} id:1`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : 0,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
        test.identical( _.strCount( op.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
        test.identical( _.strCount( op.procedure._sourcePath, 'case1' ), 1 );
        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:-1`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath} id:1` : `${programPath} id:1`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : -1,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'start' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
        test.identical( _.strCount( op.procedure._sourcePath, 'start' ), 1 );
        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:false`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath} id:1` : `${programPath} id:1`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : false,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      test.identical( o.procedure._stack, '' );
      test.identical( o.procedure._sourcePath, '' );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( o.procedure._stack, '' );
        test.identical( o.procedure._sourcePath, '' );
        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:str`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath} id:1` : `${programPath} id:1`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : 'abc',
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      test.identical( o.procedure._stack, 'abc' );
      test.identical( o.procedure._sourcePath, 'abc' );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( o.procedure._stack, 'abc' );
        test.identical( o.procedure._sourcePath, 'abc' );
        return null;
      })

      return o.ready;
    })

    /* */

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    let args = _.process.input();
    let data = { time : _.time.now(), id : args.map.id };
    console.log( JSON.stringify( data ) );
  }

}

startProcedureStack.timeOut = 5e5;

startProcedureStack.description =
`
  - option stack used to get stack
  - stack may be defined relatively
  - stack may be switched off
`

//

function startProcedureStackMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );

  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 1, mode ) ) );
  return a.ready;

  /*  */

  function run( sync, deasync, mode )
  {
    let ready = new _.Consequence().take( null )

    if( sync && !deasync && mode === 'fork' )
    return null;

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:implicit`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? [ `node ${programPath} id:1`, `node ${programPath} id:2` ] : [ `${programPath} id:1`, `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      if( sync || deasync )
      {
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
      }
      else
      {
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, null );
        test.identical( o.ended, false );
        test.identical( o.state, 'starting' );
      }

      test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
        test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
        test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
        test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

        o.runs.forEach( ( op2 ) =>
        {
          test.identical( _.strCount( op2.procedure._stack, 'case1' ), 1 );
          test.identical( _.strCount( op2.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
          test.identical( _.strCount( op2.procedure._sourcePath, 'case1' ), 1 );
          test.is( o.procedure !== op2.procedure );
        });

        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:true`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? [ `node ${programPath} id:1`, `node ${programPath} id:2` ] : [ `${programPath} id:1`, `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : true,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      if( sync || deasync )
      {
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
      }
      else
      {
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, null );
        test.identical( o.ended, false );
        test.identical( o.state, 'starting' );
      }

      test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
        test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
        test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
        test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

        o.runs.forEach( ( op2 ) =>
        {
          test.identical( _.strCount( op2.procedure._stack, 'case1' ), 1 );
          test.identical( _.strCount( op2.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
          test.identical( _.strCount( op2.procedure._sourcePath, 'case1' ), 1 );
          test.is( o.procedure !== op2.procedure );
        });

        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:0`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? [ `node ${programPath} id:1`, `node ${programPath} id:2` ] : [ `${programPath} id:1`, `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : 0,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      if( sync || deasync )
      {
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
      }
      else
      {
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, null );
        test.identical( o.ended, false );
        test.identical( o.state, 'starting' );
      }

      test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
        test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
        test.identical( _.strCount( o.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
        test.identical( _.strCount( o.procedure._sourcePath, 'case1' ), 1 );

        o.runs.forEach( ( op2 ) =>
        {
          test.identical( _.strCount( op2.procedure._stack, 'case1' ), 1 );
          test.identical( _.strCount( op2.procedure._sourcePath, 'ProcessBasic.test.s' ), 1 );
          test.identical( _.strCount( op2.procedure._sourcePath, 'case1' ), 1 );
          test.is( o.procedure !== op2.procedure );
        });

        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:-1`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? [ `node ${programPath} id:1`, `node ${programPath} id:2` ] : [ `${programPath} id:1`, `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : -1,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      if( sync || deasync )
      {
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
      }
      else
      {
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, null );
        test.identical( o.ended, false );
        test.identical( o.state, 'starting' );
      }

      test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
      test.identical( _.strCount( o.procedure._sourcePath, 'start' ), 1 );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
        test.identical( _.strCount( o.procedure._stack, 'case1' ), 1 );
        test.identical( _.strCount( op.procedure._sourcePath, 'start' ), 1 );

        o.runs.forEach( ( op2 ) =>
        {
          test.identical( _.strCount( op2.procedure._stack, 'case1' ), 1 );
          test.identical( _.strCount( op2.procedure._sourcePath, 'start' ), 1 );
          test.is( o.procedure !== op2.procedure );
        });

        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:false`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? [ `node ${programPath} id:1`, `node ${programPath} id:2` ] : [ `${programPath} id:1`, `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : false,
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      if( sync || deasync )
      {
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
      }
      else
      {
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, null );
        test.identical( o.ended, false );
        test.identical( o.state, 'starting' );
      }

      test.identical( o.procedure._stack, '' );
      test.identical( o.procedure._sourcePath, '' );
      test.identical( o.procedure._sourcePath, '' );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
        test.identical( o.procedure._stack, '' );
        test.identical( o.procedure._sourcePath, '' );

        o.runs.forEach( ( op2 ) =>
        {
          test.identical( op2.procedure._stack, '' );
          test.identical( op2.procedure._sourcePath, '' );
          test.is( o.procedure !== op2.procedure );
        });

        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( function case1()
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode} stack:str`;
      let t1 = _.time.now();
      let o =
      {
        execPath : mode !== `fork` ? [ `node ${programPath} id:1`, `node ${programPath} id:2` ] : [ `${programPath} id:1`, `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        stack : 'abc',
        mode,
        sync,
        deasync,
      }

      _.process.start( o );

      if( sync || deasync )
      {
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
      }
      else
      {
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, null );
        test.identical( o.ended, false );
        test.identical( o.state, 'starting' );
      }

      test.identical( o.procedure._stack, 'abc' );
      test.identical( o.procedure._sourcePath, 'abc' );
      test.identical( o.procedure._sourcePath, 'abc' );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( o.exitCode, 0 );
        test.identical( o.exitSignal, null );
        test.identical( o.exitReason, 'normal' );
        test.identical( o.ended, true );
        test.identical( o.state, 'terminated' );
        test.identical( o.procedure._stack, 'abc' );
        test.identical( o.procedure._sourcePath, 'abc' );

        o.runs.forEach( ( op2 ) =>
        {
          test.identical( op2.procedure._stack, 'abc' );
          test.identical( op2.procedure._sourcePath, 'abc' );
          test.is( o.procedure !== op2.procedure );
        });

        return null;
      })

      return o.ready;
    })

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    let args = _.process.input();
    let data = { time : _.time.now(), id : args.map.id };
    console.log( JSON.stringify( data ) );
  }

}

startProcedureStackMultiple.timeOut = 500000;

//

/* qqq for Yevhen : implement for other modes */
function startOnTerminateSeveralCallbacksChronology( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let track = [];

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'parent disconnects detached child process and exits, child contiues to work'
    let o =
    {
      execPath : 'node program1.js',
      mode : 'spawn',
      stdio : 'pipe',
      outputPiping : 1,
      outputCollecting : 1,
      currentPath : a.routinePath,
      detaching : 0,
      ipc : 1,
    }
    let con = _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate.1' );
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( op.state, 'terminated' );
      return null;
    })

    o.conTerminate.then( () =>
    {
      track.push( 'conTerminate.2' );
      test.identical( o.exitCode, 0 );
      test.identical( o.state, 'terminated' );
      return _.time.out( context.t1 * 6 ); /* 1000 + context.t2 */
    })

    o.conTerminate.then( () =>
    {
      track.push( 'conTerminate.3' );
      test.identical( o.exitCode, 0 );
      test.identical( o.state, 'terminated' );
      return null;
    })

    track.push( 'end' );
    return con;
  })

  .tap( () =>
  {
    track.push( 'ready' );
  })

  /*  */

  return _.time.out( context.t1 * 11, () => /* 1000 + context.t2 + context.t2 */
  {
    test.identical( track, [ 'end', 'conTerminate.1', 'conTerminate.2', 'ready', 'conTerminate.3' ] );
  });

  /* - */

  function program1()
  {
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, context.t1 ); /* 1000 */
  }

}

startOnTerminateSeveralCallbacksChronology.description =
`
- second onTerminal callbacks called after ready callback
`

//

function startChronology( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );
  let track;
  let niteration = 0;

  var modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 1, mode ) ) );
  return a.ready;

  /* */

  function run( sync, deasync, mode )
  {
    test.case = `sync:${sync} deasync:${deasync} mode:${mode}`;

    if( sync && mode === 'fork' )
    return null;

    niteration += 1;
    let ptcounter = _.Procedure.Counter;
    let pacounter = _.Procedure.FindAlive().length;
    track = [];

    var o =
    {
      execPath : mode !== 'fork' ? 'node' : null,
      args : [ testAppPath ],
      mode,
      sync,
      deasync,
      ready : new _.Consequence().take( null ),
      conStart : new _.Consequence(),
      conDisconnect : new _.Consequence(),
      conTerminate : new _.Consequence(),
    }

    test.identical( _.Procedure.Counter - ptcounter, 0 );
    ptcounter = _.Procedure.Counter;
    test.identical( _.Procedure.FindAlive().length - pacounter, 0 );
    pacounter = _.Procedure.FindAlive().length;

    o.conStart.tap( ( err, op ) =>
    {
      track.push( 'conStart' );

      test.identical( err, undefined );
      test.identical( op, o );

      test.identical( o.ready.argumentsCount(), 0 );
      test.identical( o.ready.errorsCount(), 0 );
      test.identical( o.ready.competitorsCount(), 0 );
      test.identical( o.conStart.argumentsCount(), 1 );
      test.identical( o.conStart.errorsCount(), 0 );
      test.identical( o.conStart.competitorsCount(), 0 );
      test.identical( o.conDisconnect.argumentsCount(), 0 );
      test.identical( o.conDisconnect.errorsCount(), 0 );
      test.identical( o.conDisconnect.competitorsCount(), 0 );
      test.identical( o.conTerminate.argumentsCount(), 0 );
      test.identical( o.conTerminate.errorsCount(), 0 );
      test.identical( o.conTerminate.competitorsCount(), 1 );
      test.identical( o.ended, false );
      test.identical( o.state, 'started' );
      test.identical( o.error, null );
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, null );
      test.identical( o.process.exitCode, ( sync && !deasync ) ? undefined : null );
      test.identical( o.process.signalCode, ( sync && !deasync ) ? undefined : null );
      test.identical( _.Procedure.Counter - ptcounter, ( sync && !deasync ) ? 3 : 2 );
      ptcounter = _.Procedure.Counter;
      test.identical( _.Procedure.FindAlive().length - pacounter, ( sync && !deasync ) ? 1 : 2 );
      pacounter = _.Procedure.FindAlive().length;
    });

    test.identical( _.Procedure.Counter - ptcounter, 1 );
    ptcounter = _.Procedure.Counter;
    test.identical( _.Procedure.FindAlive().length - pacounter, 1 );
    pacounter = _.Procedure.FindAlive().length;

    o.conTerminate.tap( ( err, op ) =>
    {
      track.push( 'conTerminate' );

      test.identical( err, undefined );
      test.identical( op, o );

      test.identical( o.ready.argumentsCount(), 0 );
      test.identical( o.ready.errorsCount(), 0 );
      test.identical( o.ready.competitorsCount(), ( sync && !deasync ) ? 0 : 1 );
      test.identical( o.conStart.argumentsCount(), 1 );
      test.identical( o.conStart.errorsCount(), 0 );
      test.identical( o.conStart.competitorsCount(), 0 );
      test.identical( o.conDisconnect.argumentsCount(), 0 );
      test.identical( o.conDisconnect.errorsCount(), 0 );
      test.identical( o.conDisconnect.competitorsCount(), 0 );
      test.identical( o.conTerminate.argumentsCount(), 1 );
      test.identical( o.conTerminate.errorsCount(), 0 );
      test.identical( o.conTerminate.competitorsCount(), 0 );
      test.identical( o.ended, true );
      test.identical( o.state, 'terminated' );
      test.identical( o.error, null );
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.identical( o.process.exitCode, 0 );
      test.identical( o.process.signalCode, null );
      test.identical( _.Procedure.Counter - ptcounter, ( sync && !deasync ) ? 0 : 1 );
      ptcounter = _.Procedure.Counter;
      if( sync || deasync )
      test.identical( _.Procedure.FindAlive().length - pacounter, -2 );
      else
      test.identical( _.Procedure.FindAlive().length - pacounter, niteration > 1 ? -1 : 0 );
      pacounter = _.Procedure.FindAlive().length;
      /*
      2 extra procedures dies here on non-first iteration
        2 procedures of _.time.out()
      */
    })

    let result = _.time.out( context.t1 * 6, () => /* 1000 + context.t2 */
    {
      test.identical( track, [ 'conStart', 'conTerminate', 'ready' ] );

      test.identical( o.ready.argumentsCount(), 1 );
      test.identical( o.ready.errorsCount(), 0 );
      test.identical( o.ready.competitorsCount(), 0 );
      test.identical( o.conStart.argumentsCount(), 1 );
      test.identical( o.conStart.errorsCount(), 0 );
      test.identical( o.conStart.competitorsCount(), 0 );
      test.identical( o.conDisconnect.argumentsCount(), 0 );
      test.identical( o.conDisconnect.errorsCount(), 1 );
      test.identical( o.conDisconnect.competitorsCount(), 0 );
      test.identical( o.conTerminate.argumentsCount(), 1 );
      test.identical( o.conTerminate.errorsCount(), 0 );
      test.identical( o.conTerminate.competitorsCount(), 0 );
      test.identical( o.ended, true );
      test.identical( o.state, 'terminated' );
      test.identical( o.error, null );
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.identical( o.process.exitCode, 0 );
      test.identical( o.process.signalCode, null );
      test.identical( _.Procedure.Counter - ptcounter, 0 );
      ptcounter = _.Procedure.Counter;
      if( sync || deasync )
      test.identical( _.Procedure.FindAlive().length - pacounter, niteration > 1 ? -2 : -1 );
      else
      test.identical( _.Procedure.FindAlive().length - pacounter, -1 );
      pacounter = _.Procedure.FindAlive().length;
      /*
      2 extra procedures dies here on non-first iteration
        2 procedures of _.time.out()
      */
    });

    test.identical( _.Procedure.Counter - ptcounter, 3 );
    ptcounter = _.Procedure.Counter;
    test.identical( _.Procedure.FindAlive().length - pacounter, 3 );
    pacounter = _.Procedure.FindAlive().length;

    let returned = _.process.start( o );

    if( sync )
    test.is( returned === o );
    else
    test.is( returned === o.ready );
    test.is( o.conStart !== o.ready );
    test.is( o.conDisconnect !== o.ready );
    test.is( o.conTerminate !== o.ready );

    test.identical( o.ready.argumentsCount(), ( sync || deasync ) ? 1 : 0 );
    test.identical( o.ready.errorsCount(), 0 );
    test.identical( o.ready.competitorsCount(), 0 );
    test.identical( o.conStart.argumentsCount(), 1 );
    test.identical( o.conStart.errorsCount(), 0 );
    test.identical( o.conStart.competitorsCount(), 0 );
    test.identical( o.conDisconnect.argumentsCount(), 0 );
    test.identical( o.conDisconnect.errorsCount(), ( sync || deasync ) ? 1 : 0 );
    test.identical( o.conDisconnect.competitorsCount(), 0 );
    test.identical( o.conTerminate.argumentsCount(), ( sync || deasync ) ? 1 : 0 );
    test.identical( o.conTerminate.errorsCount(), 0 );
    test.identical( o.conTerminate.competitorsCount(), ( sync || deasync ) ? 0 : 1 );
    test.identical( o.ended, ( sync || deasync ) ? true : false );
    test.identical( o.state, ( sync || deasync ) ? 'terminated' : 'started' );
    test.identical( o.error, null );
    test.identical( o.exitCode, ( sync || deasync ) ? 0 : null );
    test.identical( o.exitSignal, null );
    test.identical( o.process.exitCode, ( sync || deasync ) ? 0 : null );
    test.identical( o.process.signalCode, null );
    test.identical( _.Procedure.Counter - ptcounter, 0 );
    ptcounter = _.Procedure.Counter;
    test.identical( _.Procedure.FindAlive().length - pacounter, ( sync && !deasync ) ? -1 : -2 );
    pacounter = _.Procedure.FindAlive().length;

    o.ready.tap( ( err, op ) =>
    {
      track.push( 'ready' );

      test.identical( err, undefined );
      test.identical( op, o );

      test.identical( o.ready.argumentsCount(), 1 );
      test.identical( o.ready.errorsCount(), 0 );
      test.identical( o.ready.competitorsCount(), 0 );
      test.identical( o.conStart.argumentsCount(), 1 );
      test.identical( o.conStart.errorsCount(), 0 );
      test.identical( o.conStart.competitorsCount(), 0 );
      test.identical( o.conDisconnect.argumentsCount(), 0 );
      test.identical( o.conDisconnect.errorsCount(), 1 );
      test.identical( o.conDisconnect.competitorsCount(), 0 );
      test.identical( o.conTerminate.argumentsCount(), 1 );
      test.identical( o.conTerminate.errorsCount(), 0 );
      test.identical( o.conTerminate.competitorsCount(), 0 );
      test.identical( o.ended, true );
      test.identical( o.state, 'terminated' );
      test.identical( o.error, null );
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.identical( o.process.exitCode, 0 );
      test.identical( o.process.signalCode, null );
      test.identical( _.Procedure.Counter - ptcounter, ( sync || deasync ) ? 1 : 0 );
      ptcounter = _.Procedure.Counter;
      test.identical( _.Procedure.FindAlive().length - pacounter, ( sync || deasync ) ? 1 : -1 );
      pacounter = _.Procedure.FindAlive().length;
      return null;
    })

    return result;
  }

  /* - */

  function testApp()
  {
    setTimeout( () => {}, context.t1 ); /* 1000 */
  }

}

startChronology.timeOut = 5e5;
startChronology.description =
`
  - conTerminate goes before ready
  - conStart goes before conTerminate
  - procedures generated
  - no extra procedures generated
`

// --
// delay
// --

function startReadyDelay( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  // let modes = [ 'spawn' ];
  modes.forEach( ( mode ) => a.ready.then( () => single( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => single( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => single( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => single( 1, 1, mode ) ) );
  return a.ready;

  /*  */

  function single( sync, deasync, mode )
  {
    let ready = new _.Consequence().take( null )

    if( sync && !deasync && mode === 'fork' )
    return null;

    ready.then( () =>
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode}`;
      let t1 = _.time.now();
      let ready = new _.Consequence().take( null ).delay( context.t2 );
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath} id:1` : `${programPath} id:1`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        mode,
        sync,
        deasync,
        ready,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        let parsed = JSON.parse( op.output );
        let diff = parsed.time - t1;
        console.log( diff );
        test.ge( diff, context.t2 );
        return null;
      })

      return returned;
    })

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    let args = _.process.input();
    let data = { time : _.time.now(), id : args.map.id };
    console.log( JSON.stringify( data ) );
  }

}

startReadyDelay.timeOut = 5e5;
startReadyDelay.description =
`
  - delay in consequence ready delay starting of the process
`

//

function startReadyDelayMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 0, deasync : 0, mode }) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 0, deasync : 1, mode }) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 1, deasync : 0, mode }) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 1, deasync : 1, mode }) ) );
  return a.ready;

  /* - */

  function run( op )
  {
    let ready = new _.Consequence().take( null )

    if( op.sync && !op.deasync && op.mode === 'fork' )
    return null;

    /* */

    ready.then( () =>
    {
      test.case = `sync:${op.sync} deasync:${op.deasync} concurrent:0 mode:${op.mode}`;
      let t1 = _.time.now();
      let ready2 = new _.Consequence().take( null ).delay( context.t1*4 );
      let o =
      {
        execPath : [ ( op.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:1`, ( op.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputPiping : 1,
        outputCollecting : 1,
        outputAdditive : 1,
        sync : op.sync,
        deasync : op.deasync,
        concurrent : 0,
        mode : op.mode,
        ready : ready2,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        op.runs.forEach( ( op2, counter ) =>
        {
          test.identical( op2.exitCode, 0 );
          test.identical( op2.exitSignal, null );
          test.identical( op2.exitReason, 'normal' );
          test.identical( op2.ended, true );
          let parsed = a.fileProvider.fileRead({ filePath : a.abs( `${counter+1}.json` ), encoding : 'json' });
          let diff = parsed.time - t1;
          console.log( diff );
          test.ge( diff, context.t1*4 );
          test.identical( parsed.id, counter+1 );
        });
        return null;
      })

      return returned;
    })

    /* */

    ready.then( () =>
    {
      test.case = `sync:${op.sync} deasync:${op.deasync} concurrent:1 mode:${op.mode}`;

      if( op.sync && !op.deasync )
      return null;

      let t1 = _.time.now();
      let ready2 = new _.Consequence().take( null ).delay( context.t1*4 );
      let o =
      {
        execPath : [ ( op.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:1`, ( op.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputPiping : 1,
        outputCollecting : 1,
        outputAdditive : 1,
        sync : op.sync,
        deasync : op.deasync,
        concurrent : 1,
        mode : op.mode,
        ready : ready2,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.is( op === o );
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        op.runs.forEach( ( op2, counter ) =>
        {
          test.identical( op2.exitCode, 0 );
          test.identical( op2.exitSignal, null );
          test.identical( op2.exitReason, 'normal' );
          test.identical( op2.ended, true );
          let parsed = a.fileProvider.fileRead({ filePath : a.abs( `${counter+1}.json` ), encoding : 'json' });
          let diff = parsed.time - t1;
          console.log( diff );
          test.ge( diff, context.t1*4 );
          test.identical( parsed.id, counter+1 );
        });
        return null;
      })

      return returned;
    })

    /* */

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let args = _.process.input();
    let data = { time : _.time.now(), id : args.map.id };
    _.fileProvider.fileWrite({ filePath : _.path.join(__dirname, `${args.map.id}.json` ), data, encoding : 'json' });
    console.log( `${args.map.id}::begin` )
    setTimeout( () => console.log( `${args.map.id}::end` ), context.t1 );
  }

}

startReadyDelayMultiple.timeOut = 5e5;
startReadyDelayMultiple.description =
`
  - delay in consequence ready delay starting of 2 processes
  - concurrent starting does not cause problems
`

//

function startOptionWhenDelay( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  // let modes = [ 'spawn' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 1, mode ) ) );
  return a.ready;

  /*  */

  function run( sync, deasync, mode )
  {
    let ready = new _.Consequence().take( null )

    if( sync && !deasync && mode === 'fork' )
    return null;

    ready.then( () =>
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode}`;
      let t1 = _.time.now();
      let when = { delay : context.t2 };
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        when : when,
        sync,
        deasync,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        let parsed = JSON.parse( op.output );
        let diff = parsed.time - t1;
        console.log( diff );
        test.ge( diff, when.delay );
        return null;
      })

      return returned;
    })

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    let data = { time : _.time.now() };
    console.log( JSON.stringify( data ) );
  }

}

startOptionWhenDelay.timeOut = 5e5;

//

function startOptionWhenTime( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 1, mode ) ) );
  return a.ready;

  /* */

  function run( sync, deasync, mode )
  {
    let ready = new _.Consequence().take( null )

    if( sync && !deasync && mode === 'fork' )
    return null;

    ready.then( () =>
    {
      test.case = `sync:${sync} deasync:${deasync} mode:${mode}`;

      let t1 = _.time.now();
      let delay = 5000;
      let when = { time : _.time.now() + delay };
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        mode,
        outputPiping : 1,
        outputCollecting : 1,
        when,
        sync,
        deasync,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        let parsed = JSON.parse( op.output );
        let diff = parsed.time - t1;
        test.ge( diff, delay );
        return null;
      })

      return returned;
    })

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );

    let data = { time : _.time.now() };
    console.log( JSON.stringify( data ) );
  }
}

startOptionWhenTime.timeOut = 5e5;

//

function startOptionTimeOut( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath1 = a.program({ routine : program1 });
  let programPath2 = a.program({ routine : program2 });
  let programPath3 = a.program({ routine : program3 });
  let programPath4 = a.program({ routine : program4 });
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  function run( mode )
  {
    let ready = _.Consequence().take( null )

    ready.then( () =>
    {
      test.case = `mode:${mode}, child process runs for some time`;

      let o =
      {
        execPath : mode === 'fork' ? 'program1.js' : `node program1.js`,
        mode,
        currentPath : a.routinePath,
        timeOut : context.t1*2,
      }

      _.process.start( o );

      return test.shouldThrowErrorAsync( o.conTerminate )
      .then( () =>
      {
        /* Child process on Windows terminates with 'SIGTERM' because process was terminated using process descriptor*/
        test.identical( o.exitCode, null );
        test.identical( o.ended, true );
        test.identical( o.exitSignal, 'SIGTERM' );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, child process ignores SIGTERM`;

      let o =
      {
        execPath : mode === 'fork' ? 'program2.js' : `node program2.js`,
        mode,
        currentPath : a.routinePath,
        timeOut : context.t1*2,
      }

      _.process.start( o );

      return test.shouldThrowErrorAsync( o.conTerminate )
      .then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          test.identical( o.exitSignal, 'SIGTERM' );
        }
        else if( process.platform === 'darwin' )
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          test.identical( o.exitSignal, 'SIGKILL' );
        }
        else
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          if( mode === 'shell' )
          test.identical( o.exitSignal, 'SIGTERM' );
          else
          test.identical( o.exitSignal, 'SIGKILL' );
        }
        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, process has single child that runs normally, process waits until child will exit`;

      let o =
      {
        execPath : mode === 'fork' ? 'program3.js' : `node program3.js`,
        args : 'program1.js',
        mode,
        currentPath : a.routinePath,
        timeOut : context.t1*2,
        outputPiping : 1,
        outputCollecting : 1
      }

      _.process.start( o );

      return test.shouldThrowErrorAsync( o.conTerminate )
      .then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          test.identical( o.exitSignal, 'SIGTERM' );
          test.is( !_.strHas( o.output, 'Process was killed by exit signal SIGTERM' ) );
        }
        else
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          test.identical( o.exitSignal, 'SIGTERM' );
          test.is( _.strHas( o.output, 'Process was killed by exit signal SIGTERM' ) );
        }
        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, parent and child ignore SIGTERM`;

      let o =
      {
        execPath : mode === 'fork' ? 'program4.js' : `node program4.js`,
        args : 'program2.js',
        mode,
        currentPath : a.routinePath,
        timeOut : context.t1*2,
        outputPiping : 1,
        outputCollecting : 1
      }

      _.process.start( o );

      return test.shouldThrowErrorAsync( o.conTerminate )
      .then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          test.identical( o.exitSignal, 'SIGTERM' );
        }
        else if( process.platform === 'darwin' )
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          test.identical( o.exitSignal, 'SIGKILL' );
        }
        else
        {
          test.identical( o.exitCode, null );
          test.identical( o.ended, true );
          if( mode === 'shell' )
          test.identical( o.exitSignal, 'SIGTERM' );
          else
          test.identical( o.exitSignal, 'SIGKILL' );
        }

        return null;
      })
    })

    return ready;
  }

  /* */

  function program1()
  {
    console.log( 'program1::start' )
    setTimeout( () =>
    {
      console.log( 'program1::end' )
    }, context.t1*4 )
  }

  /* */

  function program2()
  {
    console.log( 'program2::start', process.pid )
    setTimeout( () =>
    {
      console.log( 'program2::end' )
    }, context.t1*8 )

    process.on( 'SIGTERM', () =>
    {
      console.log( 'program2: SIGTERM is ignored')
    })
  }

  /* */

  function program3()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wProcess' );

    process.removeAllListeners( 'SIGTERM' ); /* clear listeners defined in wProcess */

    let o =
    {
      execPath : 'node',
      args : process.argv.slice( 2 ),
      mode : 'spawn',
      currentPath : __dirname,
      stdio : 'pipe',
      outputPiping : 1,
    }
    _.process.start( o );

    /* ignores SIGTERM until child process will be terminated, then emits SIGTERM by itself */
    process.on( 'SIGTERM', () =>
    {
      o.conTerminate.catch( ( err ) =>
      {
        _.errLogOnce( err );
        process.removeAllListeners( 'SIGTERM' );
        process.kill( process.pid, 'SIGTERM' );
        return null;
      })
    })
  }

  /* */

  function program4()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wProcess' );

    process.removeAllListeners( 'SIGTERM' ); /* clear listeners defined in wProcess */

    let o =
    {
      execPath : 'node',
      args : process.argv.slice( 2 ),
      mode : 'spawn',
      currentPath : __dirname,
      stdio : 'pipe',
      outputPiping : 1,
    }
    _.process.start( o );

    /* ignores SIGTERM until child process will be terminated */
    process.on( 'SIGTERM', () =>
    {
      o.conTerminate.catch( ( err ) =>
      {
        _.errLogOnce( err );
        return null;
      })
    })
  }

  /* */

}

startOptionTimeOut.timeOut = 5e5;

//

function startAfterDeath( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let stack = [];
  let testAppParentPath = a.program( testAppParent );
  let testAppChildPath = a.program( testAppChild );

  /* */

  let testFilePath = a.abs( a.routinePath, 'testFile' );

  a.ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node testAppParent.js',
      mode : 'spawn',
      outputCollecting : 1,
      outputPiping : 1,
      currentPath : a.routinePath,
      ipc : 1,
    }
    debugger;
    let con = _.process.start( o );
    let childPid;
    debugger;

    o.process.on( 'message', ( e ) =>
    {
      childPid = _.numberFrom( e );
    })

    o.conTerminate.then( () =>
    {
      stack.push( 'conTerminate' );
      test.identical( o.exitCode, 0 );
      test.case = 'secondary process is alive'
      test.is( _.process.isAlive( childPid ) );
      test.case = 'child of secondary process does not exit yet'
      test.is( !a.fileProvider.fileExists( testFilePath ) );
      return _.time.out( context.t2 * 2 ); /* 10000 */
    })

    o.conTerminate.then( () =>
    {
      stack.push( 'conTerminate' );
      test.identical( stack, [ 'conTerminate', 'conTerminate' ] );
      test.case = 'secondary process is dead'
      test.is( !_.process.isAlive( childPid ) );

      test.case = 'child of secondary process is executed'
      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid2 = a.fileProvider.fileRead( testFilePath );
      childPid2 = _.numberFrom( childPid2 );

      test.case = 'secondary process and child are not same'
      test.is( !_.process.isAlive( childPid2 ) );
      test.notIdentical( childPid, childPid2 );
      return null;
    })

    return con;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      outputCollecting : 1,
      mode : 'spawn',
    }

    _.process.startAfterDeath( o );

    o.conStart.thenGive( () =>
    {
      process.send( o.process.pid );
    })

    _.time.out( context.t2, () => /* 5000 */
    {
      console.log( 'parent termination begin' );
      _.procedure.terminationBegin();
      return null;
    })
  }

  /* */

  function testAppChild()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wFiles' );

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
    })
  }

}

//

// function startAfterDeathOutput( test )
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

//     con.then( ( op ) =>
//     {
//       test.identical( op.exitCode, 0 );
//       test.identical( op.ended, true );
//       test.is( _.strHas( op.output, 'Parent process exit' ) )
//       test.is( _.strHas( op.output, 'Secondary: starting child process...' ) )
//       test.is( _.strHas( op.output, 'Child process start' ) )
//       test.is( _.strHas( op.output, 'Child process end' ) )

//       return null;
//     })

//     return con;
//   })

//   /*  */

//   return ready;
// }

// --
// detaching
// --

function startDetachingModeSpawnResourceReady( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppChildPath = a.program( testAppChild );

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'consequence receive resources after child spawn';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      detaching : 1,
      currentPath : a.routinePath,
      throwingExitCode : 0
    }
    let result = _.process.start( o );

    test.is( result !== o.conStart );
    test.is( result !== o.conTerminate );

    o.conStart.then( ( op ) =>
    {
      track.push( 'conStart' );
      test.is( _.mapIs( op ) );
      test.identical( op, o );
      test.is( _.process.isAlive( o.process.pid ) );
      o.process.kill();
      return null;
    })

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate' );
      test.notIdentical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, 'SIGTERM' );
      test.identical( track, [ 'conStart', 'conTerminate' ] );
      return null;
    })

    return o.conTerminate;
  })

  return a.ready;

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

//

function startDetachingModeForkResourceReady( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppChildPath = a.program( testAppChild );

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'consequence receives resources after child spawn';

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      detaching : 1,
      currentPath : a.routinePath,
      throwingExitCode : 0
    }
    let result = _.process.start( o );

    test.is( result !== o.conStart );
    test.is( result !== o.conTerminate );

    o.conStart.thenGive( ( op ) =>
    {
      track.push( 'conStart' );
      test.is( _.mapIs( op ) );
      test.identical( op, o );
      test.is( _.process.isAlive( o.process.pid ) );
      o.process.kill();
    })

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate' );
      test.notIdentical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, 'SIGTERM' );
      test.identical( track, [ 'conStart', 'conTerminate' ] )
      return null;
    })

    return o.conTerminate;
  })

  return a.ready;

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

//

function startDetachingModeShellResourceReady( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppChildPath = a.program( testAppChild );

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'consequence receives resources after child spawn';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      detaching : 1,
      currentPath : a.routinePath,
      throwingExitCode : 0
    }
    let result = _.process.start( o );

    test.is( result !== o.conStart );
    test.is( result !== o.conTerminate );

    o.conStart.thenGive( ( op ) =>
    {
      track.push( 'conStart' );
      test.is( _.mapIs( op ) );
      test.identical( op, o );
      test.is( _.process.isAlive( o.process.pid ) );
      o.process.kill();
    })

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate' );
      test.notIdentical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, 'SIGTERM' );
      test.identical( track, [ 'conStart', 'conTerminate' ] );
      return null;
    })

    return o.conTerminate;
  })

  return a.ready;

  function testAppChild()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

//

function startDetachingModeSpawnNoTerminationBegin( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppParentPath = a.program( testAppParent );
  let testAppChildPath = a.program( testAppChild );
  let testFilePath = a.abs( a.routinePath, 'testFile' );

  a.ready

  .then( () =>
  {
    test.case = 'stdio:ignore ipc:false, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore ipc : false outputPiping : 0 outputCollecting : 0',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
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
      execPath : 'node testAppParent.js stdio : ignore ipc : true outputPiping : 0 outputCollecting : 0',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
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
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
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
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.input();

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      ipc : 0,
      detaching : true,
    }

    _.mapExtend( o, args.map );
    if( o.ipc !== undefined )
    o.ipc = _.boolFrom( o.ipc );

    _.process.start( o );

    process.send({ childPid : o.process.pid });
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }


}

//

function startDetachingModeForkNoTerminationBegin( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppParentPath = a.program( testAppParent );
  let testAppChildPath = a.program( testAppChild );

  let testFilePath = a.abs( a.routinePath, 'testFile' );

  a.ready

  /*  */

  .then( () =>
  {
    test.case = 'stdio:ignore, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : ignore outputPiping : 0 outputCollecting : 0',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
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
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.identical( data.childPid, childPid )

      return null;
    })

    return con;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.input();

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      detaching : true,
    }

    _.mapExtend( o, args.map );
    if( o.ipc !== undefined )
    o.ipc = _.boolFrom( o.ipc );

    _.process.start( o );

    process.send({ childPid : o.process.pid });
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

}

//

function startDetachingModeShellNoTerminationBegin( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppParentPath = a.program( testAppParent );
  let testAppChildPath = a.program( testAppChild );

  let testFilePath = a.abs( a.routinePath, 'testFile' );

  a.ready

  .then( () =>
  {
    test.case = 'stdio:ignore, parent should wait for child to exit';

    let o =
    {
      execPath : 'node testAppParent.js stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
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
      currentPath : a.routinePath,
      ipc : 1,
    }
    let con = _.process.start( o );

    let data;

    o.process.on( 'message', ( e ) =>
    {
      data = e;
      data.childPid = _.numberFrom( data.childPid );
    })

    con.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.will = 'parent and child are dead';
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( data.childPid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid );
      test.is( !_.process.isAlive( childPid ) );

      return null;
    })

    return con;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.input();

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      ipc : 0,
      detaching : true,
    }

    _.mapExtend( o, args.map );
    if( o.ipc !== undefined )
    o.ipc = _.boolFrom( o.ipc );

    _.process.start( o );

    process.send({ childPid : o.process.pid });
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

//

/* qqq for Yevhen : implement for other modes */
function startDetachedOutputStdioIgnore( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppParentPath = a.program( testAppParent );
  let testAppChildPath = a.program( testAppChild );

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : ignore, no output from detached child';

    let o =
    {
      execPath : 'node testAppParent.js mode : spawn stdio : ignore',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
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

  return a.ready;

  /* - */


  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.input();

    let o =
    {
      execPath : 'testAppChild.js',
      detaching : true,
    }

    _.mapExtend( o, args.map );
    if( o.ipc !== undefined )
    o.ipc = _.boolFrom( o.ipc );

    if( o.mode !== 'fork' )
    o.execPath = 'node ' + o.execPath;

    _.process.start( o );
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      console.log( 'Child process end' )
      return null;
    })
  }

}

//

/* qqq for Yevhen : implement for other modes */
function startDetachedOutputStdioPipe( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppParentPath = a.program( testAppParent );
  let testAppChildPath = a.program( testAppChild );

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : pipe';

    let o =
    {
      execPath : 'node testAppParent.js mode : spawn stdio : pipe',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
    }
    let con = _.process.start( o );

    con.then( () =>
    {
      test.identical( o.exitCode, 0 )

      // zzz for Vova: output piping doesn't work as expected in mode "shell" on windows
      // investigate if its fixed in never verions of node or implement alternative solution

      if( process.platform === 'win32' )
      return null;

      test.is( _.strHas( o.output, 'Child process start' ) )
      test.is( _.strHas( o.output, 'Child process end' ) )
      return null;
    })

    return con;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.input();

    let o =
    {
      execPath : 'testAppChild.js',
      detaching : true,
    }

    _.mapExtend( o, args.map );
    if( o.ipc !== undefined )
    o.ipc = _.boolFrom( o.ipc );

    if( o.mode !== 'fork' )
    o.execPath = 'node ' + o.execPath;

    _.process.start( o );
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      console.log( 'Child process end' )
      return null;
    })
  }


}

//

/* qqq for Yevhen : implement for other modes */
function startDetachedOutputStdioInherit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppChildPath = a.program( testAppChild );

  /* */

  test.is( true );

  if( !Config.debug )
  return a.ready;

  a.ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : inherit';
    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      stdio : 'inherit',
      detaching : 1,
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
    }
    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  /*  */

  return a.ready;

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

//

/* qqq for Yevhen : implement for other modes */
function startDetachingModeSpawnIpc( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppChildPath = a.program( testAppChild );

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'mode : spawn, stdio : ignore';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'spawn',
      outputPiping : 0,
      outputCollecting : 0,
      stdio : 'ignore',
      currentPath : a.routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( e ) =>
    {
      message = e;
    })

    o.conStart.thenGive( () =>
    {
      track.push( 'conStart' );
      o.process.send( 'child' );
    })

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate' );
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( message, 'child' );
      test.identical( track, [ 'conStart', 'conTerminate' ] );
      track = [];
      return null;
    })

    return o.conTerminate;
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
      currentPath : a.routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( e ) =>
    {
      message = e;
    })

    o.conStart.thenGive( () =>
    {
      track.push( 'conStart' );
      o.process.send( 'child' );
    })

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate' );
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( message, 'child' );
      test.identical( track, [ 'conStart', 'conTerminate' ] );
      track = [];
      return null;
    })

    return o.conTerminate;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    process.on( 'message', ( data ) =>
    {
      process.send( data );
      process.exit();
    })

  }
}

//

/* qqq for Yevhen : implement for other modes */
function startDetachingModeForkIpc( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppChildPath = a.program( testAppChild );

  /* */

  a.ready

  .then( () =>
  {
    test.case = 'mode : fork, stdio : ignore';

    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      outputPiping : 0,
      outputCollecting : 0,
      stdio : 'ignore',
      currentPath : a.routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( e ) =>
    {
      message = e;
    })

    o.conStart.thenGive( () =>
    {
      track.push( 'conStart' );
      o.process.send( 'child' );
    })

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate' );
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( message, 'child' );
      test.identical( track, [ 'conStart', 'conTerminate' ] );
      track = [];
      return null;
    })

    return o.conTerminate;
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
      currentPath : a.routinePath,
      detaching : 1,
      ipc : 1,
    }
    _.process.start( o );

    let message;

    o.process.on( 'message', ( e ) =>
    {
      message = e;
    })

    o.conStart.thenGive( () =>
    {
      track.push( 'conStart' );
      o.process.send( 'child' );
    })

    o.conTerminate.then( ( op ) =>
    {
      track.push( 'conTerminate' );
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( message, 'child' );
      test.identical( track, [ 'conStart', 'conTerminate' ] );
      track = [];
      return null;
    })

    return o.conTerminate;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    process.on( 'message', ( data ) =>
    {
      process.send( data );
      process.exit();
    })

  }
}

//

/* qqq for Yevhen : implement for other modes */
function startDetachingModeShellIpc( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppChildPath = a.program( testAppChild );

  /* */

  test.is( true );

  if( !Config.debug )
  return a.ready;

  a.ready

  .then( () =>
  {
    test.case = 'mode : shell, stdio : ignore';

    let o =
    {
      execPath : 'node testAppChild.js',
      mode : 'shell',
      outputCollecting : 1,
      stdio : 'ignore',
      currentPath : a.routinePath,
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
      currentPath : a.routinePath,
      detaching : 1,
      ipc : 1,
    }
    return test.shouldThrowErrorSync( () => _.process.start( o ) );
  })

  /*  */

  return a.ready;

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    process.on( 'message', ( data ) =>
    {
      process.send( data );
      process.exit();
    })

  }
}

//

/* qqq for Yevhen : implement for other modes */
function startDetachingTrivial( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppParentPath = a.program( testAppParent );
  let testAppChildPath = a.program( testAppChild );
  let testFilePath = a.abs( a.routinePath, 'testFile' );

  /* */

  test.case = 'trivial use case';

  let o =
  {
    execPath : 'testAppParent.js',
    outputCollecting : 1,
    mode : 'fork',
    stdio : 'pipe',
    detaching : 0,
    throwingExitCode : 0,
    currentPath : a.routinePath,
  }

  _.process.start( o );

  var childPid;
  o.process.on( 'message', ( e ) =>
  {
    childPid = _.numberFrom( e );
  })

  o.conTerminate.then( ( op ) =>
  {
    track.push( 'conTerminate' );
    test.is( _.process.isAlive( childPid ) );
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, 'Child process start' ) );
    test.is( _.strHas( op.output, 'from parent: data' ) );
    test.is( !_.strHas( op.output, 'Child process end' ) );
    test.identical( o.exitCode, op.exitCode );
    test.identical( o.output, op.output );
    return _.time.out( context.t2 * 2 ); /* 10000 */
  })

  o.conTerminate.then( () =>
  {
    track.push( 'conTerminate' );
    test.is( !_.process.isAlive( childPid ) );

    let childPidFromFile = a.fileProvider.fileRead( testFilePath );
    childPidFromFile = _.numberFrom( childPidFromFile )
    test.is( !_.process.isAlive( childPidFromFile ) );
    test.identical( childPid, childPidFromFile )
    test.identical( track, [ 'conTerminate', 'conTerminate' ] );
    return null;
  })

  return o.conTerminate;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
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

    o.conStart.thenGive( () =>
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
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    process.on( 'message', ( data ) =>
    {
      console.log( 'from parent:', data );
      process.send( 'ready to disconnect' )
    })

    _.time.out( context.t2, () => /* 5000 */
    {
      console.log( 'Child process end' );
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      return null;
    })

  }
}

//

function startEventClose( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program({ routine : program1 });
  let data = [];

  let modes = [ 'spawn', 'fork', 'shell' ];
  let ipc = [ false, true ]
  let disconnecting = [ false, true ];

  modes.forEach( mode =>
  {
    ipc.forEach( ipc =>
    {
      disconnecting.forEach( disconnecting =>
      {
        a.ready.then( () => run( mode,ipc,disconnecting ) );
      })
    })
  })

  a.ready.then( () =>
  {
    var dim = [ data.length / 4, 4 ];
    var style = 'doubleBorder';
    var topHead = [ 'mode', 'ipc', 'disconnecting', 'event close' ];
    var got = _.strTable({ data, dim, style, topHead, colWidth : 18 });

    var exp =
`
╔════════════════════════════════════════════════════════════════════════╗
║       mode               ipc          disconnecting      event close   ║
╟────────────────────────────────────────────────────────────────────────╢
║       spawn             false             false             true       ║
║       spawn             false             true              true       ║
║       spawn             true              false             true       ║
║       spawn             true              true              false      ║
║       fork              true              false             true       ║
║       fork              true              true              false      ║
║       shell             false             false             true       ║
║       shell             false             true              true       ║
╚════════════════════════════════════════════════════════════════════════╝
`
    test.equivalent( got.result, exp );
    console.log( got.result )
    return null;
  })

  return a.ready;

  /* - */

  function run( mode, ipc, disconnecting )
  {
    let ready = new _.Consequence().take( null );

    if( ipc && mode === 'shell' )
    return ready;

    if( !ipc && mode === 'fork' )
    return ready;

    let result = [ mode, ipc, disconnecting, false ];

    ready.then( () =>
    {
      let o =
      {
        execPath : mode === 'fork' ? 'program1.js' : 'node program1.js',
        currentPath : a.routinePath,
        stdio : 'ignore',
        detaching : 0,
        mode,
        ipc,
      }

      test.case = _.toJs({ mode, ipc, disconnecting });

      _.process.start( o );

      o.conStart.thenGive( () =>
      {
        if( disconnecting )
        o.disconnect()
      })
      o.process.on( 'close', () =>
      {
        result[ 3 ] = true;
      })

      return _.time.out( context.t1 * 3, () =>
      {
        test.is( !_.process.isAlive( o.process.pid ) );

        if( mode === 'shell' )
        test.identical( result[ 3 ], true )

        if( mode === 'spawn' )
        test.identical( result[ 3 ], ipc && disconnecting ? false : true )

        if( mode === 'fork' )
        test.identical( result[ 3 ], !disconnecting )

        data.push.apply( data, result );
        return null;
      })
    })

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath )
    console.log( 'program1::begin' );
    setTimeout( () =>
    {
      console.log( 'program1::end' );
    }, context.t1 * 2 );
  }
}

startEventClose.timeOut = 5e5;
startEventClose.description =
`
Check if close event is called.
`

//

function startEventExit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program({ routine : program1 });
  let data = [];
  let modes = [ 'spawn', 'fork', 'shell' ];
  let stdio = [ 'inherit', 'pipe', 'ignore' ];
  let ipc = [ false, true ]
  let detaching = [ false, true ]
  let disconnecting = [ false, true ];

  modes.forEach( mode =>
  {
    stdio.forEach( stdio =>
    {
      ipc.forEach( ipc =>
      {
        detaching.forEach( detaching =>
        {
          disconnecting.forEach( disconnecting =>
          {
            a.ready.then(() => run( mode, stdio, ipc, detaching, disconnecting ) );
          })
        })
      })
    })
  })

  a.ready.then( () =>
  {
    var dim = [ data.length / 6, 6 ];
    var style = 'doubleBorder';
    var topHead = [ 'mode', 'stdio','ipc', 'detaching', 'disconnecting', 'event exit' ];
    var got = _.strTable({ data, dim, style, topHead, colWidth : 18 });

    var exp =
`
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║       mode              stdio              ipc            detaching       disconnecting      event exit    ║
╟────────────────────────────────────────────────────────────────────────────────────────────────────────────╢
║       spawn            inherit            false             false             false             true       ║
║       spawn            inherit            false             true              false             true       ║
║       spawn            inherit            true              false             false             true       ║
║       spawn            inherit            true              true              false             true       ║
║       spawn             pipe              false             false             false             true       ║
║       spawn             pipe              false             true              false             true       ║
║       spawn             pipe              false             false             true              true       ║
║       spawn             pipe              false             true              true              true       ║
║       spawn             pipe              true              false             false             true       ║
║       spawn             pipe              true              true              false             true       ║
║       spawn             pipe              true              false             true              true       ║
║       spawn             pipe              true              true              true              true       ║
║       spawn            ignore             false             false             false             true       ║
║       spawn            ignore             false             true              false             true       ║
║       spawn            ignore             false             false             true              true       ║
║       spawn            ignore             false             true              true              true       ║
║       spawn            ignore             true              false             false             true       ║
║       spawn            ignore             true              true              false             true       ║
║       spawn            ignore             true              false             true              true       ║
║       spawn            ignore             true              true              true              true       ║
║       fork             inherit            true              false             false             true       ║
║       fork             inherit            true              true              false             true       ║
║       fork              pipe              true              false             false             true       ║
║       fork              pipe              true              true              false             true       ║
║       fork              pipe              true              false             true              true       ║
║       fork              pipe              true              true              true              true       ║
║       fork             ignore             true              false             false             true       ║
║       fork             ignore             true              true              false             true       ║
║       fork             ignore             true              false             true              true       ║
║       fork             ignore             true              true              true              true       ║
║       shell            inherit            false             false             false             true       ║
║       shell            inherit            false             true              false             true       ║
║       shell             pipe              false             false             false             true       ║
║       shell             pipe              false             true              false             true       ║
║       shell             pipe              false             false             true              true       ║
║       shell             pipe              false             true              true              true       ║
║       shell            ignore             false             false             false             true       ║
║       shell            ignore             false             true              false             true       ║
║       shell            ignore             false             false             true              true       ║
║       shell            ignore             false             true              true              true       ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
`
    test.equivalent( got.result, exp );

    console.log( got.result )
    return null;
  })

  return a.ready;

  /* - */

  function run( mode, stdio, ipc, detaching, disconnecting )
  {
    let ready = new _.Consequence().take( null );

    if( detaching && stdio === 'inherit' ) /* remove if assert in start is removed */
    return ready;

    if( ipc && mode === 'shell' )
    return ready;

    if( !ipc && mode === 'fork' )
    return ready;

    let result = [ mode, stdio, ipc, disconnecting, detaching, false ];

    ready.then( () =>
    {
      let o =
      {
        execPath : mode === 'fork' ? 'program1.js' : 'node program1.js',
        currentPath : a.routinePath,
        outputPiping : 0,
        outputCollecting : 0,
        stdio,
        mode,
        ipc,
        detaching
      }

      test.case = _.toJs({ mode, stdio, ipc, disconnecting, detaching });

      _.process.start( o );

      o.conStart.thenGive( () =>
      {
        if( disconnecting )
        o.disconnect()
      })
      o.process.on( 'exit', () =>
      {
        result[ 5 ] = true;
      })

      return _.time.out( context.t1 * 3, () =>
      {
        test.is( !_.process.isAlive( o.process.pid ) );
        test.identical( result[ 5 ], true );
        data.push.apply( data, result );
        return null;
      })
    })

    return ready;
  }

  /* - */

  function program1()
  {
    setTimeout( () => {}, context.t1 );
  }
}

startEventExit.timeOut = 5e5;
startEventExit.description =
`
Check if exit event is called.
`

//

/* qqq for Yevhen : implement for other modes */
function startDetachingChildExitsAfterParent( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppParentPath = a.path.nativize( a.program( testAppParent ) );
  let testAppChildPath = a.path.nativize( a.program( testAppChild ) );
  let testFilePath = a.abs( a.routinePath, 'testFile' );

  /* */

  a.ready

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
      currentPath : a.routinePath,
      detaching : 0,
      ipc : 1,
    }
    let con = _.process.start( o );

    let childPid;

    o.process.on( 'message', ( e ) =>
    {
      childPid = _.numberFrom( e );
    })

    o.conTerminate.then( ( op ) =>
    {
      test.will = 'parent is dead, detached child is still running'
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( _.process.isAlive( childPid ) );
      return _.time.out( context.t2 * 2 ); /* 10000 */ /* zzz */
    })

    o.conTerminate.then( () =>
    {
      let childPid2 = a.fileProvider.fileRead( testFilePath );
      childPid2 = _.numberFrom( childPid2 )
      test.is( !_.process.isAlive( childPid2 ) );
      test.identical( childPid, childPid2 )
      return null;
    })

    return o.conTerminate;
  })

  /*  */

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      stdio : 'ignore',
      outputPiping : 0,
      outputCollecting : 0,
      detaching : true,
      mode : 'spawn',
    }

    _.process.start( o );

    process.send( o.process.pid );

    _.time.out( context.t1, () => o.disconnect() ); /* 1000 */
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' );

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' );
    })
  }
}

startDetachingChildExitsAfterParent.description =
`
Parent starts child process in detached mode and disconnects it.
Child process continues to work for at least 5 seconds after parent exits.
After 5 seconds child process creates test file in working directory and exits.
`

//

/* qqq for Yevhen : implement for other modes */
function startDetachingChildExitsBeforeParent( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppParentPath = a.path.nativize( a.program( testAppParent ) );
  let testAppChildPath = a.path.nativize( a.program( testAppChild ) );

  let testFilePath = a.abs( a.routinePath, 'testFile' );

  /* */

  a.ready

  .then( () =>
  {
    let o =
    {
      execPath : 'node testAppParent.js',
      mode : 'spawn',
      outputCollecting : 1,
      currentPath : a.routinePath,
      ipc : 1,
    }
    _.process.start( o );

    let child;
    let onChildTerminate = new _.Consequence();

    o.process.on( 'message', ( e ) =>
    {
      child = e;
      onChildTerminate.take( e );
    })

    onChildTerminate.then( () =>
    {
      let childPid = a.fileProvider.fileRead( testFilePath );
      test.is( _.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( _.numberFrom( childPid ) ) );
      return null;
    })

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );

      test.will = 'parent and chid are dead';

      test.identical( child.err, undefined );
      test.identical( child.exitCode, 0 );

      test.is( !_.process.isAlive( o.process.pid ) );
      test.is( !_.process.isAlive( child.pid ) );

      test.is( a.fileProvider.fileExists( testFilePath ) );
      let childPid = a.fileProvider.fileRead( testFilePath );
      childPid = _.numberFrom( childPid )
      test.is( !_.process.isAlive( childPid ) );

      test.identical( child.pid, childPid );

      return null;
    })

    return _.Consequence.AndKeep( onChildTerminate, o.conTerminate );
  })

  /*  */

  return a.ready;

  /* - */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let o =
    {
      execPath : 'node testAppChild.js',
      stdio : 'ignore',
      outputPiping : 0,
      outputCollecting : 0,
      detaching : true,
      mode : 'spawn',

    }

    _.process.start( o );

    o.conTerminate.finally( ( err, op ) =>
    {
      process.send({ exitCode : op.exitCode, err, pid : o.process.pid });
      return null;
    })

    _.time.out( context.t2, () => /* 5000 */
    {
      console.log( 'Parent process end' )
    });
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t1, () => /* 1000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }

}

startDetachingChildExitsBeforeParent.description =
`
Parent starts child process in detached mode and registers callback to wait for child process.
Child process creates test file after 1 second and exits.
Callback in parent recevies message. Parent exits.
`

//

function startDetachingDisconnectedEarly( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  // let modes = [ 'fork', 'spawn', 'shell' ];
  let modes = [ 'spawn' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  function run( mode )
  {
    let ready = _.Consequence().take( null );
    let track = [];

    ready
    .then( () =>
    {
      test.case = `detaching on, disconnected forked child, mode:${mode}`;
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 1,
      }

      let result = _.process.start( o );

      test.identical( o.ready.argumentsCount(), 0 );
      test.identical( o.ready.errorsCount(), 0 );
      test.identical( o.ready.competitorsCount(), 0 );
      test.identical( o.conStart.argumentsCount(), 1 );
      test.identical( o.conStart.errorsCount(), 0 );
      test.identical( o.conStart.competitorsCount(), 0 );
      test.identical( o.conDisconnect.argumentsCount(), 0 );
      test.identical( o.conDisconnect.errorsCount(), 0 );
      test.identical( o.conDisconnect.competitorsCount(), 0 );
      test.identical( o.conTerminate.argumentsCount(), 0 );
      test.identical( o.conTerminate.errorsCount(), 0 );
      test.identical( o.conTerminate.competitorsCount(), 0 );

      test.identical( o.state, 'started' );
      test.is( o.conStart !== result );
      test.is( _.consequenceIs( o.conStart ) )

      test.identical( o.state, 'started' );
      o.disconnect();
      test.identical( o.state, 'disconnected' );

      o.conStart.finally( ( err, op ) =>
      {
        track.push( 'conStart' );
        test.identical( err, undefined );
        test.identical( op, o );
        test.is( _.process.isAlive( o.process.pid ) );
        return null;
      })

      o.conDisconnect.finally( ( err, op ) =>
      {
        track.push( 'conDisconnect' );
        test.identical( err, undefined );
        test.identical( op, o );
        test.is( _.process.isAlive( o.process.pid ) )
        return null;
      })

      o.conTerminate.finally( ( err, op ) =>
      {
        track.push( 'conTerminate' );
        test.identical( err, _.dont );
        return null;
      })

      result = _.time.out( context.t2, () => /* 5000 */
      {
        test.identical( o.state, 'disconnected' );
        test.identical( o.ended, true );
        test.identical( track, [ 'conStart', 'conDisconnect', 'conTerminate' ] );
        test.is( !_.process.isAlive( o.process.pid ) );
        return null;
      })

      return _.Consequence.AndTake( o.conStart, result );
    })

    /* */

    return ready;
  }

  /* */

  function program1()
  {
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, context.t1 * 2 ); /* 2000 */
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
  }
}

startDetachingDisconnectedEarly.description =
`
Parent starts child process in detached mode and disconnects it right after start.
Child process creates test file after 2 second and stays alive.
conStart recevies message when process starts.
conDisconnect recevies message on disconnect which happen without delay.
conTerminate does not recevie an message.
Test routine waits for few seconds and checks if child is alive.
ProcessWatched should not throw any error.
`

//

function startDetachingDisconnectedLate( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  function run( mode )
  {
    let ready = _.Consequence().take( null );
    let track = [];

    ready
    .then( () =>
    {
      test.case = `detaching on, disconnected forked child, mode:${mode}`;
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 1,
      }

      let result = _.process.start( o );

      test.identical( o.ready.argumentsCount(), 0 );
      test.identical( o.ready.errorsCount(), 0 );
      test.identical( o.ready.competitorsCount(), 0 );
      test.identical( o.conStart.argumentsCount(), 1 );
      test.identical( o.conStart.errorsCount(), 0 );
      test.identical( o.conStart.competitorsCount(), 0 );
      test.identical( o.conDisconnect.argumentsCount(), 0 );
      test.identical( o.conDisconnect.errorsCount(), 0 );
      test.identical( o.conDisconnect.competitorsCount(), 0 );
      test.identical( o.conTerminate.argumentsCount(), 0 );
      test.identical( o.conTerminate.errorsCount(), 0 );
      test.identical( o.conTerminate.competitorsCount(), 0 );

      test.identical( o.state, 'started' );

      _.time.begin( 1000, () =>
      {
        test.identical( o.state, 'started' );
        o.disconnect();
        test.identical( o.state, 'disconnected' );
      });

      test.is( o.conStart !== result );
      test.is( _.consequenceIs( o.conStart ) )

      o.conStart.finally( ( err, op ) =>
      {
        track.push( 'conStart' );
        test.identical( err, undefined );
        test.identical( op, o );
        test.is( _.process.isAlive( o.process.pid ) )
        return null;
      })

      o.conDisconnect.finally( ( err, op ) =>
      {
        track.push( 'conDisconnect' );
        test.identical( err, undefined );
        test.identical( op, o );
        test.is( _.process.isAlive( o.process.pid ) )
        return null;
      })

      o.conTerminate.tap( ( err, op ) =>
      {
        track.push( 'conTerminate' );
        test.identical( err, _.dont );
      })

      result = _.time.out( context.t2, () => /* 5000 */
      {
        test.identical( o.state, 'disconnected' );
        test.identical( o.ended, true );
        test.identical( track, [ 'conStart', 'conDisconnect', 'conTerminate' ] );
        test.is( !_.process.isAlive( o.process.pid ) )
        return null;
      })

      return _.Consequence.AndTake( o.conStart, result );
    })

    /* */

    return ready;
  }

  /* */

  function program1()
  {
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, context.t1 * 2 ); /* 2000 */
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
  }
}

startDetachingDisconnectedLate.description =
`
Parent starts child process in detached mode and disconnects after short delay.
Child process creates test file after 2 second and stays alive.
conStart recevies message when process starts.
conDisconnect recevies message on disconnect which happen with short delay.
conTerminate does not recevie an message.
Test routine waits for few seconds and checks if child is alive.
ProcessWatched should not throw any error.
`

//

/* qqq for Yevhen : implement for other modes */
function startDetachingChildExistsBeforeParentWaitForTermination( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppChildPath = a.path.nativize( a.program( testAppChild ) );

  a.ready

  .then( () =>
  {
    test.case = 'detaching on, disconnected forked child'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : 'ignore',
      outputPiping : 0,
      outputCollecting : 0,
      currentPath : a.routinePath,
      detaching : 1
    }

    _.process.start( o );

    o.conTerminate.finally( ( err, op ) =>
    {
      test.identical( err, undefined );
      test.identical( op, o );
      test.is( !_.process.isAlive( o.process.pid ) )
      return null;
    })

    return o.conTerminate;
  })

  /* */

  return a.ready;

  /* */

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.input();

    _.time.out( context.t1 * 2, () => /* 2000 */
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
Test routine waits until o.conTerminate resolves message about termination of the child process.
`

//

/* qqq for Yevhen : implement for other modes */
function startDetachingEndCompetitorIsExecuted( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppChildPath = a.program( testAppChild );

  a.ready

  .then( () =>
  {
    test.case = 'detaching on, disconnected forked child'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : 'ignore',
      outputPiping : 0,
      outputCollecting : 0,
      currentPath : a.routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.is( o.conStart !== result );
    test.is( _.consequenceIs( o.conStart ) )
    test.is( _.consequenceIs( o.conTerminate ) )

    o.conStart.finally( ( err, op ) =>
    {
      track.push( 'conStart' );
      test.identical( o.ended, false );
      test.identical( err, undefined );
      test.identical( op, o );
      test.is( _.process.isAlive( o.process.pid ) );
      return null;
    })

    o.conTerminate.finally( ( err, op ) =>
    {
      track.push( 'conTerminate' );
      test.identical( o.ended, true );
      test.identical( err, undefined );
      test.identical( op, o );
      test.identical( track, [ 'conStart', 'conTerminate' ] )
      test.is( !_.process.isAlive( o.process.pid ) )
      return null;
    })

    return _.Consequence.AndTake( o.conStart, o.conTerminate );
  })

  /* */

  return a.ready;

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.input();

    _.time.out( context.t1 * 2, () => /* 2000 */
    {
      console.log( 'Child process end' )
      return null;
    })
  }

}

startDetachingEndCompetitorIsExecuted.description =

`Parent starts child process in detached mode.
Consequence conStart recevices message when process starts.
Consequence conTerminate recevices message when process ends.
o.ended is false when conStart callback is executed.
o.ended is true when conTerminate callback is executed.
`

//

function startDetachingTerminationBegin( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testFilePath = a.abs( a.routinePath, 'testFile' );
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    a.ready.then( () =>
    {
      a.fileProvider.filesDelete( a.routinePath );
      let locals = { mode }
      a.path.nativize( a.program({ routine : testAppParent, locals }) );
      a.path.nativize( a.program( testAppChild ) );
      return null;
    })

    a.ready.tap( () => test.open( mode ) );
    a.ready.then( () => run( mode ) );
    a.ready.tap( () => test.close( mode ) );
  });

  return a.ready;

  /* - */

  function run( mode )
  {
    let ready = new _.Consequence().take( null )

    /*  */

    ready.then( () =>
    {
      test.case = `child mode:${mode} stdio:ignore ipc:0`

      a.fileProvider.filesDelete( testFilePath );
      a.fileProvider.dirMakeForFile( testFilePath );

      let o =
      {
        execPath : 'node testAppParent.js stdio : ignore outputPiping : 0 outputCollecting : 0',
        mode : 'spawn',
        outputCollecting : 1,
        currentPath : a.routinePath,
        ipc : 1,
      }
      let con = _.process.start( o );

      let data;

      o.process.on( 'message', ( e ) =>
      {
        data = e;
        data.childPid = _.numberFrom( data.childPid );
      })

      con.then( ( op ) =>
      {
        test.will = 'parent is dead, child is still alive';
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( !_.process.isAlive( op.process.pid ) );
        test.is( _.process.isAlive( data.childPid ) );
        return _.time.out( context.t2 * 2 );
      })

      con.then( () =>
      {
        test.will = 'both dead';

        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( data.childPid ) );

        test.is( a.fileProvider.fileExists( testFilePath ) );
        let childPid = a.fileProvider.fileRead( testFilePath );
        childPid = _.numberFrom( childPid );
        console.log(  childPid );
        /* if shell then could be 2 processes, first - terminal, second application */
        if( mode !== 'shell' )
        test.identical( data.childPid, childPid );

        return null;
      })

      return con;
    })

    /*  */

    ready.then( () =>
    {
      test.case = `child mode:${mode} stdio:ignore ipc:1`

      a.fileProvider.filesDelete( testFilePath );
      a.fileProvider.dirMakeForFile( testFilePath );

      let o =
      {
        execPath : `node testAppParent.js stdio : ignore ${ mode === 'shell' ? '' : 'ipc:1'} outputPiping : 0 outputCollecting : 0`,
        mode : 'spawn',
        outputCollecting : 1,
        currentPath : a.routinePath,
        ipc : 1,
      }
      let con = _.process.start( o );

      let data;

      o.process.on( 'message', ( e ) =>
      {
        data = e;
        data.childPid = _.numberFrom( data.childPid );
      })

      con.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.will = 'parent is dead, child is still alive';
        test.is( !_.process.isAlive( op.process.pid ) );
        test.is( _.process.isAlive( data.childPid ) );
        return _.time.out( context.t2 * 2 );
      })

      con.then( () =>
      {
        test.will = 'both dead';

        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( data.childPid ) );

        test.is( a.fileProvider.fileExists( testFilePath ) );
        let childPid = a.fileProvider.fileRead( testFilePath );
        childPid = _.numberFrom( childPid );
        /* if shell then could be 2 processes, first - terminal, second application */
        if( mode !== 'shell' )
        test.identical( data.childPid, childPid );

        return null;
      })

      return con;
    })

    /*  */

    ready.then( () =>
    {
      test.case = `child mode:${mode} stdio:pipe ipc:0`
      a.fileProvider.filesDelete( testFilePath );
      a.fileProvider.dirMakeForFile( testFilePath );

      let o =
      {
        execPath : 'node testAppParent.js stdio : pipe',
        mode : 'spawn',
        outputCollecting : 1,
        currentPath : a.routinePath,
        ipc : 1,
      }
      let con = _.process.start( o );

      let data;

      o.process.on( 'message', ( e ) =>
      {
        data = e;
        data.childPid = _.numberFrom( data.childPid );
      })

      con.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.will = 'parent is dead, child is still alive';
        test.is( !_.process.isAlive( op.process.pid ) );
        test.is( _.process.isAlive( data.childPid ) );
        return _.time.out( context.t2 * 2 );
      })

      con.then( () =>
      {
        test.will = 'both dead';

        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( data.childPid ) );

        test.is( a.fileProvider.fileExists( testFilePath ) );
        let childPid = a.fileProvider.fileRead( testFilePath );
        childPid = _.numberFrom( childPid );
        /* if shell then could be 2 processes, first - terminal, second application */
        if( mode !== 'shell' )
        test.identical( data.childPid, childPid )

        return null;
      })

      return con;
    })

    /*  */

    ready.then( () =>
    {
      test.case = `child mode:${mode} stdio:pipe ipc:1`

      a.fileProvider.filesDelete( testFilePath );
      a.fileProvider.dirMakeForFile( testFilePath );

      let o =
      {
        execPath : `node testAppParent.js stdio : pipe ${ mode === 'shell' ? '' : 'ipc:1'}`,
        mode : 'spawn',
        outputCollecting : 1,
        currentPath : a.routinePath,
        ipc : 1,
      }
      let con = _.process.start( o );

      let data;

      o.process.on( 'message', ( e ) =>
      {
        data = e;
        data.childPid = _.numberFrom( data.childPid );
      })

      con.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.will = 'parent is dead, child is still alive';
        test.is( !_.process.isAlive( op.process.pid ) );
        test.is( _.process.isAlive( data.childPid ) );
        return _.time.out( context.t2 * 2 );
      })

      con.then( () =>
      {
        test.will = 'both dead';

        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( data.childPid ) );

        test.is( a.fileProvider.fileExists( testFilePath ) );
        let childPid = a.fileProvider.fileRead( testFilePath );
        childPid = _.numberFrom( childPid );
        /* if shell then could be 2 processes, first - terminal, second application */
        if( mode !== 'shell' )
        test.identical( data.childPid, childPid )

        return null;
      })

      return con;
    })

    return ready;
  }

  /*  */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.input();

    let o =
    {
      execPath : mode === 'fork' ? 'testAppChild.js' : 'node testAppChild.js',
      mode,
      detaching : true,
    }

    _.mapExtend( o, args.map );
    if( o.ipc !== undefined )
    o.ipc = _.boolFrom( o.ipc );

    _.process.start( o );

    console.log( o.process.pid )

    process.send({ childPid : o.process.pid });

    o.conStart.thenGive( () =>
    {
      _.procedure.terminationBegin();
    })
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    console.log( 'Child process start', process.pid )
    _.time.out( context.t1 * 2, () => /* 2000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

startDetachingTerminationBegin.timeOut = 180000;
startDetachingTerminationBegin.description =
`
Checks that detached child process continues to work after parent death.
Parent spawns child in detached mode with different stdio and ipc.
Child continues to work after parent death.
`
//

/* qqq for Yevhen : implement for other modes */
function startDetachingThrowing( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppChildPath = a.program( testAppChild );

  /* */

  test.is( true );

  if( !Config.debug )
  return;

  var o =
  {
    execPath : 'node testAppChild.js',
    mode : 'spawn',
    stdio : 'inherit',
    currentPath : a.routinePath,
    detaching : 1
  }
  test.shouldThrowErrorSync( () => _.process.start( o ) )

  /* */

  var o =
  {
    execPath : 'node testAppChild.js',
    mode : 'shell',
    stdio : 'inherit',
    currentPath : a.routinePath,
    detaching : 1
  }
  test.shouldThrowErrorSync( () => _.process.start( o ) )

  /* */

  var o =
  {
    execPath : 'testAppChild.js',
    mode : 'fork',
    stdio : 'inherit',
    currentPath : a.routinePath,
    detaching : 1
  }
  test.shouldThrowErrorSync( () => _.process.start( o ) )

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    console.log( 'Child process start' )

    _.time.out( context.t2, () => /* 5000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

//

function startNjsDetachingChildThrowing( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let track = [];
  let testAppChildPath = a.program( testAppChild );

  /* */

  test.case = 'detached child throws error, conTerminate receives resource with error';

  let o =
  {
    execPath : 'testAppChild.js',
    outputCollecting : 1,
    stdio : 'pipe',
    detaching : 1,
    applyingExitCode : 0,
    throwingExitCode : 0,
    outputPiping : 0,
    currentPath : a.routinePath,
  }

  _.process.startNjs( o );

  o.conTerminate.then( ( op ) =>
  {
    track.push( 'conTerminate' );
    test.notIdentical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.is( _.strHas( op.output, 'Child process error' ) );
    test.identical( o.exitCode, op.exitCode );
    test.identical( o.output, op.output );
    test.identical( track, [ 'conTerminate' ] )
    return null;
  })

  return o.conTerminate;

  /* - */

  function testAppChild()
  {
    setTimeout( () =>
    {
      throw new Error( 'Child process error' );
    }, context.t1 ); /* 1000 */
  }

}

// --
// on
// --

function startOnStart( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppChildPath = a.path.nativize( a.program( testAppChild ) );
  let track = [];

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    a.ready.tap( () => test.open( mode ) );
    a.ready.then( () => run( mode ) );
    a.ready.tap( () => test.close( mode ) );
  });

  return a.ready;

  /* */

  function run( mode )
  {
    let fork = mode === 'fork';
    let ready = new _.Consequence().take( null )

    /* */

    .then( () =>
    {
      test.case = 'detaching off, no errors'
      let o =
      {
        execPath : !fork ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 0
      }

      let result = _.process.start( o );

      test.notIdentical( o.conStart, result );
      test.is( _.consequenceIs( o.conStart ) )

      o.conStart.finally( ( err, op ) =>
      {
        test.identical( err, undefined );
        test.identical( op, o );
        test.is( _.process.isAlive( o.process.pid ) );
        return null;
      })

      result.then( ( op ) =>
      {
        test.identical( o, op );
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return _.Consequence.AndTake( o.conStart, result );
    })

    /* */

    .then( () =>
    {
      test.case = 'detaching off, error on spawn'
      let o =
      {
        execPath : 'unknownScript.js',
        mode,
        stdio : [ null, 'something', null ],
        currentPath : a.routinePath,
        detaching : 0
      }

      let result = _.process.start( o );

      test.notIdentical( o.conStart, result );
      test.is( _.consequenceIs( o.conStart ) )

      return test.shouldThrowErrorAsync( o.conTerminate );
    })

    /* */

    .then( () =>
    {
      test.case = 'detaching off, error on spawn, no callback for conStart'
      let o =
      {
        execPath : 'unknownScript.js',
        mode,
        stdio : [ null, 'something', null ],
        currentPath : a.routinePath,
        detaching : 0
      }

      let result = _.process.start( o );

      test.notIdentical( o.conStart, result );
      test.is( _.consequenceIs( o.conStart ) )

      return test.shouldThrowErrorAsync( o.conTerminate );
    })

    /* */

    .then( () =>
    {
      test.case = 'detaching on, conStart and result are same and give resource on start'
      let o =
      {
        execPath : !fork ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 1
      }

      let result = _.process.start( o );

      test.is( o.conStart !== result );
      test.is( _.consequenceIs( o.conStart ) )

      o.conStart.then( ( op ) =>
      {
        test.identical( o, op );
        test.identical( op.exitCode, null );
        test.identical( op.ended, false );
        test.identical( op.exitSignal, null );
        return null;
      })

      return _.Consequence.AndTake( o.conStart, o.conTerminate );
    })

    /* */

    .then( () =>
    {
      test.case = 'detaching on, error on spawn'
      let o =
      {
        execPath : 'unknownScript.js',
        mode,
        stdio : [ 'ignore', 'ignore', 'ignore', null ],
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 1
      }

      let result = _.process.start( o );

      test.is( o.conStart !== result );
      test.is( _.consequenceIs( o.conStart ) )

      result = test.shouldThrowErrorAsync( o.conTerminate );

      result.then( () => _.time.out( context.t1 * 2 ) ) /* 2000 */
      result.then( () =>
      {
        test.identical( o.conTerminate.resourcesCount(), 0 );
        return null;
      })

      return result;
    })

    /* */

    .then( () =>
    {
      test.case = 'detaching on, disconnected child';
      track = [];
      let o =
      {
        execPath : !fork ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 1
      }

      let result = _.process.start( o );

      test.is( o.conStart !== result );

      o.conStart.finally( ( err, op ) =>
      {
        track.push( 'conStart' );
        test.identical( err, undefined );
        test.identical( op, o );
        test.is( _.process.isAlive( o.process.pid ) )
        test.identical( o.state, 'started' );
        o.disconnect();
        return null;
      })

      o.conDisconnect.finally( ( err, op ) =>
      {
        track.push( 'conDisconnect' );
        test.identical( err, undefined );
        test.identical( op, o );
        test.identical( o.state, 'disconnected' );
        test.is( _.process.isAlive( o.process.pid ) );
        return null;
      })

      o.conTerminate.finally( ( err, op ) =>
      {
        track.push( 'conTerminate' );
        test.identical( err, _.dont );
        return null;
      })

      let ready = _.time.out( context.t2, () => /* 5000 */
      {
        test.identical( track, [ 'conStart', 'conDisconnect', 'conTerminate' ] );
      })

      return _.Consequence.AndTake( o.conStart, o.conDisconnect, ready );
    })

    /* */

    .then( () =>
    {
      test.case = 'detaching on, disconnected forked child'
      let o =
      {
        execPath : !fork ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 1
      }

      let result = _.process.start( o );

      test.is( o.conStart !== result );

      o.conStart.finally( ( err, op ) =>
      {
        test.identical( err, undefined );
        test.identical( op, o );
        test.identical( o.state, 'started' )
        test.is( _.process.isAlive( o.process.pid ) )
        o.disconnect();
        return null;
      })

      o.conDisconnect.finally( ( err, op ) =>
      {
        test.identical( err, undefined );
        test.identical( op, o );
        test.identical( o.state, 'disconnected' )
        test.is( _.process.isAlive( o.process.pid ) )
        return null;
      })

      result = _.time.out( context.t1 * 7, () => /* 2000 + context.t2 */
      {
        test.is( !_.process.isAlive( o.process.pid ) )
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.conTerminate.resourcesCount(), 1 );
        return null;
      })

      return _.Consequence.AndTake( o.conStart, o.conDisconnect, result );
    })

    /* */

    return ready;
  }


  /* */

  function testAppChild()
  {
    console.log( 'Child process begin' );

    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.input();

    _.time.out( context.t1 * 2, () => /* 2000 */
    {
      console.log( 'Child process end' );
      return null;
    })
  }

}

startOnStart.timeOut = 120000;

//

function startOnTerminate( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppChildPath = a.path.nativize( a.program( testAppChild ) );
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    a.ready.tap( () => test.open( mode ) );
    a.ready.then( () => run( mode ) );
    a.ready.tap( () => test.close( mode ) );
  });

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null )

    .then( () =>
    {
      test.case = 'detaching off'
      let o =
      {
        execPath : mode !== 'fork' ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 0
      }

      let result = _.process.start( o );

      test.is( o.conTerminate !== result );

      result.then( ( op ) =>
      {
        test.identical( o, op );
        test.identical( op.state, 'terminated' );
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
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
        execPath : mode !== 'fork' ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        detaching : 0
      }
      let track = [];

      let result = _.process.start( o );

      o.disconnect();

      test.is( o.conTerminate !== result );

      o.conTerminate.then( ( op ) =>
      {
        track.push( 'conTerminate' );
        test.identical( o, op );
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return _.time.out( context.t1 * 7, () => /* 2000 + context.t2 */
      {
        test.identical( o.state, 'disconnected' );
        test.identical( o.ended, true );
        test.identical( track, [] );
        test.identical( o.conTerminate.argumentsCount(), 0 );
        test.identical( o.conTerminate.errorsCount(), 1 );
        test.identical( o.conTerminate.competitorsCount(), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        return null;
      });
    })

    /* */

    .then( () =>
    {
      test.case = 'detaching, child not disconnected, parent waits for child to exit'
      let conTerminate = new _.Consequence();
      let o =
      {
        execPath : mode !== 'fork' ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        conTerminate,
        detaching : 1
      }

      let result = _.process.start( o );

      test.is( result !== o.conStart );
      test.notIdentical( conTerminate, result );
      test.identical( conTerminate, o.conTerminate );

      conTerminate.then( ( op ) =>
      {
        test.identical( o, op );
        test.identical( op.state, 'terminated' );
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = 'detached, child disconnected before it termination'
      let conTerminate = new _.Consequence();
      let o =
      {
        execPath : mode !== 'fork' ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'pipe',
        currentPath : a.routinePath,
        conTerminate,
        detaching : 1
      }
      let track = [];

      let result = _.process.start( o );
      test.is( result !== o.conStart );
      test.is( result !== o.conTerminate );
      test.identical( conTerminate, o.conTerminate );

      _.time.out( context.t1, () => o.disconnect() );

      conTerminate.then( ( op ) =>
      {
        track.push( 'conTerminate' );
        test.identical( o, op );
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return _.time.out( context.t1 * 7, () =>  /* 2000 + context.t2 */ /* 3000 is not enough */
      {
        test.identical( track, [] );
        test.identical( o.state, 'disconnected' );
        test.identical( o.ended, true );
        test.identical( o.conTerminate.argumentsCount(), 0 );
        test.identical( o.conTerminate.errorsCount(), 1 );
        test.identical( o.conTerminate.competitorsCount(), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        return null;
      });

    })

    /* */

    .then( () =>
    {
      test.case = 'detached, child disconnected after it termination'
      let conTerminate = new _.Consequence();
      let o =
      {
        execPath : mode !== 'fork' ? 'node testAppChild.js' : 'testAppChild.js',
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        conTerminate,
        detaching : 1
      }

      let result = _.process.start( o );

      test.is( result !== o.conStart );
      test.is( result !== o.conTerminate )
      test.identical( conTerminate, o.conTerminate )

      conTerminate.then( ( op ) =>
      {
        test.identical( op.state, 'terminated' );
        test.identical( op.ended, true );
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        op.disconnect();
        return op;
      })

      return test.mustNotThrowError( conTerminate )
      .then( ( op ) =>
      {
        test.identical( o, op );
        test.identical( op.state, 'terminated' );
        test.identical( op.ended, true );
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        return null;
      })
    })

    /* */

    .then( () =>
    {
      test.case = 'detached, not disconnected child throws error during execution'
      let conTerminate = new _.Consequence();
      let o =
      {
        execPath : mode !== 'fork' ? 'node testAppChild.js' : 'testAppChild.js',
        args : [ 'throwing:1' ],
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        conTerminate,
        throwingExitCode : 0,
        detaching : 1
      }

      let result = _.process.start( o );

      test.is( result !== o.conStart );
      test.is( result !== o.conTerminate );
      test.identical( conTerminate, o.conTerminate );

      conTerminate.then( ( op ) =>
      {
        test.identical( o, op );
        test.identical( op.state, 'terminated' );
        test.identical( op.ended, true );
        test.identical( op.error, null );
        test.notIdentical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        return null;
      })

      return conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = 'detached, disconnected child throws error during execution'
      let conTerminate = new _.Consequence();
      let o =
      {
        execPath : mode !== 'fork' ? 'node testAppChild.js' : 'testAppChild.js',
        args : [ 'throwing:1' ],
        mode,
        stdio : 'ignore',
        outputPiping : 0,
        outputCollecting : 0,
        currentPath : a.routinePath,
        conTerminate,
        throwingExitCode : 0,
        detaching : 1
      }
      let track = [];

      let result = _.process.start( o );

      test.is( result !== o.conStart );
      test.is( result !== o.conTerminate );
      test.identical( conTerminate, o.conTerminate );

      o.disconnect();

      conTerminate.then( () =>
      {
        track.push( 'conTerminate' );
        return null;
      })

      return _.time.out( context.t1 * 7, () =>  /* 2000 + context.t2 */ /* 3000 is not enough */
      {
        test.identical( track, [] );
        test.identical( o.state, 'disconnected' );
        test.identical( o.ended, true );
        test.identical( o.error, null );
        test.identical( o.exitCode, null );
        test.identical( o.exitSignal, null );
        test.identical( o.conTerminate.argumentsCount(), 0 );
        test.identical( o.conTerminate.errorsCount(), 1 );
        test.identical( o.conTerminate.competitorsCount(), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        return null;
      });
    })

    /* */

    return ready;
  }

  /* - */

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var args = _.process.input();

    _.time.out( context.t1 * 2, () => /* 2000 */
    {
      if( args.map.throwing )
      throw _.err( 'Child process error' );
      console.log( 'Child process end' )
      return null;
    })
  }
}

startOnTerminate.timeOut = 3e5;

//

function startNoEndBug1( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppChildPath = a.program( testAppChild );

  a.ready

  /* */

  .then( () =>
  {
    test.case = 'detaching on, error on spawn'
    let o =
    {
      execPath : 'testAppChild.js',
      mode : 'fork',
      stdio : [ 'ignore', 'ignore', 'ignore', null ],
      currentPath : a.routinePath,
      detaching : 1
    }

    let result = _.process.start( o );

    test.is( o.conStart !== result );
    test.is( _.consequenceIs( o.conStart ) )

    result = test.shouldThrowErrorAsync( o.conTerminate );

    result.then( () => _.time.out( context.t1 * 2 ) ) /* 2000 */
    result.then( () =>
    {
      test.identical( o.conTerminate.resourcesCount(), 0 );
      return null;
    })

    return result;
  })

  /* */

  return a.ready;

  /* */

  function testAppChild()
  {
    _.include( 'wProcess' );
    var args = _.process.input();
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
conStart receives error message.
Parent should not try to disconnect the child.
`

//

function startWithDelayOnReady( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let time1 = _.time.now();

  a.ready.delay( 1000 );

  /* */

  let options =
  {
    execPath : 'node',
    args : programPath,
    currentPath : a.abs( '.' ),
    throwingExitCode : 1,
    applyingExitCode : 0,
    inputMirroring : 1,
    outputCollecting : 1,
    stdio : 'pipe',
    sync : 0,
    deasync : 0,
    ready : a.ready,
  }

  _.process.start( options );

  test.is( _.consequenceIs( options.conStart ) );
  test.is( _.consequenceIs( options.conDisconnect ) );
  test.is( _.consequenceIs( options.conTerminate ) );
  test.is( _.consequenceIs( options.ready ) );
  test.is( options.conStart !== options.ready );
  test.is( options.conDisconnect !== options.ready );
  test.is( options.conTerminate !== options.ready );

  options.conStart
  .then( ( op ) =>
  {
    test.is( options === op );
    test.identical( options.output, '' );
    test.identical( options.exitCode, null );
    test.identical( options.exitSignal, null );
    test.identical( options.process.exitCode, null );
    test.identical( options.process.signalCode, null );
    test.identical( options.ended, false );
    test.identical( options.exitReason, null );
    test.is( !!options.process );
    return null;
  });

  options.conTerminate
  .finally( ( err, op ) =>
  {
    test.identical( err, undefined );
    debugger;
    test.identical( op.output, 'program1:begin\nprogram1:end\n' );
    test.identical( op.exitCode, 0 );
    test.identical( op.exitSignal, null );
    test.identical( op.ended, true );
    test.identical( op.exitReason, 'normal' );
    return null;
  });

  /* */

  return a.ready;

  /* */

  function program1()
  {
    let _ = require( toolsPath );
    console.log( 'program1:begin' );
    setTimeout( () => { console.log( 'program1:end' ) }, context.t3 ); /* 15000 */
  }

}

startWithDelayOnReady.description =
`
  - consequence conStart has delay
`

//

function startOnIsNotConsequence( test )
{
  let context = this;
  let track;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  // let modes = [ 'spawn' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 1, mode ) ) );
  return a.ready;

  /* - */

  function run( sync, deasync, mode )
  {
    let con = _.Consequence().take( null );

    if( sync && !deasync && mode === 'fork' )
    return null;

    /* */

    con.then( () =>
    {
      test.case = `normal sync:${sync} deasync:${deasync} mode:${mode}`
      track = [];
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        mode,
        sync,
        deasync,
        conStart,
        conDisconnect,
        conTerminate,
        ready,
      }
      var returned = _.process.start( o );
      o.ready.finally( function( err, op )
      {
        track.push( 'returned' );
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        return op;
      })

      return _.time.out( context.t2, () =>
      {
        test.identical( track, [ 'conStart', 'conTerminate', 'conDisconnect', 'ready', 'returned' ] );
      });
    })

    /* */

    con.then( () =>
    {
      test.case = `throwing sync:${sync} deasync:${deasync} mode:${mode}`
      track = [];
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        args : [ 'throwing' ],
        mode,
        conStart,
        conDisconnect,
        conTerminate,
        ready,
      }
      var returned = _.process.start( o );
      o.ready.finally( function( err, op )
      {
        track.push( 'returned' );
        test.is( _.errIs( err ) );
        test.identical( op, undefined );
        test.notIdentical( o.exitCode, 0 );
        test.identical( o.ended, true );
        _.errAttend( err );
        return null;
      })
      return _.time.out( context.t2, () =>
      {
        test.identical( track, [ 'conStart', 'conTerminate', 'conDisconnect', 'ready', 'returned' ] );
      });
    })

    /* */

    con.then( () =>
    {
      test.case = `detaching sync:${sync} deasync:${deasync} mode:${mode}`
      track = [];
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        detaching : 1,
        mode,
        conStart,
        conDisconnect,
        conTerminate,
        ready,
      }
      var returned = _.process.start( o );
      o.ready.finally( function( err, op )
      {
        track.push( 'returned' );
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        return op;
      })

      return _.time.out( context.t2, () =>
      {
        test.identical( track, [ 'conStart', 'conTerminate', 'conDisconnect', 'ready', 'returned' ] );
      });
    })

    /* */

    con.then( () =>
    {
      test.case = `disconnecting sync:${sync} deasync:${deasync} mode:${mode}`
      track = [];
      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        detaching : 1,
        mode,
        conStart,
        conDisconnect,
        conTerminate,
        ready,
      }
      var returned = _.process.start( o );
      o.disconnect();
      o.ready.finally( function( err, op )
      {
        track.push( 'returned' );
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        return op;
      })

      return _.time.out( context.t2, () =>
      {
        test.identical( track, [ 'conStart', 'conDisconnect', 'conTerminate', 'ready', 'returned' ] );
      });
    })

    /* */

    return con
  }

  function program1()
  {
    console.log( process.argv.slice( 2 ) );
    if( process.argv.slice( 2 ).join( ' ' ).includes( 'throwing' ) )
    throw 'Error1!'
  }

  function ready( err, arg )
  {
    track.push( 'ready' );
    if( err )
    throw err;
    return arg;
  }

  function conStart( err, arg )
  {
    track.push( 'conStart' );
    if( err )
    throw err;
    return arg;
  }

  function conTerminate( err, arg )
  {
    track.push( 'conTerminate' );
    if( err )
    throw err;
    return arg;
  }

  function conDisconnect( err, arg )
  {
    track.push( 'conDisconnect' );
    if( err )
    throw err;
    return arg;
  }

}

startOnIsNotConsequence.timeOut = 5e5;

//

function startConcurrentMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( program1 ) );
  let counter = 0;
  let time = 0;
  let filePath = a.path.nativize( a.abs( a.routinePath, 'file.txt' ) );

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single';
    time = _.time.now();
    return null;
  })

  let singleOption =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : a.ready,
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
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single, execPath in array';
    time = _.time.now();
    return null;
  })

  let singleExecPathInArrayOptions =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleExecPathInArrayOptions )
  .then( ( op ) =>
  {

    test.identical( op.runs.length, 1 );
    test.identical( op.runs[ 0 ].exitCode, 0 );
    test.is( singleExecPathInArrayOptions !== op.runs[ 0 ] );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'end 1000' ) );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready';
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBeforeScalar =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleErrorBeforeScalar )
  .finally( ( err, arg ) =>
  {
    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBeforeScalar.exitCode, null );
    test.identical( singleErrorBeforeScalar.output, '' );
    test.is( !a.fileProvider.fileExists( filePath ) );
    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready';
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBefore =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  _.process.start( singleErrorBefore )
  .finally( ( err, arg ) =>
  {

    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBefore.exitCode, null );
    test.identical( singleErrorBefore.output, '' );
    test.is( !a.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial';
    time = _.time.now();
    return null;
  })

  let subprocessesOptionsSerial =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  _.process.start( subprocessesOptionsSerial )
  .then( ( op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesOptionsSerial.exitCode, 0 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'end 1000' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 1' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 1' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 1';
    time = _.time.now();
    return null;
  })

  let subprocessesError =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  _.process.start( subprocessesError )
  .finally( ( err, op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesError.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( op === undefined );
    test.is( !a.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 0';
    time = _.time.now();
    return null;
  })

  let subprocessesErrorNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
    throwingExitCode : 0,
  }

  _.process.start( subprocessesErrorNonThrowing )
  .finally( ( err, op ) =>
  {
    test.is( !err );

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorNonThrowing.exitCode, 1 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 1 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( op.runs[ 0 ].output, 'end x' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'Expects number' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 1' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 1' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 1';
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrent =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( subprocessesErrorConcurrent )
  .finally( ( err, op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrent.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( op === undefined );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 0';
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrentNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
    throwingExitCode : 0,
  }

  _.process.start( subprocessesErrorConcurrentNonThrowing )
  .finally( ( err, op ) =>
  {
    test.is( !err );

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrentNonThrowing.exitCode, 1 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 1 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( op.runs[ 0 ].output, 'end x' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'Expects number' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 1' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 1' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1';
    time = _.time.now();
    return null;
  })

  let suprocessesConcurrentOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( suprocessesConcurrentOptions )
  .then( ( op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( suprocessesConcurrentOptions.exitCode, 0 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'end 1000' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 100' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 100' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'args';
    time = _.time.now();
    return null;
  })

  let suprocessesConcurrentArgumentsOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    args : [ 'second', 'argument' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  _.process.start( suprocessesConcurrentArgumentsOptions )
  .then( ( op ) =>
  {
    var spent = _.time.now() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( suprocessesConcurrentArgumentsOptions.exitCode, 0 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin 1000, second, argument' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'end 1000, second, argument' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 100, second, argument' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 100, second, argument' ) );

    counter += 1;
    return null;
  });

  /* - */

  return a.ready.finally( ( err, arg ) =>
  {
    test.identical( counter, 11 );
    if( err )
    throw err;
    return arg;
  });

  function program1()
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

    setTimeout( periodic, context.t0 / 2 ); /* 50 */
    function periodic()
    {
      console.log( 'tick', process.argv.slice( 2 ).join( ', ' ) );
      if( !ended )
      setTimeout( periodic, context.t0 / 2 ); /* 50 */
    }
  }

}

startConcurrentMultiple.timeOut = 100000;

//

function startConcurrentConsequencesMultiple( test )
{
  let context = this;
  let track;
  let track2;
  let a = context.assetFor( test, false );
  let programPath = a.program( program1 );
  let t0 = _.time.now();
  let o3 =
  {
    outputPiping : 1,
    outputCollecting : 1,
  }

  // let consequences = [ 'null' ];
  // let modes = [ 'spawn' ];

  let consequences = [ 'null', 'consequence', 'routine' ];
  let modes = [ 'fork', 'spawn', 'shell' ];
  consequences.forEach( ( consequence ) =>
  {
    a.ready.tap( () => test.open( `consequence:${consequence}` ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 0, deasync : 0, consequence, mode }) ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 0, deasync : 1, consequence, mode }) ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 1, deasync : 0, consequence, mode }) ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 1, deasync : 1, consequence, mode }) ) );
    a.ready.tap( () => test.close( `consequence:${consequence}` ) );
  });
  return a.ready;

  /* - */

  function run( tops )
  {
    let ready = _.Consequence().take( null );
    if( tops.mode === 'fork' && tops.sync && !tops.deasync )
    return null;

    /* */

    ready.then( function( arg )
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} mode:${tops.mode} concurrent:0 arg arg`;

      clear();
      var time1 = _.time.now();
      var execPath = tops.mode === `fork` ? `${programPath}` : `node ${programPath}`;
      var o2 =
      {
        execPath : [ execPath, execPath ],
        args : ( op ) => [ `id:${op.procedure.id}` ],
        conStart : conMake( tops, 'conStart' ),
        conDisconnect : conMake( tops, 'conDisconnect' ),
        conTerminate : conMake( tops, 'conTerminate' ),
        ready : conMake( tops, 'ready' ),
        concurrent : 0,
        sync : tops.sync,
        deasync : tops.deasync,
        mode : tops.mode,
      }

      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );

      processTrack( options );

      options.conStart.tap( ( err, op ) =>
      {
        op.runs.forEach( ( op2 ) =>
        {
          processTrack( op2 );
        });
      });

      options.ready.tap( function( err, op )
      {
        var exp =
`
${options.runs[ 0 ].procedure.id}.begin
${options.runs[ 0 ].procedure.id}.end
${options.runs[ 1 ].procedure.id}.begin
${options.runs[ 1 ].procedure.id}.end
`
        test.equivalent( options.output, exp );
        var exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.ready`,
          `${options.runs[ 1 ].procedure.id}.conTerminate`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.ready`,
          `${options.procedure.id}.conTerminate`,
          `${options.procedure.id}.ready`,
        ]
        if( options.deasync || options.sync )
        exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.procedure.id}.conTerminate`,
          `${options.procedure.id}.ready`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 0 ].procedure.id}.ready`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 1 ].procedure.id}.conTerminate`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.ready`,
        ]
        test.identical( track, exp );

        var exp =
        [
          'conStart.arg',
          'conTerminate.arg',
          'ready.arg',
        ]
        if( tops.consequence === 'routine' )
        test.identical( track2, exp );

        test.identical( options.exitCode, 0 );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'normal' );
        test.identical( options.exitSignal, null );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );

        test.identical( options.runs[ 0 ].exitCode, 0 );
        test.identical( options.runs[ 0 ].ended, true );
        test.identical( options.runs[ 0 ].exitReason, 'normal' );
        test.identical( options.runs[ 0 ].exitSignal, null );
        test.identical( options.runs[ 0 ].state, 'terminated' );
        test.identical( options.error, null );

        test.identical( options.runs[ 1 ].exitCode, 0 );
        test.identical( options.runs[ 1 ].ended, true );
        test.identical( options.runs[ 1 ].exitReason, 'normal' );
        test.identical( options.runs[ 1 ].exitSignal, null );
        test.identical( options.runs[ 1 ].state, 'terminated' );
        test.identical( options.error, null );

      })

      return options.ready;
    })

    /* */

    ready.then( function( arg )
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} mode:${tops.mode} concurrent:0 throwingExitCode:1 err arg`;

      clear();
      var time1 = _.time.now();
      var counter = 0;
      var execPath = tops.mode === `fork` ? `${programPath}` : `node ${programPath}`;
      var o2 =
      {
        execPath : [ execPath, execPath ],
        args : ( op ) => [ `id:${op.procedure.id} throwing:${++counter === 1 ? 1 : 0}` ],
        conStart : conMake( tops, 'conStart' ),
        conDisconnect : conMake( tops, 'conDisconnect' ),
        conTerminate : conMake( tops, 'conTerminate' ),
        ready : conMake( tops, 'ready' ),
        concurrent : 0,
        throwingExitCode : 1,
        sync : tops.sync,
        deasync : tops.deasync,
        mode : tops.mode,
      }

      var options = _.mapSupplement( null, o2, o3 );
      var returned = null;

      if( tops.sync )
      test.shouldThrowErrorSync( () => _.process.start( options ) );
      else
      returned = _.process.start( options );

      processTrack( options );

      options.conStart.tap( ( err, op ) =>
      {
        op.runs.forEach( ( op2 ) =>
        {
          processTrack( op2 );
        });
      });

      options.ready.finally( function( err, op )
      {
        test.identical( _.strCount( options.output, 'Error1' ), 1 );
        var exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 1 ].procedure.id}.conStart.err`,
          `${options.runs[ 1 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 1 ].procedure.id}.ready.err`,
          `${options.runs[ 0 ].procedure.id}.ready.err`,
          `${options.procedure.id}.conTerminate.err`,
          `${options.procedure.id}.ready.err`,
        ]
        if( options.deasync || options.sync )
        exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.procedure.id}.conTerminate.err`,
          `${options.procedure.id}.ready.err`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 0 ].procedure.id}.ready.err`,
          `${options.runs[ 1 ].procedure.id}.conStart.err`,
          `${options.runs[ 1 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 1 ].procedure.id}.ready.err`,
        ]

        test.identical( track, exp );

        var exp =
        [
          'conStart.arg',
          'conTerminate.err',
          'ready.err',
        ]
        if( tops.consequence === 'routine' )
        test.identical( track2, exp );

        test.is( _.errIs( err ) );
        test.notIdentical( options.exitCode, 0 );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'code' );
        test.identical( options.exitSignal, null );
        test.identical( options.state, 'terminated' );
        test.is( !!options.error );
        test.identical( _.strCount( options.error.message, 'Error1' ), 1 );

        test.notIdentical( options.runs[ 0 ].exitCode, 0 );
        test.identical( options.runs[ 0 ].ended, true );
        test.identical( options.runs[ 0 ].exitReason, 'code' );
        test.identical( options.runs[ 0 ].exitSignal, null );
        test.identical( options.runs[ 0 ].state, 'terminated' );
        test.is( !!options.runs[ 0 ].error );

        test.notIdentical( options.runs[ 1 ].exitCode, 0 );
        test.identical( options.runs[ 1 ].ended, true );
        test.identical( options.runs[ 1 ].exitReason, 'error' );
        test.identical( options.runs[ 1 ].exitSignal, null );
        test.identical( options.runs[ 1 ].state, 'initial' );
        test.is( !!options.runs[ 1 ].error );

        return null;
      })

      return options.ready;
    })

    /* */

    ready.then( function( arg )
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} mode:${tops.mode} concurrent:0 throwingExitCode:1 arg err`;

      clear();
      var time1 = _.time.now();
      var counter = 0;
      var execPath = tops.mode === `fork` ? `${programPath}` : `node ${programPath}`;
      var o2 =
      {
        execPath : [ execPath, execPath ],
        args : ( op ) => [ `id:${op.procedure.id} throwing:${++counter === 1 ? 0 : 1}` ],
        conStart : conMake( tops, 'conStart' ),
        conDisconnect : conMake( tops, 'conDisconnect' ),
        conTerminate : conMake( tops, 'conTerminate' ),
        ready : conMake( tops, 'ready' ),
        concurrent : 0,
        sync : tops.sync,
        deasync : tops.deasync,
        mode : tops.mode,
      }

      var options = _.mapSupplement( null, o2, o3 );
      var returned = null;

      if( tops.sync )
      test.shouldThrowErrorSync( () => _.process.start( options ) );
      else
      returned = _.process.start( options );

      processTrack( options );

      options.conStart.tap( ( err, op ) =>
      {
        op.runs.forEach( ( op2 ) =>
        {
          processTrack( op2 );
        });
      });

      options.ready.finally( function( err, op )
      {

        test.identical( _.strCount( options.output, 'Error1' ), 1 );
        var exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.ready`,
          `${options.runs[ 1 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 1 ].procedure.id}.ready.err`,
          `${options.procedure.id}.conTerminate.err`,
          `${options.procedure.id}.ready.err`,
        ]
        if( options.deasync || options.sync )
        exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.procedure.id}.conTerminate.err`,
          `${options.procedure.id}.ready.err`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 0 ].procedure.id}.ready`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 1 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 1 ].procedure.id}.ready.err`,
        ]
        test.identical( track, exp );

        var exp =
        [
          'conStart.arg',
          'conTerminate.err',
          'ready.err',
        ]
        if( tops.consequence === 'routine' )
        test.identical( track2, exp );

        test.is( _.errIs( err ) );
        test.notIdentical( options.exitCode, 0 );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'code' );
        test.identical( options.exitSignal, null );
        test.identical( options.state, 'terminated' );
        test.is( !!options.error );
        test.identical( _.strCount( options.error.message, 'Error1' ), 1 );

        test.identical( options.runs[ 0 ].exitCode, 0 );
        test.identical( options.runs[ 0 ].ended, true );
        test.identical( options.runs[ 0 ].exitReason, 'normal' );
        test.identical( options.runs[ 0 ].exitSignal, null );
        test.identical( options.runs[ 0 ].state, 'terminated' );
        test.is( !options.runs[ 0 ].error );

        test.notIdentical( options.runs[ 1 ].exitCode, 0 );
        test.identical( options.runs[ 1 ].ended, true );
        test.identical( options.runs[ 1 ].exitReason, 'code' );
        test.identical( options.runs[ 1 ].exitSignal, null );
        test.identical( options.runs[ 1 ].state, 'terminated' );
        test.is( !!options.runs[ 1 ].error );

        return null;
      })

      return options.ready;
    })

    /* */

    ready.then( function( arg )
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} mode:${tops.mode} concurrent:1 arg arg`;

      if( tops.sync && !tops.deasync )
      return null;

      clear();
      var time1 = _.time.now();
      var execPath = tops.mode === `fork` ? `${programPath}` : `node ${programPath}`;
      var o2 =
      {
        execPath : [ execPath, execPath ],
        args : ( op ) => [ `id:${op.procedure.id}`, `sessionId:${op.sessionId}`, `concurrent:1` ],
        conStart : conMake( tops, 'conStart' ),
        conDisconnect : conMake( tops, 'conDisconnect' ),
        conTerminate : conMake( tops, 'conTerminate' ),
        ready : conMake( tops, 'ready' ),
        concurrent : 1,
        sync : tops.sync,
        deasync : tops.deasync,
        mode : tops.mode,
      }

      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );

      processTrack( options );

      options.conStart.tap( ( err, op ) =>
      {
        op.runs.forEach( ( op2 ) =>
        {
          processTrack( op2 );
        });
      });

      options.ready.tap( function( err, op )
      {
        var exp =
`
${options.runs[ 0 ].procedure.id}.begin
${options.runs[ 1 ].procedure.id}.begin
${options.runs[ 0 ].procedure.id}.end
${options.runs[ 1 ].procedure.id}.end
`

        test.equivalent( options.output, exp );
        var exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 0 ].procedure.id}.ready`,
          `${options.runs[ 1 ].procedure.id}.conTerminate`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.ready`,
          `${options.procedure.id}.conTerminate`,
          `${options.procedure.id}.ready`,
        ]
        if( options.deasync || options.sync )
        exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.procedure.id}.conTerminate`,
          `${options.procedure.id}.ready`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 0 ].procedure.id}.ready`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 1 ].procedure.id}.conTerminate`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.ready`,
        ]
        test.identical( track, exp );

        var exp =
        [
          'conStart.arg',
          'conTerminate.arg',
          'ready.arg',
        ]
        if( tops.consequence === 'routine' )
        test.identical( track2, exp );

        test.identical( options.exitCode, 0 );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'normal' );
        test.identical( options.exitSignal, null );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );

        test.identical( options.runs[ 0 ].exitCode, 0 );
        test.identical( options.runs[ 0 ].ended, true );
        test.identical( options.runs[ 0 ].exitReason, 'normal' );
        test.identical( options.runs[ 0 ].exitSignal, null );
        test.identical( options.runs[ 0 ].state, 'terminated' );
        test.identical( options.error, null );

        test.identical( options.runs[ 1 ].exitCode, 0 );
        test.identical( options.runs[ 1 ].ended, true );
        test.identical( options.runs[ 1 ].exitReason, 'normal' );
        test.identical( options.runs[ 1 ].exitSignal, null );
        test.identical( options.runs[ 1 ].state, 'terminated' );
        test.identical( options.error, null );

      })

      return options.ready;
    })

    /* */

    ready.then( function( arg )
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} mode:${tops.mode} concurrent:1 throwingExitCode:1 err arg`;

      if( tops.sync && !tops.deasync )
      return null;

      clear();
      var time1 = _.time.now();
      var counter = 0;
      var execPath = tops.mode === `fork` ? `${programPath}` : `node ${programPath}`;
      var o2 =
      {
        execPath : [ execPath, execPath ],
        args : ( op ) => [ `id:${op.procedure.id}`, `throwing:${++counter === 1 ? 1 : 0}`, `sessionId:${op.sessionId}`, `concurrent:1` ],
        conStart : conMake( tops, 'conStart' ),
        conDisconnect : conMake( tops, 'conDisconnect' ),
        conTerminate : conMake( tops, 'conTerminate' ),
        ready : conMake( tops, 'ready' ),
        concurrent : 1,
        throwingExitCode : 1,
        sync : tops.sync,
        deasync : tops.deasync,
        mode : tops.mode,
      }

      var options = _.mapSupplement( null, o2, o3 );
      var returned = null;

      if( tops.sync )
      test.shouldThrowErrorSync( () => _.process.start( options ) );
      else
      returned = _.process.start( options );

      processTrack( options );

      options.conStart.tap( ( err, op ) =>
      {
        op.runs.forEach( ( op2 ) =>
        {
          processTrack( op2 );
        });
      });

      options.ready.finally( function( err, op )
      {
        test.identical( _.strCount( options.output, 'Error1' ), 1 );
        var exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 0 ].procedure.id}.ready.err`,
          `${options.runs[ 1 ].procedure.id}.conTerminate`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.ready`,
          `${options.procedure.id}.conTerminate.err`,
          `${options.procedure.id}.ready.err`,
        ]
        if( options.deasync || options.sync )
        exp =
        [
          `${options.procedure.id}.conStart`,
          `${options.procedure.id}.conTerminate.err`,
          `${options.procedure.id}.ready.err`,
          `${options.runs[ 0 ].procedure.id}.conStart`,
          `${options.runs[ 0 ].procedure.id}.conTerminate.err`,
          `${options.runs[ 0 ].procedure.id}.conDisconnect.err`,
          `${options.runs[ 0 ].procedure.id}.ready.err`,
          `${options.runs[ 1 ].procedure.id}.conStart`,
          `${options.runs[ 1 ].procedure.id}.conTerminate`,
          `${options.runs[ 1 ].procedure.id}.conDisconnect.dont`,
          `${options.runs[ 1 ].procedure.id}.ready`,
        ]

        test.identical( track, exp );

        var exp =
        [
          'conStart.arg',
          'conTerminate.err',
          'ready.err',
        ]
        if( tops.consequence === 'routine' )
        test.identical( track2, exp );

        test.notIdentical( options.exitCode, 0 );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'code' );
        test.identical( options.exitSignal, null );
        test.identical( options.state, 'terminated' );
        test.is( !!options.error );
        test.identical( _.strCount( options.error.message, 'Error1' ), 1 );

        test.notIdentical( options.runs[ 0 ].exitCode, 0 );
        test.identical( options.runs[ 0 ].ended, true );
        test.identical( options.runs[ 0 ].exitReason, 'code' );
        test.identical( options.runs[ 0 ].exitSignal, null );
        test.identical( options.runs[ 0 ].state, 'terminated' );
        test.is( !!options.runs[ 0 ].error );

        test.identical( options.runs[ 1 ].exitCode, 0 );
        test.identical( options.runs[ 1 ].ended, true );
        test.identical( options.runs[ 1 ].exitReason, 'normal' );
        test.identical( options.runs[ 1 ].exitSignal, null );
        test.identical( options.runs[ 1 ].state, 'terminated' );
        test.is( !options.runs[ 1 ].error );

        return null;
      })

      return options.ready;
    })

    /* */

    ready.then( function( arg )
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} mode:${tops.mode} concurrent:1 throwingExitCode:1 arg err`;

      if( tops.sync && !tops.deasync )
      return null;

      clear();
      var time1 = _.time.now();
      var counter = 0;
      var execPath = tops.mode === `fork` ? `${programPath}` : `node ${programPath}`;
      var o2 =
      {
        execPath : [ execPath, execPath ],
        args : ( op ) => [ `id:${op.procedure.id} throwing:${++counter === 1 ? 0 : 1}` ],
        conStart : conMake( tops, 'conStart' ),
        conDisconnect : conMake( tops, 'conDisconnect' ),
        conTerminate : conMake( tops, 'conTerminate' ),
        ready : conMake( tops, 'ready' ),
        concurrent : 1,
        sync : tops.sync,
        deasync : tops.deasync,
        mode : tops.mode,
      }

      var options = _.mapSupplement( null, o2, o3 );
      var returned = null;

      if( tops.sync )
      test.shouldThrowErrorSync( () => _.process.start( options ) );
      else
      returned = _.process.start( options );

      processTrack( options );

      options.conStart.tap( ( err, op ) =>
      {
        op.runs.forEach( ( op2 ) =>
        {
          processTrack( op2 );
        });
      });

      options.ready.finally( function( err, op )
      {

        test.identical( _.strCount( options.output, 'Error1' ), 1 );

        if( options.deasync || options.sync )
        {
          var exp =
          [
            `${options.procedure.id}.conStart`,
            `${options.procedure.id}.conTerminate.err`,
            `${options.procedure.id}.ready.err`,
            `${options.runs[ 0 ].procedure.id}.conStart`,
            `${options.runs[ 0 ].procedure.id}.conTerminate`,
            `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
            `${options.runs[ 0 ].procedure.id}.ready`,
            `${options.runs[ 1 ].procedure.id}.conStart`,
            `${options.runs[ 1 ].procedure.id}.conTerminate.err`,
            `${options.runs[ 1 ].procedure.id}.conDisconnect.err`,
            `${options.runs[ 1 ].procedure.id}.ready.err`,
          ]
          test.identical( track, exp );
        }
        else
        {
          var exp =
          [
            `${options.procedure.id}.conStart`,
            `${options.runs[ 0 ].procedure.id}.conStart`,
            `${options.runs[ 1 ].procedure.id}.conStart`,
            `${options.runs[ 0 ].procedure.id}.conTerminate`,
            `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
            `${options.runs[ 0 ].procedure.id}.ready`,
            `${options.runs[ 1 ].procedure.id}.conTerminate.err`,
            `${options.runs[ 1 ].procedure.id}.conDisconnect.err`,
            `${options.runs[ 1 ].procedure.id}.ready.err`,
            `${options.procedure.id}.conTerminate.err`,
            `${options.procedure.id}.ready.err`,
          ]
          /*
          the first children can be terminatead before the second, but also can after
          */
          if( !_.identical( track, exp ) )
          exp =
          [
            `${options.procedure.id}.conStart`,
            `${options.runs[ 0 ].procedure.id}.conStart`,
            `${options.runs[ 1 ].procedure.id}.conStart`,
            `${options.runs[ 1 ].procedure.id}.conTerminate.err`,
            `${options.runs[ 1 ].procedure.id}.conDisconnect.err`,
            `${options.runs[ 1 ].procedure.id}.ready.err`,
            `${options.runs[ 0 ].procedure.id}.conTerminate`,
            `${options.runs[ 0 ].procedure.id}.conDisconnect.dont`,
            `${options.runs[ 0 ].procedure.id}.ready`,
            `${options.procedure.id}.conTerminate.err`,
            `${options.procedure.id}.ready.err`,
          ]
          test.identical( track, exp );
        }

        var exp =
        [
          'conStart.arg',
          'conTerminate.err',
          'ready.err',
        ]
        if( tops.consequence === 'routine' )
        test.identical( track2, exp );

        test.is( _.errIs( err ) );
        test.notIdentical( options.exitCode, 0 );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'code' );
        test.identical( options.exitSignal, null );
        test.identical( options.state, 'terminated' );
        test.is( !!options.error );
        test.identical( _.strCount( options.error.message, 'Error1' ), 1 );

        test.identical( options.runs[ 0 ].exitCode, 0 );
        test.identical( options.runs[ 0 ].ended, true );
        test.identical( options.runs[ 0 ].exitReason, 'normal' );
        test.identical( options.runs[ 0 ].exitSignal, null );
        test.identical( options.runs[ 0 ].state, 'terminated' );
        test.is( !options.runs[ 0 ].error );

        test.notIdentical( options.runs[ 1 ].exitCode, 0 );
        test.identical( options.runs[ 1 ].ended, true );
        test.identical( options.runs[ 1 ].exitReason, 'code' );
        test.identical( options.runs[ 1 ].exitSignal, null );
        test.identical( options.runs[ 1 ].state, 'terminated' );
        test.is( !!options.runs[ 1 ].error );

        return null;
      })

      return options.ready;
    })

    /* */

    return ready;
  }

  /* - */

  function conMake( tops, name )
  {

    if( name === 'conDisconnect' )
    return null;

    if( tops.consequence === 'consequence' )
    {
      if( name === 'ready' )
      return new _.Consequence().take( null );
      else
      return new _.Consequence();
    }
    else if( tops.consequence === 'null' )
    {
      return null;
    }
    else if( tops.consequence === 'routine' )
    {
      return routine;
    }
    else _.assert( 0, `Unknown ${tops.consequence}` );
    function routine( err, arg )
    {
      if( err )
      track2.push( name + ( _.symbolIs( err ) ? '.dont' : '.err' ) );
      else
      track2.push( name + '.arg' );
      if( err )
      throw err;
      return arg;
    }
  }

  function clear()
  {
    track = [];
    track2 = [];
  }

  function processTrack( op )
  {
    consequenceTrack( op, 'conStart' );
    consequenceTrack( op, 'conTerminate' );
    consequenceTrack( op, 'conDisconnect' );
    consequenceTrack( op, 'ready' );
  }

  function consequenceTrack( op, cname )
  {
    if( _.consequenceIs( op[ cname ] ) )
    op[ cname ].tap( ( err, op2 ) =>
    {
      eventTrack( op, cname, err );
    });
  }

  function eventTrack( op, name, err )
  {
    _.assert( !!op.procedure );
    let postfix = '';
    if( err )
    postfix = _.symbolIs( err ) ? '.dont' : '.err';
    track.push( `${op.procedure.id}.${name}${postfix}` );
    /* track.push( `${op.procedure.id}.${name}${err ? '.err' : ''} - ${_.time.now() - t0}` ); */
    if( err )
    _.errAttend( err );
  }

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    let args = _.process.input();

    let sessionDelay = context.t1 * 0.5*args.map.sessionId;

    if( args.map.concurrent )
    setTimeout( () => { console.log( `${args.map.id}.begin` ) }, sessionDelay );
    else
    console.log( `${args.map.id}.begin` );
    setTimeout( () => { console.log( `${args.map.id}.end` ) }, context.t1 + sessionDelay );

    if( args.map.throwing )
    throw 'Error1';

  }

}

startConcurrentConsequencesMultiple.timeOut = 2e6;
startConcurrentConsequencesMultiple.description =
`
  - all consequences are called
  - consequences are called in correct order
`

//

function starterConcurrentMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( program1 ) );
  let counter = 0;
  let time = 0;
  let filePath = a.path.nativize( a.abs( a.routinePath, 'file.txt' ) );

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single';
    time = _.time.now();
    return null;
  })

  let singleOption2 = {}
  let singleOption =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var start = _.process.starter( singleOption );
  start( singleOption2 )

  .then( ( arg ) =>
  {
    test.identical( arg.exitCode, 0 );
    test.is( singleOption !== arg );
    test.is( singleOption2 === arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single, no second options';
    time = _.time.now();
    return null;
  })

  let singleOptionWithoutSecond =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var start = _.process.starter( singleOptionWithoutSecond );
  start()

  .then( ( arg ) =>
  {

    test.identical( arg.exitCode, 0 );
    test.is( singleOptionWithoutSecond !== arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single, execPath in array';
    time = _.time.now();
    return null;
  })

  let singleExecPathInArrayOptions2 = {};
  let singleExecPathInArrayOptions =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var start = _.process.starter( singleExecPathInArrayOptions );
  start( singleExecPathInArrayOptions2 )

  .then( ( arg ) =>
  {
    test.identical( arg.exitCode, 0 );
    test.is( singleExecPathInArrayOptions2 === arg );
    test.is( _.strHas( arg.output, 'begin 1000' ) );
    test.is( _.strHas( arg.output, 'end 1000' ) );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready, exec is scalar';
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBeforeScalar2 = {};
  let singleErrorBeforeScalar =
  {
    execPath : 'node ' + testAppPath + ' 1000',
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var start = _.process.starter( singleErrorBeforeScalar );
  start( singleErrorBeforeScalar2 )

  .finally( ( err, arg ) =>
  {

    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBeforeScalar.exitCode, undefined );
    test.identical( singleErrorBeforeScalar.output, undefined );
    test.is( !a.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'single, error in ready, exec is single-element vector';
    time = _.time.now();
    throw _.err( 'Error!' );
  })

  let singleErrorBefore2 = {};
  let singleErrorBefore =
  {
    execPath : [ 'node ' + testAppPath + ' 1000' ],
    ready : a.ready,
    verbosity : 3,
    outputCollecting : 1,
  }

  var start = _.process.starter( singleErrorBefore );
  start( singleErrorBefore2 )

  .finally( ( err, arg ) =>
  {

    test.is( arg === undefined );
    test.is( _.errIs( err ) );
    test.identical( singleErrorBefore.exitCode, undefined );
    test.identical( singleErrorBefore.output, undefined );
    test.is( !a.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial';
    time = _.time.now();
    return null;
  })

  let subprocessesOptionsSerial2 = {};
  let subprocessesOptionsSerial =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  var start = _.process.starter( subprocessesOptionsSerial );
  start( subprocessesOptionsSerial2 )

  .then( ( op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesOptionsSerial2.exitCode, 0 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'end 1000' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 1' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 1' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 1';
    time = _.time.now();
    return null;
  })

  let subprocessesError2 = {};
  let subprocessesError =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
  }

  var start = _.process.starter( subprocessesError );
  start( subprocessesError2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesError2.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( arg === undefined );
    test.is( !a.fileProvider.fileExists( filePath ) );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, serial, error, throwingExitCode : 0';
    time = _.time.now();
    return null;
  })

  let subprocessesErrorNonThrowing2 = {};
  let subprocessesErrorNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 0,
    throwingExitCode : 0,
  }

  var start = _.process.starter( subprocessesErrorNonThrowing );
  start( subprocessesErrorNonThrowing2 )

  .then( ( op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorNonThrowing2.exitCode, 1 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 1 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( op.runs[ 0 ].output, 'end x' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'Expects number' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 1' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 1' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 1';
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrent2 = {};
  let subprocessesErrorConcurrent =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var start = _.process.starter( subprocessesErrorConcurrent );
  start( subprocessesErrorConcurrent2 )

  .finally( ( err, arg ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrent2.exitCode, 1 );
    test.is( _.errIs( err ) );
    test.is( arg === undefined );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    _.errAttend( err );
    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1, error, throwingExitCode : 0';
    time = _.time.now();
    return null;
  })

  let subprocessesErrorConcurrentNonThrowing2 = {};
  let subprocessesErrorConcurrentNonThrowing =
  {
    execPath :  [ 'node ' + testAppPath + ' x', 'node ' + testAppPath + ' 1' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
    throwingExitCode : 0,
  }

  var start = _.process.starter( subprocessesErrorConcurrentNonThrowing );
  start( subprocessesErrorConcurrentNonThrowing2 )

  .then( ( op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent );
    test.gt( spent, 0 );
    test.le( spent, 5000 );

    test.identical( subprocessesErrorConcurrentNonThrowing2.exitCode, 1 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 1 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin x' ) );
    test.is( !_.strHas( op.runs[ 0 ].output, 'end x' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'Expects number' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 1' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 1' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
  {
    test.case = 'subprocesses, concurrent : 1';
    time = _.time.now();
    return null;
  })

  let subprocessesConcurrentOptions2 = {};
  let subprocessesConcurrentOptions =
  {
    execPath :  [ 'node ' + testAppPath + ' 1000', 'node ' + testAppPath + ' 100' ],
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var start = _.process.starter( subprocessesConcurrentOptions );
  start( subprocessesConcurrentOptions2 )

  .then( ( op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesConcurrentOptions2.exitCode, 0 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin 1000' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'end 1000' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 100' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 100' ) );

    counter += 1;
    return null;
  });

  /* - */

  a.ready.then( ( arg ) =>
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
    ready : a.ready,
    outputCollecting : 1,
    verbosity : 3,
    concurrent : 1,
  }

  var start = _.process.starter( subprocessesConcurrentArgumentsOptions );
  start( subprocessesConcurrentArgumentsOptions2 )

  .then( ( op ) =>
  {

    var spent = _.time.now() - time;
    logger.log( 'Spent', spent )
    test.gt( spent, 1000 );
    test.le( spent, 5000 );

    test.identical( subprocessesConcurrentArgumentsOptions2.exitCode, 0 );
    test.identical( op.runs.length, 2 );
    test.identical( a.fileProvider.fileRead( filePath ), 'written by 1000' );
    a.fileProvider.fileDelete( filePath );

    test.identical( op.runs[ 0 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 0 ].output, 'begin 1000, second, argument' ) );
    test.is( _.strHas( op.runs[ 0 ].output, 'end 1000, second, argument' ) );

    test.identical( op.runs[ 1 ].exitCode, 0 );
    test.is( _.strHas( op.runs[ 1 ].output, 'begin 100, second, argument' ) );
    test.is( _.strHas( op.runs[ 1 ].output, 'end 100, second, argument' ) );

    counter += 1;
    return null;
  });

  /* - */

  return a.ready.finally( ( err, arg ) =>
  {
    debugger;
    test.identical( counter, 12 );
    if( err )
    throw err;
    return arg;
  });

  /* - */

  function program1()
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

    setTimeout( periodic, context.t0 / 2 ); /* 50 */
    function periodic()
    {
      console.log( 'tick', process.argv.slice( 2 ).join( ', ' ) );
      if( !ended )
      setTimeout( periodic, context.t0 / 2 ); /* 50 */
    }
  }
}

starterConcurrentMultiple.timeOut = 100000;

// --
// helper
// --

function startNjs( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  var testAppPath = a.program( testApp );
  var testAppPath2 = a.program( testApp2 );

  /* */

  a.ready.then( () =>
  {
    test.case = 'execPath contains normalized path'
    return _.process.startNjs
    ({
      execPath : testAppPath2,
      args : [ 'arg' ],
      outputCollecting : 1,
      stdio : 'pipe',
    })
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( op.args, [ 'arg' ] );
      console.log( op.output )
      test.is( _.strHas( op.output, `[ 'arg' ]` ) );
      return null
    })
  })

  /* */

  // let modes = [ 'fork', 'exec', 'spawn', 'shell' ];
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    a.ready.then( () =>
    {
      var o = { execPath : testAppPath, mode, applyingExitCode : 1, throwingExitCode : 1, stdio : 'ignore', outputPiping : 0, outputCollecting : 0 };
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

    /* */

    a.ready.then( () =>
    {
      var o = { execPath : testAppPath, mode,  applyingExitCode : 1, throwingExitCode : 0, stdio : 'ignore', outputPiping : 0, outputCollecting : 0 };
      return _.process.startNjs( o )
      .finally( ( err, op ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 1 );
        process.exitCode = 0;
        test.is( !_.errIs( err ) );
        return true;
      })
    })

    /* */

    a.ready.then( () =>
    {
      var o = { execPath : testAppPath,  mode, applyingExitCode : 0, throwingExitCode : 1, stdio : 'ignore', outputPiping : 0, outputCollecting : 0 };
      var con = _.process.startNjs( o )
      return test.shouldThrowErrorAsync( con )
      .finally( () =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        return true;
      })
    })

    /* */

    a.ready.then( () =>
    {
      var o = { execPath : testAppPath,  mode, applyingExitCode : 0, throwingExitCode : 0, stdio : 'ignore', outputPiping : 0, outputCollecting : 0 };
      return _.process.startNjs( o )
      .finally( ( err, op ) =>
      {
        test.identical( o.exitCode, 1 );
        test.identical( process.exitCode, 0 );
        test.is( !_.errIs( err ) );
        return true;
      })
    })

    /* */

    a.ready.then( () =>
    {
      var o = { execPath : testAppPath,  mode, maximumMemory : 1, applyingExitCode : 0, throwingExitCode : 0, stdio : 'ignore', outputPiping : 0, outputCollecting : 0 };
      return _.process.startNjs( o )
      .finally( ( err, op ) =>
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

  return a.ready;

  /* - */

  function testApp()
  {
    throw new Error( 'Error message from child' );
  }

  function testApp2()
  {
    console.log( process.argv.slice( 2 ) )
  }

}

startNjs.timeOut = 20000;

//

function startNjsWithReadyDelayStructural( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program1 );

  /* qqq for Yevhen : add varying `sync` and `deasync`
    do not combine `detaching` with `dry`
    do not combine `detaching` with `sync` and `deasync`
    */
  /* qqq for Yevhen : add varying `sync` and `deasync` and `dry` for test routine startNjsWithReadyDelayStructuralMultiple */

  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, 1, mode ) ) );
  return a.ready;

  /* */

  function run( detaching, dry, mode ) /* qqq for Yevhen : put parameters in map `tops` */
  // function run( tops ) /* qqq for Yevhen : use map tops */
  {
    let ready = _.Consequence().take( null );

    ready.then( () =>
    {
      /*
      output piping doesn't work as expected in mode "shell" on windows
      */
      test.case = `mode:${mode} detaching:${detaching}`;
      let con = new _.Consequence().take( null ).delay( context.t1 ); /* 1000 */

      let options =
      {
        mode,
        detaching,
        dry,
        execPath : programPath,
        currentPath : a.abs( '.' ),
        throwingExitCode : 1,
        inputMirroring : 1,
        outputCollecting : 1,
        stdio : 'pipe',
        sync : 0,
        deasync : 0,
        ready : con,
      }

      let returned = _.process.startNjs( options );

      returned.then( ( op ) =>
      {
        test.identical( op.ended, true );

        if( !dry )
        {
          test.identical( op.exitCode, 0 );
          test.identical( op.output, 'program1:begin\n' );
        }

        let exp2 = _.mapExtend( null, exp );
        exp2.process = options.process;
        exp2.procedure = options.procedure;
        exp2.streamOut = options.streamOut;
        exp2.streamErr = options.streamErr;
        exp2.execPath = mode === 'fork' ? programPath : 'node';
        exp2.args = mode === 'fork' ? [] : [ programPath ];
        exp2.fullExecPath = ( mode === 'fork' ? '' : 'node ' ) + programPath;
        exp2.state = 'terminated';
        exp2.ended = true;
        if( !dry )
        {
          exp2.output = 'program1:begin\n';
          exp2.exitCode = 0;
          exp2.exitSignal = null;
          exp2.exitReason = 'normal';
        }

        test.identical( options, exp2 );
        test.identical( !!options.process, !dry );
        test.is( _.routineIs( options.disconnect ) );
        test.identical( _.streamIs( options.streamOut ), !dry );
        test.identical( _.streamIs( options.streamErr ), !dry );
        test.identical( options.streamOut !== options.streamErr, !dry );
        test.is( options.conTerminate !== options.ready );
        test.identical( options.ready.exportString(), 'Consequence:: 0 / 1' );
        test.identical( options.conTerminate.exportString(), 'Consequence:: 1 / 0' );
        test.identical( options.conDisconnect.exportString(), 'Consequence:: 1 / 0' );
        test.identical( options.conStart.exportString(), 'Consequence:: 1 / 0' );

        return null;
      });

      var exp =
      {
        mode,
        detaching,
        dry,
        'execPath' : ( mode === 'fork' ? '' : 'node ' ) + programPath,
        'currentPath' : a.abs( '.' ),
        'throwingExitCode' : 'full',
        'inputMirroring' : 1,
        'outputCollecting' : 1,
        'sync' : 0,
        'deasync' : 0,
        'passingThrough' : 0,
        'maximumMemory' : 0,
        'applyingExitCode' : 1,
        'stdio' : mode === 'fork' ? [ 'pipe', 'pipe', 'pipe', 'ipc' ] : [ 'pipe', 'pipe', 'pipe' ],
        'args' : null,
        'interpreterArgs' : null,
        'when' : 'instant',
        'ipc' : mode === 'fork' ? true : false,
        'env' : null,
        'hiding' : 1,
        'concurrent' : 0,
        'timeOut' : null,
        // 'briefExitCode' : 0,
        'verbosity' : 2,
        'outputPrefixing' : 0,
        'outputPiping' : true,
        'outputAdditive' : true,
        'outputColoring' : 1,
        'outputColoringStdout' : 1,
        'outputColoringStderr' : 1,
        'uid' : null,
        'gid' : null,
        'streamSizeLimit' : null,
        'streamOut' : null,
        'streamErr' : null,
        'outputGraying' : 0,
        'conStart' : options.conStart,
        'conTerminate' : options.conTerminate,
        'conDisconnect' : options.conDisconnect,
        'ready' : options.ready,
        'process' : options.process,
        'logger' : options.logger,
        'stack' : options.stack,
        'state' : 'initial',
        'exitReason' : null,
        'output' : '',
        'exitCode' : null,
        'exitSignal' : null,
        'procedure' : null,
        'ended' : false,
        'error' : null,
        'disconnect' : options.disconnect,
        'end' : options.end,
        'fullExecPath' : null,
        '_handleProcedureTerminationBegin' : false,
      }
      test.identical( options, exp );

      test.is( _.routineIs( options.disconnect ) );
      test.is( options.conTerminate !== options.ready );
      test.is( !!options.disconnect );
      test.identical( options.process, null );
      test.is( !!options.logger );
      test.is( !!options.stack );
      test.identical( options.ready.exportString(), 'Consequence:: 0 / 2' );
      test.identical( options.conDisconnect.exportString(), 'Consequence:: 0 / 0' );
      test.identical( options.conTerminate.exportString(), 'Consequence:: 0 / 0' );
      test.identical( options.conStart.exportString(), 'Consequence:: 0 / 0' );

      return returned;
    })

    return ready;
  }

  /* */

  function program1()
  {
    console.log( 'program1:begin' );
  }

}

startNjsWithReadyDelayStructural.description =
`
 - ready has delay
 - value of o-context is correct before start
 - value of o-context is correct after start
`

//

function startNjsOptionInterpreterArgs( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let totalMem = require( 'os' ).totalmem();

  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  /* */

  function run( mode )
  {
    let ready = _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = ''`;

      let options =
      {
        execPath : programPath,
        mode,
        outputCollecting : 1,
        interpreterArgs : '',
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Log\n' );

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = []`;

      let options =
      {
        execPath : programPath,
        mode,
        outputCollecting : 1,
        interpreterArgs : [],
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Log\n' );

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = '--version'`;

      let options =
      {
        execPath : programPath,
        mode,
        outputCollecting : 1,
        interpreterArgs : '--version',
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        test.identical( op.interpreterArgs, [ '--version' ] )
        else
        test.identical( op.args, [ '--version', programPath ] );

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, execPath : null, args : programPath, interpreterArgs = '--version'`;

      let options =
      {
        args : programPath,
        mode,
        outputCollecting : 1,
        interpreterArgs : '--version',
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        {
          test.identical( op.args, [] );
          test.identical( op.interpreterArgs, [ '--version' ] )
        }
        else
        {
          test.identical( op.args, [ '--version', programPath ] );
        }

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, execPath : '', args : 'arg1', interpreterArgs = '--version'`;

      let options =
      {
        execPath : '',
        args : 'arg1',
        mode,
        outputCollecting : 1,
        interpreterArgs : '--version',
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        {
          test.identical( op.args, [] )
          test.identical( op.interpreterArgs, [ '--version' ] )
        }
        else
        {
          test.identical( op.args, [ '--version', 'arg1' ] );
        }

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = '--version', maximumMemory : 1`;

      let options =
      {
        execPath : programPath,
        mode,
        outputCollecting : 1,
        interpreterArgs : '--version',
        maximumMemory : 1,
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        if( mode === 'shell' ) console.log( 'SHELL OP: ', op )
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        test.identical( op.interpreterArgs, [ '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}` ] )
        else
        test.identical( op.args, [ '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}`, programPath ] );

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = [ '--v8-options' ]`;

      let options =
      {
        execPath : programPath,
        mode,
        outputCollecting : 1,
        interpreterArgs : [ '--v8-options' ],
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'Synopsis:' ) );
        test.is( _.strHas( op.output, `The following syntax for options is accepted (both '-' and '--' are ok):` ) );
        test.is( _.strHas( op.output, '-e        execute a string in V8' ) );
        test.is( _.strHas( op.output, '--shell   run an interactive JavaScript shell' ) );
        test.is( _.strHas( op.output, '--module  execute a file as a JavaScript module' ) );
        test.is( _.strHas( op.output, 'Options:' ) );
        if( mode === 'fork' )
        test.identical( op.interpreterArgs, [ '--v8-options' ] )
        else
        test.identical( op.args, [ '--v8-options', programPath ] );

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = [ '--v8-options' ], maximumMemory : 1`;

      let options =
      {
        execPath : programPath,
        mode,
        outputCollecting : 1,
        interpreterArgs : [ '--v8-options' ],
        maximumMemory : 1,
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'Synopsis:' ) );
        test.is( _.strHas( op.output, `The following syntax for options is accepted (both '-' and '--' are ok):` ) );
        test.is( _.strHas( op.output, '-e        execute a string in V8' ) );
        test.is( _.strHas( op.output, '--shell   run an interactive JavaScript shell' ) );
        test.is( _.strHas( op.output, '--module  execute a file as a JavaScript module' ) );
        test.is( _.strHas( op.output, 'Options:' ) );
        if( mode === 'fork' )
        test.identical( op.interpreterArgs, [ '--v8-options', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}` ] )
        else
        test.identical( op.args, [ '--v8-options', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}`, programPath ] );

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = '--version', maximumMemory : 1, args : [ 'arg1', 'arg2' ]`;

      let options =
      {
        execPath : programPath,
        mode,
        args : [ 'arg1', 'arg2' ],
        outputCollecting : 1,
        interpreterArgs : '--version',
        maximumMemory : 1,
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        {
          test.identical( op.interpreterArgs, [ '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}` ] )
          test.identical( op.args, [ 'arg1', 'arg2' ] );
        }
        else
        {
          test.identical( op.args, [ '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}`, programPath, 'arg1', 'arg2' ] );
        }

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = '--trace-warnings --version', maximumMemory : 1, args : [ 'arg1', 'arg2' ]`;

      let options =
      {
        execPath : programPath,
        mode,
        args : [ 'arg1', 'arg2' ],
        outputCollecting : 1,
        interpreterArgs : '--trace-warnings --version',
        maximumMemory : 1,
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        {
          test.identical( op.interpreterArgs, [ '--trace-warnings', '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}` ] )
          test.identical( op.args, [ 'arg1', 'arg2' ] );
        }
        else
        {
          test.identical( op.args, [ '--trace-warnings', '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}`, programPath, 'arg1', 'arg2' ] );
        }

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = [ '--trace-warnings', '--version' ], maximumMemory : 1, args : [ 'arg1', 'arg2' ]`;

      let options =
      {
        execPath : programPath,
        mode,
        args : [ 'arg1', 'arg2' ],
        outputCollecting : 1,
        interpreterArgs : [ '--trace-warnings', '--version' ],
        maximumMemory : 1,
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        {
          test.identical( op.interpreterArgs, [ '--trace-warnings', '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}` ] )
          test.identical( op.args, [ 'arg1', 'arg2' ] );
        }
        else
        {
          test.identical( op.args, [ '--trace-warnings', '--version', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}`, programPath, 'arg1', 'arg2' ] );
        }

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, interpreterArgs = [ '--version', '--v8-options' ], maximumMemory : 1, args : [ 'arg1', 'arg2' ]`;

      let options =
      {
        execPath : programPath,
        mode,
        args : [ 'arg1', 'arg2' ],
        outputCollecting : 1,
        interpreterArgs : [ '--version', '--v8-options' ],
        maximumMemory : 1,
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        {
          test.identical( op.interpreterArgs, [ '--version', '--v8-options', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}` ] )
          test.identical( op.args, [ 'arg1', 'arg2' ] );
        }
        else
        {
          test.identical( op.args, [ '--version', '--v8-options', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}`, programPath, 'arg1', 'arg2' ] );
        }

        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode}, execPath : null, interpreterArgs = [ '--version', '--v8-options' ], maximumMemory : 1, args : [ programPath,  'arg1', 'arg2' ]`;

      let options =
      {
        execPath : null,
        mode,
        args : [ programPath, 'arg1', 'arg2' ],
        outputCollecting : 1,
        interpreterArgs : [ '--version', '--v8-options' ],
        maximumMemory : 1,
        stdio : 'pipe'
      }

      return _.process.startNjs( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, process.version + '\n' );
        if( mode === 'fork' )
        {
          test.identical( op.interpreterArgs, [ '--version', '--v8-options', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}` ] )
          test.identical( op.args, [ 'arg1', 'arg2' ] );
        }
        else
        {
          test.identical( op.args, [ '--version', '--v8-options', '--expose-gc', '--stack-trace-limit=999', `--max_old_space_size=${totalMem}`, programPath, 'arg1', 'arg2' ] );
        }

        return null;
      } )
    })

    return ready;

  }

  /* - */

  function program1()
  {
    console.log( 'Log' );
  }
}

//

function startNjsWithReadyDelayStructuralMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program1 );

  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( 0, mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run( 1, mode ) ) );
  return a.ready;

  /* */

  function run( detaching, mode )
  {
    let ready = _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `mode:${mode} detaching:${detaching}`;
      let con = new _.Consequence().take( null ).delay( context.t1 ); /* 1000 */

      let options =
      {
        mode,
        detaching,
        execPath : programPath,
        currentPath : [ a.abs( '.' ), a.abs( '.' ) ],
        throwingExitCode : 1,
        inputMirroring : 1,
        outputCollecting : 1,
        stdio : 'pipe',
        sync : 0,
        deasync : 0,
        ready : con,
      }

      let returned = _.process.startNjs( options );

      returned.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\nprogram1:begin\n' );

        let exp2 = _.mapExtend( null, exp );
        exp2.output = 'program1:begin\nprogram1:begin\n';
        exp2.exitCode = 0;
        exp2.exitSignal = null;
        exp2.runs = options.runs;
        exp2.state = 'terminated';
        exp2.exitReason = 'normal';
        exp2.ended = true;

        test.identical( options, exp2 );
        test.is( !options.process );
        test.is( _.streamIs( options.streamOut ) );
        test.is( _.streamIs( options.streamErr ) );
        test.is( options.streamOut !== options.streamErr );
        test.is( ! options.disconnect );
        test.is( options.conTerminate !== options.ready );
        test.is( _.arrayIs( options.runs ) );
        test.identical( options.ready.exportString(), 'Consequence:: 0 / 1' );
        test.identical( options.conTerminate.exportString(), 'Consequence:: 1 / 0' );
        test.identical( options.conDisconnect, null );
        test.identical( options.conStart.exportString(), 'Consequence:: 1 / 0' );

        return null;
      });

      var exp =
      {
        mode,
        detaching,
        'execPath' : ( mode === 'fork' ? '' : 'node ' ) + programPath,
        'currentPath' : [ a.abs( '.' ), a.abs( '.' ) ],
        'throwingExitCode' : 'full',
        'inputMirroring' : 1,
        'outputCollecting' : 1,
        'sync' : 0,
        'deasync' : 0,
        'passingThrough' : 0,
        'maximumMemory' : 0,
        'applyingExitCode' : 1,
        'stdio' : mode === 'fork' ? [ 'pipe', 'pipe', 'pipe', 'ipc' ] : [ 'pipe', 'pipe', 'pipe' ],
        'streamOut' : null,
        'streamErr' : null,
        'args' : null,
        'interpreterArgs' : null,
        'when' : 'instant',
        'dry' : 0,
        'ipc' : mode === 'fork' ? true : false,
        'env' : null,
        'hiding' : 1,
        'concurrent' : 0,
        'timeOut' : null,
        // 'briefExitCode' : 0,
        'verbosity' : 2,
        'outputPrefixing' : 0,
        'outputPiping' : true,
        'outputAdditive' : true,
        'outputColoring' : 1,
        'outputColoringStdout' : 1,
        'outputColoringStderr' : 1,
        'outputGraying' : 0,
        'conStart' : options.conStart,
        'conTerminate' : options.conTerminate,
        'conDisconnect' : options.conDisconnect,
        'ready' : options.ready,
        'procedure' : options.procedure,
        'logger' : options.logger,
        'stack' : options.stack,
        'streamOut' : options.streamOut,
        'streamErr' : options.streamErr,
        'uid' : null,
        'gid' : null,
        'streamSizeLimit' : null,
        'runs' : [],
        'state' : 'initial',
        'exitReason' : null,
        'output' : '',
        'exitCode' : null,
        'exitSignal' : null,
        'ended' : false,
        'error' : null
        // 'disconnect' : options.disconnect,
        // 'fullExecPath' : null,
        // '_handleProcedureTerminationBegin' : false,
      }
      test.identical( options, exp );

      test.is( options.conTerminate !== options.ready );
      test.is( !options.disconnect );
      test.is( !options.process );
      test.is( !!options.procedure );
      test.is( !!options.logger );
      test.is( !!options.stack );
      test.is( _.streamIs( options.streamOut ) );
      test.is( _.streamIs( options.streamErr ) );
      test.is( options.streamOut !== options.streamErr );
      test.identical( options.ready.exportString(), 'Consequence:: 0 / 3' );
      test.identical( options.conTerminate.exportString(), 'Consequence:: 0 / 0' );
      test.identical( options.conDisconnect, null );
      test.identical( options.conStart.exportString(), 'Consequence:: 0 / 0' );

      return returned;
    })

    return ready;
  }

  /* */

  function program1()
  {
    console.log( 'program1:begin' );
  }

}

startNjsWithReadyDelayStructuralMultiple.description =
`
 - ready has delay
 - value of o-context is correct before start
 - value of o-context is correct after start
`

// --
// sheller
// --

function sheller( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );

  /* */

  a.ready

  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    debugger;
    return shell({ execPath :  [ 'arg1', 'arg2' ] })
    .then( ( op ) =>
    {
      debugger;
      test.identical( op.runs.length, 2 );

      let o1 = op.runs[ 0 ];
      let o2 = op.runs[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.is( _.strHas( o1.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg2' ]` ) );

      return op;
    })
  })

  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath + ' arg0',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  [ 'arg1', 'arg2' ] })
    .then( ( op ) =>
    {
      test.identical( op.runs.length, 2 );

      let o1 = op.runs[ 0 ];
      let o2 = op.runs[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.is( _.strHas( o1.output, `[ 'arg0', 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg0', 'arg2' ]` ) );

      return op;
    })
  })


  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  [ 'arg1', 'arg2' ], args : [ 'arg3' ] })
    .then( ( op ) =>
    {
      test.identical( op.runs.length, 2 );

      let o1 = op.runs[ 0 ];
      let o2 = op.runs[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.identical( o1.args, [ testAppPath, 'arg1', 'arg3' ] );
      test.identical( o2.args, [ testAppPath, 'arg2', 'arg3' ] );
      test.is( _.strHas( o1.output, `[ 'arg1', 'arg3' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg2', 'arg3' ]` ) );

      return op;
    })
  })

  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath :  'node ' + testAppPath,
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath :  'arg1' })
    .then( ( op ) =>
    {
      test.identical( op.execPath, 'node' );
      test.is( _.strHas( op.output, `[ 'arg1' ]` ) );

      return op;
    })
  })

  .then( () =>
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
    .then( ( op ) =>
    {
      test.identical( op.runs.length, 2 );

      let o1 = op.runs[ 0 ];
      let o2 = op.runs[ 1 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.is( _.strHas( o1.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg1' ]` ) );

      return op;
    })
  })

  .then( () =>
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
    .then( ( op ) =>
    {
      test.identical( op.runs.length, 4 );

      let o1 = op.runs[ 0 ];
      let o2 = op.runs[ 1 ];
      let o3 = op.runs[ 2 ];
      let o4 = op.runs[ 3 ];

      test.identical( o1.execPath, 'node' );
      test.identical( o2.execPath, 'node' );
      test.identical( o3.execPath, 'node' );
      test.identical( o4.execPath, 'node' );
      test.is( _.strHas( o1.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o2.output, `[ 'arg1' ]` ) );
      test.is( _.strHas( o3.output, `[ 'arg2' ]` ) );
      test.is( _.strHas( o4.output, `[ 'arg2' ]` ) );

      return op;
    })
  })

  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : 'arg1',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath })
    .then( ( op ) =>
    {
      test.identical( op.execPath, 'node' );
      test.is( _.strHas( op.output, `[ 'arg1' ]` ) );

      return op;
    })
  })

  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : 'arg1',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath, args : 'arg2' })
    .then( ( op ) =>
    {
      test.identical( op.execPath, 'node' );
      test.is( _.strHas( op.output, `[ 'arg2' ]` ) );

      return op;
    })
  })

  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : [ 'arg1', 'arg2' ],
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath, args : 'arg3' })
    .then( ( op ) =>
    {
      test.identical( op.execPath, 'node' );
      test.is( _.strHas( op.output, `[ 'arg3' ]` ) );

      return op;
    })
  })

  .then( () =>
  {
    var shell = _.process.starter
    ({
      execPath : 'node',
      args : 'arg1',
      outputCollecting : 1,
      outputPiping : 1
    })

    return shell({ execPath : testAppPath, args : [ 'arg2', 'arg3' ] })
    .then( ( op ) =>
    {
      test.identical( op.execPath, 'node' );
      test.is( _.strHas( op.output, `[ 'arg2', 'arg3' ]` ) );

      return op;
    })
  })

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

//

function shellerArgs( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );

  /* */


  let shellerOptions =
  {
    outputCollecting : 1,
    args : [ 'arg1', 'arg2' ],
    mode : 'spawn',
    ready : a.ready
  }

  let shell = _.process.starter( shellerOptions )

  /* */

  shell
  ({
    execPath : 'node ' + testAppPath + ' arg3',
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( op.args, [ testAppPath, 'arg3', 'arg1', 'arg2' ] );
    test.identical( _.strCount( op.output, `[ 'arg3', 'arg1', 'arg2' ]` ), 1 );
    test.identical( shellerOptions.args, [ 'arg1', 'arg2' ] );
    return null;
  })

  shell
  ({
    execPath : 'node ' + testAppPath,
    args : [ 'arg3' ]
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( op.args, [ testAppPath, 'arg3' ] );
    test.identical( _.strCount( op.output, `[ 'arg3' ]` ), 1 );
    test.identical( shellerOptions.args, [ 'arg1', 'arg2' ] );
    return null;
  })

  shell
  ({
    execPath : 'node',
    args : [ testAppPath, 'arg3' ]
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( op.args, [ testAppPath, 'arg3' ] );
    test.identical( _.strCount( op.output, `[ 'arg3' ]` ), 1 );
    test.identical( shellerOptions.args, [ 'arg1', 'arg2' ] );
    return null;
  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

//

function shellerFields( test )
{

  test.case = 'defaults';
  var start = _.process.starter();

  test.contains( _.mapKeys( start ), _.mapKeys( _.process.start ) );
  test.identical( _.mapKeys( start.defaults ), _.mapKeys( _.process.start.body.defaults ) );
  test.identical( start.head, _.process.start.head );
  test.identical( start.body, _.process.start.body );
  test.identical( _.mapKeys( start.predefined ), _.mapKeys( _.process.start.body.defaults ) );

  test.case = 'execPath';
  var start = _.process.starter( 'node -v' );
  test.contains( _.mapKeys( start ), _.mapKeys( _.process.start ) );
  test.identical( _.mapKeys( start.defaults ), _.mapKeys( _.process.start.body.defaults ) );
  test.identical( start.head, _.process.start.head );
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
  test.identical( start.head, _.process.start.head );
  test.identical( start.body, _.process.start.body );
  test.is( _.arraySetIdentical( _.mapKeys( start.predefined ), _.mapKeys( _.process.start.body.defaults ) ) );
  test.identical( start.predefined.execPath, 'node -v' );
  test.identical( start.predefined.args, [ 'arg1', 'arg2' ] );
  test.identical( start.predefined.ready, ready  );
}

// --
// output
// --

function startOptionOutputCollecting( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => single( mode ) ) );
  return a.ready;

  /*  */

  function single( sync, deasync, mode )
  {
    let ready = new _.Consequence().take( null )

    if( sync && !deasync && mode === 'fork' )
    return null;

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode} outputPiping:1`;

      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        outputPiping : 1,
        outputCollecting : 1,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\n' );
        return op;
      })

      return returned;
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode} outputPiping:0`;

      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        outputPiping : 0,
        outputCollecting : 1,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\n' );
        return op;
      })

      return returned;
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode} outputPiping:null`;

      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        outputPiping : null,
        outputCollecting : 1,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\n' );
        return op;
      })

      return returned;
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode} outputPiping:implicit`;

      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\n' );
        return op;
      })

      return returned;
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode} outputPiping:0 verbosity:0`;

      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        outputPiping : 0,
        outputCollecting : 1,
        verbosity : 0,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\n' );
        return op;
      })

      return returned;
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode} outputPiping:null verbosity:0`;

      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        outputPiping : null,
        outputCollecting : 1,
        verbosity : 0,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\n' );
        return op;
      })

      return returned;
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode:${mode} outputPiping:implicit verbosity:0`;

      let o =
      {
        execPath : mode !== `fork` ? `node ${programPath}` : `${programPath}`,
        currentPath : a.abs( '.' ),
        outputCollecting : 1,
        verbosity : 0,
      }

      let returned = _.process.start( o );

      o.ready.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'program1:begin\n' );
        return op;
      })

      return returned;
    })

    /* */

    return ready;
  }

  /*  */

  function program1()
  {
    console.log( 'program1:begin' );
  }

}

//

function startOptionOutputColoring( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoring : 0, normal output, inputMirroring : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals = { programPath : testAppPath2, outputColoring : 0, inputMirroring : 0, mode };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Log\n' );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoring : 1, normal output, inputMirroring : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals = { programPath : testAppPath2, outputColoring : 1, inputMirroring : 0, mode };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        debugger;
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, '\u001b[35mLog\u001b[39;0m\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoring : 1, normal output, inputMirroring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals = { programPath : testAppPath2, outputColoring : 1, inputMirroring : 1, mode };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {

        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        let expected = `\u001b[97m > \u001b[39;0m${ mode === 'fork' ? '' : 'node ' }${testAppPath2}\n\u001b[35mLog\u001b[39;0m\n`;
        test.identical( op.output, expected )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoring : 0, error output, inputMirroring : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals = { programPath : testAppPath2, outputColoring : 0, inputMirroring : 0, mode };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Error output\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoring : 1, error output, inputMirroring : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals = { programPath : testAppPath2, outputColoring : 1, inputMirroring : 0, mode };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, `\u001b[31mError output\u001b[39;0m\n` )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoring : 1, error output, inputMirroring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals = { programPath : testAppPath2, outputColoring : 1, inputMirroring : 1, mode };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        let expected = `\u001b[97m > \u001b[39;0m${ mode === 'fork' ? '' : 'node ' }${testAppPath2}\n\u001b[31mError output\u001b[39;0m\n`;
        test.identical( op.output, expected )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    })

    /* */

    return ready;
  }

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let options =
    {
      execPath : mode === 'fork' ? programPath : 'node ' + programPath,
      throwingExitCode : 0,
      outputCollecting : 1,
      mode,
      inputMirroring,
      outputColoring,
    }

    return _.process.start( options );
  }

  function testApp2()
  {
    console.log( 'Log' );
  }

  function testApp2Error()
  {
    console.error( 'Error output' );
  }
}

//

function startOptionOutputColoringStderr( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  /* */

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStderr : 0, inputMirroring : 0, outputColloring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStderr : 0,
        outputColoring : 1,
        inputMirroring : 0,
        outputColoringStdout : null,
        mode,
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Error output\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStderr : 1, inputMirroring : 0, outputColoring : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStderr : 1,
        outputColoring : 0,
        inputMirroring : 0,
        outputColoringStdout : null,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, `Error output\n` )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStderr : 1, inputMirroring : 0, outputColoring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStderr : 1,
        outputColoring : 1,
        inputMirroring : 0,
        outputColoringStdout : null,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, `\u001b[31mError output\u001b[39;0m\n` )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStderr : 1, inputMirroring : 1, outputColoring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStderr : 1,
        inputMirroring : 1,
        outputColoring : 1,
        outputColoringStdout : null,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        let expected = `\u001b[97m > \u001b[39;0m${ mode === 'fork' ? '' : 'node ' }${testAppPath2}\n\u001b[31mError output\u001b[39;0m\n`;
        test.identical( op.output, expected )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStderr : 1, outputColoringStdout : 0, inputMirroring : 0, outputColoring : null, normal output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStderr : 1,
        outputColoringStdout : 0,
        inputMirroring : 0,
        outputColoring : null,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Log\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStderr : 1, outputColoringStdout : 0, inputMirroring : 0, outputColoring : 1, normal output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStderr : 1,
        outputColoringStdout : 0,
        inputMirroring : 0,
        outputColoring : 1,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Log\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )


    return ready;

  }

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let options =
    {
      execPath : mode === 'fork' ? programPath : 'node ' + programPath,
      throwingExitCode : 0,
      outputCollecting : 1,
      mode,
      inputMirroring,
      outputColoringStderr,
      outputColoringStdout,
      outputColoring
    }

    return _.process.start( options );
  }

  function testApp2Error()
  {
    console.error( 'Error output' );
  }

  function testApp2()
  {
    console.log( 'Log' );
  }
}

//

function startOptionOutputColoringStdout( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  /* */

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStdout : 0, inputMirroring : 0, outputColloring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStdout : 0,
        outputColoringStderr : null,
        inputMirroring : 0,
        outputColoring : 1,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Log\n' );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStdout : 1, inputMirroring : 0, outputColoring : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStdout : 1,
        outputColoringStderr : null,
        inputMirroring : 0,
        outputColoring : 0,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        debugger;
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Log\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStdout : 1, inputMirroring : 0, outputColoring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStdout : 1,
        outputColoringStderr : null,
        inputMirroring : 0,
        outputColoring : 1,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, `\u001b[35mLog\u001b[39;0m\n` )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStdout : 1, inputMirroring : 1, outputColoring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStdout : 1,
        outputColoringStderr : null,
        inputMirroring : 1,
        outputColoring : 1,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {

        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        let expected = `\u001b[97m > \u001b[39;0m${ mode === 'fork' ? '' : 'node ' }${testAppPath2}\n\u001b[35mLog\u001b[39;0m\n`;
        test.identical( op.output, expected )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStdout : 1, outputColoringStderr : 0, inputMirroring : 0, outputColoring : null`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStdout : 1,
        outputColoringStderr : 0,
        inputMirroring : 0,
        outputColoring : null,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {

        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Error output\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputColoringStdout : 1, outputColoringStderr : 0, inputMirroring : 0, outputColoring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );
      let locals =
      {
        programPath : testAppPath2,
        outputColoringStdout : 1,
        outputColoringStderr : 0,
        inputMirroring : 0,
        outputColoring : 1,
        mode
      };
      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {

        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.output, 'Error output\n' )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );
        return null
      })
    } )


    /* */

    return ready;

  }

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let options =
    {
      execPath : mode === 'fork' ? programPath : 'node ' + programPath,
      throwingExitCode : 0,
      outputCollecting : 1,
      mode,
      inputMirroring,
      outputColoringStdout,
      outputColoringStderr,
      outputColoring
    }

    return _.process.start( options );
  }

  function testApp2()
  {
    console.log( 'Log' );
  }

  function testApp2Error()
  {
    console.error( 'Error output' );
  }

}

//

function startOptionOutputGraying( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );

  /* */


  let modes = [ 'fork', 'spawn', 'shell' ];

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
      ready : a.ready
    })
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      let output = _.strSplitNonPreserving({ src : op.output, delimeter : '\n' });
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
      ready : a.ready
    })
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      let output = _.strSplitNonPreserving({ src : op.output, delimeter : '\n' });
      test.identical( output.length, 2 );
      test.identical( output[ 0 ], 'Colored message1' );
      test.identical( output[ 1 ], 'Colored message2' );
      return null;
    })
  })

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( '\u001b[31m\u001b[43mColored message1\u001b[49;0m\u001b[39;0m' )
    console.log( '\u001b[31m\u001b[43mColored message2\u001b[49;0m\u001b[39;0m' )
  }
}

startOptionOutputGraying.timeOut = 15000;

//

function startOptionOutputPrefixing( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  /* */

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPrefixing : 0, normal output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        prefixing : 0,
        programPath : testAppPath2,
        mode
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'out :\n  Log' ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPrefixing : 1, normal output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        prefixing : 1,
        programPath : testAppPath2,
        mode
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'out :\n  Log' ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* - */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPrefixing : 0, error output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        prefixing : 0,
        programPath : testAppPath2,
        mode,
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'err :' ) );
        test.is( _.strHas( op.output, 'randomText' ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPrefixing : 1, error output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        prefixing : 1,
        programPath : testAppPath2,
        mode
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'err :' ) );
        test.is( _.strHas( op.output, 'randomText' ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    return ready;

  }

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let options =
    {
      execPath : mode === 'fork' ? programPath : 'node ' + programPath,
      mode,
      outputPrefixing : prefixing,
      inputMirroring : 0,
      outputPiping : 1,
      throwingExitCode : 0
    }

    return _.process.start( options )
  }

  function testApp2()
  {
    console.log( 'Log' );
  }

  function testApp2Error()
  {
    randomText
  }
}

//

function startOptionOutputPiping( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  /* */

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode } outputPiping : 1, normal output`
      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        piping : 1,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
        prefixing : 0
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'Log' ), 2 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 0, normal output`
      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        piping : 0,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
        prefixing : 0
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'Log' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 1, outputPrefixing : 1 , normal output`
      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        piping : 1,
        prefixing : 1,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'out :\n  Log' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : null, outputPrefixing : 1, verbosity : 1, normal output`
      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        piping : null,
        verbosity : 1,
        prefixing : 1,
        programPath : testAppPath2,
        mode,
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'out :\n  Log' ), 0 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 1, outputPrefixing : 1, verbosity : 1, normal output`
      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        piping : 1,
        verbosity : 1,
        prefixing : 1,
        programPath : testAppPath2,
        mode,
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'out :\n  Log' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 0, outputPrefixing : 1 , normal output`
      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        piping : 0,
        prefixing : 1,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'out :' ), 0 );
        test.identical( _.strCount( op.output, 'Log' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 1, error output`
      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        piping : 1,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
        prefixing : 0
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'Error\n    at' ), 2 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 1, verbosity : 1, error output`
      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        piping : 1,
        programPath : testAppPath2,
        mode,
        verbosity : 1,
        prefixing : 0
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'Error\n    at' ), 2 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 0, error output`
      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        piping : 0,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
        prefixing : 0
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'err :' ), 0 );
        test.identical( _.strCount( op.output, 'Error\n    at' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 1, outputPrefixing : 1 , error output`
      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        piping : 1,
        prefixing : 1,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'err :' ), 1 );
        test.identical( _.strCount( op.output, 'Error\n    at' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, outputPiping : 0, outputPrefixing : 1 , error output`
      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        piping : 0,
        prefixing : 1,
        programPath : testAppPath2,
        mode,
        verbosity : 2,
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( _.strCount( op.output, 'err :' ), 0 );
        test.identical( _.strCount( op.output, 'Error\n    at' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })

    })

    return ready;
  }

  /* */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let options =
    {
      execPath : mode === 'fork' ? programPath : 'node ' + programPath,
      mode,
      inputMirroring : 0,
      outputPiping : piping,
      verbosity,
      outputCollecting : 1,
      throwingExitCode : 0,
      outputPrefixing : prefixing
    }

    return _.process.start( options )
    .then( ( op ) =>
    {
      if( _.strHas( programPath, 'testApp2Error' ) ) /* qqq2 for Yevhen : ??? */
      console.error( op.output );
      else
      console.log( op.output );
      return null;
    } )
  }

  function testApp2Error()
  {
    throw new Error();
  }

  function testApp2()
  {
    console.log( '\nLog1\nLog2\n' );
  }

  /* qqq2 for Yevhen : poor tests! see no console.error() cases! */
  /* qqq2 for Yevhen : poor tests! see no multiline output! */
}

startOptionOutputPiping.timeOut = 3e5;

//

function startOptionInputMirroring( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  /* */

  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, inputMirroring : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        programPath : testAppPath2,
        mode,
        inputMirroring : 0,
        verbosity : 2
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, testAppPath2 ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, inputMirroring : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        programPath : testAppPath2,
        mode,
        inputMirroring : 1,
        outputPiping : 1,
        verbosity : 2
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, testAppPath2 ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, inputMirroring : 1, verbosity : 0`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        programPath : testAppPath2,
        mode,
        inputMirroring : 1,
        verbosity : 0
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, testAppPath2 ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, inputMirroring : 1, verbosity : 1`;

      let testAppPath2 = a.path.nativize( a.program( testApp2 ) );

      let locals =
      {
        programPath : testAppPath2,
        mode,
        inputMirroring : 1,
        verbosity : 1
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, testAppPath2 ) );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, inputMirroring : 1, error output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        programPath : testAppPath2,
        mode,
        inputMirroring : 1,
        verbosity : 2
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, testAppPath2 ) );
        test.is( _.strHas( op.output, 'throw new Error();' ) )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    /* */

    ready.then( () =>
    {
      test.case = `mode : ${ mode }, inputMirroring : 1, verbosity : 1, error output`;

      let testAppPath2 = a.path.nativize( a.program( testApp2Error ) );

      let locals =
      {
        programPath : testAppPath2,
        mode,
        inputMirroring : 1,
        verbosity : 1
      }

      let testAppPath = a.path.nativize( a.program({ routine : testApp, locals }) );

      return _.process.start
      ({
        execPath : 'node ' + testAppPath,
        outputCollecting : 1,
      })
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, testAppPath2 ) );
        test.is( !_.strHas( op.output, 'throw new Error();' ) )

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      })
    })

    return ready;
  }

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let options =
    {
      execPath : mode === 'fork' ? programPath : 'node ' + programPath,
      mode,
      inputMirroring,
      verbosity,
      outputCollecting : 1,
      throwingExitCode : 0,
    }

    return _.process.start( options )

  }

  function testApp2Error()
  {
    throw new Error();
  }

  function testApp2()
  {
    console.log( 'Log' );
  }
}

//

function startOptionLogger( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );
  let modes = [ 'fork', 'spawn', 'shell' ];

  /* */

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
      outputColoring : 0,
      logger,
      ready : a.ready,
    })
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.is( _.strHas( op.output, '  One tab' ) );
      test.is( _.strHas( loggerOutput, '    One tab' ) );
      console.log( 'loggerOutput', loggerOutput );
      return null;
    })

    /*  */

    function onTransformEnd( o )
    {
      loggerOutput += o.outputForPrinter[ 0 ] + '\n';
    }
  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( '  One tab' );
  }
}

//

function startOptionLoggerTransofrmation( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );

  /* */

  let modes = [ 'fork', 'spawn', 'shell' ];
  var loggerOutput = '';

  var logger = new _.Logger({ output : null, onTransformEnd });

  modes.forEach( ( mode ) =>
  {
    let path = testAppPath;
    if( mode !== 'fork' )
    path = 'node ' + path;

    console.log( mode )

    a.ready.then( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 0, outputCollecting : 0, logger };
      return _.process.start( o )
      .then( () =>
      {
        test.identical( o.output, null );
        test.is( !_.strHas( loggerOutput, 'testApp-output') );
        console.log( loggerOutput )
        return true;
      })
    })

    a.ready.then( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 1, outputCollecting : 0, logger };
      return _.process.start( o )
      .then( () =>
      {
        test.identical( o.output, null );
        test.is( _.strHas( loggerOutput, 'testApp-output') );
        return true;
      })
    })

    a.ready.then( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 0, outputCollecting : 1, logger };
      return _.process.start( o )
      .then( () =>
      {
        test.identical( o.output, 'testApp-output\n\n' );
        test.is( !_.strHas( loggerOutput, 'testApp-output') );
        return true;
      })
    })

    a.ready.then( () =>
    {
      loggerOutput = '';
      var o = { execPath : path, mode, outputPiping : 1, outputCollecting : 1, logger };
      return _.process.start( o )
      .then( () =>
      {
        test.identical( o.output, 'testApp-output\n\n' );
        test.is( _.strHas( loggerOutput, 'testApp-output') );
        return true;
      })
    })
  })

  return a.ready;

  function onTransformEnd( o )
  {
    loggerOutput += o.outputForPrinter[ 0 ];
  }

  function testApp()
  {
    console.log( 'testApp-output\n' );
  }
}

//

/* qqq for Yevhen : describe test cases | aaa : Done */
function startOutputOptionsCompatibilityLateCheck( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );
  let testAppPathParent = a.path.nativize( a.program( testAppParent ) );

  if( !Config.debug )
  {
    test.identical( 1, 1 );
    return;
  }

  let modes = [ 'spawn', 'fork', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    a.ready.tap( () => test.open( mode ) );
    a.ready.then( () => run( mode ) );
    a.ready.tap( () => test.close( mode ) );
  })

  return a.ready;

  /* */

  function run( mode )
  {
    let commonOptions =
    {
      execPath : mode === 'fork' ? 'testApp.js' : 'node testApp.js',
      mode,
      currentPath : a.routinePath,
    }

    let ready = _.Consequence().take( null )

    .then( () =>
    {
      test.case = `outputPiping : 0, outputCollecting : 0, stdio : 'ignore'`;
      let o =
      {
        outputPiping : 0,
        outputCollecting : 0,
        stdio : 'ignore',
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 0, stdio : 'ignore'`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 0,
        stdio : 'ignore',
      }
      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync( () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 0, outputCollecting : 1, stdio : 'ignore'`;
      let o =
      {
        outputPiping : 0,
        outputCollecting : 1,
        stdio : 'ignore',
      }
      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync( () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : 'ignore'`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : 'ignore',
      }
      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync( () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 0, outputCollecting : 0, stdio : 'pipe'`;
      let o =
      {
        outputPiping : 0,
        outputCollecting : 0,
        stdio : 'pipe',
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 0, stdio : 'pipe'`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 0,
        stdio : 'pipe',
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 0, outputCollecting : 1, stdio : 'pipe'`;
      let o =
      {
        outputPiping : 0,
        outputCollecting : 1,
        stdio : 'pipe',
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( _.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : 'pipe'`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : 'pipe',
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( _.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 0, outputCollecting : 0, stdio : 'inherit'`;
      let o =
      {
        outputPiping : 0,
        outputCollecting : 0,
        stdio : 'inherit',
      }

      _.mapExtend( o, commonOptions );

      let o2 =
      {
        execPath : 'node testAppParent.js',
        mode : 'spawn',
        ipc : 1,
        currentPath : a.routinePath,
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1
      }

      _.process.start( o2 );

      o2.conStart.thenGive( () => o2.process.send( o ) );

      o2.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        return null;
      })

      return o2.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 0, stdio : 'inherit'`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 0,
        stdio : 'inherit',
      }

      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync( () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 0, outputCollecting : 1, stdio : 'inherit'`;
      let o =
      {
        outputPiping : 0,
        outputCollecting : 1,
        stdio : 'inherit',
      }

      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync( () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : 'inherit'`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : 'inherit',
      }

      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync( () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'ignore', 'ignore', 'ignore' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'ignore', 'ignore', 'ignore', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync( () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'inherit', 'inherit', 'inherit' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'inherit', 'inherit', 'inherit', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      return test.shouldThrowErrorSync(  () => _.process.start( o ) );
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'pipe', 'pipe', 'pipe' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'pipe', 'pipe', 'pipe', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( _.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'ignore', 'pipe', 'ignore' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'ignore', 'pipe', 'ignore', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( _.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'ignore', 'ignore', 'pipe' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'ignore', 'ignore', 'pipe', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'ignore', 'pipe', 'inherit' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'ignore', 'pipe', 'inherit', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( _.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'ignore', 'inherit', 'pipe' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'ignore', 'inherit', 'pipe', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      let o2 =
      {
        execPath : 'node testAppParent.js',
        mode : 'spawn',
        ipc : 1,
        currentPath : a.routinePath,
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1
      }

      _.process.start( o2 );

      o2.conStart.thenGive( () => o2.process.send( o ) );

      o2.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( _.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o2.conTerminate;
    })

    /* */

    .then( () =>
    {
      test.case = `outputPiping : 1, outputCollecting : 1, stdio : [ 'ignore', 'pipe', 'pipe' ]`;
      let o =
      {
        outputPiping : 1,
        outputCollecting : 1,
        stdio : [ 'ignore', 'pipe', 'pipe', mode === 'fork' ? 'ipc' : null ],
      }

      _.mapExtend( o, commonOptions );

      _.process.start( o );

      o.conTerminate.then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( _.strHas( op.output, 'Test output' ) );
        return null;
      })

      return o.conTerminate;
    })

    return ready;
  }

  /* */

  function testApp()
  {
    let _ = require( toolsPath );
    console.log( 'Test output' );
  }

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wProcess' );

    let ready = new _.Consequence();

    process.on( 'message', ( op ) =>
    {
      ready.take( op );
      process.disconnect();
    })

    ready.then( ( op ) => _.process.start( op ) );
  }
}

//

function startOptionVerbosity( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let capturedOutput;
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
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 1 );
    test.identical( op.ended, true );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + op.exitCode ), 0 );
    return true;
  })

  /* */

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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 1 );
    test.identical( op.ended, true );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + op.exitCode ), 0 );
    return true;
  })

  /* */

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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 1 );
    test.identical( op.ended, true );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + op.exitCode ), 0 );
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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 1 );
    test.identical( op.ended, true );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + op.exitCode ), 0 );
    return true;
  })

  /* */

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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 1 );
    test.identical( op.ended, true );
    test.identical( _.strCount( capturedOutput, 'Process returned error code ' + op.exitCode ), 1 );
    return true;
  })

  /* */

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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( op.fullExecPath, `node -e console.log( \"a\", 'b', \`c\` )` );
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
    outputColoring : 0,
    logger : captureLogger,
    ready : a.ready
  })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( op.ended, true );
    test.identical( op.fullExecPath, `node -e console.log( '"a"', "'b'", \`"c"\` )` );
    test.identical( _.strCount( capturedOutput, `node -e console.log( '"a"', "'b'", \`"c"\` )` ), 1 );
    return true;
  })

  return a.ready;

  /*  */

  function testCase( src )
  {
    a.ready.then( () =>
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

// --
// etc
// --

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
  var returned = _.process.tempOpen( testAppCode );
  var read = _.fileProvider.fileRead( returned );
  test.identical( read, testAppCode );
  _.process.tempClose( returned );
  test.is( !_.fileProvider.fileExists( returned ) );

  /* */

  test.case = 'string';
  var returned = _.process.tempOpen({ sourceCode : testAppCode });
  var read = _.fileProvider.fileRead( returned );
  test.identical( read, testAppCode );
  _.process.tempClose( returned );
  test.is( !_.fileProvider.fileExists( returned ) );

  /* */

  test.case = 'raw buffer';
  var returned = _.process.tempOpen( _.bufferRawFrom( testAppCode ) );
  var read = _.fileProvider.fileRead( returned );
  test.identical( read, testAppCode );
  _.process.tempClose( returned );
  test.is( !_.fileProvider.fileExists( returned ) );

  /* */

  test.case = 'raw buffer';
  var returned = _.process.tempOpen({ sourceCode : _.bufferRawFrom( testAppCode ) });
  var read = _.fileProvider.fileRead( returned );
  test.identical( read, testAppCode );
  _.process.tempClose( returned );
  test.is( !_.fileProvider.fileExists( returned ) );

  /* */

  test.case = 'remove all';
  var returned1 = _.process.tempOpen( testAppCode );
  var returned2 = _.process.tempOpen( testAppCode );
  test.is( _.fileProvider.fileExists( returned1 ) );
  test.is( _.fileProvider.fileExists( returned2 ) );
  _.process.tempClose();
  test.is( !_.fileProvider.fileExists( returned1 ) );
  test.is( !_.fileProvider.fileExists( returned2 ) );
  test.mustNotThrowError( () => _.process.tempClose() )

  if( !Config.debug )
  return;

  test.case = 'unexpected type of sourceCode option';
  test.shouldThrowErrorSync( () =>
  {
    _.process.tempOpen( [] );
  })

  /* */

  test.case = 'unexpected option';
  test.shouldThrowErrorSync( () =>
  {
    _.process.tempOpen({ someOption : true });
  })

  /* */

  test.case = 'try to remove file that does not exist in registry';
  var returned = _.process.tempOpen( testAppCode );
  _.process.tempClose( returned );
  test.shouldThrowErrorSync( () =>
  {
    _.process.tempClose( returned );
  })
}

// --
// other options
// --

function startOptionStreamSizeLimit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let modes = [ 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    a.ready.tap( () => test.open( mode ) )
    a.ready.then( () => run( mode ) )
    a.ready.tap( () => test.close( mode ) )
  })

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = _.take( null );

    ready.then( () =>
    {
      test.case = `data is less than streamSizeLimit ( default )`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 1,
        outputCollecting : 1,
      }

      let returned =  _.process.start( options );
      test.identical( returned.process.stdout.toString(), 'data1\n' );

      a.fileProvider.fileDelete( testAppPath );

      return returned;

    });

    /* */

    ready.then( () =>
    {
      test.case = `data is less than streamSizeLimit ( 20 )`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 1,
        streamSizeLimit : 20,
        outputCollecting : 1,
      }

      let returned =  _.process.start( options );
      test.identical( returned.process.stdout.toString(), 'data1\n' );

      a.fileProvider.fileDelete( testAppPath );

      return returned;

    });

    /* */

    ready.then( () =>
    {
      test.case = `data is equal to the streamSizeLimit`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 1,
        streamSizeLimit : 10,
        outputCollecting : 1,
      }

      let returned =  _.process.start( options );
      test.identical( returned.process.stdout.toString(), 'data1\n' )

      a.fileProvider.fileDelete( testAppPath );
      return returned;

    });

    /* */

    ready.then( () =>
    {
      test.case = `data is bigger than streamSizeLimit`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 1,
        streamSizeLimit : 4,
        outputCollecting : 1,
      }

      let returned = test.shouldThrowErrorSync( () => _.process.start( options ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, `spawnSync ${mode === 'shell' ? 'sh' : 'node' } ENOBUFS` ) )
      test.is( _.strHas( returned.message, `code : 'ENOBUFS'`) )

      test.notIdentical( options.exitCode, 0 );

      a.fileProvider.fileDelete( testAppPath );
      return null;

    });

    return ready;
  }

  /* - */

  function testApp()
  {
    console.log( 'data1' );
  }
}

//

function startOptionStreamSizeLimitThrowing( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let modes = [ 'spawn', 'shell' ];

  a.ready.then( () =>
  {
    test.case = `mode : 'fork', deasync : 1, limit : 100`;

    let testAppPath = a.path.nativize( a.program( testApp ) );

    let options =
    {
      execPath : 'node ' + testAppPath,
      mode : 'fork',
      deasync : 1,
      streamSizeLimit : 100,
      outputCollecting : 1,
    }

    let returned = test.shouldThrowErrorSync( () => _.process.start( options ) )

    test.is( _.errIs( returned ) );
    test.is( _.strHas( returned.message, `Option::streamSizeLimit is supported in mode::spawn and mode::shell with sync::1` ) )

    test.notIdentical( options.exitCode, 0 );

    a.fileProvider.fileDelete( testAppPath );

    return null;
  } )

  /* */

  modes.forEach( ( mode ) =>
  {
    a.ready.tap( () => test.open( mode ) )
    a.ready.then( () => run( mode ) )
    a.ready.tap( () => test.close( mode ) )
  })

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = _.take( null );

    /* */

    ready.then( () =>
    {
      test.case = `sync : 1, limit : '100'`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 1,
        streamSizeLimit : '100',
        outputCollecting : 1,
      }

      let returned = test.shouldThrowErrorSync( () => _.process.start( options ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, `Option::streamSizeLimit must be a positive Number which is greater than zero` ) )

      test.notIdentical( options.exitCode, 0 );

      a.fileProvider.fileDelete( testAppPath );
      return null;

    });

    /* */

    ready.then( () =>
    {
      test.case = `sync : 1, limit : -1`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 1,
        streamSizeLimit : -1,
        outputCollecting : 1,
      }

      let returned = test.shouldThrowErrorSync( () => _.process.start( options ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, `Option::streamSizeLimit must be a positive Number which is greater than zero` ) )

      test.notIdentical( options.exitCode, 0 );

      a.fileProvider.fileDelete( testAppPath );
      return null;

    });

    /* */

    ready.then( () =>
    {
      test.case = `sync : 0, limit : 100`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 0,
        streamSizeLimit : 100,
        outputCollecting : 1,
      }

      let returned = test.shouldThrowErrorSync( () => _.process.start( options ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, `Option::streamSizeLimit is supported in mode::spawn and mode::shell with sync::1` ) )

      test.notIdentical( options.exitCode, 0 );

      a.fileProvider.fileDelete( testAppPath );
      return null;

    });

    /* */

    ready.then( () =>
    {
      test.case = `sync : 0, deasync : 1, limit : 100`;

      let testAppPath = a.path.nativize( a.program( testApp ) );

      let options =
      {
        execPath : 'node ' + testAppPath,
        mode,
        sync : 0,
        deasync : 1,
        streamSizeLimit : 100,
        outputCollecting : 1,
      }

      let returned = test.shouldThrowErrorSync( () => _.process.start( options ) )

      test.is( _.errIs( returned ) );
      test.is( _.strHas( returned.message, `Option::streamSizeLimit is supported in mode::spawn and mode::shell with sync::1` ) )

      test.notIdentical( options.exitCode, 0 );

      a.fileProvider.fileDelete( testAppPath );
      return null;

    });

    return ready;
  }

  /* - */

  function testApp()
  {
    console.log( 'data1' );
  }
}

//

function startOptionDry( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( testApp );

  /*  */

  a.ready.then( () =>
  {
    test.case = 'trivial'
    let o =
    {
      execPath : 'node ' + programPath + ` arg1 "arg 2" "'arg3'"`,
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
    var returned = _.process.start( o );
    test.is( _.consequenceIs( returned ) );
    returned.then( function( op )
    {
      var t2 = _.time.now();
      test.ge( t2 - t1, 1000 )

      test.identical( op.exitCode, null );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, null );
      test.identical( op.process, null );
      test.identical( op.stdio, [ 'pipe', 'pipe', 'pipe', 'ipc' ] );
      test.identical( op.fullExecPath, `node ${programPath} arg1 arg 2 'arg3' arg0` );
      test.identical( op.output, '' );

      test.is( !a.fileProvider.fileExists( a.path.join( a.routinePath, 'file' ) ) )

      return op;
    })
    return returned;
  })

  /*  */

  return a.ready;

  /* - */

  function testApp()
  {
    var fs = require( 'fs' );
    var path = require( 'path' );
    var filePath = path.join( __dirname, 'file' );
    fs.writeFileSync( filePath, filePath );
  }
}

startOptionDry.description =
`
Simulates run of routine start with all possible options.
After execution checks fields of run descriptor.
`

//

/* qqq for Yevhen : split by modes | aaa : Done. Yevhen S.
qqq for Yevhen : not really
*/

function startOptionCurrentPath( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testFilePath = a.path.join( a.routinePath, 'program1TestFile' );
  let locals = { testFilePath };
  let programPath = a.program({ routine : program1, locals });
  let modes = [ 'shell', 'spawn', 'fork' ]

  modes.forEach( ( mode ) =>
  {
    a.ready.tap( () => test.open( mode ) )
    a.ready.then( () => run( mode ) )
    a.ready.tap( () => test.close( mode ) )
  })

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( function()
    {
      let o =
      {
        execPath :  mode !== 'fork' ? 'node ' + programPath : programPath,
        currentPath : __dirname,
        mode,
        stdio : 'pipe',
        outputCollecting : 1,
      }
      return _.process.start( o )
      .then( function( op )
      {
        let got = a.fileProvider.fileRead( testFilePath );
        test.identical( got, __dirname );
        return null;
      })
    })

    /* */

    ready.then( function()
    {
      test.case = 'normalized, currentPath leads to root of current drive';

      let trace = a.path.traceToRoot( a.path.normalize( __dirname ) );
      let currentPath = trace[ 1 ];

      let o =
      {
        execPath :  mode !== 'fork' ? 'node ' + programPath : programPath,
        currentPath,
        mode,
        stdio : 'pipe',
        outputCollecting : 1,
      }

      return _.process.start( o )
      .then( function( op )
      {
        let got = a.fileProvider.fileRead( testFilePath );
        test.identical( got, a.path.nativize( currentPath ) );
        return null;
      })
    })

    /* */

    ready.then( function()
    {
      test.case = 'normalized with slash, currentPath leads to root of current drive';

      let trace = a.path.traceToRoot( a.path.normalize( __dirname ) );
      let currentPath = trace[ 1 ] + '/';

      let o =
      {
        execPath :  mode !== 'fork' ? 'node ' + programPath : programPath,
        currentPath,
        mode,
        stdio : 'pipe',
        outputCollecting : 1,
      }

      return _.process.start( o )
      .then( function( op )
      {
        let got = a.fileProvider.fileRead( testFilePath );
        if( process.platform === 'win32')
        test.identical( got, a.path.nativize( currentPath ) );
        else
        test.identical( got, trace[ 1 ] );
        return null;
      })
    })

    /* */

    ready.then( function()
    {
      test.case = 'nativized, currentPath leads to root of current drive';

      let trace = a.path.traceToRoot( __dirname );
      let currentPath = a.path.nativize( trace[ 1 ] )

      let o =
      {
        execPath :  mode !== 'fork' ? 'node ' + programPath : programPath,
        currentPath,
        mode,
        stdio : 'pipe',
        outputCollecting : 1,
      }

      return _.process.start( o )
      .then( function( op )
      {
        let got = a.fileProvider.fileRead( testFilePath );
        test.identical( got, currentPath )
        return null;
      })
    })

    return ready;
  }



  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.fileProvider.fileWrite( testFilePath, process.cwd() );
  }

}

//

/* qqq for Yevhen : try to introduce subroutine for modes */
function startOptionCurrentPaths( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( testApp ) );

  let o2 =
  {
    execPath : 'node ' + programPath,
    ready : a.ready,
    currentPath : [ a.routinePath, __dirname ],
    stdio : 'pipe',
    outputCollecting : 1
  }

  /* */

  _.process.start( _.mapSupplement( { mode : 'shell' }, o2 ) );

  a.ready.then( ( op ) =>
  {
    let o1 = op.runs[ 0 ];
    let o2 = op.runs[ 1 ];

    test.is( _.strHas( o1.output, a.path.nativize( a.routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    return op;
  })

  /* */

  _.process.start( _.mapSupplement( { mode : 'spawn' }, o2 ) );

  a.ready.then( ( op ) =>
  {
    let o1 = op.runs[ 0 ];
    let o2 = op.runs[ 1 ];

    test.is( _.strHas( o1.output, a.path.nativize( a.routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    return op;
  })

  /* */

  _.process.start( _.mapSupplement( { mode : 'fork', execPath : programPath }, o2 ) );

  a.ready.then( ( op ) =>
  {
    let o1 = op.runs[ 0 ];
    let o2 = op.runs[ 1 ];

    test.is( _.strHas( o1.output, a.path.nativize( a.routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    return op;
  })

  /*  */

  _.process.start( _.mapSupplement( { mode : 'spawn', execPath : [ 'node ' + programPath, 'node ' + programPath ] }, o2 ) );

  a.ready.then( ( op ) =>
  {
    let o1 = op.runs[ 0 ];
    let o2 = op.runs[ 1 ];
    let o3 = op.runs[ 2 ];
    let o4 = op.runs[ 3 ];

    test.is( _.strHas( o1.output, a.path.nativize( a.routinePath ) ) );
    test.identical( o1.exitCode, 0 );

    test.is( _.strHas( o2.output, __dirname ) );
    test.identical( o2.exitCode, 0 );

    test.is( _.strHas( o3.output, a.path.nativize( a.routinePath ) ) );
    test.identical( o3.exitCode, 0 );

    test.is( _.strHas( o4.output, __dirname ) );
    test.identical( o4.exitCode, 0 );

    return op;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    console.log( process.cwd() );
  }
}

//

/* qqq for Yevhen : no need to pass 3 arguments | aaa : Removed */
function startOptionPassingThrough( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath1 = a.path.nativize( a.program( program1 ) );
  let testAppPath2 = a.path.nativize( a.program( program2 ) );

  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  /*
   program1 spawns program2 with options read from op.js
   Options for program2 are provided to program1 through file op.js.
   This method is used instead of ipc messages because second method requires to call process.disconnect in program1,
   otherwise program1 will not exit after termination of program2.
   File op.js is written on each test case, before spawn of program1
   Also, this method is used to exclude output of program2 from tester in case when stdio:inherit is used
  */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.open( `mode : ${ mode }` );
      test.open( '0 args to parent process' );
      return null;
    } );

    /* ORIGINAL BASIS*/

    // let programPath = a.path.nativize( a.program( testApp ) );

    // let o3 =
    // {
    //   outputPiping : 1,
    //   outputCollecting : 1,
    //   applyingExitCode : 0,
    //   throwingExitCode : 1
    // }

    // let o2;

    // function testApp()
    // {
    //   console.log( process.argv.slice( 2 ).join( ' ' ) );
    // }

    /* ORIGINAL */
    // a.ready.then( function()
    // {
    //   test.case = 'mode : spawn, passingThrough : true, only filePath in args';

    //   o2 =
    //   {
    //     execPath :  'node',
    //     args : [ programPath ],
    //     mode : 'spawn',
    //     passingThrough : 1,
    //     stdio : 'pipe'
    //   }
    //   return null;
    // })
    // .then( function( arg )
    // {
    //   /* mode : spawn, stdio : pipe, passingThrough : true */

    //   var options = _.mapSupplement( null, o2, o3 );

    //   return _.process.start( options )
    //   .then( function()
    //   {
    //     test.identical( options.exitCode, 0 );
    //     var expectedArgs = _.arrayAppendArray( [], process.argv.slice( 2 ) );
    //     test.identical( options.output, expectedArgs.join( ' ' ) + '\n' );
    //     return null;
    //   })
    // })

    /* REWRITTEN */
    /* PASSING */
    ready.then( () =>
    {
      test.case = 'args to child = `testAppPath2`';
      let o =
      {
        execPath : mode === 'fork' ? null : 'node ',
        args : [ testAppPath2 ],
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[]\n` );
        return null;
      })

      return o2.conTerminate;
    })

    /* */

    /* ORIGINAL */
    // a.ready.then( function()
    // {
    //   test.case = 'mode : shell, passingThrough : true, no args';

    //   o2 =
    //   {
    //     execPath :  'node ' + programPath,
    //     mode : 'shell',
    //     passingThrough : 1,
    //     stdio : 'pipe'
    //   }

    //   return null;
    // })
    // .then( function( arg )
    // {
    //   /* mode : shell, stdio : pipe, passingThrough : true */

    //   var options = _.mapSupplement( null, o2, o3 );

    //   return _.process.start( options )
    //   .then( function()
    //   {
    //     test.identical( options.exitCode, 0 );
    //     var expectedArgs= _.arrayAppendArray( [], process.argv.slice( 2 ) );
    //     test.identical( options.output, expectedArgs.join( ' ' ) + '\n' );
    //     return null;
    //   })
    // })

    /* REWRITTEN */
    /* PASSING */
    ready.then( () =>
    {
      test.case = 'args to child : none';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 : 'node ' + testAppPath2,
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.case = 'args to child : a';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 : 'node ' + testAppPath2,
        args : 'a',
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ \'a\' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /*  */

    /* ORIGINAL */
    // a.ready.then( function()
    // {
    //   test.case = 'mode : shell, passingThrough : true';

    //   o2 =
    //   {
    //     execPath :  'node ' + programPath,
    //     args : [ 'staging', 'debug' ],
    //     mode : 'shell',
    //     passingThrough : 1,
    //     stdio : 'pipe'
    //   }
    //   return null;
    // })
    // .then( function( arg )
    // {
    //   /* mode : shell, stdio : pipe, passingThrough : true */

    //   var options = _.mapSupplement( null, o2, o3 );

    //   return _.process.start( options )
    //   .then( function()
    //   {
    //     test.identical( options.exitCode, 0 );
    //     var expectedArgs = _.arrayAppendArray( [ 'staging', 'debug' ], process.argv.slice( 2 ) );
    //     test.identical( options.output, expectedArgs.join( ' ' ) + '\n');
    //     return null;
    //   })
    // })


    /* REWRITTEN */
    /* PASSING */
    ready.then( () =>
    {
      test.case = 'args to child : a, b, c';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 : 'node ' + testAppPath2,
        args : [ 'a', 'b', 'c' ],
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ \'a\', \'b\', \'c\' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.case = 'args to child in execPath: a, b, c';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 + ' a b c' : 'node ' + testAppPath2 + ' a b c',
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ \'a\', \'b\', \'c\' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.case = 'args to child in execPath: a and in args : b, c';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 + ' a' : 'node ' + testAppPath2 + ' a',
        args : [ 'b', 'c' ],
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ \'a\', \'b\', \'c\' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.close( '0 args to parent process' );
      return null;
    } )

    /* - */

    ready.then( () =>
    {
      test.open( '1 arg to parent process' );
      return null;
    } );

    ready.then( () =>
    {
      test.case = 'args to child : none; args to parent : parentA';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 : 'node ' + testAppPath2,
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        args : 'parentA',
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ 'parentA' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.case = 'args to child : a; args to parent : parentA';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 : 'node ' + testAppPath2,
        args : 'a',
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        args : 'parentA',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ 'a', 'parentA' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /*  */

    ready.then( () =>
    {
      test.case = 'args to child : a, b, c; args to parent : parentA';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 : 'node ' + testAppPath2,
        args : [ 'a', 'b', 'c' ],
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1,
        mode : 'spawn',
        args : 'parentA',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ 'a', 'b', 'c', 'parentA' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.case = 'args to child in execPath: a, b, c; args to parent in execPath : parentA';

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 + ' a b c' : 'node ' + testAppPath2 + ' a b c',
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1 + ' parentA',
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ 'a', 'b', 'c', 'parentA' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.case = 'args to child in execPath: a and in args : b, c; args to parent in execPath : parentA, and in args : empty array'

      let o =
      {
        execPath : mode === 'fork' ? testAppPath2 + ' a' : 'node ' + testAppPath2 + ' a',
        args : [ 'b', 'c' ],
        outputCollecting : 0,
        outputPiping : 0,
        mode,
        throwingExitCode : 0,
        applyingExitCode : 0,
        stdio : 'inherit'
      }
      a.fileProvider.fileWrite({ filePath : a.abs( 'op.json' ), data : o, encoding : 'json' });

      let o2 =
      {
        execPath : 'node ' + testAppPath1 + ' parentA',
        args : [],
        mode : 'spawn',
        stdio : 'pipe',
        outputPiping : 1,
        outputCollecting : 1,
      }
      _.process.start( o2 );

      o2.conTerminate.then( () =>
      {
        test.identical( o2.output, `[ 'a', 'b', 'c', 'parentA' ]\n` );
        return null;
      });

      return o2.conTerminate;
    })

    /* */

    ready.then( () =>
    {
      test.close( '1 arg to parent process' );
      return null;
    } )

    /* - */

    ready.then( () =>
    {
      test.close( `mode : ${ mode }` );
      return null;
    })

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wProcess' );

    let o = _.fileProvider.fileRead({ filePath : _.path.join( __dirname, 'op.json' ), encoding : 'json' });
    o.currentPath = __dirname;
    _.process.startPassingThrough( o );
  }

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );
    _.include( 'wProcess' );

    console.log( process.argv.slice( 2 ) );
  }
}

startOptionPassingThrough.timeOut = 5e5;

// --
// pid
// --

function startDiffPid( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testFilePath = a.abs( a.routinePath, 'testFile' );
  let modes = [ 'fork', 'spawn', 'shell' ];

  modes.forEach( ( mode ) =>
  {
    a.ready.then( () =>
    {
      a.fileProvider.filesDelete( a.routinePath );
      let locals =
      {
        mode,
      }
      a.path.nativize( a.program({ routine : testAppParent, locals }) );
      a.path.nativize( a.program( testAppChild ) );
      return null;
    })

    a.ready.tap( () => test.open( mode ) );
    a.ready.then( () => run( mode ) );
    a.ready.tap( () => test.close( mode ) );
  });

  return a.ready;

  /* - */

  function run( mode )
  {
    let ready = new _.Consequence().take( null )

    /*  */

    ready.then( () =>
    {
      test.case = 'process termination begins after short delay, detached process should continue to work after parent death';

      a.fileProvider.filesDelete( testFilePath );
      a.fileProvider.dirMakeForFile( testFilePath );

      let o =
      {
        execPath : 'node testAppParent.js stdio : ignore outputPiping : 0 outputCollecting : 0',
        mode : 'spawn',
        outputCollecting : 1,
        currentPath : a.routinePath,
        ipc : 1,
      }
      let con = _.process.start( o );
      let data;

      o.process.on( 'message', ( e ) =>
      {
        data = e;
        data.childPid = _.numberFrom( data.childPid );
      })

      con.then( ( op ) =>
      {
        test.will = 'parent is dead, child is still alive';
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.is( !_.process.isAlive( op.process.pid ) );
        test.is( _.process.isAlive( data.childPid ) );
        return _.time.out( context.t2 * 2 );
      })

      con.then( () =>
      {
        test.will = 'both dead';

        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( data.childPid ) );

        test.is( a.fileProvider.fileExists( testFilePath ) );
        let childPid = a.fileProvider.fileRead( testFilePath );
        childPid = _.numberFrom( childPid );
        console.log(  childPid );
        /* if shell then could be 2 processes, first - terminal, second application */
        if( mode !== 'shell' )
        test.identical( data.childPid, childPid );
        console.log( `${mode} : PID is ${ data.childPid === childPid ? 'same' : 'different' }` );

        return null;
      })

      return con;
    })

    /*  */

    return ready;
  }

  /*  */

  function testAppParent()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let args = _.process.input();

    let o =
    {
      execPath : mode === 'fork' ? 'testAppChild.js' : 'node testAppChild.js',
      mode,
      detaching : true,
    }

    _.mapExtend( o, args.map );
    if( o.ipc !== undefined )
    o.ipc = _.boolFrom( o.ipc );

    _.process.start( o );

    console.log( o.process.pid )

    process.send({ childPid : o.process.pid });

    o.conStart.thenGive( () =>
    {
      _.procedure.terminationBegin();
    })
  }

  function testAppChild()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    console.log( 'Child process start', process.pid );
    _.time.out( context.t1 * 2, () => /* 2000 */
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

startDiffPid.timeOut = 180000;

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
  test.shouldThrowErrorSync( () => _.process.pidFrom( { pnd : {} } ) );
  test.shouldThrowErrorSync( () => _.process.pidFrom( '123' ) );

  return ready;
}

//

function isAlive( test )
{
  let track = [];
  let o =
  {
    execPath : `node -e "setTimeout( () => { console.log( 'child terminate' ) }, 3000 )"`,
  }
  _.process.start( o );

  o.conStart.then( () =>
  {
    track.push( 'conStart' );
    test.identical( _.process.isAlive( o ), true );
    test.identical( _.process.isAlive( o.process ), true );
    test.identical( _.process.isAlive( o.process.pid ), true );
    return null;
  })

  o.conTerminate.then( () =>
  {
    track.push( 'conTerminate' );
    test.identical( _.process.isAlive( o ), false );
    test.identical( _.process.isAlive( o.process ), false );
    test.identical( _.process.isAlive( o.process.pid ), false );
    test.identical( track, [ 'conStart', 'conTerminate' ] )
    return null;
  })

  let ready = _.Consequence.AndKeep( o.conStart, o.conTerminate );

  if( !Config.debug )
  return ready;

  ready.then( () =>
  {
    test.shouldThrowErrorSync( () => _.process.isAlive() );
    test.shouldThrowErrorSync( () => _.process.isAlive( [] ) );
    test.shouldThrowErrorSync( () => _.process.isAlive( {} ) );
    test.shouldThrowErrorSync( () => _.process.isAlive( { pnd : {} } ) );
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
  let track = [];
  _.process.start( o );

  o.conStart.then( () =>
  {
    track.push( 'conStart' )
    test.identical( _.process.statusOf( o ), 'alive' );
    test.identical( _.process.statusOf( o.process ), 'alive' );
    test.identical( _.process.statusOf( o.process.pid ), 'alive' );
    return null;
  })

  o.conTerminate.then( () =>
  {
    track.push( 'conTerminate' );
    test.identical( _.process.statusOf( o ), 'dead' );
    test.identical( _.process.statusOf( o.process ), 'dead' );
    test.identical( _.process.statusOf( o.process.pid ), 'dead' );
    test.identical( track, [ 'conStart', 'conTerminate' ] );
    return null;
  })

  let ready = _.Consequence.AndKeep( o.conStart, o.conTerminate );

  if( !Config.debug )
  return ready;

  ready.then( () =>
  {
    test.shouldThrowErrorSync( () => _.process.statusOf() );
    test.shouldThrowErrorSync( () => _.process.statusOf( [] ) );
    test.shouldThrowErrorSync( () => _.process.statusOf( {} ) );
    test.shouldThrowErrorSync( () => _.process.statusOf( { pnd : {} } ) );
    test.shouldThrowErrorSync( () => _.process.statusOf( '123' ) );

    return null;
  })

  return ready;
}

//

// function exitReason( test )
// {
//   test.case = 'initial value'
//   var got = _.process.exitReason();
//   test.identical( got, null );
//
//   /* */
//
//   test.case = 'set reason'
//   _.process.exitReason( 'reason' );
//   var got = _.process.exitReason();
//   test.identical( got, 'reason' );
//
//   /* */
//
//   test.case = 'update reason'
//   _.process.exitReason( 'reason2' );
//   var got = _.process.exitReason();
//   test.identical( got, 'reason2' );
// }

//

/* qqq for Yevhen : poor tests, please extend it | aaa : Done */
function exitCode( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.open( `mode : ${ mode }` );
      return null
    })

    ready.then( () =>
    {
      test.case = 'initial value';
      let locals =
      {
        code : null
      }
      let programPath = a.program({ routine : testAppExitCode, locals });
      let options =
      {
        execPath : mode === 'fork' ? a.path.nativize( programPath ) : 'node ' + a.path.nativize( programPath ),
        throwingExitCode : 0,
        mode
      }
      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );

        a.fileProvider.fileDelete( programPath );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = 'set code';
      let locals =
      {
        code : 1
      }
      let programPath = a.program({ routine : testAppExitCode, locals});
      let options =
      {
        execPath : mode === 'fork' ? a.path.nativize( programPath ) : 'node ' + a.path.nativize( programPath ),
        throwingExitCode : 0,
        mode
      }
      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );

        a.fileProvider.fileDelete( programPath );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = 'update reason';
      let locals =
      {
        code : 2
      }
      let programPath = a.program({ routine : testAppExitCode, locals});
      let options =
      {
        execPath : mode === 'fork' ? a.path.nativize( programPath ) : 'node ' + a.path.nativize( programPath ),
        throwingExitCode : 0,
        mode
      }
      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 2 );
        test.identical( op.ended, true );

        a.fileProvider.fileDelete( programPath );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = 'wrong execPath'

      if( mode === 'spawn' )
      return test.shouldThrowErrorAsync( _.process.start({ execPath : '1', throwingExitCode : 0, mode }) );

      return _.process.start({ execPath : '1', throwingExitCode : 0, mode })
      .then( ( op ) =>
      {
        // if( process.platform === 'win32' )
        // test.identical( op.exitCode, 1 );
        // else
        // test.identical( op.exitCode, 127 );
        test.ni( op.exitCode, 0 )
        test.identical( op.ended, true );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = 'throw error in app';
      let programPath = a.program( testAppError );
      let options =
      {
        execPath : mode === 'fork' ? a.path.nativize( programPath ) : 'node ' + a.path.nativize( programPath ),
        throwingExitCode : 0,
        mode
      }
      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );

        a.fileProvider.fileDelete( programPath );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = 'error in subprocess';
      let programPath = a.program({ routine : testApp, locals : { options : null } })
      let options =
      {
        execPath : mode === 'fork' ? a.path.nativize( programPath ) : 'node ' + a.path.nativize( programPath ),
        throwingExitCode : 0,
        mode
      }
      return _.process.start( options )
      .then( ( op ) =>
      {
        if( process.platform === 'win32' )
        test.notIdentical( op.exitCode, 0 )// returns 4294967295 which is -1 to uint32
        else
        test.identical( op.exitCode, 255 );
        test.identical( op.ended, true );

        a.fileProvider.fileDelete( programPath );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = 'no error in subprocess';
      let locals =
      {
        options : { execPath : 'echo' }
      }
      let programPath = a.program({ routine : testApp, locals });
      let options =
      {
        execPath : mode === 'fork' ? a.path.nativize( programPath ) : 'node ' + a.path.nativize( programPath ),
        throwingExitCode : 0,
        mode
      }
      return _.process.start( options )
      .then( ( op ) =>
      {
        test.il( op.exitCode, 0 );
        test.il( op.ended, true );

        a.fileProvider.fileDelete( programPath );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.case = 'explicitly exit with code : 100';
      let locals =
      {
        code : 100
      }
      let programPath = a.program({ routine : testAppExit, locals});
      let options =
      {
        execPath : mode === 'fork' ? a.path.nativize( programPath ) : 'node ' + a.path.nativize( programPath ),
        throwingExitCode : 0,
        mode
      }
      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 100 );
        test.identical( op.ended, true );

        a.fileProvider.fileDelete( programPath );
        return null;
      } )
    })

    /* */

    ready.then( () =>
    {
      test.close( `mode : ${ mode }` );
      return null;
    } )

    return ready;
  }

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    return _.process.start( options );
  }

  function testAppError()
  {
    throw new Error();
  }

  function testAppExit()  /* qqq for Yevhen : should be no subsubroutines | aaa : Moved  */
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    return _.process.exit( code );
  }

  function testAppExitCode()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    if( code )
    return _.process.exitCode( code );

    return _.process.exitCode();
  }

}

// --
// termination
// --

function startOptionVerbosityLogging( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );

  return a.ready;

  /* */

  function run( mode )
  {
    let ready = new _.Consequence().take( null );

    ready.then( () =>
    {
      test.case = `logging without error; mode : ${mode}; verbosity : 4`;
      let testAppPath2 = a.program( testApp2 );
      let locals = { programPath : testAppPath2, verbosity : 4 };
      let testAppPath = a.program( { routine : testApp, locals } );

      let options =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        throwingExitCode : 0,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        test.identical( op.state, 'terminated' );
        test.identical( _.strCount( op.output, '< Process returned error code 0' ), 0 );
        test.identical( _.strCount( op.output, `Launched as "node ${ testAppPath2 }"` ), 0 );
        test.identical( _.strCount( op.output, `Launched at ${ _.strQuote( op.currentPath ) }` ), 0 );
        test.identical( _.strCount( op.output, '-> Stderr' ), 0 );
        test.identical( _.strCount( op.output, '-< Stderr' ), 0 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      } )

    })

    /* */

    ready.then( () =>
    {
      test.case = `logging with error; mode : ${mode}; verbosity : 4`;
      let testAppPathError = a.program( testAppError );
      let locals = { programPath : testAppPathError, verbosity : 4 };
      let testAppPath = a.program( { routine : testApp, locals } );

      let options =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        throwingExitCode : 0,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        test.identical( op.state, 'terminated' );
        test.identical( _.strCount( op.output, '< Process returned error code 255' ), 0 );
        test.identical( _.strCount( op.output, `Launched as "node ${ testAppPathError }"` ), 0 );
        test.identical( _.strCount( op.output, `Launched at ${ _.strQuote( op.currentPath ) }` ), 0 );
        test.identical( _.strCount( op.output, '-> Stderr' ), 0 );
        test.is( !_.strHas( op.output, '= Message of error' ) );
        test.is( !_.strHas( op.output, '= Beautified calls stack' ) );
        test.is( !_.strHas( op.output, '= Throws stack' ) );
        test.is( !_.strHas( op.output, '= Process' ) );
        test.is( !_.strHas( op.output, 'Source code from' ) );
        test.identical( _.strCount( op.output, '-< Stderr' ), 0 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPathError );

        return null;
      } )

    })

    /* */

    ready.then( () =>
    {
      test.case = `logging without error; mode : ${mode}; verbosity : 5`;
      let testAppPath2 = a.program( testApp2 );
      let locals = { programPath : testAppPath2, verbosity : 5 };
      let testAppPath = a.program( { routine : testApp, locals } );

      let options =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        throwingExitCode : 0,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        test.identical( op.state, 'terminated' );
        test.identical( _.strCount( op.output, '< Process returned error code 0' ), 1 );
        test.identical( _.strCount( op.output, `Launched as "node ${ testAppPath2 }"` ), 0 );
        test.identical( _.strCount( op.output, `Launched at ${ _.strQuote( op.currentPath ) }` ), 0 );
        test.identical( _.strCount( op.output, '-> Stderr' ), 0 );
        test.identical( _.strCount( op.output, '-< Stderr' ), 0 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPath2 );

        return null;
      } )

    })

    /* */

    ready.then( () =>
    {
      test.case = `logging with error; mode : ${mode}; verbosity : 5`;
      let testAppPathError = a.program( testAppError );
      let locals = { programPath : testAppPathError, verbosity : 5 };
      let testAppPath = a.program( { routine : testApp, locals } );

      let options =
      {
        execPath : mode === 'fork' ? testAppPath : 'node ' + testAppPath,
        mode,
        throwingExitCode : 0,
        outputCollecting : 1,
      }

      return _.process.start( options )
      .then( ( op ) =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        test.identical( op.state, 'terminated' );
        // Windows returns 4294967295 which is -1 to uint32
        if( process.platform === 'win32' )
        test.identical( _.strCount( op.output, '< Process returned error code 4294967295' ), 1 );
        else
        test.identical( _.strCount( op.output, '< Process returned error code 255' ), 1 );
        test.identical( _.strCount( op.output, `Launched as "node ${ testAppPathError }"` ), 1 );
        test.identical( _.strCount( op.output, `Launched at ${ _.strQuote( op.currentPath ) }` ), 1 );
        test.identical( _.strCount( op.output, '-> Stderr' ), 1 );
        test.is( _.strHas( op.output, '= Message of error' ) );
        test.is( _.strHas( op.output, '= Beautified calls stack' ) );
        test.is( _.strHas( op.output, '= Throws stack' ) );
        test.is( _.strHas( op.output, '= Process' ) );
        test.is( _.strHas( op.output, 'Source code from' ) );
        test.identical( _.strCount( op.output, '-< Stderr' ), 1 );

        a.fileProvider.fileDelete( testAppPath );
        a.fileProvider.fileDelete( testAppPathError );

        return null;
      } )

    })

    return ready;
  }

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    let options =
    {
      execPath : 'node ' + programPath,
      throwingExitCode : 0,
      outputCollecting : 0,
      outputPiping : 0,
      verbosity
    }

    return _.process.start( options );
  }

  function testApp2()
  {
    console.log();
  }

  function testAppError()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    return _.process.start();
  }

}

//

function startOutputMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let track = [];
  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 0, deasync : 0, mode }) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 0, deasync : 1, mode }) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 1, deasync : 0, mode }) ) );
  modes.forEach( ( mode ) => a.ready.then( () => run({ sync : 1, deasync : 1, mode }) ) );
  return a.ready;

  /* - */

  function run( tops )
  {
    let ready = new _.Consequence().take( null )

    if( tops.sync && !tops.deasync && tops.mode === 'fork' )
    return null;

    /* */

    ready.then( () =>
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} concurrent:0 mode:${tops.mode}`;
      track = [];
      let t1 = _.time.now();
      let ready2 = new _.Consequence().take( null ).delay( context.t1 / 10 );
      let o =
      {
        execPath : [ ( tops.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:1`, ( tops.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputPiping : 1,
        outputCollecting : 1,
        outputAdditive : 1,
        sync : tops.sync,
        deasync : tops.deasync,
        concurrent : 0,
        mode : tops.mode,
        ready : ready2,
      }

      let returned = _.process.start( o );

      o.conStart.tap( ( err, op ) =>
      {
        track.push( 'conStart' );
        test.is( op === o );
        processPipe( o, 0 );
      });

      o.conTerminate.tap( ( err, op ) =>
      {
        track.push( 'conTerminate' );
        test.is( op === o );
      });

      o.ready.then( ( op ) =>
      {
        track.push( 'ready' );

        if( tops.sync || tops.deasync )
        {
          var exp =
          [
            'conStart',
            'conTerminate',
            'ready',
          ]
          test.identical( track, exp );
        }
        else
        {
          /* xxx : double check later
          on older version of nodejs event finish goes before event end
          */
          var exp1 =
          [
            'conStart',
            '0.out:1::begin',
            '0.out:1::end',
            '0.err:1::err',
            '0.out:2::begin',
            '0.out:2::end',
            '0.err:2::err',
            '0.err.finish',
            '0.err.end',
            '0.out.finish',
            '0.out.end',
            'conTerminate',
            'ready',
          ]
          var exp2 =
          [
            'conStart',
            '0.out:1::begin',
            '0.out:1::end',
            '0.err:1::err',
            '0.out:2::begin',
            '0.out:2::end',
            '0.err:2::err',
            '0.err.end',
            '0.err.finish',
            '0.out.end',
            '0.out.finish',
            'conTerminate',
            'ready',
          ]
          if( _.identical( track, exp1 ) )
          test.identical( track, exp1 );
          else
          test.identical( track, exp2 );
        }

        var exp =
`
1::begin
1::end
1::err
2::begin
2::end
2::err
`
        test.equivalent( op.output, exp );
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        test.is( op === o );

        if( !tops.sync && !tops.deasync )
        test.is( _.longHas( track, '0.out.end' ) );
        test.is( !_.longHas( track, '1.out.end' ) );
        test.is( !_.longHas( track, '2.out.end' ) );

        if( !tops.sync || tops.deasync )
        {
          test.identical( op.streamOut._writableState.ended, true );
          test.identical( op.streamOut._readableState.ended, true );
          test.identical( op.streamErr._writableState.ended, true );
          test.identical( op.streamErr._readableState.ended, true );
        }
        else
        {
          test.is( op.streamOut === null );
          test.is( op.streamErr === null );
        }

        op.runs.forEach( ( op2, counter ) =>
        {
          test.identical( op2.exitCode, 0 );
          test.identical( op2.exitSignal, null );
          test.identical( op2.exitReason, 'normal' );
          test.identical( op2.ended, true );
          let parsed = a.fileProvider.fileRead({ filePath : a.abs( `${counter+1}.json` ), encoding : 'json' });
          test.identical( parsed.id, counter+1 );

          if( !tops.sync || tops.deasync )
          {
            test.identical( op2.streamOut._writableState.ended, false );
            test.identical( op2.streamOut._readableState.ended, true );
            test.identical( op2.streamErr._writableState.ended, false );
            test.identical( op2.streamErr._readableState.ended, true );
          }
          else
          {
            test.is( op2.streamOut === null );
            test.is( op2.streamErr === null );
          }

        });
        return null;
      })

      return o.ready;
    })

    /* */

    ready.then( () =>
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} concurrent:1 mode:${tops.mode}`;
      if( tops.sync && !tops.deasync )
      return null;
      track = [];
      let t1 = _.time.now();
      let ready2 = new _.Consequence().take( null ).delay( context.t1 / 10 );
      let o =
      {
        execPath : [ ( tops.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:1`, ( tops.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputPiping : 1,
        outputCollecting : 1,
        outputAdditive : 1,
        sync : tops.sync,
        deasync : tops.deasync,
        concurrent : 1,
        mode : tops.mode,
        ready : ready2,
      }

      let returned = _.process.start( o );

      o.conStart.tap( ( err, op ) =>
      {
        track.push( 'conStart' );
        test.is( op === o );
        processPipe( o, 0 );
        processPipe( o.runs[ 0 ], 1 );
        processPipe( o.runs[ 1 ], 2 );
      });

      o.conTerminate.tap( ( err, op ) =>
      {
        track.push( 'conTerminate' );
        test.is( op === o );
      });

      o.ready.then( ( op ) =>
      {
        track.push( 'ready' );

        if( tops.sync || tops.deasync )
        {
          var exp =
          [
            'conStart',
            'conTerminate',
            'ready',
          ]
          test.identical( track, exp );
        }
        else
        {
          /* xxx : double check later
          on older version of nodejs event finish goes before event end
          */
          var exp1 =
          [
            'conStart',
            '0.out:1::begin',
            '1.out:1::begin',
            '0.out:2::begin',
            '2.out:2::begin',
            '0.out:1::end',
            '1.out:1::end',
            '0.out:2::end',
            '2.out:2::end',
            '0.err:1::err',
            '1.err:1::err',
            '1.err.end',
            '1.out.end',
            '0.err:2::err',
            '2.err:2::err',
            '0.err.finish',
            '2.err.end',
            '0.err.end',
            '0.out.finish',
            '2.out.end',
            '0.out.end',
            'conTerminate',
            'ready'
          ]
          let exp2 =
          [
            'conStart',
            '0.out:1::begin',
            '1.out:1::begin',
            '0.out:2::begin',
            '2.out:2::begin',
            '0.out:1::end',
            '1.out:1::end',
            '0.out:2::end',
            '2.out:2::end',
            '0.err:1::err',
            '1.err:1::err',
            '1.err.end',
            '1.out.end',
            '0.err:2::err',
            '2.err:2::err',
            '2.err.end',
            '0.err.end',
            '0.err.finish',
            '2.out.end',
            '0.out.end',
            '0.out.finish',
            'conTerminate',
            'ready'
          ]
          if( _.identical( track, exp1 ) )
          test.identical( track, exp1 );
          else
          test.identical( track, exp2 );
        }
        var exp =
`
1::begin
2::begin
1::end
2::end
1::err
2::err
`
        test.equivalent( op.output, exp );

        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        test.is( op === o );

        if( !tops.sync && !tops.deasync )
        {
          test.is( _.longHas( track, '0.out.end' ) );
          test.is( _.longHas( track, '1.out.end' ) );
          test.is( _.longHas( track, '2.out.end' ) );
        }

        if( !tops.sync || tops.deasync )
        {
          test.identical( op.streamOut._writableState.ended, true );
          test.identical( op.streamOut._readableState.ended, true );
          test.identical( op.streamErr._writableState.ended, true );
          test.identical( op.streamErr._readableState.ended, true );
        }
        else
        {
          test.is( op.streamOut === null );
          test.is( op.streamErr === null );
        }

        op.runs.forEach( ( op2, counter ) =>
        {
          test.identical( op2.exitCode, 0 );
          test.identical( op2.exitSignal, null );
          test.identical( op2.exitReason, 'normal' );
          test.identical( op2.ended, true );
          let parsed = a.fileProvider.fileRead({ filePath : a.abs( `${counter+1}.json` ), encoding : 'json' });
          test.identical( parsed.id, counter+1 );

          if( !tops.sync || tops.deasync )
          {
            test.identical( op2.streamOut._writableState.ended, false );
            test.identical( op2.streamOut._readableState.ended, true );
            test.identical( op2.streamErr._writableState.ended, false );
            test.identical( op2.streamErr._readableState.ended, true );
          }
          else
          {
            test.is( op2.streamOut === null );
            test.is( op2.streamErr === null );
          }

        });

        return null;
      })

      return o.ready;
    })

    /* */

    return ready;
  }

  /* - */

  function processPipe( op, id )
  {
    streamPipe( op, op.streamOut, 'out', id );
    streamPipe( op, op.streamErr, 'err', id );
  }

  function streamPipe( op, steam, streamName, id )
  {
    if( op.sync && !op.deasync )
    return;
    steam.on( 'data', ( data ) =>
    {
      if( _.bufferAnyIs( data ) )
      data = _.bufferToStr( data );
      data = data.trim();
      console.log( `${id}.${streamName}`, data );
      track.push( `${id}.${streamName}:` + data );
    });
    steam.on( 'end', ( data ) =>
    {
      console.log( `${id}.${streamName}.end` );
      track.push( `${id}.${streamName}.end` );
    });
    steam.on( 'finish', ( data ) =>
    {
      console.log( `${id}.${streamName}.finish` );
      track.push( `${id}.${streamName}.finish` );
    });
  }

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let args = _.process.input();
    let data = { time : _.time.now(), id : args.map.id };
    _.fileProvider.fileWrite({ filePath : _.path.join(__dirname, `${args.map.id}.json` ), data, encoding : 'json' });
    let sessionDelay = context.t1 * 0.5*args.map.id;
    setTimeout( () => console.log( `${args.map.id}::begin` ), sessionDelay );
    setTimeout( () => console.log( `${args.map.id}::end` ), context.t1+sessionDelay );
    setTimeout( () => console.error( `${args.map.id}::err` ), context.t1*2+sessionDelay );
  }

}

startOutputMultiple.timeOut = 5e5;
startOutputMultiple.description =
`
  - callback of event exit of each stream is called
  - streams of processes are joined
  - output is collected in op.output
`

//

function startOptionStdioIgnoreMultiple( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.path.nativize( a.program( program1 ) );
  let track = [];

  let modes = [ 'fork', 'spawn', 'shell' ];
  let outputAdditives = [ true, false ]

  outputAdditives.forEach( ( outputAdditive ) =>
  {
    a.ready.tap( () => test.open( `outputAdditive:${ outputAdditive }` ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ outputAdditive, sync : 0, deasync : 0, mode }) ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ outputAdditive, sync : 0, deasync : 1, mode }) ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ outputAdditive, sync : 1, deasync : 0, mode }) ) );
    modes.forEach( ( mode ) => a.ready.then( () => run({ outputAdditive, sync : 1, deasync : 1, mode }) ) );
    a.ready.tap( () => test.close( `outputAdditive:${ outputAdditive }` ) );
  });

  return a.ready;

  /* - */

  function run( tops )
  {
    let ready = new _.Consequence().take( null )

    if( tops.sync && !tops.deasync && tops.mode === 'fork' )
    return null;

    /* */

    ready.then( () =>
    {
      test.case = `sync:${tops.sync} deasync:${tops.deasync} mode:${tops.mode} concurrent:0 `;
      track = [];
      let t1 = _.time.now();
      let ready2 = new _.Consequence().take( null ).delay( context.t1 / 10 );
      let o =
      {
        execPath : [ ( tops.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:1`, ( tops.mode !== `fork` ?  `node ` : '' ) + `${programPath} id:2` ],
        currentPath : a.abs( '.' ),
        outputAdditive : tops.outputAdditive,
        stdio : 'ignore',
        sync : tops.sync,
        deasync : tops.deasync,
        concurrent : 0,
        mode : tops.mode,
        ready : ready2,
      }

      let returned = _.process.start( o );

      o.conStart.tap( ( err, op ) =>
      {
        track.push( 'conStart' );
        test.is( op === o );
      });

      o.conTerminate.tap( ( err, op ) =>
      {
        track.push( 'conTerminate' );
        test.is( op === o );
      });

      o.ready.then( ( op ) =>
      {
        track.push( 'ready' );

        var exp =
        [
          'conStart',
          'conTerminate',
          'ready',
        ]
        test.identical( track, exp );

        test.identical( op.output, null );
        test.identical( op.exitCode, 0 );
        test.identical( op.exitSignal, null );
        test.identical( op.exitReason, 'normal' );
        test.identical( op.ended, true );
        test.is( op === o );
        test.is( op.streamOut === null );
        test.is( op.streamErr === null );

        op.runs.forEach( ( op2, counter ) =>
        {
          test.identical( op2.exitCode, 0 );
          test.identical( op2.exitSignal, null );
          test.identical( op2.exitReason, 'normal' );
          test.identical( op2.ended, true );
          test.identical( op2.output, null );
          let parsed = a.fileProvider.fileRead({ filePath : a.abs( `${counter+1}.json` ), encoding : 'json' });
          test.identical( parsed.id, counter+1 );
          test.is( op2.streamOut === null );
          test.is( op2.streamErr === null );
          test.is( op2.process.stdout === null );
          test.is( op2.process.stderr === null );
        });
        return null;
      })

      return o.ready;
    })

    /* */

    return ready;
  }

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    let args = _.process.input();
    let data = { time : _.time.now(), id : args.map.id };
    _.fileProvider.fileWrite({ filePath : _.path.join(__dirname, `${args.map.id}.json` ), data, encoding : 'json' });
    let sessionDelay = context.t1 * 0.5*args.map.id;
    setTimeout( () => console.log( `${args.map.id}::begin` ), sessionDelay );
    setTimeout( () => console.log( `${args.map.id}::end` ), context.t1+sessionDelay );
    setTimeout( () => console.error( `${args.map.id}::err` ), context.t1*2+sessionDelay );
  }

}

startOptionStdioIgnoreMultiple.timeOut = 1e6;
startOptionStdioIgnoreMultiple.description =
`
  - no problems in stdio:ignore mode
`

//

function kill( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );

  /* */

  var expectedOutput = testAppPath + '\n';

  /* */

  a.ready

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t1*2, () => _.process.kill( o.process ) ) /* 1000 */

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, null );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t1*2, () => _.process.kill( o.process.pid ) ) /* 1000 */

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
      }

      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* fork */

  .then( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t1*2, () => _.process.kill( o.process ) ) /* 1000 */

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, null );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t1*2, () => _.process.kill( o.process.pid ) ) /* 1000 */

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
      }

      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* shell */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t1*2, () => _.process.kill( o.process ) ) /* 1000 */

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, null );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t1*2, () => _.process.kill( o.process.pid ) ) /* 1000 */

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
      }

      test.is( !_.strHas( op.output, 'Application timeout!' ) );

      return null;
    })

    return ready;
  })

  // zzz for Vova : find how to simulate EPERM error using process.kill and write test case

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, context.t2 ) /* 5000 */
  }
}

//

/* qqq for Yevhen : subroutine for modes */
function killSync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );

  /*
    zzz : hangs up on Windows with interval below 150 if run in sync mode
  */

  /* */

  a.ready

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o );

    ready.then( ( op ) =>
    {

      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );
      test.identical( op.ended, true );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.kill({ pnd : o.process, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      test.is( !_.process.isAlive( o.process.pid ) );

      result.then( ( arg ) =>
      {
        test.identical( arg, true );
        return ready;
      })

      return result;
    });
  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.exitSignal, null );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGKILL' );
      }

      test.identical( op.ended, true );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.kill({ pid : o.process.pid, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      test.is( !_.process.isAlive( o.process.pid ) );

      result.then( ( arg ) =>
      {
        test.identical( arg, true );
        return ready;
      })

      return result;
    })
  })

  /* fork */

  .then( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );
      test.identical( op.ended, true );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.kill({ pnd : o.process, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      test.is( !_.process.isAlive( o.process.pid ) );

      result.then( ( arg ) =>
      {
        test.identical( arg, true );
        return ready;
      })

      return result;
    })

  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.exitSignal, null );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGKILL' );
      }

      test.identical( op.ended, true );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.kill({ pid : o.process.pid, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      test.is( !_.process.isAlive( o.process.pid ) );

      result.then( ( arg ) =>
      {
        test.identical( arg, true );
        return ready;
      })

      return result;
    })

  })

  /* shell */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    ready.then( ( op ) =>
    {
      /* Same result on Windows because process was killed using pnd, not pid */
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );

      test.identical( op.ended, true );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.kill({ pnd : o.process, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      test.is( !_.process.isAlive( o.process.pid ) );

      result.then( ( arg ) =>
      {
        test.identical( arg, true );
        return ready;
      })

      return result;
    })
  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.exitSignal, null );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGKILL' );
      }

      test.identical( op.ended, true );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );

      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.kill({ pid : o.process.pid, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      test.is( !_.process.isAlive( o.process.pid ) );

      result.then( ( arg ) =>
      {
        test.identical( arg, true );
        return ready;
      })

      return result;
    })
  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    setTimeout( () => { console.log( 'Application timeout!' ) }, context.t1*10 );
  }
}

killSync.timeOut = 5e5;

//

function killOptionWithChildren( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );
  let testAppPath2 = a.program( testApp2 );
  let testAppPath3 = a.program( testApp3 );

  /* */

  a.ready

  .then( () =>
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

    o.process.on( 'message', ( e ) =>
    {
      lastChildPid = _.numberFrom( e );
      killed = _.process.kill({ pid : o.process.pid, withChildren : 1 });
    })

    a.ready.then( ( op ) =>
    {
      return killed.then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( op.exitCode, 1 );
          test.identical( op.ended, true );
          test.identical( op.exitSignal, null );
        }
        else
        {
          test.identical( op.exitCode, null );
          test.identical( op.ended, true );
          test.identical( op.exitSignal, 'SIGKILL' );
        }
        test.identical( _.strCount( op.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( lastChildPid ) );
        return null;
      })
    })

    return ready;
  })

  /* */

  .then( () =>
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

    o.process.on( 'message', ( e ) =>
    {
      lastChildPid = _.numberFrom( e );
      killed = _.process.kill({ pid : lastChildPid, withChildren : 1 });
    })

    ready.then( ( op ) =>
    {
      return killed.then( () =>
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.identical( _.strCount( op.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( lastChildPid ) );
        return null;
      })
    })

    return ready;
  })

  /* */

  .then( () =>
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

    o.process.on( 'message', ( e ) =>
    {
      children = e.map( ( src ) => _.numberFrom( src ) )
      killed = _.process.kill({ pid : o.process.pid, withChildren : 1 });
    })

    ready.then( ( op ) =>
    {
      return killed.then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( op.exitCode, 1 );
          test.identical( op.ended, true );
          test.identical( op.exitSignal, null );
        }
        else
        {
          test.identical( op.exitCode, null );
          test.identical( op.ended, true );
          test.identical( op.exitSignal, 'SIGKILL' );
        }
        test.identical( _.strCount( op.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( children[ 0 ] ) )
        test.is( !_.process.isAlive( children[ 1 ] ) );
        return null;
      })
    })

    return ready;
  })

  /* */

  .then( () =>
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
    o.process.on( 'message', ( e ) =>
    {
      children = e.map( ( src ) => _.numberFrom( src ) )
      killed = _.process.kill({ pid : o.process.pid, withChildren : 1 });
    })

    ready.then( ( op ) =>
    {
      return killed.then( () =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( op.exitCode, 1 );
          test.identical( op.ended, true );
          test.identical( op.exitSignal, null );
        }
        else
        {
          test.identical( op.exitCode, null );
          test.identical( op.ended, true );
          test.identical( op.exitSignal, 'SIGKILL' );
        }
        test.identical( _.strCount( op.output, 'Application timeout' ), 0 );
        test.is( !_.process.isAlive( o.process.pid ) );
        test.is( !_.process.isAlive( children[ 0 ] ) )
        test.is( !_.process.isAlive( children[ 1 ] ) );
        return null;
      })
    })

    return ready;
  })

  /* */

  .then( () =>
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

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node testApp2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'inherit',
      outputPiping : 0,
      outputCollecting : 0,
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
    setTimeout( () => { console.log( 'Application timeout' ) }, context.t2 ) /* 5000 */
  }

  function testApp3()
  {
    let _ = require( toolsPath );
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

}

//

function startErrorAfterTerminationWithSend( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );
  let track;

  let modes = [ 'fork', 'spawn' ];
  modes.forEach( ( mode ) => a.ready.then( () => run( mode ) ) );
  return a.ready;

  /* */

  function run( mode )
  {
    track = [];

    var o =
    {
      execPath : mode !== 'fork' ? 'node' : null,
      args : [ testAppPath ],
      mode,
      ipc : 1,
    }

    _.process.on( 'uncaughtError', uncaughtError_functor( mode ) );

    let result = _.process.start( o );

    o.conStart.then( ( arg ) =>
    {
      track.push( 'conStart' );
      return null
    });

    o.conTerminate.finally( ( err, op ) =>
    {
      track.push( 'conTerminate' );
      test.identical( err, undefined );
      test.identical( op, o );
      test.identical( o.exitCode, 0 );

      test.description = 'Attempt to send data when ipc channel is closed';
      try
      {
        o.process.send( 1 );
      }
      catch( err )
      {
        console.log( err );
      }

/* happens on servers
--------------- uncaught error --------------->

 = Message of error#387
    Channel closed
    code : 'ERR_IPC_CHANNEL_CLOSED'
    Error starting the process
    Exec path : /Users/runner/Temp/ProcessBasic-2020-10-29-8-0-2-841-ad4.tmp/startErrorAfterTerminationWithSend/testApp.js
    Current path : /Users/runner/work/wProcess/wProcess

 = Beautified calls stack
    at ChildProcess.target.send (internal/child_process.js:705:16)
    at wConsequence.<anonymous> (/Users/runner/work/wProcess/wProcess/proto/wtools/abase/l4.test/ProcessBasic.test.s:24677:17) *
    at wConsequence.take (/Users/runner/work/wProcess/wProcess/node_modules/wConsequence/proto/wtools/abase/l9/consequence/Consequence.s:2669:8)
    at end3 (/Users/runner/work/wProcess/wProcess/proto/wtools/abase/l4_process/l3/Execution.s:783:20)
    at end2 (/Users/runner/work/wProcess/wProcess/proto/wtools/abase/l4_process/l3/Execution.s:734:12)
    at ChildProcess.handleClose (/Users/runner/work/wProcess/wProcess/proto/wtools/abase/l4_process/l3/Execution.s:845:7)
    at ChildProcess.emit (events.js:327:22)
    at maybeClose (internal/child_process.js:1048:16)
    at Process.ChildProcess._handle.onexit (internal/child_process.js:288:5)

    at Object.<anonymous> (/Users/runner/work/wProcess/wProcess/node_modules/wTesting/proto/wtools/atop/tester/entry/Exec:11:11)

 = Throws stack
    thrown at ChildProcess.handleError @ /Users/runner/work/wProcess/wProcess/proto/wtools/abase/l4_process/l3/Execution.s:865:13
    thrown at errRefine @ /Users/runner/work/wProcess/wProcess/node_modules/wTools/proto/wtools/abase/l0/l5/fErr.s:120:16

 = Process
    Current path : /Users/runner/work/wProcess/wProcess
    Exec path : /Users/runner/hostedtoolcache/node/14.14.0/x64/bin/node /Users/runner/work/wProcess/wProcess/node_modules/wTesting/proto/wtools/atop/tester/entry/Exec .run proto/** rapidity:-3

--------------- uncaught error ---------------<
*/

      return null;
    })
                                              /* qqq for Yevhen : dont use // for comments when /* is possible to use. replace in all similar places */
    return _.time.out( context.t2 * 2, () => //10000
    {
      test.identical( track, [ 'conStart', 'conTerminate', 'uncaughtError' ] );
      test.identical( o.ended, true );
      test.identical( o.state, 'terminated' );
      test.identical( o.error, null );
      test.identical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
      test.identical( o.process.exitCode, 0 );
      test.identical( o.process.signalCode, null );
    });

  }

  /* - */

  function testApp()
  {
    setTimeout( () => {}, context.t1 ); /* 1000 */
  }

  function uncaughtError_functor( mode )
  {
    return function uncaughtError( e )
    {
      var exp =
  `
  Channel closed
  `
      if( process.platform === 'darwin' )
      exp += `code : 'ERR_IPC_CHANNEL_CLOSED'`

      exp +=
`
  Error starting the process
      Exec path : ${ mode === 'fork' ? '' : 'node ' }${a.abs( 'testApp.js' )}
      Current path : ${a.path.current()}
`
      test.equivalent( e.err.originalMessage, exp )
      _.errAttend( e.err );
      track.push( 'uncaughtError' );
      _.process.off( 'uncaughtError', uncaughtError );
    }
  }

}

startErrorAfterTerminationWithSend.description =
`
  - handleClose receive error after termination of the process
  - error caused by call o.process.send()
  - throws asynchronouse uncahught error
`

//

function startTerminateHangedWithExitHandler( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );

  // if( process.platform === 'win32' )
  // {
  //   // zzz: windows-kill doesn't work correctrly on node 14
  //   // investigate if its possible to use process.kill instead of windows-kill
  //   test.identical( 1, 1 )
  //   return;
  // }

  /* */

  a.ready

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
      _.process.terminate({ pnd : o.process, timeOut : 5000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGTERM' ) );

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
      _.process.terminate({ pnd : o.process, timeOut : 5000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGTERM' ) );

      return null;
    })

    return con;
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.process._exitHandlerRepair();
    process.send( process.pid )
    while( 1 )
    {
      console.log( _.time.now() )
    }
  }
}

startTerminateHangedWithExitHandler.timeOut = 20000;

/* startTerminateHangedWithExitHandler.description =
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

function startTerminateAfterLoopRelease( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );

  // if( process.platform === 'win32' )
  // {
  //   // zzz: windows-kill doesn't work correctrly on node 14
  //   // investigate if its possible to use process.kill instead of windows-kill
  //   test.identical( 1, 1 )
  //   return;
  // }

  /* */

  a.ready

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
      _.process.terminate({ pnd : o.process, timeOut : 10000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGTERM' ) );
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
      _.process.terminate({ pnd : o.process, timeOut : 10000 });
    })

    con.then( () =>
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( o.output, 'SIGTERM' ) );
      test.is( !_.strHas( o.output, 'Exit after release' ) );

      return null;
    })

    return con;
  })

  /*  */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );

    _.include( 'wProcess' );
    _.process._exitHandlerRepair();
    let loop = true;
    setTimeout( () =>
    {
      loop = false;
    }, context.t2 ) /* 5000 */
    process.send( process.pid );
    while( loop )
    {
      loop = loop;
    }
    console.log( 'Exit after release' );
  }
}

startTerminateAfterLoopRelease.description =
`
  Test app - code that blocks event loop for short period of time and appExitHandlerRepair called at start

  Will test:
    - Termination of child process using SIGINT signal after small delay

  Expected behaviour:
    - Child was terminated after event loop release with exitCode : 0, exitSignal : null
    - Child process message should be printed
`

//

function endSignalsBasic( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program1 );
  let o3 =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 0,
    stdio : 'pipe',
  }

  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGQUIT' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGINT' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGTERM' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGHUP' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalKilling( mode, 'SIGKILL' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => terminate( mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => terminateShell( mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => kill( mode ) ) );
  return a.ready;

  /* --- */

  function signalTerminating( mode, signal )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}`;

      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [],
        mode,
      }

      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        var exp2 =
`program1:begin
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
${signal}
`
        var exp2 =
`program1:begin
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withSleep:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        var exp2 =
`program1:begin
sleep:begin
sleep:end
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withSleep:1 withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1`, `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var time1 = _.time.now();
      var returned = _.process.start( options );
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
sleep:end
program1:end
${signal}
`
        var exp2 =
`program1:begin
sleep:begin
sleep:end
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.ge( dtime, context.t1 * 10 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withDeasync:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withDeasync:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
deasync:begin
${signal}
`
        var exp2 =
`program1:begin
deasync:begin
program1:end
deasync:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function signalKilling( mode, signal )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        var exp2 =
`program1:begin
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        var exp2 =
`program1:begin
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withSleep:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var time1;
      var returned = _.process.start( options );
      _.time.out( context.t1 * 4, () =>
      {
        time1 = _.time.now();
        test.identical( options.process.killed, false );
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        var exp2 =
`program1:begin
sleep:begin
sleep:end
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withSleep:1 withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1`, `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        var exp2 =
`program1:begin
sleep:begin
sleep:end
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, ${signal}, withDeasync:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withDeasync:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
deasync:begin
`
        var exp2 =
`program1:begin
deasync:begin
program1:end
deasync:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function terminate( mode )
  {
    let ready = _.Consequence().take( null );

    if( mode === 'shell' )
    return ready;

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate`;

      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
SIGTERM
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withSleep:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withSleep:1 withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1`, `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1, timeOut : context.t1 * 4 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.ge( dtime, context.t1 * 4 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withDeasync:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withDeasync:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
deasync:begin
SIGTERM
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function terminateShell( mode )
  {
    let ready = _.Consequence().take( null );

    /* if shell then parent process may ignore the signal */
    if( mode !== 'shell' )
    return ready;

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
SIGTERM
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withSleep:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withSleep:1 withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1`, `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
sleep:end
program1:end
SIGTERM
`
        var exp2 =
`program1:begin
sleep:begin
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        /*
          on linux has two processes( shell + node ), on mac shell has only node
          on linux shell receives SIGTERM and kills node
          on mac node ignores SIGTERM because of sleep option enabled
        */
        if( process.platform === 'darwin' )
        test.identical( options.exitSignal, 'SIGKILL' );
        else
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        if( process.platform === 'darwin' )
        test.identical( options.process.signalCode, 'SIGKILL' );
        else
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, terminate, withDeasync:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withDeasync:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
deasync:begin
SIGTERM
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function kill( mode )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, kill, pid, withChildren:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.kill({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, kill withTools:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withTools:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.kill( options.process.pid );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        var exp2 =
`program1:begin
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, kill withSleep:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withSleep:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.kill( options.process.pid );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        var exp2 =
`program1:begin
sleep:begin
sleep:end
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, kill withTools:1 withSleep:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withTools:1`, `withSleep:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.kill( options.process.pid );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
sleep:begin
`
        var exp2 =
`program1:begin
sleep:begin
sleep:end
program1:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* */

    .then( function( arg )
    {
      test.case = `mode:${mode}, kill withDeasync:1`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ `withDeasync:1` ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.kill( options.process.pid );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
deasync:begin
`
        var exp2 =
`program1:begin
deasync:begin
program1:end
deasync:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        /* if shell then parent process may ignore the signal */
        if( mode !== 'shell' )
        test.le( dtime, context.t1 * 2 );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function program1()
  {
    console.log( 'program1:begin' );

    let withSleep = process.argv.includes( 'withSleep:1' );
    let withTools = process.argv.includes( 'withTools:1' );
    let withDeasync = process.argv.includes( 'withDeasync:1' );

    // console.log( `withSleep:${withSleep} withTools:${withTools} withDeasync:${withDeasync}` );

    if( withTools || withDeasync )
    {
      let _ = require( toolsPath );
      _.include( 'wProcess' );
      _.process._exitHandlerRepair();
    }

    setTimeout( () => { console.log( 'program1:end' ) }, context.t1 * 8 );

    if( withSleep )
    sleep( context.t1 * 10 );

    if( withDeasync )
    deasync( context.t1 * 10 );

    function onTime()
    {
      console.log( 'time:end' );
    }

    function sleep( delay )
    {
      console.log( 'sleep:begin' );
      let now = Date.now();
      while( ( Date.now() - now ) < delay )
      {
        let x = Number( '123' );
      }
      console.log( 'sleep:end' );
    }

    function deasync( delay )
    {
      let _ = wTools;
      console.log( 'deasync:begin' );
      let con = new _.Consequence().take( null );
      con.delay( delay ).deasync();
      console.log( 'deasync:end' );
    }

    function handlersRemove()
    {
      process.removeAllListeners( 'SIGHUP' );
      process.removeAllListeners( 'SIGINT' );
      process.removeAllListeners( 'SIGQUIT' );
      process.removeAllListeners( 'SIGTERM' );
      process.removeAllListeners( 'exit' );
    }

  }

}

endSignalsBasic.timeOut = 1e6;
endSignalsBasic.description =
`
  - signals terminate or kill started process
`

/* zzz : find a way to really freeze a process to test routine _.process.terminate() with timeout */

//

function endSignalsOnExit( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program1 );
  let o3 =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 0,
    stdio : 'pipe',
  }

  let modes = [ 'fork', 'spawn', 'shell' ];
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGQUIT' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGINT' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGTERM' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGHUP' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalKilling( mode, 'SIGKILL' ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => terminate( mode ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => kill( mode ) ) );
  return a.ready;

  /* --- */

  function signalTerminating( mode, signal )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, ${signal}`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
${signal}
exit:end
`
        var exp2 =
`program1:begin
program1:end
exit:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function signalKilling( mode, signal )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, ${signal}`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        var exp2 =
`program1:begin
program1:end
exit:end
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, signal );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, signal );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function terminate( mode )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, terminate, pid`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pid : options.process.pid, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
SIGTERM
exit:end
`
        test.identical( options.output, exp1 );
        test.identical( _.strCount( options.output, 'exit:' ), 1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, terminate, native descriptor`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.terminate({ pnd : options.process, withChildren : 1 });
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
SIGTERM
exit:end
`
        test.identical( options.output, exp1 );
        test.identical( _.strCount( options.output, 'exit:' ), 1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGTERM' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGTERM' );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function kill( mode )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, kill, pid`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.kill( options.process.pid );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        var exp2 =
`program1:begin
Killed
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, false );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, kill, native descriptor`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 4, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        _.process.kill( options.process );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
`
        var exp2 =
`program1:begin
Killed
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( options.exitCode, null );
        test.identical( options.exitSignal, 'SIGKILL' );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'signal' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, null );
        test.identical( options.process.signalCode, 'SIGKILL' );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function program1()
  {

    console.log( 'program1:begin' );

    let withExitHandler = process.argv.includes( 'withExitHandler:1' );
    let withTools = process.argv.includes( 'withTools:1' );

    if( withTools )
    {
      let _ = require( toolsPath );
      _.include( 'wProcess' );
      _.process._exitHandlerRepair();
    }

    if( withExitHandler )
    process.once( 'exit', onExit );

    setTimeout( () => { console.log( 'program1:end' ) }, context.t1 * 8 );

    function onTime()
    {
      console.log( 'time:end' );
    }

    function onExit()
    {
      console.log( 'exit:end' );
    }

  }

}

endSignalsOnExit.timeOut = 1e6;
endSignalsOnExit.description =
`
  - handler of the event "exit" should be called, despite of signal, unless signal is SIGKILL
  - handler of the event "exit" should be called exactly once
`

//

function endSignalsOnExitExitAgain( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let programPath = a.program( program1 );
  let o3 =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 0,
    stdio : 'pipe',
  }

  let modes = [ 'fork', 'spawn' ];
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGINT', 128 + 2 ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGQUIT', 128 + 3 ) ) );
  modes.forEach( ( mode ) => a.ready.then( () => signalTerminating( mode, 'SIGTERM', 128 + 15 ) ) );
  return a.ready;

  /* --- */

  function signalTerminating( mode, signal, exitCode )
  {
    let ready = _.Consequence().take( null );

    /* - */

    ready

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, withCode:0, ${signal}`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1', 'withCode:0' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 3, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
${signal}
exit:${exitCode}
`
        var exp2 =
`program1:begin
program1:end
exit:${exitCode}
`
        if( mode === 'shell' )
        test.is( options.output === exp1 || options.output === exp2 );
        else
        test.identical( options.output, exp1 );
        test.identical( _.strCount( options.output, 'exit:' ), 1 );
        test.identical( options.exitCode, exitCode );
        test.identical( options.exitSignal, null );
        test.identical( options.ended, true );
        test.identical( options.exitReason, 'code' );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.exitCode, exitCode );
        test.identical( options.process.signalCode, null );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    .then( function( arg )
    {
      test.case = `mode:${mode}, withExitHandler:1, withTools:1, withCode:1, ${signal}`;
      var o2 =
      {
        execPath : mode === `fork` ? `${programPath}` : `node ${programPath}`,
        args : [ 'withExitHandler:1', 'withTools:1', 'withCode:1' ],
        mode,
      }
      var options = _.mapSupplement( null, o2, o3 );
      var returned = _.process.start( options );
      var time1;
      _.time.out( context.t1 * 3, () =>
      {
        test.identical( options.process.killed, false );
        time1 = _.time.now();
        options.process.kill( signal );
        return null;
      })
      returned.finally( function()
      {
        var exp1 =
`program1:begin
${signal}
exit:${exitCode}
`
        var exp2 =
`program1:begin
`
        /*
        Windows doesn't support signals handling, but will exit with signal if process was killed using pnd, exit event will not be emiited
        On Unix signal will be handled and process will exit with code passed to exit event handler
        */

        if( process.platform === 'win32' )
        {
          test.identical( options.output, exp2 );
          test.identical( options.exitCode, null );
          test.identical( options.exitSignal, signal );
          test.identical( options.exitReason, 'signal' );
        }
        else
        {
          test.identical( options.output, exp1 );
          test.identical( options.exitReason, 'code' );
          test.identical( options.exitCode, exitCode );
          test.identical( options.exitSignal, null );
        }

        test.identical( _.strCount( options.output, 'exit:' ), 1 );
        test.identical( options.ended, true );
        test.identical( options.state, 'terminated' );
        test.identical( options.error, null );
        test.identical( options.process.killed, true );
        var dtime = _.time.now() - time1;
        console.log( `dtime:${dtime}` );
        return null;
      })

      return returned;
    })

    /* - */

    return ready;
  }

  /* -- */

  function program1()
  {

    console.log( 'program1:begin' );

    let withExitHandler = process.argv.includes( 'withExitHandler:1' );
    let withCode = process.argv.includes( 'withCode:1' );
    let withTools = process.argv.includes( 'withTools:1' );

    if( withTools )
    {
      let _ = require( toolsPath );
      _.include( 'wProcess' );
      _.process._exitHandlerRepair();
    }

    if( withExitHandler )
    {
      process.on( 'exit', onExit );
      process.on( 'exit', onExit2 );
    }

    setTimeout( () => { console.log( 'program1:end' ) }, context.t1 * 6 );

    function onExit2( exitCode )
    {
      console.log( `exit2:${exitCode}` );
    }

    function onExit( exitCode )
    {
      console.log( `exit:${exitCode}` );
      /* explicit call of process.exit() in exit handler cause problem with termination reason */
      if( withCode )
      process.exit( exitCode );
      else
      process.exit();
    }

  }

}

endSignalsOnExitExitAgain.description =
`
  - trait : explicit call of process.exit() in exit handler cause problem with termination reason
  - trait : explicit call of process.exit() in exit handler does not allow to call other exit handler
  - handler of the event "exit" should be executed on Unix
`

//

/* qqq for Vova : describe test cases. describe test. this and related */
function terminate( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );

  // if( process.platform === 'win32' )
  // {
  //   // zzz for Vova : windows-kill doesn't work correctrly on node 14
  //   // investigate if its possible to use process.kill instead of windows-kill
  //   test.identical( 1, 1 )
  //   return;
  // }

  a.ready

  .then( () =>
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
      _.process.terminate({ pnd : o.process });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );//1 because process was killed using pid
        test.identical( op.exitSignal, null );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pid : o.process.pid, timeOut : 0 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pnd : o.process, timeOut : 1 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.is( op.exitSignal === 'SIGKILL' || op.exitSignal === 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pnd : o.process, timeOut : 0 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pnd : o.process, timeOut : 1 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* fork */

  .then( () =>
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

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );//1 because process was killed using pid
        test.identical( op.exitSignal, null );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pnd : o.process });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.identical( op.ended, true );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pid : o.process.pid, timeOut : 0 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pnd : o.process, timeOut : 0 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pid : o.process.pid, timeOut : 1 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.is( op.exitSignal === 'SIGKILL' || op.exitSignal === 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pnd : o.process, timeOut : 1 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.is( op.exitSignal === 'SIGKILL' || op.exitSignal === 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* shell */

  /*
    zzz Vova: shell,exec modes have different behaviour on Windows,OSX and Linux
    look for solution that allow to have same behaviour on each mode
  */

  .then( () =>
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
      _.process.terminate( o.process );
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );// null because process was killed using pnd
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate( o.process.pid );
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pnd : o.process, timeOut : 0 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );// null because process was killed using pnd
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  .then( () =>
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
      _.process.terminate({ pnd : o.process, timeOut : 1 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
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
      _.process.terminate({ pid : o.process.pid, timeOut : 1 });
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return ready;
  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.process._exitHandlerRepair();
    if( process.send )
    process.send( process.pid );
    else
    console.log( 'ready' );
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, context.t2 ) /* 5000 */
  }
}

//

function terminateSync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );

  // if( process.platform === 'win32' )
  // {
  //   // яяя for Vova : windows-kill doesn't work correctrly on node 14
  //   // investigate if its possible to use process.kill instead of windows-kill
  //   test.identical( 1, 1 );
  //   return;
  // }

  a.ready

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.terminate({ pnd : o.process, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      let got = result.sync();
      test.identical( got, true );
      return o.conTerminate;
    })
  })

  /* */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o );

    o.conTerminate.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, 1 );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.terminate({ pid : o.process.pid, sync : 1  });
      test.identical( result.resourcesCount(), 1 );
      let got = result.sync();
      test.identical( got, true );
      return o.conTerminate;
    })
  })

  /* fork */

  .then( () =>
  {

    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o )

    o.conTerminate.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, 1 );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.terminate({ pid : o.process.pid, sync : 1  });
      test.identical( result.resourcesCount(), 1 );
      let got = result.sync();
      test.identical( got, true );
      return o.conTerminate;
    })
  })

  /* */

  .then( () =>
  {
    let ready = _.Consequence();

    var o =
    {
      execPath : testAppPath,
      mode : 'fork',
      ipc : 1,
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o )

    o.conTerminate.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.ended, true );
        test.identical( op.exitCode, null );
        test.identical( op.exitSignal, 'SIGTERM' );
        test.is( _.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }

      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.terminate({ pnd : o.process, sync : 1  });
      test.identical( result.resourcesCount(), 1 );
      let got = result.sync();
      test.identical( got, true );
      return o.conTerminate;
    })
  })

  /* shell */

  /*
    zzz Vova: shell,exec modes have different behaviour on Windows,OSX and Linux
    look for solution that allow to have same behaviour on each mode
  */

  .then( () =>
  {

    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o )

    o.conTerminate.then( ( op ) =>
    {
      test.identical( op.exitCode, null );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, 'SIGKILL' );
      test.is( !_.strHas( op.output, 'SIGTERM' ) );
      test.is( !_.strHas( op.output, 'Application timeout!' ) );

      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.terminate({ pnd : o.process, timeOut : 0, sync : 1  });
      test.identical( result.resourcesCount(), 1 );
      let got = result.sync();
      test.identical( got, true );
      return o.conTerminate;
    })
  })

  /* */

  .then( () =>
  {

    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0
    }

    _.process.start( o )

    o.conTerminate.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      else
      {
        test.identical( op.exitCode, null );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, 'SIGKILL' );
        test.is( !_.strHas( op.output, 'SIGTERM' ) );
        test.is( !_.strHas( op.output, 'Application timeout!' ) );
      }
      return null;
    })

    return _.time.out( context.t1*2, () =>
    {
      let result = _.process.terminate({ pid : o.process.pid, timeOut : 0, sync : 1 });
      test.identical( result.resourcesCount(), 1 );
      let got = result.sync();
      test.identical( got, true );
      return o.conTerminate;
    })
  })

  /*
    zzz Vova: shell,exec modes have different behaviour on Windows,OSX and Linux
    look for solution that allow to have same behaviour on each mode
  */

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.process._exitHandlerRepair();
    if( process.send )
    process.send( process.pid );
    else
    console.log( 'ready' );
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, context.t2 ) /* 5000 */
  }
}

terminateSync.timeOut = 5e5;

//

function terminateFirstChildSpawn( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    test.is( _.process.isAlive( program2Pid ) );

    return _.time.out( context.t1*15 );
  })

  o.conTerminate.then( () =>
  {
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'pipe',
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite( _.path.join( __dirname, 'program2end' ), 'end' );
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

}

terminateFirstChildSpawn.timeOut = 40000;
terminateFirstChildSpawn.description =
`
mode : spawn
terminate first child withChildren:0
first child with signal SIGTERM on unix and exit code 1 on win
second child continues to work
`

function terminateFirstChildFork( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'program1.js',
    currentPath : a.routinePath,
    mode : 'fork',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    test.is( _.process.isAlive( program2Pid ) );

    return _.time.out( context.t1*15 );
  })

  o.conTerminate.then( () =>
  {
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var o =
    {
      execPath : 'program2.js',
      currentPath : __dirname,
      mode : 'fork',
      stdio : 'pipe',
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite( _.path.join( __dirname, 'program2end' ), 'end' );
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

}

terminateFirstChildFork.timeOut = 40000;
terminateFirstChildFork.description =
`
mode : fork
terminate first child
first child with signal SIGTERM on unix and exit code 1 on win
`

//

function terminateFirstChildShell( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'shell',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'Time out!' ), 0 );

    /*
       On darwing program1 exists right after signal, program2 continues to work
       On win/linux program1 waits for termination of program2 because only shell was terminated
    */

    if( process.platform === 'darwin' )
    {
      test.identical( _.strCount( o.output, 'program2::end' ), 0 );
      test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
      test.is( _.process.isAlive( program2Pid ) );

      return _.time.out( context.t1*15, () =>
      {
        test.is( !_.process.isAlive( program2Pid ) );
        test.is( a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
        return null;
      });
    }
    else
    {
      test.identical( _.strCount( o.output, 'program2::end' ), 1 );
      test.is( a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
      test.is( !_.process.isAlive( program2Pid ) );
    }

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'shell',
      stdio : 'pipe',
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.out( context.t1*25 );

    console.log( 'program1::begin' );

    process.on( 'exit', () =>
    {
      console.log( 'program1::end' );
    })
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite( _.path.join( __dirname, 'program2end' ), 'end' );
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

}

terminateFirstChildShell.timeOut = 3e5;
terminateFirstChildShell.description =
`
mode : shell
terminate first child
first child with signal SIGTERM on unix and exit code 1 on win
On darwing program1 exists right after signal, program2 continues to work
On win/linux program1 waits for termination of program2 because only shell was terminated
`

//

function terminateSecondChildSpawn( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : program2Pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    test.identical( o.exitCode, 0 );
    test.identical( o.exitSignal, null );

    let program2Op = _.fileProvider.fileRead({ filePath : a.abs( 'program2' ), encoding : 'json' });
    test.identical( program2Op.pid, program2Pid );
    if( process.platform === 'win32' )
    {
      test.identical( program2Op.exitCode, 1 );
      test.identical( program2Op.exitSignal, null );
    }
    else
    {
      test.identical( program2Op.exitCode, null );
      test.identical( program2Op.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'inherit',
      inputMirroring : 0,
      outputPiping : 0,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

    o.conTerminate.thenGive( () =>
    {
      timer.take( _.dont );

      let data =
      {
        pid : o.process.pid,
        exitCode : o.exitCode,
        exitSignal : o.exitSignal
      }
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2' ),
        data,
        encoding : 'json'
      })
    })
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

}

terminateSecondChildSpawn.timeOut = 40000;
terminateSecondChildSpawn.description =
`
terminate second child
first child exits as normal
second exits with signal SIGTERM on unix and exit code 1 on win
`

//

function terminateSecondChildFork( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'program1.js',
    currentPath : a.routinePath,
    mode : 'fork',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : program2Pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    test.identical( o.exitCode, 0 );
    test.identical( o.exitSignal, null );

    let program2Op = _.fileProvider.fileRead({ filePath : a.abs( 'program2' ), encoding : 'json' });
    test.identical( program2Op.pid, program2Pid );
    if( process.platform === 'win32' )
    {
      test.identical( program2Op.exitCode, 1 );
      test.identical( program2Op.exitSignal, null );
    }
    else
    {
      test.identical( program2Op.exitCode, null );
      test.identical( program2Op.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'program2.js',
      currentPath : __dirname,
      mode : 'fork',
      stdio : 'inherit',
      inputMirroring : 0,
      outputPiping : 0,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

    o.conTerminate.thenGive( () =>
    {
      timer.take( _.dont );

      let data =
      {
        pid : o.process.pid,
        exitCode : o.exitCode,
        exitSignal : o.exitSignal
      }
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2' ),
        data,
        encoding : 'json'
      })
    })
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

}

terminateSecondChildFork.timeOut = 40000;
terminateSecondChildFork.description =
`
terminate second child
first child exits as normal
second exits with signal SIGTERM on unix and exit code 1 on win
`

//

function terminateSecondChildShell( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'shell',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : program2Pid,
      timeOut : context.t1 * 5,
      withChildren : 0,
    })
  })

  o.conTerminate.then( () =>
  {
    test.identical( o.exitCode, 0 );
    test.identical( o.exitSignal, null );

    let program2Op = _.fileProvider.fileRead({ filePath : a.abs( 'program2' ), encoding : 'json' });

    if( process.platform !== 'linux' )
    test.identical( program2Op.pid, program2Pid );

    if( process.platform === 'win32' )
    {
      test.identical( program2Op.exitCode, 1 );
      test.identical( program2Op.exitSignal, null );
    }
    else
    {
      /*
      if spawn does create second process then those checks are not relvenat
      */
      if( !program2Op.exitCode )
      {
        test.identical( program2Op.exitCode, null );
        test.identical( program2Op.exitSignal, 'SIGTERM' );
      }
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'shell',
      stdio : 'inherit',
      inputMirroring : 0,
      outputPiping : 0,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

    o.conTerminate.thenGive( () =>
    {
      timer.take( _.dont );

      let data =
      {
        pid : o.process.pid,
        exitCode : o.exitCode,
        exitSignal : o.exitSignal
      }
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2' ),
        data,
        encoding : 'json'
      })
    })
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

}

terminateSecondChildShell.timeOut = 40000;
terminateSecondChildShell.description =
`
terminate second child
first child exits as normal
second exits with signal SIGTERM on unix and exit code 1 on win
`

//

function terminateDetachedFirstChildSpawn( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( _.process.isAlive( program2Pid ) );

    return _.time.out( context.t1*15 ); /* qqq for Vova: replace with periodic + timeout + kill */
  })

  o.conTerminate.then( () =>
  {
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'pipe',
      detaching : 1,
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }
}

terminateDetachedFirstChildSpawn.timeOut = 60000;
terminateDetachedFirstChildSpawn.description =
`
program1 starts program2 in detached mode
tester terminates program1 with option withChildren : 0
program2 should continue to work
`

//

function terminateDetachedFirstChildFork( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'program1.js',
    currentPath : a.routinePath,
    mode : 'fork',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( _.process.isAlive( program2Pid ) );

    return _.time.out( context.t1*15 ); /* qqq for Vova: replace with periodic + timeout + kill */
  })

  o.conTerminate.then( () =>
  {
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'program2.js',
      currentPath : __dirname,
      mode : 'fork',
      stdio : 'pipe',
      detaching : 1,
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }
}

terminateDetachedFirstChildFork.timeOut = 60000;
terminateDetachedFirstChildFork.description =
`
program1 starts program2 in detached mode
tester terminates program1 with option withChildren : 0
program2 should continue to work
`

//

function terminateDetachedFirstChildShell( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( _.process.isAlive( program2Pid ) );

    return _.time.out( context.t1*15 ); /* qqq for Vova: replace with periodic + timeout + kill */
  })

  o.conTerminate.then( () =>
  {
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'shell',
      stdio : 'pipe',
      detaching : 1,
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }
}

terminateDetachedFirstChildShell.timeOut = 60000;
terminateDetachedFirstChildShell.description =
`
program1 starts program2 in detached mode
tester terminates program1 with option withChildren : 0
program2 should continue to work
`

//

function terminateWithDetachedChildSpawn( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 1
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'pipe',
      detaching : 1,
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }
}

terminateWithDetachedChildSpawn.timeOut = 60000;
terminateWithDetachedChildSpawn.description =
`program1 starts program2 in detached mode
tester terminates program1 with option withChildren : 1
program1 and program2 should be terminated
`

//

/* qqq for Vova : have a ( fast! ) look, please */

/*

 > program1.js
program1::begin
program2::begin
SIGTERM
--------------- uncaught error --------------->

 = Message of error#1
    IPC channel is already disconnected
    Error starting the process
        Exec path : program2.js
        Current path : /pro/Temp/ProcessBasic-2020-10-26-22-32-51-515-e694.tmp/terminateWithDetachedChildFork

 = Beautified calls stack
    at ChildProcess.target.disconnect (internal/child_process.js:832:26)
    at Pipe.channel.onread (internal/child_process.js:582:14)

 = Throws stack
    thrown at ChildProcess.handleError @ /wtools/abase/l4_process/l3/Execution.s:854:13
    thrown at errRefine @ /wtools/abase/l0/l5/fErr.s:120:16

 = Process
    Current path : /pro/Temp/ProcessBasic-2020-10-26-22-32-51-515-e694.tmp/terminateWithDetachedChildFork
    Exec path : /home/kos/.nvm/versions/node/v12.9.1/bin/node /pro/Temp/ProcessBasic-2020-10-26-22-32-51-515-e694.tmp/terminateWithDetachedChildFork/program1.js


--------------- uncaught error ---------------<

        - got :
          255
        - expected :
          null
        - difference :
          *

        /wtools/abase/l4.test/ProcessBasic.test.s:29900:12
          29896 :       test.identical( o.exitSignal, null );
          29897 :     }
          29898 :     else
          29899 :     {
        * 29900 :       test.identical( o.exitCode, null );

        Test check ( TestSuite::Tools.l4.ProcessBasic / TestRoutine::terminateWithDetachedChildFork /  # 1 ) ... failed
        - got :
          null
        - expected :
          'SIGTERM'
        - difference :
          *

        /wtools/abase/l4.test/ProcessBasic.test.s:29901:12
          29897 :     }
          29898 :     else
          29899 :     {
          29900 :       test.identical( o.exitCode, null );
        * 29901 :       test.identical( o.exitSignal, 'SIGTERM' );

*/

/* qqq for Vova : join routines, use subroutine for mode varying */
function terminateWithDetachedChildFork( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'program1.js',
    currentPath : a.routinePath,
    mode : 'fork',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 1
    })
  })

  o.conTerminate.then( () =>
  {

    /*
    if both processes dies simultinously uncaught njs error can be thrown by the parent process:
    "IPC channel is already disconnected"
    */

    if( o.exitCode )
    {
      test.notIdentical( o.exitCode, 0 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  function handleOutput( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'program2.js',
      currentPath : __dirname,
      mode : 'fork',
      stdio : 'pipe',
      detaching : 1,
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );
  }

}

terminateWithDetachedChildFork.timeOut = 60000;
terminateWithDetachedChildFork.description =
`program1 starts program2 in detached mode
tester terminates program1 with option withChildren : 1
program1 and program2 should be terminated
`

//

function terminateWithDetachedChildShell( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'shell',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program2::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 1
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var o =
    {
      execPath : 'node program2.js',
      currentPath : __dirname,
      mode : 'shell',
      stdio : 'pipe',
      detaching : 1,
      inputMirroring : 0,
      outputPiping : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }
    _.process.start( o );

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );

  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }
}

terminateWithDetachedChildShell.timeOut = 60000;
terminateWithDetachedChildShell.description =
`program1 starts program2 in detached mode
tester terminates program1 with option withChildren : 1
program1 and program2 should be terminated
`

//

function terminateSeveralChildren( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );
  let testAppPath3 = a.program( program3 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let program3PID = null;
  let c = 0;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( _.strHas( output, 'program2::begin' ) || _.strHas( output, 'program3::begin' ) )
    c += 1;

    if( c !== 2 )
    return;

    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    program3PID = _.fileProvider.fileRead({ filePath : a.abs( 'program3PID' ), encoding : 'json' });
    program3PID = program3PID.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 1
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program3::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.identical( _.strCount( o.output, 'program3::end' ), 0 );
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( !_.process.isAlive( program3PID ) );
    test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    test.is( !a.fileProvider.fileExists( a.abs( 'program3end' ) ) );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );


  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var o =
    {
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'inherit',
      inputMirroring : 0,
      outputPiping : 0,
      outputCollecting : 0,
      throwingExitCode : 0,
    }

    _.process.start( _.mapExtend( null, o, { execPath : 'node program2.js' }));
    _.process.start( _.mapExtend( null, o, { execPath : 'node program3.js' }));

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

  /* - */

  function program3()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program3PID' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program3::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program3end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program3::begin' );

  }

}

//

function terminateWithSeveralDetachedChildren( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );
  let testAppPath2 = a.program( program2 );
  let testAppPath3 = a.program( program3 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  let program2Pid = null;
  let program3PID = null;
  let c = 0;
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( _.strHas( output, 'program2::begin' ) || _.strHas( output, 'program3::begin' ) )
    c += 1;

    if( c !== 2 )
    return;

    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    program2Pid = _.fileProvider.fileRead({ filePath : a.abs( 'program2Pid' ), encoding : 'json' });
    program2Pid = program2Pid.pid;
    program3PID = _.fileProvider.fileRead({ filePath : a.abs( 'program3PID' ), encoding : 'json' });
    program3PID = program3PID.pid;
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 1
    })
  })

  o.conTerminate.then( () =>
  {
    if( process.platform === 'win32' )
    {
      test.identical( o.exitCode, 1 );
      test.identical( o.exitSignal, null );
    }
    else
    {
      test.identical( o.exitCode, null );
      test.identical( o.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( o.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program3::begin' ), 1 );
    test.identical( _.strCount( o.output, 'program2::end' ), 0 );
    test.identical( _.strCount( o.output, 'program3::end' ), 0 );
    test.is( !_.process.isAlive( program2Pid ) );
    test.is( !_.process.isAlive( program3PID ) );
    test.is( !a.fileProvider.fileExists( a.abs( 'program2end' ) ) );
    test.is( !a.fileProvider.fileExists( a.abs( 'program3end' ) ) );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );


  function program1()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    var o =
    {
      currentPath : __dirname,
      mode : 'spawn',
      stdio : 'pipe',
      inputMirroring : 0,
      outputPiping : 1,
      detaching : 1,
      outputCollecting : 0,
      throwingExitCode : 0,
    }

    _.process.start( _.mapExtend( null, o, { execPath : 'node program2.js' }));
    _.process.start( _.mapExtend( null, o, { execPath : 'node program3.js' }));

    let timer = _.time.outError( context.t1*25 );

    console.log( 'program1::begin' );
  }

  /* - */

  function program2()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program2Pid' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program2::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program2end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program2::begin' );

  }

  /* - */

  function program3()
  {
    let _ = require( toolsPath );
    _.include( 'wFiles' );

    process.removeAllListeners( 'SIGTERM' )

    _.fileProvider.fileWrite
    ({
      filePath : _.path.join( __dirname, 'program3PID' ),
      data : { pid : process.pid },
      encoding : 'json'
    })

    setTimeout( () =>
    {
      console.log( 'program3::end' );
      _.fileProvider.fileWrite
      ({
        filePath : _.path.join( __dirname, 'program3end' ),
        data : 'end'
      })
    }, context.t1*15 )

    console.log( 'program3::begin' );

  }

}

terminateWithSeveralDetachedChildren.description =
`
Program1 spawns two detached children.
Tester terminates Program1 with option withChildren:1
All three processes should be dead before timeOut.
`

//

function terminateDeadProcess( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );

  let o =
  {
    execPath : 'node program1.js',
    currentPath : a.routinePath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o );

  o.conTerminate.then( () =>
  {
    test.identical( o.exitCode, 0 )
    test.identical( o.exitSignal, null );
    return _.process.terminate({ pid : o.process.pid, withChildren : 0 });
  })

  o.conTerminate.then( ( got ) =>
  {
    test.identical( got, true );
    let con = _.process.terminate({ pid : o.process.pid, withChildren : 1 });
    return test.shouldThrowErrorAsync( con );
  })

  return o.conTerminate;

  /* - */

  function program1()
  {
    console.log( 'program1::begin' );
    setTimeout( () =>
    {
      console.log( 'program1::begin' );
    }, context.t1 );
  }
}

terminateDeadProcess.description =
`
Terminated dead process.
Returns true with withChildren:0
Throws an error with withChildren:1
`

//

function terminateTimeOutNoHandler( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );

  /* - */

  var o =
  {
    execPath :  'node ' + testAppPath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o )
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program1::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( ( op ) =>
  {
    test.identical( op.ended, true );

    if( process.platform === 'win32' )
    {
      test.identical( op.exitCode, 1 );
      test.identical( op.exitSignal, 0 );
    }
    else
    {
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGTERM' );
    }

    test.identical( _.strCount( op.output, 'SIGTERM' ), 0 );
    test.identical( _.strCount( op.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( op.output, 'program1::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    setTimeout( () =>
    {
      console.log( 'program1::end' );
    }, context.t1 * 15 );

    console.log( 'program1::begin' );
  }
}

terminateTimeOutNoHandler.description =
`
Program1 has no SIGTERM handler.
Should terminate before timeOut with SIGTERM on unix and exit code 1 on win
`

//

function terminateTimeOutIgnoreSignal( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );

  /* - */

  var o =
  {
    execPath :  'node ' + testAppPath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o )
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program1::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : context.t1 * 5,
      withChildren : 0
    })
  })

  o.conTerminate.then( ( op ) =>
  {
    test.identical( op.ended, true );

    if( process.platform === 'win32' )
    {
      test.identical( op.exitCode, 1 );
      test.identical( op.exitSignal, 0 );
      test.identical( _.strCount( op.output, 'program1::SIGTERM' ), 0 );
    }
    else
    {
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );
      test.identical( _.strCount( op.output, 'program1::SIGTERM' ), 1 );
    }

    test.identical( _.strCount( op.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( op.output, 'program1::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    process.on( 'SIGTERM', () =>
    {
      console.log( 'program1::SIGTERM' )
    })

    setTimeout( () =>
    {
      console.log( 'program1::end' );
    }, context.t1 * 15 );

    console.log( 'program1::begin' );
  }
}

terminateTimeOutIgnoreSignal.description =
`
Program1 has SIGTERM handler that ignores signal.
Should terminate after timeOut with SIGKILL on unix and exit code 1 on win
Windows doesn't support signals
`

//

function terminateZeroTimeOutSpawn( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );

  /* - */

  var o =
  {
    execPath :  'node ' + testAppPath,
    mode : 'spawn',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o )
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program1::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : 0,
      withChildren : 0
    })
  })

  o.conTerminate.then( ( op ) =>
  {
    test.identical( op.ended, true );

    if( process.platform === 'win32' )
    {
      test.identical( op.exitCode, 1 );
      test.identical( op.exitSignal, 0 );
    }
    else
    {
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );
    }

    test.identical( _.strCount( op.output, 'program1::SIGTERM' ), 0 );
    test.identical( _.strCount( op.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( op.output, 'program1::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    process.on( 'SIGTERM', () =>
    {
      console.log( 'program1::SIGTERM' )
    })

    setTimeout( () =>
    {
      console.log( 'program1::end' );
    }, context.t1 * 15 );

    console.log( 'program1::begin' );
  }
}

terminateZeroTimeOutSpawn.description =
`
Program1 has SIGTERM handler that ignores signal.
Should terminate right after call with SIGKILL on unix and exit code 1 on win
Signal handler should not be executed
`

//

function terminateZeroTimeOutFork( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );

  /* - */

  var o =
  {
    execPath : 'program1',
    currentPath : a.routinePath,
    mode : 'fork',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o )
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program1::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : 0,
      withChildren : 0
    })
  })

  o.conTerminate.then( ( op ) =>
  {
    test.identical( op.ended, true );

    if( process.platform === 'win32' )
    {
      test.identical( op.exitCode, 1 );
      test.identical( op.exitSignal, 0 );
    }
    else
    {
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );
    }

    test.identical( _.strCount( op.output, 'program1::SIGTERM' ), 0 );
    test.identical( _.strCount( op.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( op.output, 'program1::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    process.on( 'SIGTERM', () =>
    {
      console.log( 'program1::SIGTERM' )
    })

    setTimeout( () =>
    {
      console.log( 'program1::end' );
    }, context.t1 * 15 );

    console.log( 'program1::begin' );
  }
}

terminateZeroTimeOutFork.description =
`
Program1 has SIGTERM handler that ignores signal.
Should terminate right after call with SIGKILL on unix and exit code 1 on win
Signal handler should not be executed
`

//

function terminateZeroTimeOutWithoutChildrenShell( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );

  /* - */

  var o =
  {
    execPath : 'node program1',
    currentPath : a.routinePath,
    mode : 'shell',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o )
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program1::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : 0,
      withChildren : 0
    })
  })

  o.conTerminate.then( ( op ) =>
  {
    test.identical( op.ended, true );

    if( process.platform === 'win32' )
    {
      test.identical( op.exitCode, 1 );
      test.identical( op.exitSignal, 0 );
    }
    else
    {
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );
    }

    test.identical( _.strCount( op.output, 'program1::SIGTERM' ), 0 );
    test.identical( _.strCount( op.output, 'program1::begin' ), 1 );

    /*
      Single process on darwin, Two processes on linux and windows
      Child continues to work on linux/windows
    */
    if( process.platform === 'darwin' )
    test.identical( _.strCount( op.output, 'program1::end' ), 0 );
    else
    test.identical( _.strCount( op.output, 'program1::end' ), 1 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    process.on( 'SIGTERM', () =>
    {
      console.log( 'program1::SIGTERM' )
    })

    setTimeout( () =>
    {
      console.log( 'program1::end' );
    }, context.t1 * 15 );

    console.log( 'program1::begin' );
  }
}

terminateZeroTimeOutWithoutChildrenShell.description =
`
Program1 has SIGTERM handler that ignores signal.
Should terminate right after call with SIGKILL on unix and exit code 1 on win
On darwin node exists right after signal, because it is a single process
On unix/windows shell is spawned in addition to node process, so node continues to work after signal
Signal handler should not be executed
`

function terminateZeroTimeOutWithtChildrenShell( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( program1 );

  /* - */

  var o =
  {
    execPath : 'node program1',
    currentPath : a.routinePath,
    mode : 'shell',
    outputPiping : 1,
    outputCollecting : 1,
    throwingExitCode : 0
  }

  _.process.start( o )
  let terminate = _.Consequence();

  function handleOutput ( output )
  {
    output = output.toString();
    if( !_.strHas( output, 'program1::begin' ) )
    return;
    o.process.stdout.removeListener( 'data', handleOutput );
    terminate.take( null );
  }

  o.process.stdout.on( 'data', handleOutput );

  terminate.then( () =>
  {
    return _.process.terminate
    ({
      pid : o.process.pid,
      timeOut : 0,
      withChildren : 1
    })
  })

  o.conTerminate.then( ( op ) =>
  {
    test.identical( op.ended, true );

    if( process.platform === 'win32' )
    {
      test.identical( op.exitCode, 1 );
      test.identical( op.exitSignal, 0 );
    }
    else
    {
      test.identical( op.exitCode, null );
      test.identical( op.exitSignal, 'SIGKILL' );
    }

    test.identical( _.strCount( op.output, 'program1::SIGTERM' ), 0 );
    test.identical( _.strCount( op.output, 'program1::begin' ), 1 );
    test.identical( _.strCount( op.output, 'program1::end' ), 0 );

    return null;
  })

  return _.Consequence.AndKeep( terminate, o.conTerminate );

  /* - */

  function program1()
  {
    process.on( 'SIGTERM', () =>
    {
      console.log( 'program1::SIGTERM' )
    })

    setTimeout( () =>
    {
      console.log( 'program1::end' );
    }, context.t1 * 15 );

    console.log( 'program1::begin' );
  }
}

terminateZeroTimeOutWithtChildrenShell.description =
`
Program1 has SIGTERM handler that ignores signal.
Should terminate right after call with SIGKILL on unix and exit code 1 on win
On darwin node exists right after signal, because it is a single process
On unix/windows shell is spawned in addition to node process, so node continues to work after signal
Signal handler should not be executed
`

//

function terminateDifferentStdio( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );

  /* */

  a.ready

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'inherit',
      outputPiping : 0,
      outputCollecting : 0,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t0 * 15, () => /* 1500 */
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      else
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      return null;
    })

    return ready;
  })

  /* - */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'ignore',
      outputPiping : 0,
      outputCollecting : 0,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t0 * 15, () => /* 1500 */
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      else
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      return null;
    })

    return ready;
  })

  /* - */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'pipe',
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t0 * 15, () => /* 1500 */
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      else
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      return null;
    })

    return ready;
  })

  /* - */

  .then( () =>
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

    _.time.out( context.t0 * 15, () => /* 1500 */
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      else
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      return null;
    })

    return ready;
  })

  /* - */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'inherit',
      outputPiping : 0,
      outputCollecting : 0,
      ipc : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t0 * 15, () => /* 1500 */
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      else
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      return null;
    })

    return ready;
  })

  /* - */

  .then( () =>
  {
    var o =
    {
      execPath :  'node ' + testAppPath,
      mode : 'spawn',
      stdio : 'ignore',
      outputPiping : 0,
      outputCollecting : 0,
      ipc : 1,
      throwingExitCode : 0
    }

    let ready = _.process.start( o )

    _.time.out( context.t0 * 15, () => /* 1500 */
    {
      return test.mustNotThrowError( () => _.process.terminate( o.process.pid ) )
    })

    ready.then( ( op ) =>
    {
      if( process.platform === 'win32' )
      {
        test.identical( op.exitCode, 1 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( !a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }
      else
      {
        test.identical( op.exitCode, 0 );
        test.identical( op.ended, true );
        test.identical( op.exitSignal, null );
        test.is( a.fileProvider.fileExists( a.abs( a.routinePath, o.process.pid.toString() ) ) );
      }

      return null;
    })

    return ready;
  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    process.on( 'SIGTERM', () =>
    {
      var fs = require( 'fs' );
      var path = require( 'path' )
      fs.writeFileSync( path.join( __dirname, process.pid.toString() ), process.pid.toString() );
      process.exit( 0 );
    })
    setTimeout( () =>
    {
      process.exit( -1 );
    }, context.t2 ) /* 5000 */
  }
}

//

/* zzz for Vova : extend, cover kill of group of processes */

function killComplex( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );
  let testAppPath2 = a.program( testApp2 );

  /* */

  a.ready

  .then( () =>
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
    o.process.on( 'message', ( e ) =>
    {
      if( !pid )
      {
        pid = _.numberFrom( e )
        _.process.kill( pid );
      }
      else
      {
        childOfChild = e;
      }
    })

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      test.identical( op.exitSignal, null );
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

  return a.ready;

  /* - */

  function testApp()
  {
    setTimeout( () =>
    {
      console.log( 'Application timeout!' )
    }, context.t2 / 2 ) /* 2500 */
  }

  function testApp2()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    var testAppPath = _.fileProvider.path.nativize( _.path.join( __dirname, 'testApp.js' ) );
    var o = { execPath : 'node ' + testAppPath, throwingExitCode : 0  }
    var ready = _.process.start( o )
    process.send( o.process.pid );
    ready.then( ( op ) =>
    {
      process.send({ exitCode : o.exitCode, pid : o.process.pid, exitSignal : o.exitSignal })
      return null;
    })
    return ready;
  }

}

//

function children( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );
  let testAppPath2 = a.program( testApp2 );

  /* */

  a.ready

  .then( () =>
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

    o.process.on( 'message', ( e ) =>
    {
      lastChildPid = _.numberFrom( e );
      children = _.process.children({ pid : process.pid, format : 'tree' });
    })

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
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
      return children.then( ( op ) =>
      {
        test.contains( op, expected );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .then( () =>
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

    o.process.on( 'message', ( e ) =>
    {
      lastChildPid = _.numberFrom( e )
      children = _.process.children({ pid : o.process.pid, format : 'tree' });
    })

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      var expected =
      {
        [ o.process.pid ] :
        {
          [ lastChildPid ] : {}
        }
      }
      return children.then( ( op ) =>
      {
        test.contains( op, expected );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .then( () =>
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

    o.process.on( 'message', ( e ) =>
    {
      lastChildPid = _.numberFrom( e )
      children = _.process.children({ pid : lastChildPid, format : 'tree' });
    })

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      var expected =
      {
        [ lastChildPid ] : {}
      }
      return children.then( ( op ) =>
      {
        test.contains( op, expected );
        return null;
      })

    })

    return ready;
  })

  /* - */

  .then( () =>
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

    let ready = _.Consequence.AndTake( r1, r2 );

    o1.process.on( 'message', () =>
    {
      children = _.process.children({ pid : process.pid, format : 'tree' });
    })

    ready.then( ( op ) =>
    {
      test.identical( op[ 0 ].exitCode, 0 );
      test.identical( op[ 1 ].exitCode, 0 );
      var expected =
      {
        [ process.pid ] :
        {
          [ op[ 0 ].process.pid ] : {},
          [ op[ 1 ].process.pid ] : {},
        }
      }
      return children.then( ( op ) =>
      {
        test.contains( op, expected );
        return null;
      })
    })

    return ready;
  })

  /* - */

  .then( () =>
  {
    test.case = 'only parent'
    return _.process.children({ pid : process.pid, format : 'tree' })
    // return _.process.children( process.pid )
    .then( ( op ) =>
    {
      test.contains( op, { [ process.pid ] : {} })
      return null;
    })
  })

  /* - */

  .then( () =>
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
      // let ready = _.process.children( o.process.pid );
      let ready = _.process.children({ pid : o.process.pid, format : 'tree' });
      return test.shouldThrowErrorAsync( ready );
    })

  })

  /* */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
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
    setTimeout( () => {}, context.t0 * 15 ) /* 1500 */
  }
}

//

function childrenOptionFormatList( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );
  let testAppPath2 = a.program( testApp2 );

  /* */

  a.ready

  .then( () =>
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

    o.process.on( 'message', ( e ) =>
    {
      lastChildPid = _.numberFrom( e );
      children = _.process.children({ pid : process.pid, format : 'list' })
    })

    ready.then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( op.ended, true );
      return children.then( ( op ) =>
      {
        if( process.platform === 'win32' )
        {
          test.identical( op.runs.length, 5 );

          test.identical( op.runs[ 0 ].pid, process.pid );
          test.identical( op.runs[ 1 ].pid, o.process.pid );

          test.is( _.numberIs( op.runs[ 2 ].pid ) );
          test.identical( op.runs[ 2 ].name, 'conhost.exe' );

          test.identical( op.runs[ 3 ].pid, lastChildPid );

          test.is( _.numberIs( op.runs[ 4 ].pid ) );
          test.identical( op.runs[ 4 ].name, 'conhost.exe' );

        }
        else
        {
          var expected =
          [
            { pid : process.pid },
            { pid : o.process.pid },
            { pid : lastChildPid }
          ]
          test.contains( op, expected );
        }
        return null;
      })
    })

    return ready;
  })

  /*  */

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
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
    setTimeout( () => {}, context.t0 * 15 ) /* 1500 */
  }
}

// --
// experiment
// --

function streamJoinExperiment()
{
  let context = this;

  let pass = new Stream.PassThrough();
  let src1 = new Stream.PassThrough();
  let src2 = new Stream.PassThrough();

  src1.pipe( pass, { end : false } );
  src2.pipe( pass, { end : false } );

  src1.on( 'data', ( chunk ) =>
  {
    console.log( 'src1.data', chunk.toString() );
  });

  src1.on( 'end', () =>
  {
    console.log( 'src1.end' );
  });

  src1.on( 'finish', () =>
  {
    console.log( 'src1.finish' );
  });

  pass.on( 'data', ( chunk ) =>
  {
    console.log( 'pass.data', chunk.toString() );
  });

  pass.on( 'end', () =>
  {
    debugger;
    console.log( 'pass.end' );
  });

  pass.on( 'finish', () =>
  {
    debugger;
    console.log( 'pass.finish' );
  });

  src1.write( 'src1a' );
  src2.write( 'src2a' );
  src1.write( 'src1b' );
  src2.write( 'src2b' );

  console.log( '1' );
  src1.end();
  console.log( '2' );
  src2.end();
  console.log( '3' );

  return _.time.out( context.t1 ); /* 1000 */
}

streamJoinExperiment.experimental = 1;

//

function experimentIpcDeasync( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  for( let i = 0 ; i < 10; i++ )
  a.ready.then( run )

  return a.ready;

  function run( )
  {
    var o =
    {
      execPath : 'node -e "process.send(1);setTimeout(()=>{},500)"',
      mode : 'spawn',
      stdio : 'pipe',
      ipc : 1,
      throwingExitCode : 0
    }
    _.process.start( o );

    var ready = _.Consequence();

    o.process.on( 'message', () =>
    {
      let interval = setInterval( () =>
      {
        if( _.process.isAlive( o.process.pid ) )
        return false;
        ready.take( true );
        clearInterval( interval );
      })
      ready.deasync();
    })


    return _.Consequence.AndKeep( o.conTerminate, ready );
  }
}

experimentIpcDeasync.experimental = 1;
experimentIpcDeasync.description =
`
This expriment shows problem with usage of _.time.periodic with deasync.
Problem happens only if code if deasync is launched from 'message' callback
`

//

function experiment( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.program( testApp );
  let testAppPath2 = a.program( testApp2 );
  let o3 =
  {
    outputPiping : 1,
    outputCollecting : 1,
    applyingExitCode : 0,
    throwingExitCode : 1
  }

  let o2;

  /* - */

  a.ready.then( function()
  {
    test.case = 'mode : shell, passingThrough : true, no args';

    o =
    {
      execPath :  'node testApp.js *',
      currentPath : a.routinePath,
      mode : 'spawn',
      stdio : 'pipe'
    }

    return null;
  })
  .then( function( arg )
  {
    var options = _.mapSupplement( null, o2, o3 );

    return _.process.start( options )
    .then( function()
    {
      test.identical( options.exitCode, 0 );
      test.is( _.strHas( options.output, `[ '*' ]` ) );
      return null;
    })
  })

  return a.ready;

  /* - */

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    _.process.start
    ({
      execPath : 'node testApp2.js',
      mode : 'shell',
      passingThrough : 1,
      stdio : 'inherit',
      outputPiping : 0,
      outputCollecting : 0,
      inputMirroring : 0
    })
  }

  function testApp2()
  {
    console.log( process.argv.slice( 2 ) );
  }
}

experiment.experimental = 1;

//

function experiment2( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let testAppPath = a.path.nativize( a.program( testApp ) );
  let track;

  var o =
  {
    execPath : 'node -e "console.log(process.ppid,process.pid)"',
    mode : 'shell',
    stdio : 'pipe'
  }
  _.process.start( o );
  console.log( 'Shell:', o.process.pid )

}

experiment2.experimental = 1;

//

function experiment3( test )
{
  let context = this;
  let a = context.assetFor( test, false );

  var o =
  {
    execPath : 'node -e "console.log(setTimeout(()=>{},10000))"',
    mode : 'spawn',
    stdio : 'pipe',
    timeOut : 2000,
    throwingExitCode : 0
  }
  _.process.start( o );

  o.conTerminate.then( ( op ) =>
  {
    test.identical( op.ended, true );
    test.identical( op.exitReason, 'signal' );
    test.identical( op.exitCode, null );
    test.identical( op.exitSignal, 'SIGTERM' );
    test.is( !_.process.isAlive( op.process.pid ) );
    return null;
  })

  return o.conTerminate;
}

experiment3.experimental = 1;
experiment3.description =
`
Shows that timeOut kills the child process and handleClose is called
`

// --
// suite
// --

var Proto =
{

  name : 'Tools.l4.ProcessBasic',
  silencing : 1,
  routineTimeOut : 60000,
  onSuiteBegin : suiteBegin,
  onSuiteEnd : suiteEnd,

  context :
  {

    assetFor,
    suiteTempPath : null,

    t0 : 100,
    t1 : 1000,
    t2 : 5000,
    t3 : 15000,

  },

  tests :
  {

    // basic

    startBasic,
    startBasic2,
    startFork,
    startErrorHandling,

    // sync

    startSync,
    startSyncDeasync,
    startSpawnSyncDeasync, /* qqq for Yevhen : join with subroutine */
    startSpawnSyncDeasyncThrowing,
    startShellSyncDeasync, /* qqq for Yevhen : join with subroutine */
    startShellSyncDeasyncThrowing,
    startForkSyncDeasync, /* qqq for Yevhen : join with subroutine */
    startForkSyncDeasyncThrowing,
    startSyncDeasyncMultiple,

    // arguments

    startWithoutExecPath,
    startArgsOption,
    startArgumentsParsing,
    startArgumentsParsingNonTrivial,
    startArgumentsNestedQuotes,
    startExecPathQuotesClosing,
    startExecPathSeveralCommands,
    startExecPathNonTrivialModeShell,
    startArgumentsHandlingTrivial,
    startArgumentsHandling,
    startImportantExecPath,
    startImportantExecPathPassingThrough,
    startNormalizedExecPath,
    startExecPathWithSpace,
    startDifferentTypesOfPaths,
    startNjsPassingThroughExecPathWithSpace,
    startNjsPassingThroughDifferentTypesOfPaths,
    startPassingThroughExecPathWithSpace,

    // procedures / chronology / structural

    startProcedureTrivial,
    startProcedureExists,
    startProcedureStack,
    startProcedureStackMultiple, /* qqq for Yevhen : extend it using startProcedureStack as example | aaa : Done. */
    startOnTerminateSeveralCallbacksChronology,
    startChronology,

    // delay

    startReadyDelay,
    startReadyDelayMultiple,
    startOptionWhenDelay,
    startOptionWhenTime,
    startOptionTimeOut,
    // startAfterDeath, /* zzz : fix */
    // startAfterDeathOutput, /* zzz : ? */

    // detaching

    startDetachingModeSpawnResourceReady,
    startDetachingModeForkResourceReady,
    startDetachingModeShellResourceReady,
    startDetachingModeSpawnNoTerminationBegin,
    startDetachingModeForkNoTerminationBegin,
    startDetachingModeShellNoTerminationBegin,
    startDetachedOutputStdioIgnore,
    startDetachedOutputStdioPipe,
    startDetachedOutputStdioInherit,
    startDetachingModeSpawnIpc,
    startDetachingModeForkIpc,
    startDetachingModeShellIpc,

    startDetachingTrivial,
    startDetachingChildExitsAfterParent,
    startDetachingChildExitsBeforeParent,
    startDetachingDisconnectedEarly,
    startDetachingDisconnectedLate,
    startDetachingChildExistsBeforeParentWaitForTermination,
    startDetachingEndCompetitorIsExecuted,
    startDetachingTerminationBegin,
    startEventClose,
    startEventExit,
    startDetachingThrowing,
    startNjsDetachingChildThrowing,

    // on

    startOnStart,
    startOnTerminate,
    startNoEndBug1,
    startWithDelayOnReady,
    startOnIsNotConsequence,

    // concurrent

    startConcurrentMultiple,
    startConcurrentConsequencesMultiple,
    starterConcurrentMultiple,

    /* qqq for Yevhen : use routine _.process.startMinimal() where it is possible and make renaming of test routines */

    // helper

    startNjs,
    startNjsWithReadyDelayStructural,
    startNjsOptionInterpreterArgs,
    startNjsWithReadyDelayStructuralMultiple,

    // sheller

    sheller,
    shellerArgs,
    shellerFields,

    // output

    startOptionOutputCollecting,
    startOptionOutputColoring,
    startOptionOutputColoringStderr,
    startOptionOutputColoringStdout,
    startOptionOutputGraying,
    // startOptionOutputPrefixing, /* qqq2 for Yevhen : rewrote test routine taking into account new cases */
    // startOptionOutputPiping, /* qqq2 for Yevhen : rewrote test routine taking into account new cases */
    startOptionInputMirroring,
    startOptionLogger,
    startOptionLoggerTransofrmation,
    startOutputOptionsCompatibilityLateCheck,
    // startOptionVerbosity, /* qqq2 for Yevhen : rewrite the test routine appropriately */
    startOptionVerbosityLogging,
    startOutputMultiple,
    startOptionStdioIgnoreMultiple,

    // etc

    appTempApplication,

    // other options

    startOptionStreamSizeLimit,
    startOptionStreamSizeLimitThrowing,
    startOptionDry, /* qqq for Yevhen : make sure option dry is covered good enough */
    /* qqq for Yevhen : write test routine startOptionDryMultiple */
    startOptionCurrentPath,
    startOptionCurrentPaths,
    startOptionPassingThrough, /* qqq for Yevhen : extend please | aaa : Done. Yevhen S. */

    // pid / status / exit

    startDiffPid,
    pidFrom,

    isAlive,
    statusOf,

    // exitReason, /* qqq2 for Yevhen : it should be in subprocess */
    exitCode, /* qqq for Yevhen : check order of test routines. it's messed up */

    // termination

    kill,
    killSync,
    killOptionWithChildren,

    startErrorAfterTerminationWithSend,
    startTerminateHangedWithExitHandler,
    startTerminateAfterLoopRelease,

    endSignalsBasic,
    endSignalsOnExit,
    endSignalsOnExitExitAgain,

    terminate, /* qqq for Vova: review, remove duplicates, check timeouts */
    terminateSync,

    terminateFirstChildSpawn,
    terminateFirstChildFork,
    terminateFirstChildShell,

    terminateSecondChildSpawn,
    terminateSecondChildFork,
    terminateSecondChildShell,

    terminateDetachedFirstChildSpawn,
    terminateDetachedFirstChildFork,
    terminateDetachedFirstChildShell,

    terminateWithDetachedChildSpawn,
    terminateWithDetachedChildFork,
    terminateWithDetachedChildShell,

    terminateSeveralChildren,
    terminateWithSeveralDetachedChildren,
    terminateDeadProcess,

    terminateTimeOutNoHandler,
    terminateTimeOutIgnoreSignal,
    terminateZeroTimeOutSpawn,
    terminateZeroTimeOutFork,
    terminateZeroTimeOutWithoutChildrenShell,
    terminateZeroTimeOutWithtChildrenShell,

    terminateDifferentStdio, /* qqq for Vova: rewrite, don't use timeout to run terminate */

    killComplex,

    // children

    children,
    childrenOptionFormatList,

    // experiments

    experimentIpcDeasync, /* qqq for Vova : collect information for different versions and different OSs */
    streamJoinExperiment,
    experiment,
    experiment2,
    experiment3,

  }

}

_.mapExtend( Self, Proto );

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self );

})();
