( function _Basic_test_s( )
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( './../../../node_modules/Tools' );
  _.include( 'wTesting' );
  _.include( 'wFilesBasic' );
  _.include( 'wProcessWatcher' );
  require( '../l4_process/module/Process.s' );
}

const _global = _global_;
const _ = _global_.wTools;

// --
// context
// --

function suiteBegin()
{
  let context = this;
  context.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'Io' );
  context.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  context.appJsPath = _.path.nativize( _.module.resolve( 'wProcess' ) );
}

//

function suiteEnd()
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, '/Io' ) )
  _.path.tempClose( context.suiteTempPath );
}

//

function onWithArguments( test )
{
  const self = this;
  const a = test.assetFor( false );
  a.fileProvider.dirMake( a.abs( '.' ) );

  /* - */

  a.ready.then( () =>
  {
    test.case = 'no callbacks for events';
    return null;
  });
  var program = a.program( withoutCallbacks );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '[]' ), 1 );
    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'single callback for single event, single event is given';
    return null;
  });
  var program = a.program( callbackForAvailable );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '[ [] ]' ), 1 );
    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'single callback for single event, a few events are given';
    return null;
  });
  var program = a.program( callbackForAvailableDouble );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '[ [] ]' ), 1 );
    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'single callback for single event, a few events are given';
    return null;
  });
  var program = a.program( callbacksForEvents );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    var exp = `[ [], 'uncaughtError1', 'uncaughtError2' ]`;
    test.identical( _.strCount( op.output, exp ), 1 );
    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'throw uncaught error';
    return null;
  });
  var program = a.program( uncaughtError );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    var exp = 'exit';
    test.identical( _.strCount( op.output, exp ), 0 );
    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'events exitBefore and exit';
    return null;
  });
  var program = a.program( callbackOnExit );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '0 arg' ), 1 );
    test.identical( _.strCount( op.output, '[ 0 ]' ), 1 );
    return null;
  });

  /* - */

  return a.ready;

  /* */

  function withoutCallbacks()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function callbackForAvailable()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.on( 'available', ( ... args ) => result.push( args ) );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function callbackForAvailableDouble()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.on( 'available', ( ... args ) => result.push( args ) );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function callbacksForEvents()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.on( 'available', ( ... args ) => result.push( args ) );
    _.process.on( 'uncaughtError', ( e ) => result.push( e + result.length ) );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function uncaughtError()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    _.process.on( 'uncaughtError', ( o ) => _.errAttend( o.err ) );
    throw _.err( 'Error' );
    console.log( 'exit' );
  }

  /* */

  function callbackOnExit()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    _.process.on( 'exit', ( ... args ) => { console.log( args ); return true } );
    _.process.on( 'exitBefore', ( e ) => { console.log( e + ' arg' ); return true } );
  }
}

// function onWithArguments( test )
// {
//   var self = this;
//
//   /* */
//
//   test.case = 'no callback for events';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   _.event.eventGive( _.process._ehandler, 'uncaughtError' );
//   test.identical( result, [] );
//   _.event.eventGive( _.process._ehandler, 'available' );
//   test.identical( result, [] );
//
//   /* */
//
//   test.case = 'single callback for single event, single event is given';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   var got = _.process.on( 'uncaughtError', onEvent );
//   _.event.eventGive( _.process._ehandler, 'uncaughtError' );
//   test.identical( result, [ 0 ] );
//   _.event.eventGive( _.process._ehandler, 'available' );
//   test.identical( result, [ 0 ] );
//   test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent2 } ) );
//   got.uncaughtError.off();
//
//   /* */
//
//   test.case = 'single callback for single event, a few events are given';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   var got = _.process.on( 'uncaughtError', onEvent );
//   _.event.eventGive( _.process._ehandler, 'uncaughtError' );
//   test.identical( result, [ 0 ] );
//   _.event.eventGive( _.process._ehandler, 'uncaughtError' );
//   test.identical( result, [ 0, 1 ] );
//   _.event.eventGive( _.process._ehandler, 'available' );
//   test.identical( result, [ 0, 1 ] );
//   test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent2 } ) );
//   got.uncaughtError.off();
//
//   /* */
//
//   test.case = 'single callback for each events in event handler, a few events are given';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   _.process._ehandler.events.event2 = [];
//   var got = _.process.on( 'uncaughtError', onEvent );
//   var got2 = _.process.on( 'event2', onEvent2 );
//   _.event.eventGive( _.process._ehandler, 'uncaughtError' );
//   test.identical( result, [ 0 ] );
//   _.event.eventGive( _.process._ehandler, 'uncaughtError' );
//   test.identical( result, [ 0, 1 ] );
//   _.event.eventGive( _.process._ehandler, 'event2' );
//   _.event.eventGive( _.process._ehandler, 'event2' );
//   delete   _.process._ehandler.events.event2;
//   test.identical( result, [ 0, 1, -2, -3 ] );
//   test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   got.uncaughtError.off();
// }

