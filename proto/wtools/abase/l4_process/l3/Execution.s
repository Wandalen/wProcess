( function _Execution_s_()
{

'use strict';

let System, ChildProcess, StripAnsi, WindowsKill, WindowsProcessTree;
let _global = _global_;
let _ = _global_.wTools;
let Self = _.process = _.process || Object.create( null );

_.assert( !!_realGlobal_ );

// --
// starter
// --

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
  // _.assert( _.longHas( [ 'fork', 'exec', 'spawn', 'shell' ], o.mode ) );
  _.assert( _.longHas( [ 'fork', 'spawn', 'shell' ], o.mode ) );
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
 * @param {String} o.mode='shell' Execution mode. Possible values: `fork`, `spawn`, `shell`. {@link https://nodejs.org/api/child_process.html Details about modes}
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
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
 */

function start_body( o )
{

/* Subroutine index :

  preform
  endDeasyncing
  end
  multiple
  single
  form
  launch
  timeOutForm
  pipe
  disconnect
  inputMirror
  execPathParse
  argsUnqoute
  argsJoin
  argEscape
  optionsForSpawn
  optionsForFork
  execPathForFork
  onProcedureTerminationBegin
  exitCodeSet
  infoGet
  handleClose
  handleError
  handleStderr
  handleStdout
  log

*/

  _.assertRoutineOptions( start_body, arguments );
  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( _.longHas( [ 'fork', 'exec', 'spawn', 'shell' ], o.mode ) );
  _.assert( _.longHas( [ 'fork', 'spawn', 'shell' ], o.mode ) );
  _.assert( !!o.args || !!o.execPath, 'Expects {-args-} either {-execPath-}' )
  _.assert( o.args === null || _.arrayIs( o.args ) || _.strIs( o.args ) );
  _.assert( o.execPath === null || _.strIs( o.execPath ) || _.strsAreAll( o.execPath ), 'Expects string or strings {-o.execPath-}, but got', _.strType( o.execPath ) );
  _.assert( o.timeOut === null || _.numberIs( o.timeOut ), 'Expects null or number {-o.timeOut-}, but got', _.strType( o.timeOut ) );
  _.assert( _.longHas( [ 'instant' ],  o.when ) || _.objectIs( o.when ), 'Unsupported starting mode:', o.when );
  _.assert( o.when !== 'afterdeath', `Starting mode:'afterdeath' is moved to separate routine _.process.startAfterDeath` );
  _.assert( !o.detaching || !_.longHas( _.arrayAs( o.stdio ), 'inherit' ), `Unsupported stdio: ${o.stdio} for process detaching` );
  _.assert( !o.detaching || _.longHas( [ 'fork', 'spawn', 'shell' ],  o.mode ), `Unsupported mode: ${o.mode} for process detaching` );
  _.assert( o.onStart === null || _.consequenceIs( o.onStart ) );
  _.assert( o.onTerminate === null || _.consequenceIs( o.onTerminate ) );
  _.assert( !o.ipc || _.longHas( [ 'fork', 'spawn' ], o.mode ), `Mode: ${o.mode} doesn't support inter process communication.` );

  // let state = 0;
  // let currentExitCode;
  let killedByTimeout = false;
  let stderrOutput = '';
  let decoratedOutput = '';
  let decoratedErrorOutput = '';
  let startingDelay = 0;
  let procedure, execArgs, argumentsManual;

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

  preform1();

  if( _global_.debugger )
  debugger;

  /* */

  if( _.arrayIs( o.execPath ) || _.arrayIs( o.currentPath ) )
  return multiple();

  preform2();

  /* */

  if( o.sync && !o.deasync )
  {
    let arg = o.ready.sync();
    single();
    end( undefined, o )
    return o;
  }
  else
  {
    if( startingDelay )
    o.ready.then( () => _.time.out( startingDelay, () => null ) );
    o.ready.thenGive( single );
    if( !o.detaching )
    o.ready.finallyKeep( end );
    return endDeasyncing();
  }

  /* */

  function preform1()
  {
    o.ready = o.ready || new _.Consequence().take( null );

    if( o.onStart === null ) /* qqq2 : implement test for multiple to check onStart works as should */
    {
      o.onStart = o.ready;
      if( !o.detaching )
      o.onStart = new _.Consequence();
    }
    if( o.onTerminate === null )
    {
      o.onTerminate = o.ready;
      if( o.detaching )
      o.onTerminate = new _.Consequence();
    }

    if( o.detaching )
    _.assert( o.ready === o.onStart && o.ready !== o.onTerminate );
    else
    _.assert( o.ready === o.onTerminate && o.ready !== o.onStart );
    _.assert( o.onStart !== o.onTerminate );

  }

  /* */

  function preform2()
  {

    o.disconnect = disconnect;
    o.state = 'initial';
    o.fullExecPath = null;
    o.output = null;
    o.exitCode = null;
    o.exitSignal = null;
    o.process = null;
    o.procedure = null;
    Object.preventExtensions( o );

  }

  /* */

  function endDeasyncing()
  {
    if( o.sync && o.deasync )
    {
      o.ready.deasync();
      return o.ready.sync();
    }
    if( !o.sync && o.deasync )
    {
      o.ready.deasync();
      return o.ready;
    }
    return o.ready;
  }

  /* */

  function end( err, arg )
  {
    // if( state > 0 )
    if( o.state !== 'initial' ) /* xxx */
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
      debugger;
      // if( state < 2 )
      if( o.state !== 'terminated' && o.state !== 'failed' )
      o.exitCode = null;
      throw _.err( err );
    }
    return arg;
  }

  /* */

  function multiple()
  {

    if( _.arrayIs( o.execPath ) && o.execPath.length > 1 && o.concurrent && o.outputAdditive === null )
    o.outputAdditive = 0;

    o.currentPath = o.currentPath || _.path.current();

    let prevReady = o.ready;
    let readies = [];
    let optionsArray = [];

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
      o2.onStart = null;
      o2.onTerminate = null;
      o2.execPath = execPath[ p ];
      o2.args = o.args ? o.args.slice() : o.args;
      o2.currentPath = currentPath[ c ];
      o2.ready = currentReady;
      optionsArray.push( o2 );
      _.process.start( o2 );

    }

    o.ready
    .then( () => _.Consequence.AndKeep_( ... readies ) )
    .finally( ( err, arg ) =>
    {
      o.exitCode = err ? null : 0;

      for( let a = 0 ; a < optionsArray.length-1 ; a++ )
      {
        let o2 = optionsArray[ a ];
        if( !o.exitCode && o2.exitCode )
        o.exitCode = o2.exitCode;
      }

      if( err )
      throw err;

      return arg;
    });

    if( o.sync && !o.deasync )
    {
      if( o.returningOptionsArray )
      return optionsArray;
      return o;
    }

    return endDeasyncing();
  }

  /* */

  function single()
  {

    // _.assert( state === 0 );
    _.assert( o.state === 'initial' );
    // state = 1;

    try
    {
      form();
      launch();
      timeOutForm();
      pipe();
      if( o.dry )
      o.ready.take( o ); /* qqq : should be no o.ready */
    }
    catch( err )
    {
      debugger
      exitCodeSet( -1 );
      if( o.sync && !o.deasync )
      {
        err = _.err( err );
        log( _.errOnce( err ), 1 );
        throw err;
      }
      else
      {
        if( !o.detaching )
        o.onStart.error( err );
        err = _.err( err );
        log( _.errOnce( err ), 1 );
        o.ready.error( err ); /* qqq : should be no o.ready */
      }
    }

  }

  /* */

  function form()
  {

    if( _.arrayIs( o.args ) )
    o.args = o.args.slice();
    o.args = _.arrayAs( o.args );

    if( _.strIs( o.execPath ) )
    {
      o.fullExecPath = o.execPath;
      execArgs = execPathParse( o.execPath );
      // if( o.mode !== 'shell' && o.mode !== 'exec' )
      if( o.mode !== 'shell' )
      execArgs = argsUnqoute( execArgs );
      o.execPath = execArgs.shift();
    }

    if( o.execPath === null )
    {
      _.assert( o.args.length, 'Expects {-args-} to have at least one argument if {-execPath-} is not defined' );

      o.execPath = o.args.shift();
      o.fullExecPath = o.execPath;

      let begin = _.strBeginOf( o.execPath, [ '"', `'`, '`' ] );
      let end = _.strEndOf( o.execPath, [ '"', `'`, '`' ] );

      if( begin && begin === end )
      o.execPath = _.strInsideOf( o.execPath, begin, end );
    }

    if( execArgs && execArgs.length )
    o.args = _.arrayPrependArray( o.args || [], execArgs );

    if( o.outputAdditive === null )
    o.outputAdditive = true;
    o.outputAdditive = !!o.outputAdditive;
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
      argumentsManual = process.argv.slice( 2 );
      if( argumentsManual.length )
      o.args = _.arrayAppendArray( o.args || [], argumentsManual );
    }

    // /* out options */
    //
    // o.exitCode = null;
    // o.exitSignal = null;
    // o.process = null;
    // o.procedure = null;
    // Object.preventExtensions( o );

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
      log( _.errOnce( err ), 1 );
      // _.errLogOnce( err );
    }

    if( o.detaching )
    {
      _.procedure.on( 'terminationBegin', onProcedureTerminationBegin );
    }

  }

  /* */

  function launch()
  {
    o.state = 'starting';

    if( _.strIs( o.interpreterArgs ) )
    o.interpreterArgs = _.strSplitNonPreserving({ src : o.interpreterArgs });

    _.assert
    (
      _.fileProvider.isDir( o.currentPath ),
      () => `Current path ( ${o.currentPath} ) doesn\'t exist or it\'s not a directory.\n> ${o.fullExecPath}`
    );

    let execPath = o.execPath;
    let args = o.args.slice();

    if( process.platform === 'win32' )
    {
      execPath = _.path.nativizeTolerant( execPath );
    }

    if( o.mode === 'fork')
    {
      _.assert( !o.sync || o.deasync, '{ shell.mode } "fork" is available only in async/deasync version of shell' );
      let o2 = optionsForFork();
      execPath = execPathForFork( execPath );

      o.fullExecPath = _.strConcat( _.arrayAppendArray( [ execPath ], args ) );
      inputMirror();

      if( o.dry )
      return;

      o.process = ChildProcess.fork( execPath, args, o2 );
    }
    // else if( o.mode === 'exec' )
    // {
    //   let currentPath = _.path.nativize( o.currentPath );
    //   log( 'option::mode:exec of routine _.process.start is deprecated' );
    //   if( args.length )
    //   execPath = execPath + ' ' + argsJoin( args );
    //
    //   o.fullExecPath = execPath;
    //   inputMirror();
    //
    //   if( o.dry )
    //   return;
    //
    //   if( o.sync && !o.deasync )
    //   {
    //     // debugger;
    //     // o.process = ChildProcess.execSync( execPath, { env : o.env, cwd : currentPath } ); /* yyy */
    //     try
    //     {
    //       o.process = ChildProcess.execSync( execPath, { env : o.env, cwd : currentPath } );
    //       o.process.status = 0;
    //       o.process.signal = null;
    //     }
    //     catch( _process )
    //     {
    //       debugger;
    //       o.process = _process;
    //     }
    //   }
    //   else
    //   {
    //     o.process = ChildProcess.exec( execPath, { env : o.env, cwd : currentPath } );
    //   }
    // }
    else if( o.mode === 'spawn' )
    {
      let o2 = optionsForSpawn();

      o.fullExecPath = _.strConcat( _.arrayAppendArray( [ execPath ], args ) );
      inputMirror();

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
      inputMirror();

      if( o.dry )
      return;

      if( o.sync && !o.deasync )
      o.process = ChildProcess.spawnSync( appPath, [ arg1, arg2 ], o2 );
      else
      o.process = ChildProcess.spawn( appPath, [ arg1, arg2 ], o2 );

    }
    else _.assert( 0, 'Unknown mode', _.strQuote( o.mode ), 'to start process at path', _.strQuote( o.paths ) );

    /* extend with close */

    o.state = 'started';
    o.onStart.take( o );

    if( !o.detaching && !o.sync )
    {
      let result = _.procedure.find( 'PID:' + o.process.pid );
      _.assert( result.length === 0 || result.length === 1, 'Only one procedure expected for child process with pid:', o.pid );
      if( !result.length )
      procedure = o.procedure = _.procedure.begin({ _name : 'PID:' + o.process.pid, _object : o.process });
      else
      o.procedure = result[ 0 ];
    }

  }

  /* */

  function timeOutForm()
  {

    if( o.timeOut && !o.dry )
    if( !o.sync || o.deasync )
    _.time.begin( o.timeOut, () =>
    {
      // if( state === 2 )
      if( o.state === 'terminated' || o.state === 'failed' )
      return;
      killedByTimeout = true;
      o.process.kill( 'SIGTERM' ); /* qqq : need to catch event when process is really down */
    });

  }

  /* */

  function pipe()
  {

    if( o.dry )
    return;

    // qqq2 xxx yyy : uncomment
    // if( o.outputPiping || o.outputCollecting )
    // _.assert( !!o.process.stdout || !!o.process.stderr, 'stdout is not available to collect output or pipe it. Set option::stdio to "pipe"' );

    /* piping out channel */

    if( o.outputPiping || o.outputCollecting )
    if( o.process.stdout )
    if( o.sync && !o.deasync )
    handleStdout( o.process.stdout );
    else
    o.process.stdout.on( 'data', handleStdout );

    /* piping error channel */

    // if( o.outputPiping || o.outputCollecting ) /* qqq : why no such line? */
    if( o.process.stderr )
    if( o.sync && !o.deasync )
    handleStderr( o.process.stderr );
    else
    o.process.stderr.on( 'data', handleStderr );

    /* handling */

    if( o.sync && !o.deasync )
    {
      if( o.process.error )
      handleError( o.process.error ); /* qqq2 : cover this branch in all modes */
      else
      handleClose( o.process.status, o.process.signal ); /* qqq2 : cover this branch in all modes */
    }
    else
    {
      o.process.on( 'error', handleError );
      o.process.on( 'close', handleClose );
    }

  }

  /* */

  function disconnect()
  {

    _.assert( !!this.process, 'Process is not started. Cant disconnect.' );

    if( this.process.stdout )
    this.process.stdout.destroy();
    if( this.process.stderr )
    this.process.stderr.destroy();
    if( this.process.stdin )
    this.process.stdin.destroy();

    if( this.process.disconnect )
    if( this.process.connected )
    this.process.disconnect();

    this.process.unref();

    // xxx qqq : strange? explain
    if( !this.detaching || this.process._disconnected )
    return true;
    this.process._disconnected = true;
    if( _.process.isAlive( this.process.pid ) )
    this.onTerminate.error( _._err({ args : [ 'This process was disconnected' ], reason : 'disconnected' }) );

    return true;
  }

  /* */

  function inputMirror()
  {
    /* logger */
    try
    {

      if( o.verbosity >= 3 )
      {
        let output = '   at ';
        if( !o.outputGray )
        output = _.ct.format( output, { fg : 'bright white' } ) + _.ct.format( o.currentPath, { fg : 'path' } );
        else
        output = output + o.currentPath
        log( output );
      }

      if( o.verbosity && o.inputMirroring )
      {
        let prefix = ' > ';
        if( !o.outputGray )
        prefix = _.ct.format( prefix, { fg : 'bright white' } );
        log( prefix + o.fullExecPath );
      }

    }
    catch( err )
    {
      debugger;
      log( _.errOnce( err ), 1 );
    }
  }

  /* */

  function execPathParse( src )
  {
    let strOptions =
    {
      src,
      delimeter : [ ' ' ],
      quoting : 1,
      quotingPrefixes : [ '"', `'`, '`' ],
      quotingPostfixes : [ '"', `'`, '`' ],
      preservingEmpty : 0,
      preservingQuoting : 1,
      stripping : 1
    }
    let args = _.strSplit( strOptions );

    let quotes = [ '"', `'`, '`' ];
    for( let i = 0; i < args.length; i++ )
    {
      let begin = _.strBeginOf( args[ i ], quotes );
      let end = _.strEndOf( args[ i ], quotes );

      if( begin && end )
      if( begin === end )
      continue;

      if( _.longHas( quotes, args[ i ] ) )
      continue;

      let r = _.strQuoteAnalyze
      ({
        src : args[ i ],
        quote : strOptions.quotingPrefixes
      });

      quotes.forEach( ( quote ) =>
      {
        let found = _.strFindAll( args[ i ], quote );

        if( found.length % 2 === 0 )
        return;

        for( let k = 0; k < found.length; k += 1 )
        {
          let pos = found[ k ].charsRangeLeft[ 0 ];

          for( let j = 0; j < r.ranges.length; j += 2 )
          if( pos >= r.ranges[ j ] && pos <= r.ranges[ j + 1 ] )
          break;
          throw _.err( 'Arguments string in execPath:', src, 'has not closed quoting in argument:', args[ i ] );
        }
      })
    }

    return args;
  }

  /* */

  function argsUnqoute( args )
  {
    let quotes = [ '"', `'`, '`' ];

    for( let i = 0; i < args.length; i++ )
    {
      let begin = _.strBeginOf( args[ i ], quotes );
      let end = _.strEndOf( args[ i ], quotes );
      if( begin )
      if( begin && begin === end )
      args[ i ] = _.strInsideOf( args[ i ], begin, end );
    }

    return args;
  }

  /* */

  function argsJoin( args )
  {
    if( !execArgs && !argumentsManual ) /* qqq : argumentsManual?? should be no such global variable */
    return args.join( ' ' );

    let i = execArgs ? execArgs.length : args.length - argumentsManual.length;
    for( ; i < args.length; i++ )
    {
      let quotesToEscape = process.platform === 'win32' ? [ '"' ] : [ '"', '`' ]
      _.each( quotesToEscape, ( quote ) =>
      {
        args[ i ] = argEscape( args[ i ], quote );
      })
      args[ i ] = _.strQuote( args[ i ] );
    }

    return args.join( ' ' );
  }

  /* */

  function argEscape( arg, quote )
  {
    return _.strReplaceAll( arg, quote, ( match, it ) =>
    {
      if( it.input[ it.charsRangeLeft[ 0 ] - 1 ] === '\\' )
      return match;
      return '\\' + match;
    });
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
      detached : !!o.detaching,
      env : o.env,
      stdio : o.stdio,
      execArgv : interpreterArgs,
    }
    if( o.currentPath )
    o2.cwd = _.path.nativize( o.currentPath );
    return o2;
  }

  /* */

  function execPathForFork( execPath )
  {
    let quotes = [ '"', `'`, '`' ];
    let begin = _.strBeginOf( execPath, quotes );
    if( begin )
    execPath = _.strInsideOf( execPath, begin, begin );
    return execPath;
  }

  /* */

  function onProcedureTerminationBegin()
  {
    // if( o.when === 'instant' ) /* qqq : ? */
    // o.ready.error( _.err( 'Detached child with pid:', o.process.pid, 'is continuing execution after parent death.' ) );
    o.disconnect();
    _.procedure.off( 'terminationBegin', onProcedureTerminationBegin );
  }

  /* */

  function exitCodeSet( exitCode )
  {
    // console.log( _.process.realMainFile(), 'exitCodeSet', exitCode );
    // debugger;
    if( o.exitCode )
    return;
    o.exitCode = exitCode;
    exitCode = _.numberIs( exitCode ) ? exitCode : -1;
    if( o.applyingExitCode )
    _.process.exitCode( exitCode );
    // if( currentExitCode )
    // return;
    // if( o.applyingExitCode && exitCode !== 0 )
    // {
    //   currentExitCode = _.numberIs( exitCode ) ? exitCode : -1;
    //   _.process.exitCode( currentExitCode );
    // }
  }

  /* */

  function infoGet()
  {
    let result = '';
    result += 'Launched as ' + _.strQuote( o.fullExecPath ) + '\n';
    result += 'Launched at ' + _.strQuote( o.currentPath ) + '\n';
    debugger;
    if( stderrOutput.length )
    result += '\n -> Stderr' + '\n' + ' -  ' + _.strLinesIndentation( stderrOutput, ' -  ' ) + '\n -< Stderr';
    return result;
  }

  /* */

  function handleClose( exitCode, exitSignal )
  {
    if( procedure )
    procedure.end();

    if( o.detaching )
    _.procedure.off( 'terminationBegin', onProcedureTerminationBegin );

    // if( exitSignal && exitCode === null )
    // exitCode = -1;

    // debugger;
    exitCodeSet( exitCode );
    // o.exitCode = exitCode;
    o.exitSignal = exitSignal;

    if( o.verbosity >= 5 )
    {
      log( ' < Process returned error code ' + exitCode );
      if( exitCode )
      log( infoGet() );
    }

    // if( state === 2 )
    if( o.state === 'terminated' || o.state === 'failed' ) /* xxx qqq : move above */
    return;

    o.state = 'terminated';
    // state = 2;

    if( ( exitSignal || exitCode !== 0 ) && o.throwingExitCode )
    {
      let err;

      if( _.numberIs( exitCode ) )
      err = _.err( 'Process returned exit code', exitCode, '\n', infoGet() );
      else if( killedByTimeout )
      err = _.err( 'Process timed out, killed by exit signal', exitSignal, '\n', infoGet() );
      else
      err = _.err( 'Process was killed by exit signal', exitSignal, '\n', infoGet() );

      if( o.briefExitCode )
      err = _.errBrief( err );

      if( o.sync && !o.deasync )
      {
        throw err;
      }
      else
      {
        o.onTerminate.error( err );
      }
    }
    else if( !o.sync || o.deasync )
    {
      o.onTerminate.take( o );
    }

  }

  /* */

  function handleError( err )
  {

    exitCodeSet( -1 );

    if( o.state === 'terminated' || o.state === 'failed' ) /* xxx qqq : move above */
    return;

    o.state = 'failed';

    // if( state === 2 )
    // return;
    //
    // state = 2;

    err = _.err( 'Error shelling command\n', o.execPath, '\nat', o.currentPath, '\n', err );
    if( o.verbosity )
    log( _.errOnce( err ), 1 );
    // err = _.errLogOnce( err );

    if( o.sync && !o.deasync )
    {
      throw err;
    }
    else
    {
      o.onTerminate.error( err );
    }
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
    data = 'stderr :\n' + '  ' + _.strLinesIndentation( data, '  ' );

    if( _.color && !o.outputGray )
    data = _.ct.format( data, 'pipe.negative' );

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
    data = 'stdout :\n' + '  ' + _.strLinesIndentation( data, '  ' );

    if( _.color && !o.outputGray && !o.outputGrayStdout )
    data = _.ct.format( data, 'pipe.neutral' );

    log( data );
  }

  /* */

  function log( msg, isError )
  {

    if( msg === undefined )
    return;

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

  /* */

}

