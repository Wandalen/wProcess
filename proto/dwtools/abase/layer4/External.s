( function _ExecTools_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    _global_.Esprima = require( 'esprima' );
  }
  catch( err )
  {
  }

}

var System, ChildProcess, Net, Stream;

var _global = _global_;
var Self = _global_.wTools;
var _ = _global_.wTools;

var _ArraySlice = Array.prototype.slice;
var _FunctionBind = Function.prototype.bind;
var _ObjectToString = Object.prototype.toString;
var _ObjectHasOwnProperty = Object.hasOwnProperty;

var _assert = _.assert;
var _arraySlice = _.arraySlice;

_.assert( _globalReal_ );

// --
// exec
// --

function shell( o )
{

  if( _.strIs( o ) )
  o = { path : o };

  _.routineOptions( shell,o );
  _.assert( arguments.length === 1 );
  _.accessorForbid( o,'child' );
  _.accessorForbid( o,'returnCode' );

  if( !_.numberIs( o.verbosity ) )
  o.verbosity = o.verbosity ? 1 : 0;
  if( o.verbosity < 0 )
  o.verbosity = 0;

  if( o.outputPiping === null )
  o.outputPiping = o.verbosity >= 2;

  o.con = new _.Consequence();

  if( o.args )
  _.assert( _.arrayIs( o.args ) );

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
    var argumentsManual = process.argv.slice( 2 );
    if( argumentsManual.length )
    o.args = _.arrayAppendArray( o.args || [],argumentsManual );
  }

  /* outputCollecting */

  if( o.outputCollecting && !o.output )
  o.output = '';

  /* */

  if( !ChildProcess )
  ChildProcess = require( 'child_process' );

  if( o.outputColoring && typeof module !== 'undefined' )
  try
  {
    _.include( 'wLogger' );
    _.include( 'wColor' );
  }
  catch( err )
  {
  }

  /* logger */

  if( o.verbosity )
  {
    if( o.args )
    logger.log( o.path, o.args.join( ' ' ) );
    else
    logger.log( o.path );
  }

  /* create process */

  try
  {
    var optionsForSpawn = Object.create( null );

    if( o.stdio )
    optionsForSpawn.stdio = o.stdio;
    optionsForSpawn.detached = !!o.detaching;
    if( o.env )
    optionsForSpawn.env = o.env;

    if( o.mode === 'fork')
    {
      o.process = ChildProcess.fork( o.path,'',{ silent : false } );
    }
    else if( o.mode === 'spawn' )
    {
      var app = o.path;

      if( !o.args )
      {
        o.args = _.strSplit( o.path );
        app = o.args.shift();
      }
      else
      {
        /*
         o.path can contain arguments but only if those were not specified through options, otherwise it will lead to 'ENOENT' error:

          _.shell({ path : 'node /path/to/file arg1', mode : 'spawn' }) - ok
          _.shell({ path : 'node', args : [ '/path/to/file', 'arg1' ], mode : 'spawn' }) - ok
          _.shell({ path : 'node /path/to/file', args : [ 'arg1' ], mode : 'spawn' }) - error
        */

        if( app.length )
        _.assert( _.strSplit( app ).length === 1, ' o.path must not contain arguments if those were provided through options' )
      }

      o.process = ChildProcess.spawn( app,o.args,optionsForSpawn );
    }
    else if( o.mode === 'shell' )
    {
      var app = process.platform === 'win32' ? 'cmd' : 'sh';
      var arg1 = process.platform === 'win32' ? '/c' : '-c';
      var arg2 = o.path;

      optionsForSpawn.windowsVerbatimArguments = true;

      if( o.args && o.args.length )
      arg2 = arg2 + ' ' + '"' + o.args.join( '" "' ) + '"';

      o.process = ChildProcess.spawn( app,[ arg1,arg2 ],optionsForSpawn );
    }
    else if( o.mode === 'exec' )
    {
      logger.warn( '{ shell.mode } "exec" is deprecated' );
      o.process = ChildProcess.exec( o.path );
    }
    else _.assert( 0,'unknown mode',o.mode );

  }
  catch( err )
  {
    return o.con.error( _.errLogOnce( err ) );
  }

  // /* ipc */
  //
  // if( o.ipc )
  // {
  //   var ipcChannelIndex = o.stdio.indexOf( 'ipc' );
  //   logger.log( 'ipcChannelIndex',ipcChannelIndex );
  //   logger.log( 'o.process.stdio',o.process.stdio );
  //   _.assert( o.process.stdio[ ipcChannelIndex ] );
  //   o.process.stdio[ ipcChannelIndex ].writable = true;
  //   xxx
  // }

  /* piping out channel */

  if( o.outputPiping )
  if( o.process.stdout )
  o.process.stdout.on( 'data', function( data )
  {

    if( _.bufferAnyIs( data ) )
    data = _.bufferToStr( data );

    if( _.strEnds( data,'\n' ) )
    data = _.strRemoveEnd( data,'\n' );

    if( o.outputCollecting )
    o.output += data;

    if( o.outputPrefixing )
    data = 'stdout :\n' + _.strIndentation( data,'  ' );

    if( _.color && o.outputColoring )
    data = _.color.strFormat( data,'pipe.neutral' );

    logger.log( data );
  });

  /* piping error channel */

  if( o.outputPiping )
  if( o.process.stderr )
  o.process.stderr.on( 'data', function( data )
  {

    if( _.bufferAnyIs( data ) )
    data = _.bufferToStr( data );

    if( _.strEnds( data,'\n' ) )
    data = _.strRemoveEnd( data,'\n' );

    if( o.outputPrefixing )
    data = 'stderr :\n' + _.strIndentation( data,'  ' );

    if( _.color && o.outputColoring )
    data = _.color.strFormat( data,'pipe.negative' );

    logger.warn( data );
  });

  /* error */

  var done = false;
  o.process.on( 'error', function( err )
  {

    debugger;
    if( o.verbosity )
    err = _.errLogOnce( err );

    if( done )
    return;

    done = true;
    o.con.error( err );
  });

  /* close */

  o.process.on( 'close', function( exitCode,signal )
  {

    o.exitCode = exitCode;
    o.signal = signal;

    if( o.verbosity >= 3 )
    {
      logger.log( 'Process returned error code :',exitCode );
      if( exitCode )
      logger.log( 'Launched as :',o.path );
    }

    if( done )
    return;

    done = true;

    if( o.applyingExitCode )
    if( exitCode !== 0 || o.signal )
    {
      if( _.numberIs( exitCode ) )
      _.appExitCode( exitCode );
      else
      _.appExitCode( -1 );
    }

    if( exitCode !== 0 && o.throwingExitCode )
    {
      debugger;
      if( _.numberIs( exitCode ) )
      o.con.error( _.err( 'Process returned error code :',exitCode,'\nLaunched as :',o.path ) );
      else
      o.con.error( _.err( 'Process wass killed by signal :',signal,'\nLaunched as :',o.path ) );
    }
    else
    {
      o.con.give( o );
    }

  });

  return o.con;
}