//

function onWithOptionsMap( test )
{
  const self = this;
  const a = test.assetFor( false );
  const con = _.take( null );
  a.fileProvider.dirMake( a.abs( '.' ) );

  /* - */

  con.then( () =>
  {
    test.case = 'no callbacks for events';
    var program = a.program( withoutCallbacks );
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[]' ), 1 );
      return null;
    });
  });

  /* - */

  con.then( () =>
  {
    test.open( 'single callback for event' );
    return null;
  });

  con.then( () =>
  {
    test.case = 'single callback for single event, single event is given';
    var o =
    {
      callbackMap : { 'available' : ( ... args ) => result.push( args ) },
      first : false,
    };
    var program = a.program({ entry : callbackForAvailable, locals : { o, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[ [] ]' ), 1 );
      return null;
    });
  });

  /* */

  con.then( () =>
  {
    test.case = 'single callback for single event, a few events are given';
    var o =
    {
      callbackMap : { 'available' : ( ... args ) => result.push( args ) },
      first : false,
    };
    var program = a.program({ entry : callbackForAvailableDouble, locals : { o, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[ [] ]' ), 1 );
      return null;
    });
  });

  /* */

  con.then( () =>
  {
    test.case = 'single callback for single event, a few events are given';
    var o =
    {
      callbackMap : { 'available' : ( ... args ) => result.push( args ) },
      first : false,
    };
    var program = a.program({ entry : callbacksForEvents, locals : { o, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[ [], \'uncaughtError1\', \'uncaughtError2\' ]' ), 1 );
      return null;
    });
  });

  /* */

  con.then( () =>
  {
    test.case = 'throw uncaught error';
    var o =
    {
      callbackMap : { 'available' : ( ... args ) => result.push( args ) },
      first : false,
    };
    var program = a.program({ entry : uncaughtError, locals : { o, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      var exp = 'exit';
      test.identical( _.strCount( op.output, exp ), 0 );
      return null;
    });
  });

  con.then( () =>
  {
    test.close( 'single callback for event' );
    return null;
  });

  /* - */

  con.then( () =>
  {
    test.open( 'options map with option first' );
    return null;
  });

  con.then( () =>
  {
    test.case = 'callback1.first - false, callback2.first - false';
    var o1 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( args ) },
      first : false,
    };
    var o2 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( result.length ) },
      first : false,
    };
    var program = a.program({ entry : severalCallbacks, locals : { o1, o2, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[ [ \'exitBefore\', \'arg\' ], 1 ]' ), 1 );
      return null;
    });
  });

  /* */

  con.then( () =>
  {
    test.case = 'callback1.first - true, callback2.first - false';
    var o1 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( args ) },
      first : true,
    };
    var o2 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( result.length ) },
      first : false,
    };
    var program = a.program({ entry : severalCallbacks, locals : { o1, o2, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[ [ \'exitBefore\', \'arg\' ], 1 ]' ), 1 );
      return null;
    });
  });

  /* */

  con.then( () =>
  {
    test.case = 'callback1.first - false, callback2.first - true';
    var o1 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( args ) },
      first : false,
    };
    var o2 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( result.length ) },
      first : true,
    };
    var program = a.program({ entry : severalCallbacks, locals : { o1, o2, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[ 0, [ \'exitBefore\', \'arg\' ] ]' ), 1 );
      return null;
    });
  });

  /* */

  con.then( () =>
  {
    test.case = 'callback1.first - true, callback2.first - true';
    var o1 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( args ) },
      first : true,
    };
    var o2 =
    {
      callbackMap : { 'exitBefore' : ( ... args ) => result.push( result.length ) },
      first : true,
    };
    var program = a.program({ entry : severalCallbacks, locals : { o1, o2, result : [] } });
    return program.start()
    .then( ( op ) =>
    {
      test.identical( op.exitCode, 0 );
      test.identical( _.strCount( op.output, '[ 0, [ \'exitBefore\', \'arg\' ] ]' ), 1 );
      return null;
    });
  });

  con.then( () =>
  {
    test.close( 'options map with option first' );
    return null;
  });

  /* */

  if( Config.debug )
  con.then( () =>
  {
    test.case = 'without arguments';
    test.shouldThrowErrorSync( () => _.process.on() );

    test.case = 'wrong type of callback';
    test.shouldThrowErrorSync( () => _.process.on( 'event1', {} ) );

    test.case = 'wrong type of event name';
    test.shouldThrowErrorSync( () => _.process.on( [], () => 'str' ) );

    test.case = 'wrong type of options map o';
    test.shouldThrowErrorSync( () => _.process.on( 'wrong' ) );

    test.case = 'extra options in options map o';
    test.shouldThrowErrorSync( () => _.process.on({ callbackMap : {}, wrong : {} }) );

    test.case = 'not known event in callbackMap';
    test.shouldThrowErrorSync( () => _.process.on({ callbackMap : { unknown : () => 'unknown' } }) );
    return null;
  });

  /* - */

  return con;

  /* */

  function withoutCallbacks()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function callbackForAvailable()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    _.process.on( o );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function callbackForAvailableDouble()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.on( 'available', ( ... args ) => result.push( args ) );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function callbacksForEvents()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.on( 'available', ( ... args ) => result.push( args ) );
    _.process.on( 'uncaughtError', ( e ) => result.push( e + result.length ) );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    _.process.eventGive( 'available', 'arg' );
    _.process.eventGive( 'uncaughtError', 'arg' );
    console.log( result );
  }

  /* */

  function uncaughtError()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    _.process.on( 'uncaughtError', ( o ) => _.errAttend( o.err ) );
    throw _.err( 'Error' );
    console.log( 'exit' );
  }

  /* */

  function severalCallbacks()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    _.process.on( o1 );
    _.process.on( o2 );
    _.process.eventGive( 'exitBefore', 'arg' );
    console.log( result );
  }
}

