( function _ProcessBasic_s_() {

'use strict';

/**
 * Collection of routines to execute system commands, run shell, batches, launch external processes from JavaScript application. ExecTools leverages not only outputting data from an application but also inputting, makes application arguments parsing and accounting easier. Use the module to get uniform experience from interaction with an external processes on different platforms and operating systems.
  @module Tools/base/ProcessBasic
*/

/**
 * @file ProcessBasic.s.
 */

/**
 * Collection of routines to execute system commands, run shell, batches, launch external processes from JavaScript application.
  @namespace Tools( module::ProcessBasic )
  @memberof module:Tools/base/ProcessBasic
*/

/* Return values of routine start for each combination of options sync and deasync:

  Single process
  | Combination      | Options map | Consequence |
  | ---------------- | ----------- | ----------- |
  | sync:0 deasync:0 | +           | +           |
  | sync:1 deasync:1 | +           | -           |
  | sync:0 deasync:1 | +           | +           |
  | sync:1 deasync:0 | +           | -           |
  
  Multiple processes
  | Combination      | Array of maps of options | Single options map | Consequence |
  | ---------------- | ------------------------ | ------------------ | ----------- |
  | sync:0 deasync:0 | +                        | -                  | +           |
  | sync:1 deasync:1 | +                        | -                  | -           |
  | sync:0 deasync:1 | +                        | -                  | +           |
  | sync:1 deasync:0 | -                        | +                  | -           |
*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wPathBasic' );
  _.include( 'wGdfStrategy' );
  _.include( 'wConsequence' );

}

let System, ChildProcess, StripAnsi;
let _global = _global_;
let _ = _global_.wTools;
let Self = _.process = _.process || Object.create( null );

_.assert( !!_realGlobal_ );

// --
// exec
// --

function start_pre( routine, args )
{
  let o;

  if( _.strIs( args[ 0 ] ) || _.arrayIs( args[ 0 ] ) )
  o = { execPath : args[ 0 ] };
  else
  o = args[ 0 ];

  o = _.routineOptions( routine, o );

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1, 'Expects single argument' );
  _.assert( _.longHas( [ 'fork', 'exec', 'spawn', 'shell' ], o.mode ) );
  _.assert( !!o.args || !!o.execPath, 'Expects {-args-} either {-execPath-}' )
  _.assert( o.args === null || _.arrayIs( o.args ) || _.strIs( o.args ) );
  _.assert( o.execPath === null || _.strIs( o.execPath ) || _.strsAreAll( o.execPath ), 'Expects string or strings {-o.execPath-}, but got', _.strType( o.execPath ) );
  _.assert( o.timeOut === null || _.numberIs( o.timeOut ), 'Expects null or number {-o.timeOut-}, but got', _.strType( o.timeOut ) );

  return o;
}

//

/**
 * @summary Executes command in a controled child process.
 *
 * @param {Object} o Options map
 * @param {String} o.execPath Command to execute, path to application, etc.
 * @param {String} o.currentPath Current working directory of child process.

 * @param {Boolean} o.sync=0 Execute command in synchronous mode.
   There are two synchrounous modes: first uses sync method of `ChildProcess` module , second uses async method, but in combination with {@link https://www.npmjs.com/package/deasync deasync} and `wConsequence` to turn async execution into synchrounous.
   Which sync mode will be selected depends on value of `o.deasync` option.
   Sync mode returns options map.
   Async mode returns instance of {@link module:Tools/base/Consequence.Consequence wConsequence} with gives a message( options map ) when execution of child process is finished.
 * @param {Boolean} o.deasync=1 Controls usage of `deasync` module in synchrounous mode. Allows to run command synchrounously in modes( o.mode ) that don't support synchrounous execution, like `fork`.

 * @param {Array} o.args=null Arguments for command.
 * @param {Array} o.interpreterArgs=null Arguments for node. Used only in `fork` mode. {@link https://nodejs.org/api/cli.html Command Line Options}
 * @param {String} o.mode='shell' Execution mode. Possible values: `fork`, `exec`, `spawn`, `shell`. {@link https://nodejs.org/api/child_process.html Details about modes}
 * @param {Object} o.ready=null `wConsequence` instance that gives a message when execution is finished.
 * @param {Object} o.logger=null `wLogger` instance that prints output during command execution.

 * @param {Object} o.env=null Environment variables( key-value pairs ).
 * @param {String/Array} o.stdio='pipe' Controls stdin,stdout configuration. {@link https://nodejs.org/api/child_process.html#child_process_options_stdio Details}
 * @param {Boolean} o.ipc=0  Creates `ipc` channel between parent and child processes.
 * @param {Boolean} o.detaching=0 Creates independent process for a child. Allows child process to continue execution when parent process exits. Platform dependent option. {@link https://nodejs.org/api/child_process.html#child_process_options_detached Details}.
 * @param {Boolean} o.windowHiding=1 Hide the child process console window that would normally be created on Windows. {@link https://nodejs.org/api/child_process.html#child_process_child_process_spawn_command_args_options Details}.
 * @param {Boolean} o.passingThrough=0 Allows to pass arguments of parent process to the child process.
 * @param {Boolean} o.concurrent=0 Allows paralel execution of several child processes. By default executes commands one by one.
 * @param {Number} o.timeOut=null Time in milliseconds before execution will be terminated.

 * @param {Boolean} o.throwingExitCode=1 Throws an Error if child process returns non-zero exit code. Child returns non-zero exit code if it was terminated by parent, timeOut or when internal error occurs.

 * @param {Boolean} o.applyingExitCode=0 Applies exit code to parent process.

 * @param {Number} o.verbosity=2 Controls amount of output, `0` disables output at all.
 * @param {Boolean} o.outputGray=0 Logger prints everything in raw mode, no styles applied.
 * @param {Boolean} o.outputGrayStdout=0 Logger prints output from `stdout` in raw mode, no styles applied.
 * @param {Boolean} o.outputPrefixing=0 Add prefix with name of output channel( stderr, stdout ) to each line.
 * @param {Boolean} o.outputPiping=null Handles output from `stdout` and `stderr` channels. Is enabled by default if `o.verbosity` levels is >= 2 and option is not specified explicitly. This option is required by other "output" options that allows output customization.
 * @param {Boolean} o.outputCollecting=0 Enables coullection of output into sinle string. Collects output into `o.output` property if enabled.
 * @param {Boolean} o.outputAdditive=null Prints output during execution. Enabled by default if shell executes only single command and option is not specified explicitly.
 * @param {Boolean} o.inputMirroring=1 Print complete input line before execution: path to command, arguments.
 *
 * @return {Object} Returns `wConsequence` instance in async mode. In sync mode returns options map. Options map contains not only input options, but child process descriptor, collected output, exit code and other useful info.
 *
 * @example //short way, command and arguments in one string
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * _.include( 'wConsequence' )
 * _.include( 'wLogger' )
 *
 * let con = _.process.start( 'node -v' );
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @example //command and arguments as options
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * _.include( 'wConsequence' )
 * _.include( 'wLogger' )
 *
 * let con = _.process.start({ execPath : 'node', args : [ '-v' ] });
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @function shell
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

function start_body( o )
{

  _.assertRoutineOptions( start_body, arguments );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.longHas( [ 'fork', 'exec', 'spawn', 'shell' ], o.mode ) );
  _.assert( !!o.args || !!o.execPath, 'Expects {-args-} either {-execPath-}' )
  _.assert( o.args === null || _.arrayIs( o.args ) || _.strIs( o.args ) );
  _.assert( o.execPath === null || _.strIs( o.execPath ) || _.strsAreAll( o.execPath ), 'Expects string or strings {-o.execPath-}, but got', _.strType( o.execPath ) );
  _.assert( o.timeOut === null || _.numberIs( o.timeOut ), 'Expects null or number {-o.timeOut-}, but got', _.strType( o.timeOut ) );
  _.assert( _.longHas( [ 'instant', 'afterdeath' ],  o.when ) || _.objectIs( o.when ), 'Unsupported starting mode:', o.when );

  let state = 0;
  let currentExitCode;
  let killedByTimeout = false;
  let stderrOutput = '';
  let decoratedOutput = '';
  let decoratedErrorOutput = '';
  let startingDelay = 0;

  if( _.objectIs( o.when ) )
  {
    if( Config.debug )
    {
      let keys = _.mapKeys( o.when );
      _.assert( keys.length === 1 && _.longHas([ 'time', 'delay' ], keys[ 0 ] ) );
      _.assert( _.numberIs( o.when.delay ) || _.numberIs( o.when.time ) )
    }

    if( o.when.delay !== undefined )
    startingDelay = o.when.delay;
    else
    startingDelay = o.when.time - _.time.now();

    _.assert( startingDelay >= 0, 'Wrong value of {-o.when.delay } or {-o.when.time-}. Starting delay should be >= 0, current:', startingDelay )
  }

  o.ready = o.ready || new _.Consequence().take( null );

  if( _global_.debugger )
  debugger;

  /* */

  if( _.arrayIs( o.execPath ) || _.arrayIs( o.currentPath ) )
  return multiple();

  /*  */

  if( o.sync && !o.deasync )
  {
    let arg = o.ready.sync();
    if( _.errIs( arg ) )
    throw _.err( arg );
    single();
    end( undefined, o )
    return o;
  }
  else
  {
    if( startingDelay )
    o.ready.then( () => _.time.out( startingDelay, () => null ) )
    o.ready.thenGive( single );
    o.ready.finallyKeep( end );
    
    return endDeasyncMaybe();
  }
  
  /*  */
  
  function endDeasyncMaybe()
  {
    if( o.sync && o.deasync )
    {
      // return o.ready.finallyDeasyncGive();
      o.ready.deasyncWait();
      return o.ready.sync();
    }
    if( !o.sync && o.deasync ) /* qqq : check, does not work properly! Vova: wrote tests for each mode, works as expected*/
    {
      // o.ready.finallyDeasyncKeep();
      o.ready.deasyncWait();
      return o.ready;
    }

    return o.ready;
  }

  /*  */

  function multiple()
  {

    if( _.arrayIs( o.execPath ) && o.execPath.length > 1 && o.concurrent && o.outputAdditive === null )
    o.outputAdditive = 0;

    o.currentPath = o.currentPath || _.path.current();

    let prevReady = o.ready;
    let readies = [];
    let options = [];

    let execPath = _.arrayAs( o.execPath );
    let currentPath = _.arrayAs( o.currentPath );

    for( let p = 0 ; p < execPath.length ; p++ )
    for( let c = 0 ; c < currentPath.length ; c++ )
    {

      let currentReady = new _.Consequence();
      readies.push( currentReady );

      if( o.concurrent )
      {
        prevReady.then( currentReady );
      }
      else
      {
        prevReady.finally( currentReady );
        prevReady = currentReady;
      }

      let o2 = _.mapExtend( null, o );
      o2.execPath = execPath[ p ];
      o2.args = o.args ? o.args.slice() : o.args;
      o2.currentPath = currentPath[ c ];
      o2.ready = currentReady;
      options.push( o2 );
      _.process.start( o2 );

    }

    // debugger;
    o.ready
    // .then( () => new _.Consequence().take( null ).andKeep( readies ) )
    .then( () => _.Consequence.AndKeep( readies ) )
    .finally( ( err, arg ) =>
    {
      // debugger;
      o.exitCode = err ? null : 0;

      for( let a = 0 ; a < options.length-1 ; a++ )
      {
        let o2 = options[ a ];
        if( !o.exitCode && o2.exitCode )
        o.exitCode = o2.exitCode;
      }

      if( err )
      throw err;

      return arg;
    });
    
    if( o.sync && !o.deasync )
    {
      if( o.optionsArrayReturn )
      return options;
      return o;
    }

   /* 
    if( o.sync && o.deasync )
    {
      o.ready.deasyncWait();
      return o.ready.sync();
      // return o.ready.finallyDeasyncGive();
    }
    if( !o.sync && o.deasync ) // qqq : check Vova:wrote test routine, works as expected
    {
      o.ready.deasyncWait();
      return o.ready;
      // o.ready.finallyDeasyncKeep();
      // return o.ready;
    } */

    return endDeasyncMaybe();
  }

  /*  */

  function single()
  {

    _.assert( state === 0 );
    state = 1;

    try
    {
      if( o.when === 'afterdeath' && !o.dry )
      prepareAfterDeath();
      prepare();
      launch();
      pipe();
      
      if( o.dry )
      o.ready.take( o );
    }
    catch( err )
    {
      debugger
      exitCodeSet( -1 );
      if( o.sync && !o.deasync )
      throw _.errLogOnce( err );
      else
      o.ready.error( _.errLogOnce( err ) );
    }

  }

  /* */

  function end( err, arg )
  {

    if( state > 0 )
    {
      if( !o.outputAdditive )
      {
        if( decoratedOutput )
        o.logger.log( decoratedOutput );
        if( decoratedErrorOutput )
        o.logger.error( decoratedErrorOutput );
      }
    }

    if( err )
    {
      if( state < 2 )
      o.exitCode = null;
      throw err;
    }
    return arg;
  }

  /* */

  function prepareAfterDeath()
  {
    let toolsPath = _.path.nativize( _.path.join( __dirname, '../../Tools.s' ) );
    let toolsPathInclude = `let _ = require( '${_.strEscape( toolsPath )}' );\n`

    function secondaryProcess()
    {
      _.include( 'wAppBasic' );
      _.include( 'wFiles' );

      let startOptions;
      let parentPid;
      let interval;
      let delay = 100;

      try
      {
        startOptions = JSON.parse( process.argv[ 2 ] );
      }
      catch ( err )
      {
        _.errLogOnce( err );
      }

      if( !startOptions )
      return;

      parentPid = _.numberFrom( process.argv[ 3 ] )
      interval = setInterval( onInterval, delay );

      /*  */

      function onInterval()
      {
        if( !parentIsRunning() )
        start();
      }

      /*  */

      function parentIsRunning()
      {
        try
        {
          return process.kill( parentPid, 0 );
        }
        catch (e)
        {
          return e.code === 'EPERM'
        }
      }

      /*  */

      function start()
      {
        clearInterval( interval );
        console.log( 'Secondary: starting child process...' );
        _.process.start( startOptions );
      }
    }

    let secondaryProcessSource = toolsPathInclude + secondaryProcess.toString() + '\nsecondaryProcess();';
    let secondaryFilePath = _.process.tempOpen({ sourceCode : secondaryProcessSource });

    let childOptions = _.mapExtend( null, o );

    childOptions.ready = null;
    childOptions.logger = null;
    childOptions.when = 'instant';

    o.execPath = 'node';
    o.mode = 'spawn';
    o.args = [ _.path.nativize( secondaryFilePath ), _.toJson( childOptions ), process.pid ]
    o.ipc = false;
    o.stdio = 'inherit'
    o.detaching = true;
    o.inputMirroring = 0;
  }

  /* */

  function prepare()
  {

    // qqq : cover the case ( args is string ) for both routines shell and sheller
    // Vova: added required test cases
    // if( _.strIs( o.args ) )
    // o.args = _.strSplitNonPreserving({ src : o.args });

    if( _.arrayIs( o.args ) )
    o.args = o.args.slice();

    o.args = _.arrayAs( o.args );

    let execArgs;

    if( _.strIs( o.execPath ) )
    {
      o.fullExecPath = o.execPath;
      execArgs = execPathParse( o.execPath );
      o.execPath = execArgs.shift();
    }

    if( o.execPath === null )
    {
      _.assert( o.args.length, 'Expects {-args-} to have at least one argument if {-execPath-} is not defined' );

      o.execPath = o.args.shift();
      o.fullExecPath = o.execPath;

      let begin = _.strBeginOf( o.execPath, [ '"', "'", '`' ] );
      let end = _.strEndOf( o.execPath, [ '"', "'", '`' ] );

      if( begin && begin === end )
      o.execPath = _.strInsideOf( o.execPath, begin, end );
    }

    if( execArgs && execArgs.length )
    o.args = _.arrayPrependArray( o.args || [], execArgs );

    if( o.outputAdditive === null )
    o.outputAdditive = true;
    o.outputAdditive = !!o.outputAdditive;
    // o.currentPath = o.currentPath || _.path.current();
    o.currentPath = _.path.resolve( o.currentPath || '.' );
    o.logger = o.logger || _global.logger;

    /* verbosity */

    if( !_.numberIs( o.verbosity ) )
    o.verbosity = o.verbosity ? 1 : 0;
    if( o.verbosity < 0 )
    o.verbosity = 0;
    if( o.outputPiping === null )
    o.outputPiping = o.verbosity >= 2;
    if( o.outputCollecting && !o.output )
    o.output = '';

    /* ipc */

    if( o.ipc )
    {
      if( _.strIs( o.stdio ) )
      o.stdio = _.dup( o.stdio, 3 );
      if( !_.longHas( o.stdio, 'ipc' ) )
      o.stdio.push( 'ipc' );
    }

    /* passingThrough */

    if( o.passingThrough )
    {
      let argumentsManual = process.argv.slice( 2 );
      if( argumentsManual.length )
      o.args = _.arrayAppendArray( o.args || [], argumentsManual );
    }

    /* out options */

    o.exitCode = null;
    o.exitSignal = null;
    o.process = null;
    Object.preventExtensions( o );

    /* dependencies */

    if( !ChildProcess )
    ChildProcess = require( 'child_process' );

    if( o.outputGraying )
    if( !StripAnsi )
    StripAnsi = require( 'strip-ansi' );

    if( !o.outputGray && typeof module !== 'undefined' )
    try
    {
      _.include( 'wLogger' );
      _.include( 'wColor' );
    }
    catch( err )
    {
      if( o.verbosity >= 2 )
      _.errLogOnce( err );
    }

  }

  /* */

  function launch()
  {

    /* launch */

    launchAct();

    /* time out */

    if( o.timeOut && !o.dry )
    if( !o.sync || o.deasync )
    _.time.begin( o.timeOut, () =>
    {
      if( state === 2 )
      return;
      killedByTimeout = true;
      o.process.kill( 'SIGTERM' );
    });

  }

  /* */

  function launchAct()
  {
    if( _.strIs( o.interpreterArgs ) )
    o.interpreterArgs = _.strSplitNonPreserving({ src : o.interpreterArgs });

    _.assert( _.fileProvider.isDir( o.currentPath ), 'Current path', o.currentPath, 'doesn\'t exist or it\'s not a directory.' );

    let execPath = o.execPath;
    let args = o.args.slice();

    if( process.platform === 'win32' )
    {
      execPath = _.path.nativize( execPath );
      if( args.length )
      args[ 0 ] = _.path.nativize( args[ 0 ] )
    }

    if( o.mode === 'fork')
    {
      _.assert( !o.sync || o.deasync, '{ shell.mode } "fork" is available only in async/deasync version of shell' );
      let o2 = optionsForFork();
      execPath = execPathForFork( execPath );

      o.fullExecPath = _.strConcat( _.arrayAppendArray( [ execPath ], args ) );
      launchInputLog();
      
      if( o.dry )
      return;
      
      o.process = ChildProcess.fork( execPath, args, o2 );
    }
    else if( o.mode === 'exec' )
    {
      let currentPath = _.path.nativize( o.currentPath );
      log( '{ shell.mode } "exec" is deprecated' );
      if( args.length )
      execPath = execPath + ' ' + argsJoin( args );

      o.fullExecPath = execPath;
      launchInputLog();
      
      if( o.dry )
      return;
      
      if( o.sync && !o.deasync )
      { 
        try
        {
          o.process = ChildProcess.execSync( execPath, { env : o.env, cwd : currentPath } );
          o.process.status = 0;
          o.process.signal = null;
        }
        catch( _process )
        { 
          o.process = _process;
        }
      }
      else
      {
        o.process = ChildProcess.exec( execPath, { env : o.env, cwd : currentPath } );
      }
    }
    else if( o.mode === 'spawn' )
    {
      let o2 = optionsForSpawn();

      o.fullExecPath = _.strConcat( _.arrayAppendArray( [ execPath ], args ) );
      launchInputLog();
      
      if( o.dry )
      return;

      if( o.sync && !o.deasync )
      o.process = ChildProcess.spawnSync( execPath, args, o2 );
      else
      o.process = ChildProcess.spawn( execPath, args, o2 );

    }
    else if( o.mode === 'shell' )
    {

      let appPath = process.platform === 'win32' ? 'cmd' : 'sh';
      let arg1 = process.platform === 'win32' ? '/c' : '-c';
      let arg2 = execPath;
      let o2 = optionsForSpawn();

     /*

      windowsVerbatimArguments allows to have arguments with space(s) in shell on Windows
      Following calls will not work as expected( argument will be splitted by space ), if windowsVerbatimArguments is disabled:

      _.process.start( 'node path/to/script.js "path with space"' );
      _.process.start({ execPath : 'node path/to/script.js', args : [ "path with space" ] });

     */

      o2.windowsVerbatimArguments = true;

      if( args.length )
      arg2 = arg2 + ' ' + argsJoin( args );

      o.fullExecPath = arg2;
      launchInputLog();
      
      if( o.dry )
      return;

      if( o.sync && !o.deasync )
      o.process = ChildProcess.spawnSync( appPath, [ arg1, arg2 ], o2 );
      else
      o.process = ChildProcess.spawn( appPath, [ arg1, arg2 ], o2 );

    }
    else _.assert( 0, 'Unknown mode', _.strQuote( o.mode ), 'to start process at path', _.strQuote( o.paths ) );

    if( o.detaching )
    o.process.unref();

  }

  //

  function launchInputLog()
  {
    /* logger */
    try
    {

      if( o.verbosity && o.inputMirroring )
      {
        let prefix = ' > ';
        if( !o.outputGray )
        prefix = _.color.strFormat( prefix, { fg : 'bright white' } );
        log( prefix + o.fullExecPath );
      }

      if( o.verbosity >= 3 )
      {
        let prefix = '   at ';
        if( !o.outputGray )
        prefix = _.color.strFormat( prefix, { fg : 'bright white' } );
        log( prefix + o.currentPath );
      }

    }
    catch( err )
    {
      debugger;
      _.errLogOnce( err );
    }
  }

  /* */

  function execPathParse( src )
  {
    let strOptions =
    {
      src : src,
      delimeter : [ ' ' ],
      quoting : 1,
      quotingPrefixes : [ "'", '"', "`" ],
      quotingPostfixes : [ "'", '"', "`" ],
      preservingEmpty : 0,
      preservingQuoting : 1,
      stripping : 1
    }
    let args = _.strSplit( strOptions );

    for( let i = 0; i < args.length; i++ )
    {
      let begin = _.strBeginOf( args[ i ], strOptions.quotingPrefixes );
      let end = _.strEndOf( args[ i ], strOptions.quotingPostfixes );
      if( begin )
      {
        _.sure( begin === end, 'Arguments string in execPath:', src, 'has not closed quoting in argument:', args[ i ] );
        args[ i ] = _.strInsideOf( args[ i ], begin, end );
      }
    }
    return args;
  }

  /* */

  function argsJoin( src )
  {
    let args = src.slice();


    for( let i = 0; i < args.length; i++ )
    {
      // escape quotes to make shell interpret them as regular symbols
      let quotesToEscape = process.platform === 'win32' ? [ '"' ] : [ '"', "`" ]
      _.each( quotesToEscape, ( quote ) =>
      {
        args[ i ] = _.strReplaceAll( args[ i ], quote, ( match, it ) =>
        {
          if( it.input[ it.range[ 0 ] - 1 ] === '\\' )
          return match;
          return '\\' + match;
        });
      })
    }

    if( args.length === 1 )
    return _.strQuote( args[ 0 ] );

    //quote only arguments with spaces
    _.each( args, ( arg, i ) =>
    {
      if( _.strHas( src[ i ], ' ' ) )
      args[ i ] = _.strQuote( arg );
    })

    return args.join( ' ' );
  }

  /* */

  function optionsForSpawn()
  {
    let o2 = Object.create( null );
    if( o.stdio )
    o2.stdio = o.stdio;
    o2.detached = !!o.detaching;
    if( o.env )
    o2.env = o.env;
    if( o.currentPath )
    o2.cwd = _.path.nativize( o.currentPath );
    if( o.timeOut && o.sync )
    o2.timeout = o.timeOut;
    o2.windowsHide = !!o.windowHiding;
    return o2;
  }

  /* */

  function optionsForFork()
  {
    let interpreterArgs = o.interpreterArgs || process.execArgv;
    let o2 =
    {
      silent : false,
      env : o.env,
      stdio : o.stdio,
      execArgv : interpreterArgs,
    }

    if( o.currentPath )
    o2.cwd = _.path.nativize( o.currentPath );

    return o2;
  }

  function execPathForFork( execPath )
  {
    let quotes = [ "'", '"', "`" ];
    let begin = _.strBeginOf( execPath, quotes );
    if( begin )
    execPath = _.strInsideOf( execPath, begin, begin );
    return execPath;
  }

  /* */

  function pipe()
  { 
    if( o.dry )
    return;

    /* piping out channel */

    if( o.outputPiping || o.outputCollecting )
    if( o.process.stdout )
    if( o.sync && !o.deasync )
    handleStdout( o.process.stdout );
    else
    o.process.stdout.on( 'data', handleStdout );

    /* piping error channel */

    if( o.process.stderr )
    if( o.sync && !o.deasync )
    handleStderr( o.process.stderr );
    else
    o.process.stderr.on( 'data', handleStderr );

    if( o.sync && !o.deasync )
    {
      if( o.process.error )
      handleError( o.process.error );
      else
      handleClose( o.process.status, o.process.signal );
    }
    else
    {
      o.process.on( 'error', handleError );
      o.process.on( 'close', handleClose );
    }

  }

  /* */

  function exitCodeSet( exitCode )
  {
    if( currentExitCode )
    return;
    if( o.applyingExitCode && exitCode !== 0 )
    {
      currentExitCode = _.numberIs( exitCode ) ? exitCode : -1;
      _.process.exitCode( currentExitCode );
    }
  }

  /* */

  function infoGet()
  {
    let result = '';
    result += 'Launched as ' + _.strQuote( o.fullExecPath ) + '\n';
    result += 'Launched at ' + _.strQuote( o.currentPath ) + '\n';
    if( stderrOutput.length )
    result += '\n -> Stderr' + '\n' + ' -  ' + _.strIndentation( stderrOutput, ' -  ' ) + '\n -< Stderr';
    // !!! : implement error's collectors
    debugger;
    return result;
  }

  /* */

  function handleClose( exitCode, exitSignal )
  {
    // if( exitSignal && exitCode === null )
    // exitCode = -1;

    o.exitCode = exitCode;
    o.exitSignal = exitSignal;

    if( o.verbosity >= 5 )
    {
      log( ' < Process returned error code ' + exitCode );
      if( exitCode )
      {
        log( infoGet() );
      }
    }

    if( state === 2 )
    return;

    state = 2;

    exitCodeSet( exitCode );

    if( ( exitSignal || exitCode !== 0 ) && o.throwingExitCode )
    {
      let err;

      if( _.numberIs( exitCode ) )
      err = _.err( 'Process returned exit code', exitCode, '\n', infoGet() );
      else if( killedByTimeout )
      err = _.err( 'Process timed out, killed by exit signal', exitSignal, '\n', infoGet() );
      else
      err = _.err( 'Process wass killed by exit signal', exitSignal, '\n', infoGet() );

      if( o.briefExitCode )
      err = _.errBrief( err );

      if( o.sync && !o.deasync )
      throw err;
      else
      o.ready.error( err );
    }
    else if( !o.sync || o.deasync )
    {
      o.ready.take( o );
    }

  }

  /* */

  function handleError( err )
  {

    exitCodeSet( -1 );

    if( state === 2 )
    return;

    state = 2;

    err = _.err( 'Error shelling command\n', o.execPath, '\nat', o.currentPath, '\n', err );
    if( o.verbosity )
    err = _.errLogOnce( err );

    if( o.sync && !o.deasync )
    throw err;
    else
    o.ready.error( err );
  }

  /* */

  function handleStderr( data )
  {

    if( _.bufferAnyIs( data ) )
    data = _.bufferToStr( data );

    if( o.outputGraying )
    data = StripAnsi( data );

    stderrOutput += data;

    if( o.outputCollecting )
    o.output += data;

    if( !o.outputPiping )
    return;

    if( _.strEnds( data, '\n' ) )
    data = _.strRemoveEnd( data, '\n' );

    if( o.outputPrefixing )
    data = 'stderr :\n' + '  ' + _.strIndentation( data, '  ' );

    if( _.color && !o.outputGray )
    data = _.color.strFormat( data, 'pipe.negative' );

    log( data, 1 );
  }

  /* */

  function handleStdout( data )
  {

    if( _.bufferAnyIs( data ) )
    data = _.bufferToStr( data );

    if( o.outputGraying )
    data = StripAnsi( data );

    if( o.outputCollecting )
    o.output += data;
    if( !o.outputPiping )
    return;

    if( _.strEnds( data, '\n' ) )
    data = _.strRemoveEnd( data, '\n' );

    if( o.outputPrefixing )
    data = 'stdout :\n' + '  ' + _.strIndentation( data, '  ' );

    if( _.color && !o.outputGray && !o.outputGrayStdout )
    data = _.color.strFormat( data, 'pipe.neutral' );

    log( data );

  }

  /* */

  function log( msg, isError )
  {

    if( o.outputAdditive )
    {
      if( isError )
      o.logger.error( msg );
      else
      o.logger.log( msg );
    }
    else
    {
      decoratedOutput += msg + '\n';
      if( isError )
      decoratedErrorOutput += msg + '\n';
    }

  }

}

start_body.defaults =
{

  execPath : null,
  currentPath : null,
  args : null,
  interpreterArgs : null,

  sync : 0,
  deasync : 0,
  when : 'instant', /* instant / afterdeath / time / delay */
  dry : 0,

  mode : 'shell', /* fork / exec / spawn / shell */
  ready : null,

  logger : null,
  stdio : 'pipe', /* pipe / ignore / inherit */
  ipc : 0,

  env : null,
  detaching : 0,
  windowHiding : 1,
  passingThrough : 0,
  concurrent : 0,
  timeOut : null,
  optionsArrayReturn : 1,//Vova: returns array of maps of options for multiprocess launch in sync mode

  throwingExitCode : 1, /* must be on by default */
  applyingExitCode : 0,
  briefExitCode : 0,

  verbosity : 2,
  outputPrefixing : 0,
  outputPiping : null,
  outputCollecting : 0,
  outputAdditive : null,
  inputMirroring : 1,

  outputGray : 0,
  outputGrayStdout : 0,
  outputGraying : 0,

}

let start = _.routineFromPreAndBody( start_pre, start_body );
/*
qqq
add coverage
Vova: tests routines :

  shellArgsOption,
  shellArgumentsParsing,
  shellArgumentsParsingNonTrivial,
  shellArgumentsNestedQuotes,
  shellExecPathQuotesClosing,
  shellExecPathSeveralCommands

for combination:
  path to exe file : [ with space, without space ]
  execPath : [ has arguments, only path to exe file ]
  args : [ has arguments, empty ]
  mode : [ 'fork', 'exec', 'spawn', 'shell' ]

example of execPath :
  execPath : '"/dir with space/app.exe" firstArg secondArg:1 "third arg" \'fourth arg\'  `"fifth" arg`

== samples

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

//

let startPassingThrough = _.routineFromPreAndBody( start_pre, start_body );

var defaults = startPassingThrough.defaults;

defaults.verbosity = 0;
defaults.passingThrough = 1;
defaults.applyingExitCode = 1;
defaults.throwingExitCode = 0;
defaults.outputPiping = 1;
defaults.stdio = 'inherit';
// defaults.mode = 'spawn'; // xxx : uncomment after fix of the mode

//

/**
 * @summary Short-cut for {@link module:Tools/base/ProcessBasic.Tools( module::ProcessBasic ).start start} routine. Executes provided script in with `node` runtime.
 * @description
 * Expects path to javascript file in `o.execPath` option. Automatically prepends `node` prefix before script path `o.execPath`.
 * @param {Object} o Options map, see {@link module:Tools/base/ProcessBasic.Tools( module::ProcessBasic ).start start} for detailed info about options.
 * @param {Boolean} o.passingThrough=0 Allows to pass arguments of parent process to the child process.
 * @param {Boolean} o.maximumMemory=0 Allows `node` to use all available memory.
 * @param {Boolean} o.applyingExitCode=1 Applies exit code to parent process.
 * @param {String|Array} o.stdio='inherit' Prints all output through stdout,stderr channels of parent.
 *
 * @return {Object} Returns `wConsequence` instance in async mode. In sync mode returns options map. Options map contains not only input options, but child process descriptor, collected output, exit code and other useful info.
 *
 * @example
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * _.include( 'wConsequence' )
 * _.include( 'wLogger' )
 *
 * let con = _.process.startNode({ execPath : 'path/to/script.js' });
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @function startNode
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

function startNode_body( o )
{

  if( !System )
  System = require( 'os' );

  _.include( 'wPathBasic' );
  _.include( 'wFiles' );

  _.assertRoutineOptions( startNode_body, o );
  _.assert( _.strIs( o.execPath ) );
  _.assert( !o.code );
  _.assert( arguments.length === 1, 'Expects single argument' );

  /*
  1024*1024 for megabytes
  1.4 factor found empirically for windows
      implementation of nodejs for other OSs could be able to use more memory
  */

  let logger = o.logger || _global.logger;
  let interpreterArgs = '';
  if( o.maximumMemory )
  {
    let totalmem = System.totalmem();
    if( o.verbosity )
    logger.log( 'System.totalmem()', _.strMetricFormatBytes( totalmem ) );
    if( totalmem < 1024*1024*1024 )
    Math.floor( ( totalmem / ( 1024*1024*1.4 ) - 1 ) / 256 ) * 256;
    else
    Math.floor( ( totalmem / ( 1024*1024*1.1 ) - 1 ) / 256 ) * 256;
    interpreterArgs = '--expose-gc --stack-trace-limit=999 --max_old_space_size=' + totalmem;
  }

  let path = _.fileProvider.path.nativize( o.execPath );
  if( o.mode === 'fork' )
  o.interpreterArgs = interpreterArgs;
  else
  path = _.strConcat([ 'node', interpreterArgs, path ]);

  let startOptions = _.mapOnly( o, _.process.start.defaults );
  startOptions.execPath = path;

  let result = _.process.start( startOptions )
  .give( function( err, arg )
  {
    o.exitCode = startOptions.exitCode;
    o.exitSignal = startOptions.exitSignal;
    this.take( err, arg );
  });

  o.ready = startOptions.ready;
  o.process = startOptions.process;

  return result;
}

