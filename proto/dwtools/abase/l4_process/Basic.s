( function _Basic_s_() {

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

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wPathBasic' );
  _.include( 'wGdfStrategy' );
  _.include( 'wConsequence' );

  require( './l3/Execution.s' );
  require( './l3/Io.s' );

}

let System, ChildProcess, StripAnsi, WindowsKill, WindowsProcessTree;
let _global = _global_;
let _ = _global_.wTools;
let Self = _.process = _.process || Object.create( null );

_.assert( !!_realGlobal_ );

// --
// temp
// --

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
// //
//
// function _eventExitSetup()
// {
//
//   _.assert( arguments.length === 0, 'Expects no arguments' );
//
//   if( !_global.process )
//   return;
//
//   if( !_.process._registeredExitHandler )
//   {
//     _global.process.once( 'exit', _.process._eventExitHandle );
//     _.process._registeredExitHandler = _.process._eventExitHandle;
//     // process.once( 'SIGINT', onExitHandler );
//     // process.once( 'SIGTERM', onExitHandler );
//   }
//
// }
//
// //
//
// function _eventExitHandle()
// {
//   let args = arguments;
//   _.each( _.process._eventCallbackMap.exit, ( callback ) =>
//   {
//     try
//     {
//       callback.apply( _.process, args );
//     }
//     catch( err )
//     {
//       _.setup._errUncaughtHandler2( err, 'uncaught error on termination' );
//     }
//   })
//   process.removeListener( 'exit', _.process._registeredExitHandler );
//   // process.removeListener( 'SIGINT', _.process._registeredExitHandler );
//   // process.removeListener( 'SIGTERM', _.process._registeredExitHandler );
//   _.process._eventCallbackMap.exit.splice( 0, _.process._eventCallbackMap.exit.length );
// }

//

function _eventAvailableHandle()
{
  if( !_.process._eventCallbackMap.available.length )
  return;

  let callbacks = _.process._eventCallbackMap.available.slice();
  callbacks.forEach( ( callback ) =>
  {
    try
    {
      _.arrayRemoveOnceStrictly( _.process._eventCallbackMap.available, callback );
      callback.call( _.process );
    }
    catch( err )
    {
      throw _.err( `Error in handler::${callback.name} of an event::available of module::Process\n`, err );
    }
  });

}

// --
// meta
// --

function _Setup1()
{

  _.process._eventAvailableHandle();
  _.process._exitHandlerRepair();
  _.process._eventExitSetup();

}

// --
// declare
// --

let _eventCallbackMap =
{
  available : [],
  exit : [],
}

// let Fields =
// {
//   _exitReason : null,
//   _registeredExitHandler : null,
// }

let Extension =
{

  // temp

  tempOpen,
  tempClose,

  // eventer

  on,
  // _eventExitSetup,
  // _eventExitHandle,
  _eventAvailableHandle,

  // meta

  _Setup1,

  // fields

  _tempFiles,
  _registeredExitHandler : null,

}

_.mapExtend( Self, Extension );
_.mapSupplement( Self._eventCallbackMap, _eventCallbackMap );
_.assert( _.routineIs( _.process.start ) );
_.process._Setup1();

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