// //
//
// function onWithOptionsMap( test )
// {
//   var self = this;
//
//   /* - */
//
//   test.open( 'option first - 0' );
//
//   test.case = 'no callback for events';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [] );
//   _.event.eventGive( _.process._edispatcher, 'available' );
//   test.identical( result, [] );
//
//   /* */
//
//   test.case = 'single callback for single event, single event is given';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ 0 ] );
//   _.event.eventGive( _.process._edispatcher, 'available' );
//   test.identical( result, [ 0 ] );
//   test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent2 } ) );
//   got.uncaughtError.off();
//
//   /* */
//
//   test.case = 'single callback for single event, a few events are given';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent }} );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ 0 ] );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ 0, 1 ] );
//   _.event.eventGive( _.process._edispatcher, 'available' );
//   test.identical( result, [ 0, 1 ] );
//   test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent2 } ) );
//   got.uncaughtError.off();
//
//   /* */
//
//   test.case = 'single callback for each events in event handler, a few events are given';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   _.process._edispatcher.events.event2 = [];
//   var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent, 'event2' : onEvent2 } });
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ 0 ] );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ 0, 1 ] );
//   _.event.eventGive( _.process._edispatcher, 'event2' );
//   _.event.eventGive( _.process._edispatcher, 'event2' );
//   delete _.process._edispatcher.events.event2;
//   test.identical( result, [ 0, 1, -2, -3 ] );
//   test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   got.uncaughtError.off();
//
//   test.close( 'option first - 0' );
//
//   /* - */
//
//   test.open( 'option first - 1' );
//
//   test.case = 'callback added before other callback';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
//   var got2 = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent2 }, 'first' : 1 });
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ -0, 1 ] );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ -0, 1, -2, 3 ] );
//   got.uncaughtError.off();
//   got2.uncaughtError.off();
//
//   /* */
//
//   test.case = 'callback added after other callback';
//
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var onEvent2 = () => result.push( -1 * result.length );
//   var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent2 }, 'first' : 1 });
//   var got2 = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ -0, 1 ] );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [ -0, 1, -2, 3 ] );
//
//   test.close( 'option first - 1' );
//
//   /* - */
//
//   if( !Config.debug )
//   return;
//
//   test.case = 'without arguments';
//   test.shouldThrowErrorSync( () => _.process.on() );
//
//   test.case = 'wrong type of callback';
//   test.shouldThrowErrorSync( () => _.process.on( 'uncaughtError', {} ) );
//
//   test.case = 'wrong type of event name';
//   test.shouldThrowErrorSync( () => _.process.on( [], () => 'str' ) );
//
//   test.case = 'wrong type of options map o';
//   test.shouldThrowErrorSync( () => _.process.on( 'wrong' ) );
//
//   test.case = 'extra options in options map o';
//   test.shouldThrowErrorSync( () => _.process.on({ callbackMap : {}, wrong : {} }) );
//
//   test.case = 'not known event in callbackMap';
//   test.shouldThrowErrorSync( () => _.process.on({ callbackMap : { unknown : () => 'unknown' } }) );
// }