var defaults = startNode_body.defaults = Object.create( start.defaults );

defaults.passingThrough = 0;
defaults.maximumMemory = 0;
defaults.applyingExitCode = 1;
defaults.stdio = 'inherit';
defaults.mode = 'fork';

let startNode = _.routineFromPreAndBody( start_pre, startNode_body );

//

/**
 * @summary Short-cut for {@link module:Tools/base/ProcessBasic.Tools( module::ProcessBasic ).startNode startNode} routine.
 * @description
 * Passes arguments of parent process to the child and allows `node` to use all available memory.
 * Expects path to javascript file in `o.execPath` option. Automatically prepends `node` prefix before script path `o.execPath`.
 * @param {Object} o Options map, see {@link module:Tools/base/ProcessBasic.Tools( module::ProcessBasic ).start start} for detailed info about options.
 * @param {Boolean} o.passingThrough=1 Allows to pass arguments of parent process to the child process.
 * @param {Boolean} o.maximumMemory=1 Allows `node` to use all available memory.
 * @param {Boolean} o.applyingExitCode=1 Applies exit code to parent process.
 *
 * @return {Object} Returns `wConsequence` instance in async mode. In sync mode returns options map. Options map contains not only input options, but child process descriptor, collected output, exit code and other useful info.
 *
 * @example
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * _.include( 'wConsequence' )
 * _.include( 'wLogger' )
 *
 * let con = _.process.startNodePassingThrough({ execPath : 'path/to/script.js' });
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @function startNodePassingThrough
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

let startNodePassingThrough = _.routineFromPreAndBody( start_pre, startNode.body );

var defaults = startNodePassingThrough.defaults;

defaults.verbosity = 0;
defaults.passingThrough = 1;
defaults.maximumMemory = 1;
defaults.applyingExitCode = 1;
defaults.throwingExitCode = 0;
defaults.outputPiping = 1;
defaults.mode = 'fork';

//

let startAfterDeath = _.routineFromPreAndBody( start_pre, start.body );

var defaults = startAfterDeath.defaults;

defaults.when = 'afterdeath';

//

/**
 * @summary Generates start routine that reuses provided option on each call.
 * @description
 * Routine vectorize `o.execPath` and `o.args` options. `wConsequence` instance `o.ready` can be reused to run several starts in a row, see examples.
 * @param {Object} o Options map
 *
 * @return {Function} Returns start routine with options saved as inner state.
 *
 * @example //single command execution
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * _.include( 'wConsequence' )
 * _.include( 'wLogger' )
 *
 * let start = _.process.starter({ execPath : 'node' });
 *
 * let con = start({ args : [ '-v' ] });
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @example //multiple commands execution with same args
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * _.include( 'wConsequence' )
 * _.include( 'wLogger' )
 *
 * let start = _.process.starter({ args : [ '-v' ]});
 *
 * let con = start({ execPath : [ 'node', 'npm' ] });
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @example
 * //multiple commands execution with same args, using sinle consequence
 * //second command will be executed when first is finished
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * _.include( 'wConsequence' )
 * _.include( 'wLogger' )
 *
 * let ready = new _.Consequence().take( null );
 * let start = _.process.starter({ args : [ '-v' ], ready });
 *
 * start({ execPath : 'node' });
 *
 * ready.then( ( got ) =>
 * {
 *  console.log( 'node ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * start({ execPath : 'npm' });
 *
 * ready.then( ( got ) =>
 * {
 *  console.log( 'npm ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @function starter
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

function starter( o0 )
{
  _.assert( arguments.length === 0 || arguments.length === 1 );
  if( _.strIs( o0 ) )
  o0 = { execPath : o0 }
  o0 = _.routineOptions( starter, o0 );
  o0.ready = o0.ready || new _.Consequence().take( null );

  _.routineExtend( er, _.process.start );
  er.predefined = o0;
  /* qqq : cover fields of generated routine Vova: wrote test routine shellerFields */

  return er;

  function er()
  {
    let o = optionsFrom( arguments[ 0 ] );
    let o00 = _.mapExtend( null, o0 );
    merge( o00, o );
    _.mapExtend( o, o00 )

    for( let a = 1 ; a < arguments.length ; a++ )
    {
      let o1 = optionsFrom( arguments[ a ] );
      merge( o, o1 );
      _.mapExtend( o, o1 );
    }

    return _.process.start( o );
  }

  function optionsFrom( options )
  {
    if( _.strIs( options ) || _.arrayIs( options ) )
    options = { execPath : options }
    options = options || Object.create( null );
    _.assertMapHasOnly( options, starter.defaults );
    return options;
  }

  function merge( dst, src )
  {
    if( _.strIs( src ) || _.arrayIs( src ) )
    src = { execPath : src }
    _.assertMapHasOnly( src, starter.defaults );

    if( src.execPath !== null && src.execPath !== undefined && dst.execPath !== null && dst.execPath !== undefined )
    {
      _.assert( _.arrayIs( src.execPath ) || _.strIs( src.execPath ), () => 'Expects string or array, but got ' + _.strType( src.execPath ) );
      if( _.arrayIs( src.execPath ) )
      src.execPath = _.arrayFlatten( src.execPath );

      /*
      condition required, otherwise vectorization of results will be done what is not desirable
      */

      if( _.arrayIs( dst.execPath ) || _.arrayIs( src.execPath ) )
      dst.execPath = _.eachSample( [ dst.execPath, src.execPath ] ).map( ( path ) => path.join( ' ' ) );
      else
      dst.execPath = dst.execPath + ' ' + src.execPath;

      delete src.execPath;
    }

    _.mapExtend( dst, src );

    return dst;
  }

}