start_body.defaults = /* qqq : split on _.process.start(), _.process.startBasic() */
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
  logger : null,
  stdio : 'pipe', /* pipe / ignore / inherit */
  ipc : 0,

  ready : null,
  onStart : null,
  onTerminate : null,

  env : null,
  detaching : 0,
  windowHiding : 1,
  passingThrough : 0,
  concurrent : 0,
  timeOut : null,
  returningOptionsArray : 1, /* Vova: returns array of maps of options for multiprocess launch in sync mode */

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
// defaults.mode = 'spawn'; // qqq xxx : uncomment after fix of the mode

//

/**
 * @summary Short-cut for {@link module:Tools/base/ProcessBasic.Tools.process.start start} routine. Executes provided script in with `node` runtime.
 * @description
 * Expects path to javascript file in `o.execPath` option. Automatically prepends `node` prefix before script path `o.execPath`.
 * @param {Object} o Options map, see {@link module:Tools/base/ProcessBasic.Tools.process.start start} for detailed info about options.
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
 * let con = _.process.startNjs({ execPath : 'path/to/script.js' });
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @function startNjs
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
 */

function startNjs_body( o )
{

  if( !System )
  System = require( 'os' );

  _.include( 'wPathBasic' );
  _.include( 'wFiles' );

  _.assertRoutineOptions( startNjs_body, o );
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

  let path = _.fileProvider.path.nativizeTolerant( o.execPath );

  if( o.mode === 'fork' )
  o.interpreterArgs = interpreterArgs;
  else
  path = _.strConcat([ 'node', interpreterArgs, path ]);

  let startOptions = _.mapOnly( o, _.process.start.defaults );
  startOptions.execPath = path;

  let result = _.process.start( startOptions );

  o.ready = startOptions.ready;
  o.onStart = startOptions.onStart;
  o.onTerminate = startOptions.onTerminate;
  o.process = startOptions.process;
  o.disconnect = startOptions.disconnect;
  // o.status = startOptions.status;

  _.assert( !!startOptions.ready );
  _.assert( !!startOptions.onStart );
  _.assert( !!startOptions.onTerminate );
  _.assert( !!startOptions.disconnect );
  // _.assert( !!startOptions.status );

  startOptions.onStart.give( function( err, arg )
  {
    _.assert( !!startOptions.process );
    _.assert( !!startOptions.disconnect );
    // _.assert( !!startOptions.status );
    o.process = startOptions.process;
    o.disconnect = startOptions.disconnect;
    // o.status = startOptions.status;
    this.take( err, arg );
  })

  startOptions.onTerminate.give( function( err, arg )
  {
    o.output = startOptions.output;
    o.exitCode = startOptions.exitCode;
    o.exitSignal = startOptions.exitSignal;
    // o.status = startOptions.status;
    this.take( err, arg );
  })

  return result;
}