//

function onWithChain( test )
{
  const self = this;
  const a = test.assetFor( false );
  a.fileProvider.dirMake( a.abs( '.' ) );

  /* - */

  a.ready.then( () =>
  {
    test.case = 'chain in args';
    return null;
  });
  var program = a.program( chainInArgs );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '[ [ \'exit\', \'arg\' ] ]' ), 1 );
    return null;
  });

  a.ready.then( () =>
  {
    test.case = 'chain in map';
    return null;
  });
  var program = a.program( chainInMap );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '[ [ \'exit\', \'arg\' ] ]' ), 1 );
    return null;
  });

  /* - */

  return a.ready

  /* */

  function chainInArgs()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.on( _.event.Chain( 'exitBefore', 'exit' ), ( ... args ) => result.push( args ) );
    _.process.eventGive( 'exit', 'arg' );
    _.process.eventGive( 'exitBefore', 'arg' );
    _.process.eventGive( 'exit', 'arg' );
    console.log( result );
  }

  /* */

  function chainInMap()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    _.process.on({ callbackMap : { 'exitBefore' : [ _.event.Name( 'exit' ), ( ... args ) => result.push( args ) ] } });
    _.process.eventGive( 'exit', 'arg' );
    _.process.eventGive( 'exitBefore', 'arg' );
    _.process.eventGive( 'exit', 'arg' );
    console.log( result );
  }
}

// //
//
// function onWithChain( test )
// {
//   var self = this;
//
//   /* */
//
//   test.case = 'call with arguments';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var got = _.process.on( _.event.Chain( 'uncaughtError', 'available' ), onEvent );
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [] );
//   _.event.eventGive( _.process._edispatcher, 'available' );
//   test.identical( result, [ 0 ] );
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
//   _.event.off( _.process._edispatcher, { callbackMap : { available : null } } );
//
//   /* */
//
//   test.case = 'call with options map';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var got = _.process.on({ callbackMap : { uncaughtError : [ _.event.Name( 'available' ), onEvent ] } });
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
//   _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
//   test.identical( result, [] );
//   _.event.eventGive( _.process._edispatcher, 'available' );
//   test.identical( result, [ 0 ] );
//   test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
//   _.event.off( _.process._edispatcher, { callbackMap : { available : null } } );
// }

//