starter.defaults = Object.create( start.defaults );

// --
// app
// --

/**
 * @summary Parses arguments of current process.
 * @description
 * Supports processing of regular arguments, options( key:value pairs), commands and arrays.
 * @param {Object} o Options map.
 * @param {Boolean} o.keyValDelimeter=':' Delimeter for key:value pairs.
 * @param {String} o.commandsDelimeter=';' Delimeneter for commands, for example : `.build something ; .exit `
 * @param {Array} o.argv=null Arguments array. By default takes arguments from `process.argv`.
 * @param {Boolean} o.caching=true Caches results for speedup next calls.
 * @param {Boolean} o.parsingArrays=true Enables parsing of array from arguments.
 *
 * @return {Object} Returns map with parsed arguments.
 *
 * @example
 *
 * let _ = require('wTools')
 * _.include( 'wProcessBasic' )
 * let result = _.process.args();
 * console.log( result );
 *
 * @function args
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

let _argsCache;
let _argsInSamFormatDefaults = Object.create( null )
var defaults = _argsInSamFormatDefaults.defaults = Object.create( null );

defaults.keyValDelimeter = ':';
defaults.commandsDelimeter = ';';
defaults.caching = true;
defaults.parsingArrays = true;

defaults.interpreterPath = null;
defaults.interpreterArgs = null;
defaults.scriptPath = null;
defaults.scriptArgs = null;

//

function _argsInSamFormatNodejs( o )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );
  o = _.routineOptions( _argsInSamFormatNodejs, arguments );

  if( _.boolLike( o.keyValDelimeter ) )
  o.keyValDelimeter = !!o.keyValDelimeter;

  let isStandardOptions =
       o.keyValDelimeter === _argsInSamFormatNodejs.defaults.keyValDelimeter
    && o.commandsDelimeter === _argsInSamFormatNodejs.defaults.commandsDelimeter
    && o.parsingArrays === _argsInSamFormatNodejs.defaults.parsingArrays
    && o.interpreterPath === _argsInSamFormatNodejs.defaults.interpreterPath
    && o.interpreterArgs === _argsInSamFormatNodejs.defaults.interpreterArgs
    && o.scriptPath === _argsInSamFormatNodejs.defaults.scriptPath
    && o.scriptArgs === _argsInSamFormatNodejs.defaults.scriptArgs;

  if( o.caching )
  if( _argsCache )
  if( isStandardOptions )
  return _argsCache;

  // let result = Object.create( null );
  let result = o;

  if( o.caching )
  // if( o.keyValDelimeter === _argsInSamFormatNodejs.defaults.keyValDelimeter )
  if( isStandardOptions )
  _argsCache = result;

  // if( !_global.process )
  // {
  //   result.subject = '';
  //   result.map = Object.create( null );
  //   result.subjects = [];
  //   result.maps = [];
  //   return result;
  // }

  // o.argv = o.argv || process.argv;
  // result.interpreterArgs = o.interpreterArgs;

  // if( result.applicationArgs === null )
  // result.applicationArgs = process.argv;

  if( result.interpreterArgs === null )
  result.interpreterArgs = _global_.process ? _global_.process.execArgv : [];
  result.interpreterArgsStrings = argsToString( result.interpreterArgs );

  let argv = _global_.process ? _global_.process.argv : [ '', '' ];
  _.assert( _.longIs( argv ) );
  if( result.interpreterPath === null )
  result.interpreterPath = argv[ 0 ];
  result.interpreterPath = _.path.normalize( result.interpreterPath );
  if( result.scriptPath === null )
  result.scriptPath = argv[ 1 ];
  result.scriptPath = _.path.normalize( result.scriptPath );
  if( result.scriptArgs === null )
  result.scriptArgs = argv.slice( 2 );
  result.scriptArgsString = argsToString( result.scriptArgs );

  // debugger;

  let r = _.strRequestParse
  ({
    src : result.scriptArgsString,
    keyValDelimeter : o.keyValDelimeter,
    commandsDelimeter : o.commandsDelimeter,
    parsingArrays : o.parsingArrays,
  });

  _.mapExtend( result, r );

  return result;

  function argsToString( args )
  {
    return args.map( e => _.strHas( e, /\s/ ) ? `"${e}"` : e ).join( ' ' ).trim();
  }
}

_argsInSamFormatNodejs.defaults = Object.create( _argsInSamFormatDefaults.defaults );

//

function _argsInSamFormatBrowser( o )
{
  debugger; /* xxx */

  _.assert( arguments.length === 0 || arguments.length === 1 );
  o = _.routineOptions( _argsInSamFormatBrowser, arguments );

  if( o.caching )
  if( _argsCache && o.keyValDelimeter === _argsCache.keyValDelimeter )
  return _argsCache;

  let result = Object.create( null );

  result.map =  Object.create( null );

  if( o.caching )
  if( o.keyValDelimeter === _argsInSamFormatBrowser.defaults.keyValDelimeter )
  _argsCache = result;

  return result;
}