var defaults = startNjs_body.defaults = Object.create( start.defaults );

defaults.passingThrough = 0;
defaults.maximumMemory = 0;
defaults.applyingExitCode = 1;
defaults.stdio = 'inherit';
defaults.mode = 'fork';

let startNjs = _.routineFromPreAndBody( start_pre, startNjs_body );

//

/**
 * @summary Short-cut for {@link module:Tools/base/ProcessBasic.Tools.process.startNjs startNjs} routine.
 * @description
 * Passes arguments of parent process to the child and allows `node` to use all available memory.
 * Expects path to javascript file in `o.execPath` option. Automatically prepends `node` prefix before script path `o.execPath`.
 * @param {Object} o Options map, see {@link module:Tools/base/ProcessBasic.Tools.process.start start} for detailed info about options.
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
 * let con = _.process.startNjsPassingThrough({ execPath : 'path/to/script.js' });
 *
 * con.then( ( got ) =>
 * {
 *  console.log( 'ExitCode:', got.exitCode );
 *  return got;
 * })
 *
 * @function startNjsPassingThrough
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
 */

let startNjsPassingThrough = _.routineFromPreAndBody( start_pre, startNjs.body );

var defaults = startNjsPassingThrough.defaults;

defaults.verbosity = 0;
defaults.passingThrough = 1;
defaults.maximumMemory = 1;
defaults.applyingExitCode = 1;
defaults.throwingExitCode = 0;
defaults.outputPiping = 1;
defaults.mode = 'fork';

