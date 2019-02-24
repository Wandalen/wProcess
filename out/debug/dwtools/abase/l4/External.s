( function _External_s_() {

'use strict';

/**
 * Collection of routines to execute system commands, run shell, batches, launch external processes from JavaScript application. ExecTools leverages not only outputting data from an application but also inputting, makes application arguments parsing and accounting easier. Use the module to get uniform experience from interaction with an external processes on different platforms and operating systems.
  @module Tools/base/ExternalFundamentals
*/

/**
 * @file ExternalFundamentals.s.
 */

let Esprima, Deasync;

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wPathFundamentals' );
  _.include( 'wGdfStrategy' );

}

let System, ChildProcess, Net, Stream;

let _global = _global_;
let _ = _global_.wTools;
let Self = _global_.wTools;

let _ArraySlice = Array.prototype.slice;
let _FunctionBind = Function.prototype.bind;
let _ObjectToString = Object.prototype.toString;
let _ObjectHasOwnProperty = Object.hasOwnProperty;
let _arraySlice = _.longSlice;

_.assert( !!_realGlobal_ );

// --
// exec
// --

/*
qqq : implement multiple commands
resolved : implement option timeOut aaa : done, needs review
*/

function shell( o )
{

  if( _.strIs( o ) )
  o = { path : o };

  _.routineOptions( shell, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( o.args === null || _.arrayIs( o.args ) );
  _.assert( _.arrayHas( [ 'fork', 'exec', 'spawn', 'shell' ], o.mode ) );
  _.assert( _.strIs( o.path ) || _.strsAreAll( o.path ), 'Expects string or strings {-o.path-}, but got', _.strType( o.path ) );
  _.assert( o.timeOut === null || _.numberIs( o.timeOut ), 'Expects null or number {-o.timeOut-}, but got', _.strType( o.timeOut ) );

  let done = false;
  let currentExitCode;
  let currentPath;
  let killedByTimeout = false;
  let stderrOutput = '';

  o.ready = o.ready || new _.Consequence().take( null );

  /* xxx : problem */

  if( _.arrayIs( o.path ) )
  {
    for( let p = 0 ; p < o.path.length ; p++ )
    {
      let o2 = _.mapExtend( null, o );
      o2.path = o.path[ p ];
      _.shell( o2 );
    }

    if( o.sync && !o.deasync )
    return o;

    if( o.sync && o.deasync )
    return waitForCon( o.ready );

    return o.ready;
  }

  /*  */

  if( o.sync && !o.deasync )
  {
    main();
    return o;
  }
  else
  {
    o.ready.ifNoErrorGot( main );

    // o.ready.finally( ( err, arg ) =>
    // {
    //   debugger;
    //   if( err )
    //   throw err;
    //   return arg;
    // });

    if( o.sync && o.deasync )
    return waitForCon( o.ready );

    return o.ready;
  }

  /*  */

  function main()
  {

    let done = false;
    let currentExitCode;
    currentPath = o.currentPath || _.path.current();

    o.logger = o.logger || _global_.logger;

    prepare();

    if( !o.outputGray && typeof module !== 'undefined' )
    try
    {
      _.include( 'wLogger' );
      _.include( 'wColor' );
    }
    catch( err )
    {
      if( o.verbosity )
      _.errLogOnce( err );
    }

    /* logger */

    o.argsStr = _.strConcat( _.arrayAppendArray( [ o.path ], o.args || [] ) );

    if( o.verbosity && o.outputMirroring )
    {
      let prefix = ' > ';
      if( !o.outputGray )
      prefix = _.color.strFormat( prefix, { fg : 'bright white' } );
      o.logger.log( prefix + o.argsStr );
    }

    // let prefix = ' > ';
    // o.logger.log( prefix + o.argsStr ); // xxx

    /* create process */

    try
    {
      launch();
    }
    catch( err )
    {
      debugger
      appExitCode( -1 );
      if( o.sync && !o.deasync )
      throw _.errLogOnce( err );
      else
      return o.ready.error( _.errLogOnce( err ) );
    }

    /* piping out channel */

    if( o.outputPiping || o.outputCollecting )
    if( o.process.stdout )
    if( o.sync && !o.deasync )
    handleStdout( o.process.stdout );
    else
    o.process.stdout.on( 'data', handleStdout );

    /* piping error channel */

    // if( o.outputPiping || o.outputCollecting )
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
      /* error */

      o.process.on( 'error', handleError );

      /* close */

      o.process.on( 'close', handleClose );
    }

  }


  /* */

  function prepare()
  {

    /* verbosity */

    // debugger;
    if( !_.numberIs( o.verbosity ) )
    o.verbosity = o.verbosity ? 1 : 0;
    if( o.verbosity < 0 )
    o.verbosity = 0;
    if( o.outputPiping === null )
    o.outputPiping = o.verbosity >= 2;
    if( o.outputCollecting && !o.output )
    o.output = '';

    // _.assert( !o.outputCollecting || !!o.outputPiping, 'If {-o.outputCollecting-} enabled then {-o.outputPiping-} either should be' );

    // console.log( 'o.outputCollecting', o.outputCollecting );

    /* ipc */

    if( o.ipc )
    {
      if( _.strIs( o.stdio ) )
      o.stdio = _.dup( o.stdio,3 );
      if( !_.arrayHas( o.stdio,'ipc' ) )
      o.stdio.push( 'ipc' );
    }

    /* passingThrough */

    if( o.passingThrough )
    {
      let argumentsManual = process.argv.slice( 2 );
      if( argumentsManual.length )
      o.args = _.arrayAppendArray( o.args || [], argumentsManual );
    }

    /* etc */

    if( !ChildProcess )
    ChildProcess = require( 'child_process' );

  }

  /* */

  function launch()
  {
    let optionsForSpawn = Object.create( null );

    if( o.stdio )
    optionsForSpawn.stdio = o.stdio;
    optionsForSpawn.detached = !!o.detaching;
    if( o.env )
    optionsForSpawn.env = o.env;
    if( o.currentPath )
    optionsForSpawn.cwd = _.path.nativize( o.currentPath );

    if( o.timeOut && o.sync )
    optionsForSpawn.timeout = o.timeOut;

    if( _.strIs( o.interpreterArgs ) )
    o.interpreterArgs = _.strSplitNonPreserving({ src : o.interpreterArgs, preservingDelimeters : 0 });

    // debugger;
    if( o.mode === 'fork')
    {
      _.assert( !o.sync || o.deasync, '{ shell.mode } "fork" is available only in async/deasync version of shell' );
      let interpreterArgs = o.interpreterArgs || process.execArgv;
      let args = o.args || [];
      o.process = ChildProcess.fork( o.path, args, { silent : false, env : o.env, cwd : optionsForSpawn.cwd, stdio : optionsForSpawn.stdio, execArgv : interpreterArgs } );
    }
    else if( o.mode === 'exec' )
    {
      o.logger.warn( '{ shell.mode } "exec" is deprecated' );
      if( o.sync && !o.deasync )
      o.process = ChildProcess.execSync( o.path,{ env : o.env, cwd : optionsForSpawn.cwd } );
      else
      o.process = ChildProcess.exec( o.path,{ env : o.env, cwd : optionsForSpawn.cwd } );
    }
    else if( o.mode === 'spawn' )
    {
      let app = o.path;

      if( !o.args )
      {
        o.args = _.strSplitNonPreserving({ src : o.path, preservingDelimeters : 0 });
        app = o.args.shift();
      }
      else
      {
        if( app.length )
        _.assert( _.strSplitNonPreserving({ src : app, preservingDelimeters : 0 }).length === 1, ' o.path must not contain arguments if those were provided through options' )
      }

      if( o.sync && !o.deasync )
      o.process = ChildProcess.spawnSync( app, o.args, optionsForSpawn );
      else
      o.process = ChildProcess.spawn( app, o.args, optionsForSpawn );

    }
    else if( o.mode === 'shell' )
    {

      let app = process.platform === 'win32' ? 'cmd' : 'sh';
      let arg1 = process.platform === 'win32' ? '/c' : '-c';
      let arg2 = o.path;

      optionsForSpawn.windowsVerbatimArguments = true; /* qqq : explain why is it needed please */

      if( o.args && o.args.length )
      arg2 = arg2 + ' ' + '"' + o.args.join( '" "' ) + '"';

      if( o.sync && !o.deasync )
      o.process = ChildProcess.spawnSync( app, [ arg1, arg2 ], optionsForSpawn );
      else
      o.process = ChildProcess.spawn( app, [ arg1, arg2 ], optionsForSpawn );

    }
    else _.assert( 0,'Unknown mode', _.strQuote( o.mode ), 'to shell path', _.strQuote( o.paths ) );

    if( o.timeOut && !( o.sync && !o.deasync ) )
    _.timeOut( o.timeOut, () =>
    {
      if( !done )
      {
        killedByTimeout = true;
        o.process.kill( 'SIGTERM' );
      }

      return true;
    });

  }

  /* */

  function appExitCode( exitCode )
  {
    if( currentExitCode )
    return;
    if( o.applyingExitCode && exitCode !== 0 )
    {
      currentExitCode = _.numberIs( exitCode ) ? exitCode : -1;
      _.appExitCode( currentExitCode );
    }
  }

  /* */

  function infoGet()
  {
    let result = '';
    debugger;
    result += 'Launched as ' + _.strQuote( o.argsStr ) + '\n';
    result += 'Launched at ' + _.strQuote( currentPath ) + '\n';
    if( stderrOutput.length )
    result += '\n * Stderr' + '\n' + stderrOutput + '\n'; // !!! : implemen error's collectors
    return result;
  }

  /* */

  function handleClose( exitCode, signal )
  {

    o.exitCode = exitCode;
    o.signal = signal;

    if( o.verbosity >= 5 )
    {
      o.logger.log( 'Process returned error code', exitCode );
      if( exitCode )
      {
        o.logger.log( infoGet() );
      }
    }

    if( done )
    return;

    done = true;

    appExitCode( exitCode );

    if( exitCode !== 0 && o.throwingExitCode )
    {
      debugger;

      let err;

      if( _.numberIs( exitCode ) )
      err = _.err( 'Process returned error code', exitCode, '\n', infoGet() );
      else if( killedByTimeout )
      err = _.err( 'Process timed out, killed by signal', signal, '\n', infoGet() );
      else
      err = _.err( 'Process wass killed by signal', signal, '\n', infoGet() );

      if( o.sync && !o.deasync )
      throw err;
      else
      o.ready.error( err );
    }
    else if( !( o.sync && !o.deasync ) )
    {
      o.ready.take( o );
    }

  }

  /* */

  function handleError( err )
  {

    appExitCode( -1 );

    if( done )
    return;

    done = true;

    debugger;
    err = _.err( 'Error shelling command\n', o.path, '\nat', o.currentPath, '\n', err );
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

    stderrOutput += data;

    if( o.outputCollecting )
    o.output += data;
    if( !o.outputPiping )
    return;

    if( _.strEnds( data,'\n' ) )
    data = _.strRemoveEnd( data,'\n' );

    if( o.outputPrefixing )
    data = 'stderr :\n' + _.strIndentation( data,'  ' );

    if( _.color && !o.outputGray )
    data = _.color.strFormat( data,'pipe.negative' );

    o.logger.error( data );
  }

  /* */

  function handleStdout( data )
  {

    if( _.bufferAnyIs( data ) )
    data = _.bufferToStr( data );

    if( o.outputCollecting )
    o.output += data;
    if( !o.outputPiping )
    return;

    if( _.strEnds( data,'\n' ) )
    data = _.strRemoveEnd( data,'\n' );

    if( o.outputPrefixing )
    data = 'stdout :\n' + _.strIndentation( data,'  ' );

    if( _.color && !o.outputGray && !o.outputGrayStdout )
    data = _.color.strFormat( data, 'pipe.neutral' );

    o.logger.log( data );
  }

  /* */

  /* qqq : use Consequence.deasync */
  function waitForCon( con )
  {
    let ready = false;
    let result = Object.create( null );

    con.got( ( err, data ) =>
    {
      result.err = err;
      result.data = data;
      ready = true;
    })

    if( !Deasync )
    Deasync = require( 'deasync' );
    Deasync.loopWhile( () => !ready )

    if( result.err )
    throw result.err;
    return result.data;
  }

}

/*
qqq : implement currentPath for all modes
*/

shell.defaults =
{

  path : null,
  currentPath : null,

  sync : 0,
  deasync : 1,

  args : null,
  interpreterArgs : null,
  mode : 'shell', /* 'fork', 'exec', 'spawn', 'shell' */
  ready : null,
  logger : null,

  env : null,
  stdio : 'pipe', /* 'pipe' / 'ignore' / 'inherit' */
  ipc : 0,
  detaching : 0,
  passingThrough : 0,
  timeOut : null,

  throwingExitCode : 1, /* must be on by default */
  applyingExitCode : 0,

  verbosity : 2,
  outputGray : 0,
  outputGrayStdout : 0,
  outputPrefixing : 0,
  outputPiping : null,
  outputCollecting : 0,
  outputMirroring : 1,

}

//

function sheller( o0 )
{
  _.assert( arguments.length === 0 || arguments.length === 1 );
  if( _.strIs( o0 ) )
  o0 = { path : o0 }
  o0 = _.routineOptions( sheller, o0 );
  o0.ready = o0.ready || new _.Consequence().take( null );

  return function er()
  {
    let o = _.mapExtend( null, o0 );

    if( _.arrayIs( o.path  ) )
    o.path = _.arrayFlatten( o.path );

    for( let a = 0 ; a < arguments.length ; a++ )
    {
      let o1 = arguments[ 0 ];
      if( _.strIs( o1 ) || _.arrayIs( o1 ) )
      o1 = { path : o1 }
      _.assertMapHasOnly( o1, sheller.defaults );
      if( o1.path && o.path )
      {
        _.assert( _.arrayIs( o1.path ) || _.strIs( o1.path ), () => 'Expects string or array, but got ' + _.strType( o1.path ) );
        // if( _.arrayIs( o1.path ) )
        // o.path = _.arrayAppendArrayOnce( _.arrayAs( o.path ), o1.path );
        // else
        // o.path = o.path + ' ' + o1.path;
        if( _.arrayIs( o1.path ) )
        o1.path = _.arrayFlatten( o1.path );
        o.path = _.eachSample( [ o.path, o1.path ] );
        delete o1.path;
      }

      _.mapExtend( o, o1 );

    }

    if( _.arrayIs( o.path ) )
    {
      // debugger;

      let os = o.path.map( ( path ) =>
      {
        let o2 = _.mapExtend( null, o );
        o2.path = path;
        if( _.arrayIs( path ) )
        o2.path = o2.path.join( ' ' );
        o2.ready = null;
        return function onPath()
        {
          return _.shell( o2 );
        }
      })

      // debugger;
      return o.ready.andKeep( os );
    }

    return _.shell( o );
  }

}

sheller.defaults = Object.create( shell.defaults );

//

function shellNode( o )
{

  if( !System )
  System = require( 'os' );

  _.include( 'wPathFundamentals' );
  _.include( 'wFiles' );

  if( _.strIs( o ) )
  o = { path : o }

  _.routineOptions( shellNode,o );
  _.assert( _.strIs( o.path ) );
  _.assert( !o.code );
  _.accessor.forbid( o,'child' );
  _.accessor.forbid( o,'returnCode' );
  _.assert( arguments.length === 1, 'Expects single argument' );

  /*
  1024*1024 for megabytes
  1.4 factor found empirically for windows
      implementation of nodejs for other OSs could be able to use more memory
  */

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

  let path = _.fileProvider.path.nativize( o.path );
  if( o.mode === 'fork' )
  o.interpreterArgs = interpreterArgs;
  else
  path = _.strConcat([ 'node', interpreterArgs, path ]);

  let shellOptions = _.mapOnly( o, _.shell.defaults );
  shellOptions.path = path;

  let result = _.shell( shellOptions )
  .got( function( err,arg )
  {
    // if( shellOptions.exitCode )
    // _.appExit( -1 );
    o.exitCode = shellOptions.exitCode;
    o.signal = shellOptions.signal;
    this.take( err,arg );
  });

  o.ready = shellOptions.ready;
  o.process = shellOptions.process;

  return result;
}

var defaults = shellNode.defaults = Object.create( shell.defaults );

defaults.passingThrough = 0;
defaults.maximumMemory = 0;
defaults.applyingExitCode = 1;
defaults.stdio = 'inherit';

//

function shellNodePassingThrough( o )
{

  if( _.strIs( o ) )
  o = { path : o }

  _.routineOptions( shellNodePassingThrough,o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  let result = _.shellNode( o );

  return result;
}

var defaults = shellNodePassingThrough.defaults = Object.create( shellNode.defaults );

defaults.passingThrough = 1;
defaults.maximumMemory = 1;
defaults.applyingExitCode = 1;

// --
// app
// --

let _appArgsCache;
let _appArgsInSamFormat = Object.create( null )
var defaults = _appArgsInSamFormat.defaults = Object.create( null );

defaults.keyValDelimeter = ':';
defaults.subjectsDelimeter = ';';
defaults.argv = null;
defaults.caching = true;
defaults.parsingArrays = true;

//

function _appArgsInSamFormatNodejs( o )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );
  o = _.routineOptions( _appArgsInSamFormatNodejs,arguments );

  if( o.caching )
  if( _appArgsCache && o.keyValDelimeter === _appArgsCache.keyValDelimeter && o.subjectsDelimeter === _appArgsCache.subjectsDelimeter )
  return _appArgsCache;

  let result = Object.create( null );

  if( o.caching )
  if( o.keyValDelimeter === _appArgsInSamFormatNodejs.defaults.keyValDelimeter )
  _appArgsCache = result;

  if( !_global.process )
  {
    result.subject = '';
    result.map = Object.create( null );
    result.subjects = [];
    result.maps = [];
    return result;
  }

  o.argv = o.argv || process.argv;

  _.assert( _.longIs( o.argv ) );

  result.interpreterPath = _.path.normalize( o.argv[ 0 ] );
  result.mainPath = _.path.normalize( o.argv[ 1 ] );
  result.interpreterArgs = process.execArgv;

  // result.keyValDelimeter = o.keyValDelimeter;
  // result.subjectsDelimeter = o.subjectsDelimeter;
  // result.map = Object.create( null );
  // result.subject = '';

  result.scriptArgs = o.argv.slice( 2 );
  result.scriptString = result.scriptArgs.join( ' ' );
  result.scriptString = result.scriptString.trim();

  let r = _.strRequestParse
  ({
    src : result.scriptString,
    keyValDelimeter : o.keyValDelimeter,
    subjectsDelimeter : o.subjectsDelimeter,
    parsingArrays : o.parsingArrays,
  });

  _.mapExtend( result, r );

  return result;

  // // if( !result.scriptString )
  // // return result;
  //
  // /* should be strSplit, but not strIsolateBeginOrAll because of quoting */
  //
  // let commands = _.strSplit
  // ({
  //   src : result.scriptString,
  //   delimeter : o.subjectsDelimeter,
  //   stripping : 1,
  //   quoting : 1,
  //   preservingDelimeters : 0,
  //   preservingEmpty : 0,
  // });
  //
  // /* */
  //
  // for( let c = 0 ; c < commands.length ; c++ )
  // {
  //
  //   let mapEntries = _.strSplit
  //   ({
  //     src : commands[ c ],
  //     delimeter : o.keyValDelimeter,
  //     stripping : 1,
  //     quoting : 1,
  //     preservingDelimeters : 1,
  //     preservingEmpty : 0,
  //   });
  //
  //   let subject, map;
  //
  //   if( mapEntries.length === 1 )
  //   {
  //     subject = mapEntries[ 0 ];
  //     map = Object.create( null );
  //   }
  //   else
  //   {
  //     let subjectAndKey = _.strIsolateEndOrAll( mapEntries[ 0 ], ' ' );
  //     subject = subjectAndKey[ 0 ];
  //     mapEntries[ 0 ] = subjectAndKey[ 2 ];
  //
  //     map = _.strToMap
  //     ({
  //       src : mapEntries.join( '' ),
  //       keyValDelimeter : o.keyValDelimeter,
  //       parsingArrays : o.parsingArrays,
  //     });
  //
  //   }
  //
  //   result.subjects.push( subject );
  //   result.maps.push( map );
  // }
  //
  // if( result.subjects.length )
  // result.subject = result.subjects[ 0 ];
  // if( result.maps.length )
  // result.map = result.maps[ 0 ];
  //
  // return result;
}