_argsInSamFormatBrowser.defaults = Object.create( _argsInSamFormatDefaults.defaults );

//

/**
 * @summary Reads options from arguments of current process and copy them on target object `o.dst`.
 * @description
 * Checks if found options are expected using map `o.namesMap`. Throws an Error if arguments contain unknown option.
 *
 * @param {Object} o Options map.
 * @param {Object} o.dst=null Target object.
 * @param {Object} o.propertiesMap=null Map with parsed options. By default routine gets this map using {@link module:Tools/base/ProcessBasic.Tools( module::ProcessBasic ).args args} routine.
 * @param {Object} o.namesMap=null Map of expected options.
 * @param {Object} o.removing=1 Removes copied options from result map `o.propertiesMap`.
 * @param {Object} o.only=1 Check if all option are expected. Throws error if not.
 *
 * @return {Object} Returns map with parsed options.
 *
 * @function argsReadTo
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

function argsReadTo( o )
{

  if( arguments[ 1 ] !== undefined )
  o = { dst : arguments[ 0 ], namesMap : arguments[ 1 ] };

  o = _.routineOptions( argsReadTo, o );

  if( !o.propertiesMap )
  o.propertiesMap = _.process.args().map;

  if( _.arrayIs( o.namesMap ) )
  {
    let namesMap = Object.create( null );
    for( let n = 0 ; n < o.namesMap.length ; n++ )
    namesMap[ o.namesMap[ n ] ] = o.namesMap[ n ];
    o.namesMap = namesMap;
  }

  _.assert( arguments.length === 1 || arguments.length === 2 )
  _.assert( _.objectIs( o.dst ), 'Expects map {-o.dst-}' );
  _.assert( _.objectIs( o.namesMap ), 'Expects map {-o.namesMap-}' );

  for( let n in o.namesMap )
  {
    if( o.propertiesMap[ n ] !== undefined )
    {
      set( o.namesMap[ n ], o.propertiesMap[ n ] );
      if( o.removing )
      delete o.propertiesMap[ n ];
    }
  }

  if( o.only )
  {
    let but = Object.keys( _.mapBut( o.propertiesMap, o.namesMap ) );
    if( but.length )
    {
      throw _.err( 'Unknown application arguments : ' + _.strQuote( but ).join( ', ' ) );
    }
  }

  return o.propertiesMap;

  /* */

  function set( k, v )
  {
    _.assert( o.dst[ k ] !== undefined, () => 'Entry ' + _.strQuote( k ) + ' is not defined' );
    if( _.numberIs( o.dst[ k ] ) )
    {
      v = Number( v );
      _.assert( !isNaN( v ) );
      o.dst[ k ] = v;
    }
    else if( _.boolIs( o.dst[ k ] ) )
    {
      v = !!v;
      o.dst[ k ] = v;
    }
    else
    {
      o.dst[ k ] = v;
    }
  }

}

