( function _Io_s_() {

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let Self = _.process = _.process || Object.create( null );

_.assert( !!_realGlobal_ );

// --
//
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
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
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

/* xxx : redo caching using _Setup1 */

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

  let r = _.strRequestParse
  ({
    src : result.scriptArgsString,
    keyValDelimeter : o.keyValDelimeter,
    commandsDelimeter : o.commandsDelimeter,
    parsingArrays : o.parsingArrays,
    severalValues : 1,
  });

  _.mapExtend( result, r );

  return result;

  function argsToString( args )
  {

    return args.map( e =>
    {
      if( !_.strHas( e, /\s/ ) )
      {
        if( _.path.isGlob( e ) || _.strEnds( e, [ '/', '\\' ] ) )
        return `"${e}"`;
        return e;
      }

      let quotes = _.strQuoteAnalyze( e );
      if( quotes.ranges.length )
      {
        return e;
      }

      return `"${e}"`;
    }).join( ' ' ).trim();

    // return args.map( e => _.strHas( e, /\s/ ) ? `"${e}"` : e ).join( ' ' ).trim();
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
 * @param {Object} o.propertiesMap=null Map with parsed options. By default routine gets this map using {@link module:Tools/base/ProcessBasic.Tools.process.args args} routine.
 * @param {Object} o.namesMap=null Map of expected options.
 * @param {Object} o.removing=1 Removes copied options from result map `o.propertiesMap`.
 * @param {Object} o.only=1 Check if all option are expected. Throws error if not.
 *
 * @return {Object} Returns map with parsed options.
 *
 * @function argsReadTo
 * @module Tools/base/ProcessBasic
 * @namespace Tools.process
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
    let dstValue = o.dst[ k ]
    _.assert( dstValue !== undefined, () => 'Entry ' + _.strQuote( k ) + ' is not defined' );
    if( _.numberIs( dstValue ) )
    {
      v = Number( v );
      _.assert( !isNaN( v ) );
      o.dst[ k ] = v;
    }
    else if( _.boolIs( dstValue ) )
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

// --
// declare
// --

let Extension =
{

  _argsInSamFormatNodejs,
  _argsInSamFormatBrowser,

  argsInSamFormat : Config.interpreter === 'njs' ? _argsInSamFormatNodejs : _argsInSamFormatBrowser,
  args : Config.interpreter === 'njs' ? _argsInSamFormatNodejs : _argsInSamFormatBrowser,
  argsReadTo,
  anchor,

}

_.mapExtend( Self, Extension );
_.assert( _.routineIs( _.process.start ) );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