shell.defaults =
{

  path : null,
  args : null,
  mode : 'shell',

  env : null,
  stdio : 'pipe', /* 'pipe' / 'ignore' / 'inherit' */
  ipc : 0,
  detaching : 0,
  passingThrough : 0,

  throwingExitCode : 1, /* must be on by default */
  applyingExitCode : 0,

  outputColoring : 1,
  outputPrefixing : 1,
  outputPiping : 1,
  outputCollecting : 0,
  verbosity : 1,

}

//

function shellNode( o )
{

  if( !System )
  System = require( 'os' );

  _.include( 'wPath' );
  _.include( 'wFiles' );

  if( _.strIs( o ) )
  o = { path : o }

  _.routineOptions( shellNode,o );
  _.assert( _.strIs( o.path ) );
  _.assert( !o.code );
  _.accessorForbid( o,'child' );
  _.accessorForbid( o,'returnCode' );
  _.assert( arguments.length === 1 );

  /*
  1024*1024 for megabytes
  1.5 factor found empirically for windows
      implementation of nodejs for other OSs could be able to use more memory
  */

  var argumentsForNode = '';
  if( o.maximumMemory )
  {
    var totalmem = System.totalmem();
    if( o.verbosity )
    logger.log( 'System.totalmem()',_.strMetricFormatBytes( totalmem ) );
    var totalmem = Math.floor( ( totalmem / ( 1024*1024*1.5 ) - 1 ) / 256 ) * 256;
    argumentsForNode = '--expose-gc --stack-trace-limit=999 --max_old_space_size=' + totalmem;
  }

  var path = _.fileProvider.nativize( o.path );
  path = _.strConcat( 'node',argumentsForNode,path );

  var shellOptions = _.mapScreen( _.shell.defaults,o );
  shellOptions.path = path;

  var result = _.shell( shellOptions )
  .got( function( err,arg )
  {
    o.exitCode = shellOptions.exitCode;
    o.signal = shellOptions.signal;
    this.give( err,arg );
  });

  o.con = shellOptions.con;
  o.process = shellOptions.process;

  return result;
}