argsReadTo.defaults =
{
  dst : null,
  propertiesMap : null,
  namesMap : null,
  removing : 1,
  only : 1,
}

//

function anchor( o )
{
  o = o || {};

  _.routineOptions( anchor, arguments );

  let a = _.strStructureParse
  ({
    src : _.strRemoveBegin( window.location.hash, '#' ),
    keyValDelimeter : ':',
    entryDelimeter : ';',
  });

  if( o.extend )
  {
    _.mapExtend( a, o.extend );
  }

  if( o.del )
  {
    _.mapDelete( a, o.del );
  }

  if( o.extend || o.del )
  {

    let newHash = '#' + _.mapToStr
    ({
      src : a,
      keyValDelimeter : ':',
      entryDelimeter : ';',
    });

    if( o.replacing )
    history.replaceState( undefined, undefined, newHash )
    else
    window.location.hash = newHash;

  }

  return a;
}

anchor.defaults =
{
  extend : null,
  del : null,
  replacing : 0,
}

//

/**
 * @summary Allows to set/get exit reason of current process.
 * @description Saves exit reason if argument `reason` was provided, otherwise returns current exit reason value.
 * Returns `null` if reason was not defined yet.
 * @function exitReason
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

function exitReason( reason )
{
  if( !_realGlobal_.wTools )
  _realGlobal_.wTools = Object.create( null );
  if( !_realGlobal_.wTools.process )
  _realGlobal_.wTools.process = Object.create( null );
  if( _realGlobal_.wTools.process._exitReason === undefined )
  _realGlobal_.wTools.process._exitReason = null;
  if( reason === undefined )
  return _realGlobal_.wTools.process._exitReason;
  _realGlobal_.wTools.process._exitReason = reason;
  return _realGlobal_.wTools.process._exitReason;
}

//

/**
 * @summary Allows to set/get exit code of current process.
 * @description Updates exit code if argument `status` was provided and returns previous exit code. Returns current exit code if no argument provided.
 * Returns `0` if exit code was not defined yet.
 * @function exitCode
 * @memberof module:Tools/base/ProcessBasic.Tools( module::ProcessBasic )
 */