_appArgsInSamFormatNodejs.defaults = Object.create( _appArgsInSamFormat.defaults );

/*
qqq : does not work
filePath : [ "./a ./b" ]
*/

//

function _appArgsInSamFormatBrowser( o )
{
  debugger; /* xxx */

  _.assert( arguments.length === 0 || arguments.length === 1 );
  o = _.routineOptions( _appArgsInSamFormatNodejs,arguments );

  if( o.caching )
  if( _appArgsCache && o.keyValDelimeter === _appArgsCache.keyValDelimeter )
  return _appArgsCache;

  let result = Object.create( null );

  result.map =  Object.create( null );

  if( o.caching )
  if( o.keyValDelimeter === _appArgsInSamFormatNodejs.defaults.keyValDelimeter )
  _appArgsCache = result;

  /* xxx */

  return result;
}

_appArgsInSamFormatBrowser.defaults = Object.create( _appArgsInSamFormat.defaults );

//

function appArgsReadTo( o )
{

  if( arguments[ 1 ] !== undefined )
  o = { dst : arguments[ 0 ], namesMap : arguments[ 1 ] };

  o = _.routineOptions( appArgsReadTo, o );

  if( !o.propertiesMap )
  o.propertiesMap = _.appArgs().map;

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

  function set( k,v )
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

appArgsReadTo.defaults =
{
  dst : null,
  propertiesMap : null,
  namesMap : null,
  removing : 1,
  only : 1,
}

//

function appAnchor( o )
{
  o = o || {};

  _.routineOptions( appAnchor,arguments );

  let a = _.strToMap
  ({
    src : _.strRemoveBegin( window.location.hash,'#' ),
    keyValDelimeter : ':',
    entryDelimeter : ';',
  });

  if( o.extend )
  {
    _.mapExtend( a,o.extend );
  }

  if( o.del )
  {
    _.mapDelete( a,o.del );
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

appAnchor.defaults =
{
  extend : null,
  del : null,
  replacing : 0,
}

//

function appExitCode( status )
{
  let result;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( status === undefined || _.numberIs( status ) );

  if( _global.process )
  {
    if( status !== undefined )
    process.exitCode = status;
    result = process.exitCode;
  }

  return result;
}

//

function appExit( exitCode )
{

  // debugger; // xxx

  exitCode = exitCode !== undefined ? exitCode : appExitCode();

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

function appExitWithBeep( exitCode )
{

  exitCode = exitCode !== undefined ? exitCode : appExitCode();

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( exitCode === undefined || _.numberIs( exitCode ) );

  _.diagnosticBeep();

  if( exitCode )
  _.diagnosticBeep();

  _.appExit( exitCode );
}

//

let appRepairExitHandlerDone = 0;
function appRepairExitHandler()
{

  _.assert( arguments.length === 0 );

  if( appRepairExitHandlerDone )
  return;
  appRepairExitHandlerDone = 1;

  if( typeof process === 'undefined' )
  return;

  // try
  // {
  //   _.errLog( _.err( 'xxx' ) );
  // }
  // catch( err2 )
  // {
  //   console.log( err2 );
  // }

  process.on( 'SIGINT',function()
  {
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

  process.on( 'SIGUSR1',function()
  {
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
      process.removeListener( 'exit' );
      process.exit();
    }
  });

  process.on( 'SIGUSR2',function()
  {
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
      process.removeListener( 'exit' );
      process.exit();
    }
  });

}

//

function appRegisterExitHandler( routine )
{
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );

  if( typeof process === 'undefined' )
  return;

  process.once( 'exit', onExitHandler );
  process.once( 'SIGINT', onExitHandler );
  process.once( 'SIGTERM', onExitHandler );

  /*  */

  function onExitHandler( arg )
  {
    routine( arg );
    process.removeListener( 'exit', onExitHandler );
    process.removeListener( 'SIGINT', onExitHandler );
    process.removeListener( 'SIGTERM', onExitHandler );
  }
}

//

function appMemoryUsageInfo()
{
  var usage = process.memoryUsage();
  return ( usage.heapUsed >> 20 ) + ' / ' + ( usage.heapTotal >> 20 ) + ' / ' + ( usage.rss >> 20 ) + ' Mb';
}

// --
// declare
// --

let Proto =
{

  shell,
  sheller,
  shellNode,
  shellNodePassingThrough,

  //

  _appArgsInSamFormatNodejs,
  _appArgsInSamFormatBrowser,

  appArgsInSamFormat : Config.platform === 'nodejs' ? _appArgsInSamFormatNodejs : _appArgsInSamFormatBrowser,
  appArgs : Config.platform === 'nodejs' ? _appArgsInSamFormatNodejs : _appArgsInSamFormatBrowser,
  appArgsReadTo,

  appAnchor,

  appExitCode,
  appExit,
  appExitWithBeep,

  appRepairExitHandler,
  appRegisterExitHandler,

  appMemoryUsageInfo,

}

_.mapExtend( Self, Proto );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