shellNode.defaults =
{

  path : null,
  verbosity : 1,
  passingThrough : 0,
  maximumMemory : 1,

  outputPrefixing : 1,
  outputCollecting : 0,
  applyingExitCode : 1,
  throwingExitCode : 1,

  stdio : 'inherit',

}

shellNode.defaults.__proto__ = shell.defaults;

//

function shellNodePassingThrough( o )
{

  if( _.strIs( o ) )
  o = { path : o }

  _.routineOptions( shellNodePassingThrough,o );
  _.assert( arguments.length === 1 );
  var result = _.shellNode( o );

  return result;
}

shellNodePassingThrough.defaults =
{

  passingThrough : 1,
  maximumMemory : 1,

}

shellNodePassingThrough.defaults.__proto__ = shellNode.defaults;

// --
//
// --

function routineSourceGet( o )
{
  if( _.routineIs( o ) )
  o = { routine : o };

  _.routineOptions( routineSourceGet,o );
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( o.routine ) );

  var result = o.routine.toSource ? o.routine.toSource() : o.routine.toString();

  function unwrap( code )
  {

    var reg1 = /^\s*function\s*\w*\s*\([^\)]*\)\s*\{/;
    var reg2 = /\}\s*$/;

    var before = reg1.exec( code );
    var after = reg2.exec( code );

    if( before && after )
    {
      code = code.replace( reg1,'' );
      code = code.replace( reg2,'' );
    }

    return [ before[ 0 ], code, after[ 0 ] ];
  }

  if( !o.withWrap )
  result = unwrap( result )[ 1 ];

  if( o.usingInline && o.routine.inlines )
  {
    debugger;
    var prefix = '\n';
    for( var i in o.routine.inlines )
    {
      var inline = o.routine.inlines[ i ];
      prefix += '  var ' + i + ' = ' + _.toJs( inline,o.toJsOptions ) + ';\n';
    }
    debugger;
    var splits = unwrap( result );
    debugger;
    splits[ 1 ] = prefix + '\n' + splits[ 1 ];
    result = splits.join( '' );
  }

  return result;
}

routineSourceGet.defaults =
{
  routine : null,
  wrap : 1,
  withWrap : 1,
  usingInline : 1,
  toJsOptions : null,
}

//

