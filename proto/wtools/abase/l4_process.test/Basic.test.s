( function _Basic_test_s( )
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( './../../../node_modules/Tools' );
  _.include( 'wTesting' );
  _.include( 'wFiles' );
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
  var self = this;

  /* */

  test.case = 'no callback for events';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [] );

  /* */

  test.case = 'single callback for single event, single event is given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on( 'uncaughtError', onEvent );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [ 0 ] );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for single event, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on( 'uncaughtError', onEvent );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [ 0, 1 ] );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for each events in event handler, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.process._edispatcher.events.event2 = [];
  var got = _.process.on( 'uncaughtError', onEvent );
  var got2 = _.process.on( 'event2', onEvent2 );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._edispatcher, 'event2' );
  _.event.eventGive( _.process._edispatcher, 'event2' );
  delete   _.process._edispatcher.events.event2;
  test.identical( result, [ 0, 1, -2, -3 ] );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  got.uncaughtError.off();
}

//

function onWithOptionsMap( test )
{
  var self = this;

  /* - */

  test.open( 'option first - 0' );

  test.case = 'no callback for events';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [] );

  /* */

  test.case = 'single callback for single event, single event is given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [ 0 ] );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for single event, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent }} );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [ 0, 1 ] );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for each events in event handler, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.process._edispatcher.events.event2 = [];
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent, 'event2' : onEvent2 } });
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._edispatcher, 'event2' );
  _.event.eventGive( _.process._edispatcher, 'event2' );
  delete _.process._edispatcher.events.event2;
  test.identical( result, [ 0, 1, -2, -3 ] );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  got.uncaughtError.off();

  test.close( 'option first - 0' );

  /* - */

  test.open( 'option first - 1' );

  test.case = 'callback added before other callback';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
  var got2 = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent2 }, 'first' : 1 });
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ -0, 1 ] );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ -0, 1, -2, 3 ] );
  got.uncaughtError.off();
  got2.uncaughtError.off();

  /* */

  test.case = 'callback added after other callback';

  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent2 }, 'first' : 1 });
  var got2 = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ -0, 1 ] );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [ -0, 1, -2, 3 ] );

  test.close( 'option first - 1' );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'without arguments';
  test.shouldThrowErrorSync( () => _.process.on() );

  test.case = 'wrong type of callback';
  test.shouldThrowErrorSync( () => _.process.on( 'uncaughtError', {} ) );

  test.case = 'wrong type of event name';
  test.shouldThrowErrorSync( () => _.process.on( [], () => 'str' ) );

  test.case = 'wrong type of options map o';
  test.shouldThrowErrorSync( () => _.process.on( 'wrong' ) );

  test.case = 'extra options in options map o';
  test.shouldThrowErrorSync( () => _.process.on({ callbackMap : {}, wrong : {} }) );

  test.case = 'not known event in callbackMap';
  test.shouldThrowErrorSync( () => _.process.on({ callbackMap : { unknown : () => 'unknown' } }) );
}

//

function onWithChain( test )
{
  var self = this;

  /* */

  test.case = 'call with arguments';
  var result = [];
  var onEvent = () => result.push( result.length );
  var got = _.process.on( _.event.Chain( 'uncaughtError', 'available' ), onEvent );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [ 0 ] );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.off( _.process._edispatcher, { callbackMap : { available : null } } );

  /* */

  test.case = 'call with options map';
  var result = [];
  var onEvent = () => result.push( result.length );
  var got = _.process.on({ callbackMap : { uncaughtError : [ _.event.Name( 'available' ), onEvent ] } });
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.eventGive( _.process._edispatcher, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._edispatcher, 'available' );
  test.identical( result, [ 0 ] );
  test.false( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.off( _.process._edispatcher, { callbackMap : { available : null } } );
}

//

function onCheckDescriptor( test )
{
  var self = this;

  /* */

  test.case = 'call with arguments';
  var result = [];
  var onEvent = () => result.push( result.length );
  var descriptor = _.process.on( 'uncaughtError', onEvent );
  test.identical( _.props.keys( descriptor ), [ 'uncaughtError' ] );
  test.identical( _.props.keys( descriptor.uncaughtError ), [ 'off', 'enabled', 'first', 'callbackMap' ] );
  test.identical( descriptor.uncaughtError.enabled, true );
  test.identical( descriptor.uncaughtError.first, 0 );
  test.equivalent( descriptor.uncaughtError.callbackMap, { uncaughtError : onEvent } );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  descriptor.uncaughtError.off();

  /* */

  test.case = 'call with arguments';
  var result = [];
  var onEvent = () => result.push( result.length );
  var descriptor = _.process.on({ callbackMap : { 'uncaughtError' : onEvent } });
  test.identical( _.props.keys( descriptor ), [ 'uncaughtError' ] );
  test.identical( _.props.keys( descriptor.uncaughtError ), [ 'off', 'enabled', 'first', 'callbackMap' ] );
  test.identical( descriptor.uncaughtError.enabled, true );
  test.identical( descriptor.uncaughtError.first, 0 );
  test.equivalent( descriptor.uncaughtError.callbackMap, { uncaughtError : onEvent } );
  test.true( _.event.eventHasHandler( _.process._edispatcher, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  descriptor.uncaughtError.off();
}

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