//

function startAfterDeath_body( o )
{
  _.assertRoutineOptions( startAfterDeath_body, o );
  _.assert( _.strIs( o.execPath ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  let toolsPath = _.path.nativize( _.path.join( __dirname, '../../../../wtools/Tools.s' ) );
  let toolsPathInclude = `let _ = require( '${_.strEscape( toolsPath )}' );\n`
  let secondaryProcessSource = toolsPathInclude + afterDeathSecondaryProcess.toString() + '\nafterDeathSecondaryProcess();';
  let secondaryFilePath = _.process.tempOpen({ sourceCode : secondaryProcessSource });
  let srcOptions = _.mapExtend( null, o );

  let o2 = _.mapExtend( null, o );
  o2.execPath = _.path.nativize( secondaryFilePath );
  o2.mode = 'fork';
  o2.args = [];
  o2.stdio = 'ignore';
  o2.outputPiping = 0;
  o2.detaching = true;
  o2.inputMirroring = 0;

  let result = _.process.start( o2 );

  o.onStart = o2.onStart;
  o.onTerminate = o2.onTerminate;
  o.ready = o2.ready;
  o.process = o2.process;
  o.disconnect = _.routineJoin( o2, o2.disconnect );

  o2.onStart.give( function( err, got )
  {
    if( !err )
    o2.process.send( srcOptions );
    this.take( err, got );
  })

  o2.onTerminate.catchGive( function( err )
  {
    _.errAttend( err );
    if( err.reason !== 'disconnected' )
    this.error( err );
  })

  return result;

  /* */

  function afterDeathSecondaryProcess()
  {
    _.include( 'wProcess' );
    _.include( 'wFiles' );

    process.on( 'message', ( o ) =>
    {
      process.on( 'disconnect', () => _.process.start( o ) )
    })
  }

}

var defaults = startAfterDeath_body.defaults = Object.create( start.defaults );

let startAfterDeath = _.routineFromPreAndBody( start_pre, startAfterDeath_body );

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
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
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
// exit
// --

/**
 * @summary Allows to set/get exit reason of current process.
 * @description Saves exit reason if argument `reason` was provided, otherwise returns current exit reason value.
 * Returns `null` if reason was not defined yet.
 * @function exitReason
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
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
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
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

// function exitWithBeep( exitCode )
function exitWithBeep()
{
  let exitCode = _.process.exitCode();

  // exitCode = exitCode !== undefined ? exitCode : _.process.exitCode();
  // _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( exitCode === undefined || _.numberIs( exitCode ) );

  _.diagnosticBeep();

  if( exitCode )
  _.diagnosticBeep();

  _.process.exit( exitCode );

  return exitCode;
}

//

/*
zzz : use maybe _exitHandlerRepair instead of _exitHandlerOnce?
zzz : investigate difference between _exitHandlerRepair and _exitHandlerOnce
Vova: _exitHandlerRepair allows app to exit safely when one of exit signals will be triggered
      _exitHandlerOnce allows to execute some code when process is about to exit:
       - process.exit() was called explcitly
       - no additional work for nodejs event loop
      Correct work of _exitHandlerOnce can't be achieved without _exitHandlerRepair.
      _exitHandlerRepair allows _exitHandlerOnce to execute handlers in case when one of termination signals was raised.
*/

let appRepairExitHandlerDone = 0;
function _exitHandlerRepair()
{

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( appRepairExitHandlerDone )
  return;
  appRepairExitHandlerDone = 1;

  if( !_global.process )
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

function _eventExitSetup()
{

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( !_global.process )
  return;

  if( !_.process._registeredExitHandler )
  {
    _global.process.once( 'exit', _.process._eventExitHandle );
    _.process._registeredExitHandler = _.process._eventExitHandle;
    // process.once( 'SIGINT', onExitHandler );
    // process.once( 'SIGTERM', onExitHandler );
  }

}

//

function _eventExitHandle()
{
  let args = arguments;
  _.process.eventGive({ event : 'exit', args });
  process.removeListener( 'exit', _.process._registeredExitHandler );
  // process.removeListener( 'SIGINT', _.process._registeredExitHandler );
  // process.removeListener( 'SIGTERM', _.process._registeredExitHandler );
  _.process._ehandler.events.exit.splice( 0, _.process._ehandler.events.exit.length );
}

// --
// children
// --

function isAlive( src )
{
  let pid = _.process.pidFrom( src );
  _.assert( arguments.length === 1 );
  _.assert( _.numberIs( pid ), `Expects process id as number, but got:${pid}` );

  try
  {
    return process.kill( pid, 0 );
  }
  catch( err )
  {
    return err.code === 'EPERM'
  }

  /* qqq : not handled branch? */
}

//

function pidFrom( src )
{
  _.assert( arguments.length === 1 );

  if( !ChildProcess )
  ChildProcess = require( 'child_process' );

  if( _.numberIs( src ) )
  return src;
  if( _.objectIs( src ) )
  {
    if( src.process )
    src = src.process;
    _.assert( src instanceof ChildProcess.ChildProcess );
    return src.pid;
  }

  _.assert( 0, `Unexpected source:${src}` );
}

//

function statusOf( src )
{
  _.assert( arguments.length === 1 );
  let isAlive = _.process.isAlive( src );
  return isAlive ? 'alive' : 'dead';
}

//

function kill( o )
{
  if( _.numberIs( o ) )
  o = { pid : o };
  else if( _.routineIs( o.kill ) )
  o = { process : o };

  _.assert( arguments.length === 1 );
  _.routineOptions( kill, o );

  if( o.process )
  {
    _.assert( o.pid === null );
    o.pid = o.process.pid;
  }

  _.assert( _.numberIs( o.pid ) );
  _.assert( _.numberIs( o.waitTimeOut ) );

  let isWindows = process.platform === 'win32';

  let ready = _.Consequence().take( null );

  ready.then( () =>
  {
    if( !o.withChildren )
    {
      if( o.process )
      o.process.kill( 'SIGKILL' );
      else
      process.kill( o.pid, 'SIGKILL' )
      return true;
    }

    return _.process.children({ pid : o.pid, asList : isWindows })
    .then( ( children ) =>
    {
      if( !isWindows )
      return killChildren( children );

      for( var l = children.length - 1; l >= 0; l-- )
      {
        if( l && children[ l ].name === 'conhost.exe' )
        continue;
        if( _.process.isAlive( children[ l ].pid ) )
        process.kill( children[ l ].pid, 'SIGKILL' );
      }
      return true;
    })
  })

  ready.then( waitForTermination )
  ready.catch( handleError );

  return ready;

  /* */

  function killChildren( tree )
  {
    for( let pid in tree )
    {
      pid = _.numberFrom( pid );
      if( _.process.isAlive( pid ) )
      process.kill( pid, 'SIGKILL' );
      killChildren( tree[ pid ] );
    }
    return true;
  }

  /* */

  function handleError( err )
  {
    // if( err.code === 'EINVAL' )
    // throw _.err( err, '\nAn invalid signal was specified:', _.strQuote( o.signal ) )
    if( err.code === 'EPERM' )
    throw _.err( err, '\nCurrent process does not have permission to kill target process' );
    if( err.code === 'ESRCH' )
    throw _.err( err, '\nTarget process:', _.strQuote( o.pid ), 'does not exist.' ); /* qqq : rewrite all strings as template-strings */
    throw _.err( err );
  }

  /* */

  function waitForTermination()
  {
    var ready = _.Consequence();
    var timer;
    timer = _.time._periodic( 100, () =>
    {
      if( _.process.isAlive( o.pid ) )
      return false;
      timer._cancel();
      ready.take( true );
      return true;
      /* Dmytro ; new implementation of periodic timer require to return something different to undefined or _.dont.
         Otherwise, timer will be canceled. This code does not affect current behavior of routines and will work with
         new behavior.

         When module Tools will be updated, we can use next code instead of current :

        if( _.process.isAlive( o.pid ) )
        return false;
        ready.take( true );
       */
    });

    let timeOutError = _.time.outError( o.waitTimeOut )

    ready.orKeepingSplit( [ timeOutError ] );

    ready.finally( ( err, got ) =>
    {
      if( !timeOutError.resourcesCount() )
      timeOutError.take( _.dont );

      if( err )
      {
        _.errAttend( err );
        if( err.reason === 'time out' )
        err = _.err( err, `\nTarget process: ${_.strQuote( o.pid )} is still alive. Waited for ${o.waitTimeOut} ms.` );
        throw err;
      }
      return got;
    })

    return ready;
  }

  /* */

}

kill.defaults =
{
  pid : null,
  process : null,
  withChildren : 0,
  waitTimeOut : 5000
}

//

/*
  zzz Vova: shell mode have different behaviour on Windows, OSX and Linux
  look for solution that allow to have same behaviour on each mode
*/

function terminate( o )
{
  if( _.numberIs( o ) )
  o = { pid : o };
  else if( _.routineIs( o.kill ) )
  o = { process : o };

  _.assert( arguments.length === 1 );
  _.routineOptions( terminate, o );
  _.assert( o.timeOut === null || _.numberIs( o.timeOut ) );

  if( o.process )
  {
    _.assert( o.pid === null );
    o.pid = o.process.pid;
  }

  _.assert( _.numberIs( o.pid ) );

  let isWindows = process.platform === 'win32';

  try
  {
    if( !o.withChildren )
    return terminateProcess( o.pid );

    let ready = _.process.children({ pid : o.pid, asList : isWindows })
    .then( ( tree ) =>
    {
      if( isWindows )
      return terminateChildrenWin( tree )
      else
      return terminateChildren( tree );
    })
    .catch( handleError );

    return ready;
  }
  catch( err )
  {
    handleError( err );
  }

  /* */

  function terminateProcess( pid )
  {
    let result;

    if( isWindows )
    result = windowsKill( pid );
    else
    result = process.kill( pid, 'SIGINT' );

    timeOutMaybe( pid );

    return result;
  }

  /* */

  function windowsKill( pid )
  {
    return _.process.start
    ({
      execPath : 'node',
      args : [ '-e', `var kill = require( 'wwindowskill' )();kill( ${pid},'SIGINT' )` ],
      currentPath : __dirname,
      inputMirroring : 0,
      outputPiping : 1,
      mode : 'spawn',
      windowHiding : 1,
      timeOut : o.timeOut,
      throwingExitCode : 0,
      sync : 0
    })
  }

  /* */

  function timeOutMaybe( pid )
  {
    if( o.timeOut )
    _.time.out( o.timeOut, () =>
    {
      if( !_.process.isAlive( pid ) )
      return null;
      if( o.process )
      o.process.kill( 'SIGKILL' )
      else
      process.kill( pid, 'SIGKILL' );
    })
  }

  /* */

  function handleError( err )
  {
    if( err.code === 'EPERM' )
    throw _.err( err, '\nCurrent process does not have permission to kill target process' );
    if( err.code === 'ESRCH' )
    throw _.err( err, '\nTarget process:', _.strQuote( o.pid ), 'does not exist.' );
    throw _.err( err );
  }

  /* */

  function terminateChildren( tree )
  {
    for( let pid in tree )
    {
      pid = _.numberFrom( pid );
      if( _.process.isAlive( pid ) )
      terminateProcess( pid );
      terminateChildren( tree[ pid ] );
    }
    return null;
  }

  /* */

  function terminateChildrenWin( tree )
  {
    let cons = [];
    for( var l = tree.length - 1; l >= 0; l-- )
    {
      if( l && tree[ l ].name === 'conhost.exe' )
      continue;
      if( !_.process.isAlive( tree[ l ].pid ) )
      continue;
      cons.push( terminateProcess( tree[ l ].pid ) );
    }
    if( cons.length )
    return _.Consequence.AndKeep_( ... cons );
    return true;
  }

}

terminate.defaults =
{
  process : null,
  pid : null,
  withChildren : 0,
  timeOut : 5000
}

//

function children( o )
{
  if( _.numberIs( o ) )
  o = { pid : o };
  else if( _.routineIs( o.kill ) )
  o = { process : o }

  _.routineOptions( children, o )
  _.assert( arguments.length === 1 );
  _.assert( _.numberIs( o.pid ) );

  if( o.process )
  {
    _.assert( o.pid === null );
    o.pid = o.process.pid;
  }

  let result;

  if( !_.process.isAlive( o.pid ) )
  {
    let err = _.err( '\nTarget process:', _.strQuote( o.pid ), 'does not exist.' );
    return new _.Consequence().error( err );
  }

  if( process.platform === 'win32' )
  {
    if( !WindowsProcessTree )
    {
      try
      {
        WindowsProcessTree = require( 'wwindows-process-tree' );
      }
      catch( err )
      {
        throw _.err( 'Failed to get child process list.\n', err );
      }
    }

    let con = new _.Consequence();
    if( o.asList )
    {
      WindowsProcessTree.getProcessList( o.pid, ( result ) => con.take( result ) )
    }
    else
    {
      WindowsProcessTree.getProcessTree( o.pid, ( got ) =>
      {
        result = Object.create( null );
        handleWindowsResult( result, got );
        con.take( result );
      })
    }
    return con;
  }
  else
  {
    if( o.asList )
    result = [];
    else
    result = Object.create( null );

    if( process.platform === 'darwin' )
    return childrenOf( 'pgrep -P', o.pid, result )
    else
    return childrenOf( 'ps -o pid --no-headers --ppid', o.pid, result )
  }

  /* */

  function childrenOf( command, pid, _result )
  {
    return _.process.start
    ({
      execPath : command + ' ' + pid,
      outputCollecting : 1,
      throwingExitCode : 0,
      inputMirroring : 0
    })
    .then( ( got ) =>
    {
      if( o.asList )
      _result.push( _.numberFrom( pid ) );
      else
      _result[ pid ] = Object.create( null );
      if( got.exitCode !== 0 )
      return result;
      let ready = new _.Consequence().take( null );
      let pids = _.strSplitNonPreserving({ src : got.output, delimeter : '\n' });
      _.each( pids, ( cpid ) => ready.then( () => childrenOf( command, cpid, o.asList ? _result : _result[ pid ] ) ) )
      return ready;
    })
  }

  function handleWindowsResult( tree, result )
  {
    tree[ result.pid ] = Object.create( null );
    if( result.children && result.children.length )
    _.each( result.children, ( child ) => handleWindowsResult( tree[ result.pid ], child ) )
    return tree;
  }

}

children.defaults =
{
  process : null,
  pid : null,
  asList : 0
}

// --
// declare
// --

let Extension =
{

  // start

  start,
  startPassingThrough,
  startNjs,
  startNjsPassingThrough,
  startAfterDeath,
  starter,

  // exit

  exitReason,
  exitCode,
  exit,
  exitWithBeep,

  _exitHandlerRepair, /* zzz */

  _eventExitSetup,
  _eventExitHandle,

  // children

  isAlive,
  pidFrom,
  statusOf,
  kill,
  terminate,
  children,

  // fields

  _exitReason : null,

}

_.mapExtend( Self, Extension );
_.assert( _.routineIs( _.process.start ) );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