function exitCode( status )
{
  let result;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( status === undefined || _.numberIs( status ) );

  if( _global.process )
  {
    result = process.exitCode || 0;
    if( status !== undefined )
    process.exitCode = status;
  }

  return result;
}

//

function exit( exitCode )
{

  exitCode = exitCode !== undefined ? exitCode : _.process.exitCode();

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( exitCode === undefined || _.numberIs( exitCode ) );

  if( _global.process )
  {
    process.exit( exitCode );
  }
  else
  {
    /*debugger;*/
  }

}

//

function exitWithBeep( exitCode )
{

  exitCode = exitCode !== undefined ? exitCode : _.process.exitCode();

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( exitCode === undefined || _.numberIs( exitCode ) );

  _.diagnosticBeep();

  if( exitCode )
  _.diagnosticBeep();

  _.process.exit( exitCode );
}

//

/*
qqq : use maybe exitHandlerRepair instead of exitHandlerOnce?
qqq : investigate difference between exitHandlerRepair and exitHandlerOnce
Vova: exitHandlerRepair allows app to exit safely when one of exit signals will be triggered
      exitHandlerOnce allows to execute some code when process is about to exit:
       - process.exit() was called explcitly
       - no additional work for nodejs event loop
      Correct work of exitHandlerOnce can't be achieved without exitHandlerRepair.
      exitHandlerRepair allows exitHandlerOnce to execute handlers in case when one of termination signals was raised.
*/