function routineMake( o )
{
  var result;

  if( _.strIs( o ) )
  o = { code : o };

  _.routineOptions( routineMake,o );
  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o.externals ) || o.externals === null );
  _.assert( _globalReal_ );

  /* prefix */

  var prefix = '\n';

  if( o.usingStrict )
  prefix += `'use strict';\n`;
  if( o.debug )
  prefix += 'debugger;\n';
  if( o.filePath )
  prefix += '// ' + o.filePath + '\n';

  if( o.externals )
  {
    if( !_globalReal_.__wTools__externals__ )
    _globalReal_.__wTools__externals__ = [];
    _globalReal_.__wTools__externals__.push( o.externals );
    prefix += '\n';
    for( e in o.externals )
    prefix += 'var ' + e + ' = ' + '_globalReal_.__wTools__externals__[ ' + String( _globalReal_.__wTools__externals__.length-1 ) + ' ].' + e + ';\n';
    prefix += '\n';
  }

  /* */

  function make( code )
  {
    try
    {
      if( o.name )
      code = 'return function ' + o.name + '()\n{\n' + code + '\n}';
      var result = new Function( code );
      if( o.name )
      result = result();
      return result;
    }
    catch( err )
    {
      debugger;
      throw _.err( err );
    }
  }

  /* */

  try
  {

    if( o.prependingReturn )
    try
    {
      var code = prefix + 'return ' + o.code.trimLeft();
      result = make( code );
    }
    catch( err )
    {
      var code = prefix + o.code;
      result = make( code );
    }
    else
    {
      var code = prefix + o.code;
      result = make( code );
    }

  }
  catch( err )
  {

    console.error( 'Cant parse the routine :' );
    console.error( code );

    if( _global.document )
    {
      var e = document.createElement( 'script' );
      e.type = 'text/javascript';
      e.src = 'data:text/javascript;charset=utf-8,' + escape( o.code );
      document.head.appendChild( e );
    }
    else if( _global.Blob && _global.Worker )
    {
      var worker = _.makeWorker( code )
    }
    else if( _global.Esprima || _global.esprima )
    {
      var Esprima = _global.Esprima || _global.esprima;
      try
      {
        var parsed = Esprima.parse( '(function(){\n' + code + '\n})();' );
      }
      catch( err2 )
      {
        debugger;
        throw _._err
        ({
          args : [ err , err2 ],
          level : 1,
          sourceCode : code,
        });
      }
    }

    throw _.err( 'More information about error is comming asynchronously.\n',err );
    return null;
  }

  return result;
}

routineMake.defaults =
{
  debug : 0,
  code : null,
  filePath : null,
  prependingReturn : 1,
  usingStrict : 0,
  externals : null,
  name : null,
}

//

function routineExec( o )
{
  var result = Object.create( null );

  if( _.strIs( o ) )
  o = { code : o };
  _.assert( arguments.length === 1 );
  _.routineOptions( routineExec,o );

  o.routine = routineMake
  ({
    code : o.code,
    debug : o.debug,
    filePath : o.filePath,
    prependingReturn : o.prependingReturn,
    externals : o.externals,
  });

  /* */

  try
  {
    if( o.context )
    o.result = o.routine.apply( o.context );
    else
    o.result = o.routine.call( _global );
  }
  catch( err )
  {
    debugger;
    throw _._err
    ({
      args : [ err ],
      level : 1,
      sourceCode : o.routine.toString(),
      location : { path : o.filePath },
    });
  }

  return o;
}

routineExec.defaults =
{
  context : null,
}

routineExec.defaults.__proto__ = routineMake.defaults;

//

function exec( o )
{
  _.assert( arguments.length === 1 );
  if( _.strIs( o ) )
  o = { code : o };
  routineExec( o );
  return o.result;
}

exec.defaults =
{
}

exec.defaults.__proto__ = routineExec.defaults;

//

function execInWorker( o )
{
  var result;

  if( _.strIs( o ) )
  o = { code : o };
  _.assert( arguments.length === 1 );
  _.routineOptions( execInWorker,o );

  var blob = new Blob( [ o.code ], { type : 'text/javascript' } );
  var worker = new Worker( URL.createObjectURL( blob ) );

  throw _.err( 'not implemented' );

}

execInWorker.defaults =
{
  code : null,
}

//

function makeWorker( o )
{
  var result;

  if( _.strIs( o ) )
  o = { code : o };
  _.assert( arguments.length === 1 );
  _.routineOptions( makeWorker,o );

  var blob = new Blob( [ o.code ], { type : 'text/javascript' } );
  var worker = new Worker( URL.createObjectURL( blob ) );

  return worker;
}

makeWorker.defaults =
{
  code : null,
}

//

// function execAsyn( routine,onEnd,context )
// {
//   _assert( arguments.length >= 3,'execAsyn :','expects 3 arguments or more' );
//
//   var args = arraySlice( arguments,3 ); throw _.err( 'not tested' );
//
//   _.timeOut( 0,function()
//   {
//
//     routine.apply( context,args );
//     onEnd();
//
//   });
//
// }