function onCheckDescriptor( test )
{
  const self = this;
  const a = test.assetFor( false );
  a.fileProvider.dirMake( a.abs( '.' ) );

  /* - */

  a.ready.then( () =>
  {
    test.case = 'from arguments';
    return null;
  });
  var program = a.program( callbackInArgs );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '[ \'available\' ]' ), 1 );
    test.identical( _.strCount( op.output, '[ \'off\', \'enabled\', \'first\', \'callbackMap\' ]' ), 1 );
    test.identical( _.strCount( op.output, 'descriptor.enabled : true' ), 1 );
    test.identical( _.strCount( op.output, 'descriptor.first : false' ), 1 );
    test.identical( _.strCount( op.output, 'descriptor.callbackMap : available' ), 1 );
    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'from map';
    return null;
  });
  var program = a.program( callbackInMap );
  program.start();
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '[ \'available\' ]' ), 1 );
    test.identical( _.strCount( op.output, '[ \'off\', \'enabled\', \'first\', \'callbackMap\' ]' ), 1 );
    test.identical( _.strCount( op.output, 'descriptor.enabled : true' ), 1 );
    test.identical( _.strCount( op.output, 'descriptor.first : true' ), 1 );
    test.identical( _.strCount( op.output, 'descriptor.callbackMap : available' ), 1 );
    return null;
  });

  /* - */

  return a.ready;

  /* */

  function callbackInArgs()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    const descriptor = _.process.on( 'available', ( ... args ) => result.push( args ) );
    console.log( _.props.keys( descriptor ) );
    console.log( _.props.keys( descriptor.available ) );
    console.log( `descriptor.enabled : ${ descriptor.available.enabled }` );
    console.log( `descriptor.first : ${ descriptor.available.first }` );
    console.log( `descriptor.callbackMap : ${ _.props.keys( descriptor.available.callbackMap ) }` );
  }

  /* */

  function callbackInMap()
  {
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    const result = [];
    const descriptor = _.process.on({ callbackMap : { 'available' : ( ... args ) => result.push( args ) }, first : true });
    console.log( _.props.keys( descriptor ) );
    console.log( _.props.keys( descriptor.available ) );
    console.log( `descriptor.enabled : ${ descriptor.available.enabled }` );
    console.log( `descriptor.first : ${ descriptor.available.first }` );
    console.log( `descriptor.callbackMap : ${ _.props.keys( descriptor.available.callbackMap ) }` );
  }
}

// //
//
// function onCheckDescriptor( test )
// {
//   var self = this;
//
//   /* */
//
//   test.case = 'call with arguments';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var descriptor = _.process.on( 'uncaughtError', onEvent );
//   test.identical( _.props.keys( descriptor ), [ 'uncaughtError' ] );
//   test.identical( _.props.keys( descriptor.uncaughtError ), [ 'off', 'enabled', 'first', 'callbackMap' ] );
//   test.identical( descriptor.uncaughtError.enabled, true );
//   test.identical( descriptor.uncaughtError.first, 0 );
//   test.equivalent( descriptor.uncaughtError.callbackMap, { uncaughtError : onEvent } );
//   test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   descriptor.uncaughtError.off();
//
//   /* */
//
//   test.case = 'call with arguments';
//   var result = [];
//   var onEvent = () => result.push( result.length );
//   var descriptor = _.process.on({ callbackMap : { 'uncaughtError' : onEvent } });
//   test.identical( _.props.keys( descriptor ), [ 'uncaughtError' ] );
//   test.identical( _.props.keys( descriptor.uncaughtError ), [ 'off', 'enabled', 'first', 'callbackMap' ] );
//   test.identical( descriptor.uncaughtError.enabled, true );
//   test.identical( descriptor.uncaughtError.first, 0 );
//   test.equivalent( descriptor.uncaughtError.callbackMap, { uncaughtError : onEvent } );
//   test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
//   descriptor.uncaughtError.off();
// }

//

function _argEscape2( test )
{
  let isWin = process.platform === 'win32';

  var src = 'a';
  var expected = isWin ? `^"a^"`: 'a'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = 'a b';
  var expected = isWin ? '^"a^ b^"' : 'a\\ b'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '/a/b/';
  var expected = isWin ? '^"/a/b/^"' : '\\/a\\/b\\/'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '/a/b c/';
  var expected = isWin ? '^"/a/b^ c/^"' : '\\/a\\/b\\ c\\/'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = 'A:\\b\\';
  var expected = isWin ? '^"A:\\b\\\\^"' : 'A\\:\\\\b\\\\'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = 'A:\\b c\\';
  var expected = isWin ? '^"A:\\b^ c\\\\^"' : 'A\\:\\\\b\\ c\\\\'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '"a"';
  var expected = isWin ?  '^"\\^"a\\^"^"' : '\\"a\\"'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '\\"a\\"';
  var expected = isWin ?  '^"\\\\\\^"a\\\\\\^"^"' : '\\\\\\"a\\\\\\"'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '"/a/b/"';
  var expected = isWin ? '^"\\\\^"a\\\\^"^"' : '\\"\\/a\\/b\\/\\"'
  var got = _.process._argEscape2( src )

  var src = '"/a/b c/"';
  var expected = isWin ? '^"\\^"/a/b^ c/\\^"^"' : '\\"\\/a\\/b\\ c\\/\\"'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = 'option : value';
  var expected = isWin ? '^"option^ :^ value^"' : 'option\\ \\:\\ value'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = 'option : 123';
  var expected = isWin ? '^"option^ :^ 123^"' : 'option\\ \\:\\ 123'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '**';
  var expected = isWin ?  '^"^*^*^"' : '\\*\\*'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '"**"';
  var expected = isWin ? '^"\\^"^*^*\\^"^"' : '\\"\\*\\*\\"'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );

  var src = '&&';
  var expected = isWin ?  '^"^&^&^"' : '\\&\\&'
  var got = _.process._argEscape2( src )
  test.identical( got, expected );
}