let appRepairExitHandlerDone = 0;
function exitHandlerRepair()
{
  
  _.assert( arguments.length === 0 );

  if( appRepairExitHandlerDone )
  return;
  appRepairExitHandlerDone = 1;

  if( typeof process === 'undefined' )
  return;

  // process.on( 'SIGHUP', function()
  // {
  //   debugger;
  //   console.log( 'SIGHUP' );
  //   try
  //   {
  //     process.exit();
  //   }
  //   catch( err )
  //   {
  //     console.log( 'Error!' );
  //     console.log( err.toString() );
  //     console.log( err.stack );
  //     process.removeAllListeners( 'exit' );
  //     process.exit();
  //   }
  // });

  process.on( 'SIGQUIT', function()
  {
    debugger;
    console.log( 'SIGQUIT' );
    try
    {
      process.exit();
    }
    catch( err )
    {
      console.log( 'Error!' );
      console.log( err.toString() );
      console.log( err.stack );
      process.removeAllListeners( 'exit' );
      process.exit();
    }
  });

  process.on( 'SIGINT', function()
  {
    debugger;
    console.log( 'SIGINT' );
    try
    {
      process.exit();
    }
    catch( err )
    {
      console.log( 'Error!' );
      console.log( err.toString() );
      console.log( err.stack );
      process.removeAllListeners( 'exit' );
      process.exit();
    }
  });

  process.on( 'SIGTERM', function()
  {
    debugger;
    console.log( 'SIGTERM' );
    try
    {
      process.exit();
    }
    catch( err )
    {
      console.log( 'Error!' );
      console.log( err.toString() );
      console.log( err.stack );
      process.removeAllListeners( 'exit' );
      process.exit();
    }
  });

  process.on( 'SIGUSR1', function()
  {
    debugger;
    console.log( 'SIGUSR1' );
    try
    {
      process.exit();
    }
    catch( err )
    {
      console.log( 'Error!' );
      console.log( err.toString() );
      console.log( err.stack );
      process.removeAllListeners( 'exit' );
      process.exit();
    }
  });

  process.on( 'SIGUSR2', function()
  {
    debugger;
    console.log( 'SIGUSR2' );
    try
    {
      process.exit();
    }
    catch( err )
    {
      console.log( 'Error!' );
      console.log( err.toString() );
      console.log( err.stack );
      process.removeAllListeners( 'exit' );
      process.exit();
    }
  });

}