//

function execStages( stages,o )
{
  var o = o || Object.create( null );

  _.routineOptionsWithUndefines( execStages,o );

  o.stages = stages;

  Object.preventExtensions( o );

  /* validation */

  _.assert( _.objectIs( stages ) || _.arrayLike( stages ),'expects array or object ( stages ), but got',_.strTypeOf( stages ) );

  for( var s in stages )
  {

    var routine = stages[ s ];

    _.assert( routine || routine === null,'execStages :','#'+s,'stage is not defined' );
    _.assert( _.routineIs( routine ) || routine === null,'execStages :','stage','#'+s,'does not have routine to execute' );

  }

  /*  var */

  var con = _.timeOut( 1 );
  var keys = Object.keys( stages );
  var s = 0;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  /* begin */

  if( o.onBegin )
  con.doThen( o.onBegin );

  /* end */

  function handleEnd()
  {

    con.doThen( function( err,data )
    {

      if( err )
      throw _.errLogOnce( err );
      else
      return data;

    });

    if( o.onEnd )
    con.doThen( o.onEnd );

  }

  /* staging */

  function handleStage()
  {

    var stage = stages[ keys[ s ] ];
    var iteration = Object.create( null );

    iteration.index = s;
    iteration.key = keys[ s ];

    s += 1;

    if( stage === null )
    return handleStage();

    if( !stage )
    return handleEnd();

    /* arguments */

    iteration.routine = stage;
    iteration.routine = _.routineJoin( o.context,iteration.routine,o.args );

    function routineCall()
    {
      var ret = iteration.routine();
      return ret;
    }

    /* exec */

    if( o.onEachRoutine )
    {
      con.ifNoErrorThen( _.routineSeal( o.context,o.onEachRoutine,[ iteration.routine,iteration,o ] ) );
    }

    if( !o.manual )
    con.ifNoErrorThen( routineCall );

    con.timeOutThen( o.delay );

    handleStage();

  }

  /* */

  handleStage();

  return con;
}

execStages.defaults =
{
  delay : 1,

  args : undefined,
  context : undefined,

  manual : false,

  onEachRoutine : null,
  onBegin : null,
  onEnd : null,
}

// --
//
// --

var _appArgsInSubjectAndMapFormatResult;
function appArgsInSubjectAndMapFormat( o )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );
  o = _.routineOptions( appArgsInSubjectAndMapFormat,arguments );

  if( o.caching )
  if( _appArgsInSubjectAndMapFormatResult && o.delimeter === _appArgsInSubjectAndMapFormatResult.delimeter )
  return _appArgsInSubjectAndMapFormatResult;

  var result = Object.create( null );

  if( o.caching )
  if( o.delimeter === appArgsInSubjectAndMapFormat.defaults.delimeter )
  _appArgsInSubjectAndMapFormatResult = result;

  if( _global.process )
  {
    if( o.argv )
    _.assert( _.arrayLike( o.argv ) );

    var argv = o.argv || process.argv;

    result.interpreterPath = _.normalize( argv[ 0 ] );
    result.mainPath = _.normalize( argv[ 1 ] );
    result.interpreterArgs = process.execArgv;
    result.delimeter = o.delimeter;
    result.map = Object.create( null );
    result.subject = '';
    result.scriptArgs = argv.slice( 2 );
    result.scriptString = result.scriptArgs.join( ' ' );

    if( !result.scriptArgs.length )
    return result;

    var scriptArgs = [];
    result.scriptArgs.forEach( function( arg, pos )
    {
      if( arg.length > 1 && arg.indexOf( o.delimeter ) !== -1 )
      {
        var argSplitted = _.strSplit({ src : arg, delimeter : o.delimeter, stripping : 1, preservingDelimeters : 1 })
        scriptArgs.push.apply( scriptArgs, argSplitted );
      }
      else
      scriptArgs.push( arg );
    })

    result.scriptArgs = scriptArgs;

    if( result.scriptArgs.length === 1 )
    {
      result.subject = result.scriptArgs[ 0 ];
      return result;
    }

    var i =  result.scriptArgs.indexOf( o.delimeter );
    if( i > 1 )
    {
      var part = result.scriptArgs.slice( 0, i - 1 );
      var subject = part.join( ' ' );
      var regexp = new RegExp( '.?\h*\\' + o.delimeter + '\\h*.?' );
      if( !regexp.test( subject ) )
      result.subject = subject;
    }

    if( i < 0 )
    result.subject = result.scriptArgs.shift();

    var args = result.scriptArgs.join( ' ' );
    args = args.trim();

    if( !args )
    return result;

    var splitted = _.strSplit({ src : args, delimeter : o.delimeter, stripping : 1 });

    if( splitted.length === 1 )
    {
      result.subject = splitted[ 0 ];
      return result;
    }

    _.assert( _.strCutOffAllLeft( splitted[ 0 ],' ' ).length === 3 )
    splitted[ 0 ] = _.strCutOffAllLeft( splitted[ 0 ],' ' )[ 2 ];

    result.map = _.strParseMap( splitted.join( ':' ) );

  }

  return result;
}

