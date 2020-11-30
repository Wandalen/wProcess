( function _Process_s_()
{

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let Self = _.process = _.process || Object.create( null );

_.assert( !!_realGlobal_ );

// --
// checker
// --

let ProcessMinimal = _.Blueprint
({

  execPath : null,
  currentPath : null,
  args : null,
  interpreterArgs : null,
  passingThrough : 0,

  sync : 0,
  deasync : 0,
  when : 'instant', /* instant / afterdeath / time / delay */
  dry : 0,

  mode : 'shell', /* fork / spawn / shell */
  stdio : 'pipe', /* pipe / ignore / inherit */
  ipc : null,

  logger : null,
  procedure : null,
  stack : null,
  sessionId : 0,

  ready : null,
  conStart : null,
  conTerminate : null,
  conDisconnect : null,

  env : null,
  detaching : 0,
  hiding : 1,
  uid : null,
  gid : null,
  streamSizeLimit : null,
  timeOut : null,

  throwingExitCode : 'full', /* [ bool-like, 'full', 'brief' ] */ /* must be on by default */  /* qqq for Yevhen : cover */
  applyingExitCode : 0,

  verbosity : 2,
  outputPrefixing : 0,
  outputPiping : null,
  outputCollecting : 0,
  outputAdditive : null, /* qqq for Yevhen : cover the option */
  outputColoring : 1,
  outputGraying : 0,
  inputMirroring : 1,

});

let Process = _.Blueprint
({
  typed : _.trait.typed(),
  // withConstructor : _.trait.typed(),
  // extendable : _.trait.extendable(),

  // constructor : function constructor1() { _.assert( 0 ) },
  // Constructor : function constructor2() { _.assert( 0 ) },

  execPath : null,
  currentPath : null,
  args : null,
  interpreterArgs : null,
  passingThrough : 0,

  sync : 0,
  deasync : 0,
  when : 'instant', /* instant / afterdeath / time / delay */
  dry : 0,

  mode : 'shell', /* fork / spawn / shell */
  stdio : 'pipe', /* pipe / ignore / inherit */
  ipc : null,

  logger : null,
  procedure : null,
  stack : null,
  sessionId : 0,

  ready : null,
  conStart : null,
  conTerminate : null,
  conDisconnect : null,

  env : null,
  detaching : 0,
  hiding : 1,
  uid : null,
  gid : null,
  streamSizeLimit : null,
  timeOut : null,

  throwingExitCode : 'full', /* [ bool-like, 'full', 'brief' ] */ /* must be on by default */  /* qqq for Yevhen : cover */
  applyingExitCode : 0,

  verbosity : 2,
  outputPrefixing : 0,
  outputPiping : null,
  outputCollecting : 0,
  outputAdditive : null, /* qqq for Yevhen : cover the option */
  outputColoring : 1,
  outputGraying : 0,
  inputMirroring : 1,

  disconnect : null,
  _end : null,
  state : null, /* `initial`, `starting`, `started`, `terminating`, `terminated`, `disconnected` */
  exitReason : null,
  exitCode : null,
  exitSignal : null,
  error : null,
  args2 : null,
  pnd : null,
  execPath2 : null,
  output : null,
  ended : false,
  _handleProcedureTerminationBegin : false,
  streamOut : null,
  streamErr : null,

});

// --
// declare
// --

let ToolsExtension =
{

  ProcessMinimal,
  Process,

}

_.mapExtend( _, ToolsExtension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
