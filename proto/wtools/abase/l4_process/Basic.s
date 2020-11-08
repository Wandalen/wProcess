( function _Basic_s_()
{

'use strict';

/**
 * Collection of cross-platform routines to execute system commands, run shell, batches, launch external processes from JavaScript application. Module Process leverages not only outputting data from an application but also inputting, makes application arguments parsing and accounting easier. Use the module to get uniform experience from interaction with an external processes on different platforms and operating systems.
  @module Tools/base/ProcessBasic
*/

/**
 * Collection of cross-platform routines to execute system commands, run shell, batches, launch external processes from JavaScript application.
  @namespace Tools.process
  @extends Tools
  @module Tools/base/ProcessBasic
*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wPathBasic' );
  _.include( 'wGdf' );
  _.include( 'wConsequence' );
  _.include( 'wFiles' );

  require( './l3/Execution.s' );
  require( './l3/Io.s' );

}

let System, ChildProcess, StripAnsi, WindowsKill, WindowsProcessTree;
let _global = _global_;
let _ = _global_.wTools;
let Self = _.process = _.process || Object.create( null );

_.assert( !!_realGlobal_ );

// --
// checker
// --

function isNativeDescriptor( src )
{
  if( !src )
  return false;
  if( !ChildProcess )
  ChildProcess = require( 'child_process' );
  return src instanceof ChildProcess.ChildProcess;
}

//

function isSession( src )
{
  if( !_.objectIs( src ) )
  return false;
  return src.ipc !== undefined && src.procedure !== undefined && src.process !== undefined;
}

//

function pidFrom( src )
{
  _.assert( arguments.length === 1 );

  if( _.numberIs( src ) )
  return src;
  if( _.objectIs( src ) )
  {
    if( src.process )
    src = src.process;
    if( src.pnd )
    src = src.pnd;
    _.assert( src instanceof ChildProcess.ChildProcess );
    return src.pid;
  }

  _.assert( 0, `Cant get PID from ${_.strType( src )}` );
}

// --
// temp
// --

let _tempFiles = [];

function tempOpen_head( routine, args )
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

  let tempDirPath = _.path.tempOpen( _.path.realMainDir(), 'ProcessTempOpen' );
  let filePath = _.path.join( tempDirPath, _.idWithDateAndTime() + '.ss' );
  _tempFiles.push( filePath );
  _.fileProvider.fileWrite( filePath, o.sourceCode );
  return filePath;
}

var defaults = tempOpen_body.defaults = Object.create( null );
defaults.sourceCode = null;

let tempOpen = _.routineUnite( tempOpen_head, tempOpen_body );

//

function tempClose_head( routine, args )
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

let tempClose = _.routineUnite( tempClose_head, tempClose_body );

// --
// eventer
// --

let _on = _.process.on;
function on()
{
  let o2 = _on.apply( this, arguments );
  if( o2.callbackMap.available )
  _.process._eventAvailableHandle();
  return o2;
}

on.defaults =
{
  callbackMap : null,
}

//

function _eventAvailableHandle()
{
  if( !_.process._ehandler.events.available.length )
  return;

  let callbacks = _.process._ehandler.events.available.slice();
  callbacks.forEach( ( callback ) =>
  {
    try
    {
      _.arrayRemoveOnceStrictly( _.process._ehandler.events.available, callback );
      callback.call( _.process );
    }
    catch( err )
    {
      throw _.err( `Error in handler::${callback.name} of an event::available of module::Process\n`, err );
    }
  });

}

//

_realGlobal_._exitHandlerRepairDone = _realGlobal_._exitHandlerRepairDone || 0;
_realGlobal_._exitHandlerRepairTerminating = _realGlobal_._exitHandlerRepairTerminating || 0;
function _exitHandlerRepair()
{

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( _realGlobal_._exitHandlerRepairDone )
  return;
  _realGlobal_._exitHandlerRepairDone = 1;

  if( !_global.process )
  return;

  process.on( 'SIGHUP', handle_functor( 'SIGHUP', 1 ) ); /* yyy : experiment */
  process.on( 'SIGQUIT', handle_functor( 'SIGQUIT', 3 ) );
  process.on( 'SIGINT', handle_functor( 'SIGINT', 2 ) );
  process.on( 'SIGTERM', handle_functor( 'SIGTERM', 15 ) );
  process.on( 'SIGUSR1', handle_functor( 'SIGUSR1', 16 ) );
  process.on( 'SIGUSR2', handle_functor( 'SIGUSR2', 17 ) );

  function handle_functor( signal, signalCode )
  {
    return function handle()
    {
      if( _.process._verbosity )
      console.log( signal );
      if( _realGlobal_._exitHandlerRepairTerminating )
      return;
      _realGlobal_._exitHandlerRepairTerminating = 1;
      /*
       short delay is required to set exit reason of the process
       otherwise reason will be exit code, not exit signal
      */
      _.time._begin( _.process._sanitareTime, () =>
      {
        try
        {
          process.removeListener( signal, handle );
          if( !process._exiting )
          {
            try
            {
              process._exiting = true;
              process.emit( 'exit', 128 + signalCode );
            }
            catch( err )
            {
              console.error( _.err( err ) );
            }
            process.kill( process.pid, signal );
          }
        }
        catch( err )
        {
          console.log( `Error on signal ${signal}` );
          console.log( err.toString() );
          console.log( err.stack );
          process.removeAllListeners( 'exit' );
          process.exit( -1 );
        }
      });
    }
  }

}

//

function _eventsSetup()
{

  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( !_global.process )
  return;

  if( !_.process._registeredExitHandler )
  {
    _global.process.once( 'exit', _.process._eventExitHandle );
    _.process._registeredExitHandler = _.process._eventExitHandle;
  }

  if( !_.process._registeredExitBeforeHandler )
  {
    _global.process.on( 'beforeExit', _.process._eventExitBeforeHandle );
    _.process._registeredExitBeforeHandler = _.process._eventExitBeforeHandle;
  }

}

//

function _eventExitHandle()
{
  let args = arguments;
  process.removeListener( 'exit', _.process._registeredExitHandler );
  _.process._registeredExitHandler = null;
  _.process.eventGive({ event : 'exit', args });
  _.process._ehandler.events.exit.splice( 0, _.process._ehandler.events.exit.length );
}

//

function _eventExitBeforeHandle()
{
  let args = arguments;
  _.process.eventGive({ event : 'exitBefore', args });
}

// --
// escape
// --

function escapeArg( arg )
{
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( arg ) );

  if( process.platform !== 'win32' )
  {
		// Backslash-escape any hairy characters:
    arg = arg.replace( /([^a-zA-Z0-9_])/g, '\\$1' );
  }
  else
  {
    //Sequence of backslashes followed by a double quote:
    //double up all the backslashes and escape the double quote
    arg = arg.replace( /(\\*)"/g, '$1$1\\"' );

    // Sequence of backslashes followed by the end of the string
    // (which will become a double quote later):
    // double up all the backslashes
    arg = arg.replace( /(\\*)$/,'$1$1' );

    // All other backslashes occur literally

    // Quote the whole thing:
    arg = `"${arg}"`;

    // Escape shell metacharacters:
    arg = arg.replace( /([()\][%!^"`<>&|;, *?])/g, '^$1' );
  }

  return arg;
}

//

function escapeProg( prog )
{
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( prog ) );

  // Windows cmd.exe: needs special treatment
  if( process.platform === 'win32' )
  {
		// Escape shell metacharacters:
    prog = prog.replace( /([()\][%!^"`<>&|;, *?])/g, '^$1' );
  }
  else
  {
    // Unix shells: same procedure as for arguments
		prog = _.process.escapeArg( prog );
  }

  return prog;
}


//

function escapeCmd( prog, args )
{
  _.assert( arguments.length === 2 );
  _.assert( _.strIs( prog ) );
  _.assert( _.arrayIs( args ) );

  prog = _.process.escapeProg( prog );

  if( !args.length )
  return prog;

  args = args.map( ( arg ) => _.process.escapeArg( arg ) );

  return `${prog} ${args.join( ' ' )}`;
}

// --
// meta
// --

function _Setup1()
{
  if( _.path && _.path.current )
  this._initialCurrentPath = _.path.current();

  _.process._eventAvailableHandle();
  _.process._exitHandlerRepair();
  _.process._eventsSetup();

}

// --
// declare
// --

let Events =
{
  available : [],
  exit : [],
  exitBefore : [],
}

let Extension =
{

  // etc

  isNativeDescriptor,
  isSession,
  pidFrom,

  // temp

  tempOpen,
  tempClose,

  // eventer

  on,
  _eventAvailableHandle,

  // event

  _exitHandlerRepair, /* zzz */
  _eventsSetup,
  _eventExitHandle,
  _eventExitBeforeHandle,

  // escape

  escapeArg,
  escapeProg,
  escapeCmd,

  // meta

  _Setup1,

  // fields

  _verbosity : 1,
  _sanitareTime : 1,
  _exitReason : null,

  _tempFiles,
  _registeredExitHandler : null,
  _registeredExitBeforeHandler : null,
  _initialCurrentPath : null

}

_.mapExtend( Self, Extension );
_.mapSupplement( Self._ehandler.events, Events );
_.assert( _.routineIs( _.process.start ) );
_.process._Setup1();

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