//

let _onExitHandlers = [];

function exitHandlerOnce( routine )
{
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );

  _.process.exitHandlerRepair();

  if( typeof process === 'undefined' )
  return;

  if( !_onExitHandlers.length )
  {
    process.once( 'exit', onExitHandler );
    // process.once( 'SIGINT', onExitHandler );
    // process.once( 'SIGTERM', onExitHandler );
  }

  _onExitHandlers.push( routine );

  /*  */

  function onExitHandler( arg )
  {
    _.each( _onExitHandlers, ( routine ) =>
    {
      try
      {
        routine( arg );
      }
      catch( err )
      {
        _.errLogOnce( err );
      }
    })
    process.removeListener( 'exit', onExitHandler );
    // process.removeListener( 'SIGINT', onExitHandler );
    // process.removeListener( 'SIGTERM', onExitHandler );
    _onExitHandlers.splice( 0, _onExitHandlers.length );
  }

}

//

/*
qqq : cover routine exitHandlerOff by tests
Vova : wrote test routine exitHandlerOff
*/

function exitHandlerOff( routine )
{
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );

  debugger;

  return _.arrayRemovedElement( _onExitHandlers, routine );
}

// function exitHandlerOnce( routine )
// {
//   _.assert( arguments.length === 1 );
//   _.assert( _.routineIs( routine ) );
//
//   if( typeof process === 'undefined' )
//   return;
//
//   if( !_onExitHandlers.length )
//   {
//     process.once( 'exit', onExitHandler );
//     process.once( 'SIGINT', onExitHandler );
//     process.once( 'SIGTERM', onExitHandler );
//   }
//
//   _onExitHandlers.push( routine );
//
//   /*  */
//
//   function onExitHandler( arg )
//   {
//     _.each( _onExitHandlers, ( routine ) =>
//     {
//       try
//       {
//         routine( arg );
//       }
//       catch( err )
//       {
//         _.errLogOnce( err );
//       }
//     })
//
//     process.removeListener( 'exit', onExitHandler );
//     process.removeListener( 'SIGINT', onExitHandler );
//     process.removeListener( 'SIGTERM', onExitHandler );
//   }
//
// }

//

function memoryUsageInfo()
{
  var usage = process.memoryUsage();
  return ( usage.heapUsed >> 20 ) + ' / ' + ( usage.heapTotal >> 20 ) + ' / ' + ( usage.rss >> 20 ) + ' Mb';
}

//

let _tempFiles = [];

function tempOpen_pre( routine, args )
{
  let o;

  if( _.strIs( args[ 0 ] ) || _.bufferRawIs( args[ 0 ] ) )
  o = { sourceCode : args[ 0 ] };
  else
  o = args[ 0 ];

  o = _.routineOptions( routine, o );

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1, 'Expects single argument' );

  return o;
}

function tempOpen_body( o )
{
  _.assertRoutineOptions( tempOpen, arguments );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( o.sourceCode ) || _.bufferRawIs( o.sourceCode ), 'Expects string or buffer raw {-o.sourceCode-}, but got', _.strType( o.sourceCode ) );

  let tempDirPath = _.path.pathDirTempOpen( _.path.current() );
  let filePath = _.path.join( tempDirPath, _.idWithDate() + '.ss' );
  _tempFiles.push( filePath );
  _.fileProvider.fileWrite( filePath, o.sourceCode );
  return filePath;
}

var defaults = tempOpen_body.defaults = Object.create( null );
defaults.sourceCode = null;

let tempOpen = _.routineFromPreAndBody( tempOpen_pre, tempOpen_body );

//

function tempClose_pre( routine, args )
{
  let o;

  if( _.strIs( args[ 0 ] ) )
  o = { filePath : args[ 0 ] };
  else
  o = args[ 0 ];

  if( !o )
  o = Object.create( null );

  o = _.routineOptions( routine, o );

  _.assert( arguments.length === 2 );
  _.assert( args.length <= 1, 'Expects single argument or none' );

  return o;
}

function tempClose_body( o )
{
  _.assertRoutineOptions( tempClose, arguments );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( o.filePath ) || o.filePath === null, 'Expects string or null {-o.filePath-}, but got', _.strType( o.filePath ) );

  if( !o.filePath )
  {
    if( !_tempFiles.length )
    return;

    _.fileProvider.filesDelete( _tempFiles );
    _tempFiles.splice( 0 );
  }
  else
  {
    let i = _.longLeftIndex( _tempFiles, o.filePath );
    _.assert( i !== -1, 'Requested {-o.filePath-}', o.filePath, 'is not a path of temp application.' )
    _.fileProvider.fileDelete( o.filePath );
    _tempFiles.splice( i, 1 );
  }
}

var defaults = tempClose_body.defaults = Object.create( null );
defaults.filePath = null;

let tempClose = _.routineFromPreAndBody( tempClose_pre, tempClose_body );

//

function isRunning( pid )
{ 
  _.assert( arguments.length === 1 );
  _.assert( _.numberIs( pid ) );
  
  try
  {
    return process.kill( pid, 0 );
  }
  catch ( err )
  {
    return err.code === 'EPERM'
  }
}

//

function kill( o )
{ 
  if( _.numberIs( o ) )
  o = { pid : o };
  
  _.routineOptions( kill, o );
  _.assert( arguments.length === 1 ); 
  _.assert( _.numberIs( o.pid ) );
  _.assert( _.strDefined( o.signal ) || _.numberIs( o.signal ) );
  
  if( o.signal === 0 )
  return _.process.isRunning( o.pid );
  
  try
  {
    process.kill( o.pid, o.signal );
  }
  catch( err )
  { 
    if( !o.throwing )
    return false;
    
    if( err.code === 'EINVAL' )
    throw _.err( err, '\nAn invalid signal was specified:', _.strQuote( o.signal ) )
    if( err.code === 'EPERM' )
    throw _.err( err, '\nCurrent process does not have permission to kill target process' );
    if( err.code === 'ESRCH' )
    throw _.err( err, '\nTarget process:', _.strQuote( o.pid ), 'does not exist.' );
    throw _.err( err );
  }
  
  return true;
}

var defaults = kill.defaults = Object.create( null );
defaults.pid = null;
defaults.signal = 'SIGTERM'
defaults.throwing = 1;

// --
// declare
// --

let Fields =
{
  _exitReason : null,
}

let Routines =
{

  start,
  startPassingThrough,
  startNode,
  startNodePassingThrough,
  startAfterDeath,
  starter,

  _argsInSamFormatNodejs,
  _argsInSamFormatBrowser,

  argsInSamFormat : Config.interpreter === 'njs' ? _argsInSamFormatNodejs : _argsInSamFormatBrowser,
  args : Config.interpreter === 'njs' ? _argsInSamFormatNodejs : _argsInSamFormatBrowser,
  argsReadTo,

  anchor,

  exitReason, /* qqq : cover and document Vova:wrote test routine exitReason */
  exitCode, /* qqq : cover and document Vova:wrote test routine exitCode */
  exit,
  exitWithBeep,

  exitHandlerRepair,
  exitHandlerOnce,
  exitHandlerOff,

  memoryUsageInfo,

  tempOpen,
  tempClose,
  
  isRunning,
  kill

}

_.mapExtend( Self, Fields );
_.mapExtend( Self, Routines );
_.assert( _.routineIs( _.process.start ) );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