appArgsInSubjectAndMapFormat.defaults =
{
  delimeter : ':',
  argv : null,
  caching : true
}

//

function appArgsReadTo( o )
{

  _.assert( arguments.length === 1 || arguments.length === 2 )

  if( arguments[ 1 ] !== undefined )
  o = { dst : arguments[ 0 ], nameMap : arguments[ 1 ] };

  o = _.routineOptions( appArgsReadTo,o );

  if( !o.appArgs )
  o.appArgs = _.appArgs();

  _.assert( _.objectIs( o.dst ) );
  _.assert( _.objectIs( o.nameMap ) );

  function set( k,v )
  {
    _.assert( o.dst[ k ] !== undefined );
    if( _.numberIs( o.dst[ k ] ) )
    {
      var v = Number( v );
      _.assert( !isNaN( v ) );
      o.dst[ k ] = v;
    }
    else if( _.boolIs( o.dst[ k ] ) )
    {
      var v = !!v;
      o.dst[ k ] = v;
    }
    else
    {
      o.dst[ k ] = v;
    }
  }

  for( var n in o.nameMap )
  {
    if( o.appArgs.map[ n ] !== undefined )
    {
      set( o.nameMap[ n ], o.appArgs.map[ n ] );
      delete o.appArgs.map[ n ];
    }
  }

}

appArgsReadTo.defaults =
{
  dst : null,
  appArgs : null,
  nameMap : null,
  removing : 1,
}

//

function appAnchor( o )
{
  var o = o || {};

  _.routineOptions( appAnchor,arguments );

  var a = _.strParseMap
  ({
    src : _.strRemoveBegin( window.location.hash,'#' ),
    valKeyDelimeter : ':',
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

    var newHash = '#' + _.mapToStr
    ({
      src : a,
      valKeyDelimeter : ':',
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
  var result;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( status === undefined || _.numberIs( status ) );

  if( _global.process )
  {
    result = process.exitCode;
    if( status !== undefined )
    process.exitCode = status;
  }

  return result;
}

//

function appExit( exitCode )
{

  debugger;

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

  _.beep();

  if( exitCode )
  _.beep();

  _.appExit( exitCode );
}

// --
// prototype
// --

var Proto =
{

  shell : shell,
  shellNode : shellNode,
  shellNodePassingThrough : shellNodePassingThrough,


  //

  routineSourceGet : routineSourceGet,

  routineMake : routineMake,
  routineExec : routineExec,

  exec : exec,

  execInWorker : execInWorker,
  makeWorker : makeWorker,

  execStages : execStages, /* experimental */


  //

  appArgsInSubjectAndMapFormat : appArgsInSubjectAndMapFormat,
  appArgs : appArgsInSubjectAndMapFormat,
  appArgsReadTo : appArgsReadTo,

  appAnchor : appAnchor,

  appExitCode : appExitCode,
  appExit : appExit,
  appExitWithBeep : appExitWithBeep,

}

_.mapExtend( Self, Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