//

function _argProgEscape( test )
{
  let isWin = process.platform === 'win32';

  var src = 'a';
  var expected = 'a'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = 'a b';
  var expected = isWin ? 'a^ b' : 'a\\ b'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '/a/b/';
  var expected = isWin ? '/a/b/' : '\\/a\\/b\\/'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '/a/b c/';
  var expected = isWin ? '/a/b^ c/' : '\\/a\\/b\\ c\\/'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = 'A:\\b\\';
  var expected = isWin ? 'A:\\b\\' : 'A\\:\\\\b\\\\'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = 'A:\\b c\\';
  var expected = isWin ? 'A:\\b^ c\\' : 'A\\:\\\\b\\ c\\\\'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '"a"';
  var expected = isWin ?  '^"a^"' : '\\"a\\"'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '\\"a\\"';
  var expected = isWin ?  '\\^"a\\^"' : '\\\\\\"a\\\\\\"'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '"/a/b/"';
  var expected = isWin ? '^"/a/b^ c/^"' : '\\"\\/a\\/b\\/\\"'
  var got = _.process._argProgEscape( src )

  var src = '"/a/b c/"';
  var expected = isWin ? '^"/a/b^ c/^"' : '\\"\\/a\\/b\\ c\\/\\"'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = 'option : value';
  var expected = isWin ? 'option^ :^ value' : 'option\\ \\:\\ value'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = 'option : 123';
  var expected = isWin ? 'option^ :^ 123' : 'option\\ \\:\\ 123'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '**';
  var expected = isWin ?  '^*^*' : '\\*\\*'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '"**"';
  var expected = isWin ? '^"^*^*^"' : '\\"\\*\\*\\"'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );

  var src = '&&';
  var expected = isWin ?  '^&^&' : '\\&\\&'
  var got = _.process._argProgEscape( src )
  test.identical( got, expected );
}

//

function _argCmdEscape( test )
{
  let isWin = process.platform === 'win32';

  var prog = 'node'
  var args = [ '-v' ]
  var expected = isWin ? 'node ^"-v^"' : 'node \\-v'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

  var prog = '/path/to/node'
  var args = [ '-v' ]
  var expected = isWin ? '/path/to/node ^"-v^"' : '\\/path\\/to\\/node \\-v'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

  var prog = '/path/with space/node'
  var args = [ '-v' ]
  var expected = isWin ? '/path/with^ space/node ^"-v^"' : '\\/path\\/with\\ space\\/node \\-v'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

  var prog = '"node"'
  var args = [ '-v' ]
  var expected = isWin ? '^"node^" ^"-v^"' : '\\"node\\" \\-v'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

  var prog = 'node -v'
  var args = []
  var expected = isWin ? 'node^ -v' : 'node\\ \\-v'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

  var prog = '/path/to/node -v'
  var args = []
  var expected = isWin ? '/path/to/node^ -v' : '\\/path\\/to\\/node\\ \\-v'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

  var prog = '/path/with space/node -v'
  var args = []
  var expected = isWin ? '/path/with^ space/node^ -v' : '\\/path\\/with\\ space\\/node\\ \\-v'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

  var prog = 'ls'
  var args = [ '*' ]
  var expected = isWin ? 'ls ^"^*^"' : 'ls \\*'
  var got = _.process._argCmdEscape( prog,args )
  test.identical( got, expected );

}

//

const Proto =
{

  name : 'Tools.l4.process.Basic',
  silencing : 1,
  routineTimeOut : 60000,
  onSuiteBegin : suiteBegin,
  onSuiteEnd : suiteEnd,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,
  },

  tests :
  {
    // events

    onWithArguments,
    onWithOptionsMap,
    onWithChain,
    onCheckDescriptor,

    _argEscape2,
    _argProgEscape,
    _argCmdEscape

  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
