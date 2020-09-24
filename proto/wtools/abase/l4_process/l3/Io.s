( function _Io_s_()
{

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

    return args.map( ( e ) =>
    {
      if( !_.strHas( e, /\s/ ) )
      return e;

      let quotes = _.strQuoteAnalyze( e );
      if( quotes.ranges.length )
      return e;

      return `"${e}"`;
    })
    .join( ' ' )
    .trim();

    // return args.map( e => _.strHas( e, /\s/ ) ? `"${e}"` : e ).join( ' ' ).trim();
  }
}

_argsInSamFormatNodejs.defaults = Object.create( _argsInSamFormatDefaults.defaults );

//

function _argsInSamFormatBrowser( o )
{
  // debugger; /* xxx */

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

//

function pathsRead()
{
  if( !_global_.process )
  return [];

  let paths = _global_.process.env.PATH;

  if( _global_.process.platform === 'win32' )
  paths = paths.split( ';' );
  else
  paths = paths.split( ':' );

  return _.path.s.normalize( paths );
}

//

function systemEntryAdd( o )
{

  if( !_.mapIs( o ) )
  o = { appPath : arguments[ 0 ] }

  _.routineOptions( systemEntryAdd, o );

  if( _.boolLikeTrue( o.logger ) )
  o.logger = _.LoggerPrime();

  if( o.platform === 'multiple' )
  o.platform = [ 'windows', 'posix' ];

  if( o.platform === null )
  o.platform = process.platform === 'win32' ? 'windows' : 'posix';

  o.platform = _.arrayAs( o.platform );

  if( o.allowingMissed === null )
  o.allowingMissed = !!o.forcing;
  if( o.allowingNotInPath === null )
  o.allowingNotInPath = !!o.forcing;

  _.assert( _.path.isAbsolute( o.appPath ), () => `Epects absolute path o.appPath, but got ${o.appPath}` );

  o.appPath = _.path.normalize( o.appPath );
  if( o.name === null )
  o.name = _.path.name( o.appPath );

  _.assert( _.longHasAll( [ 'windows', 'posix' ], o.platform ), `Unknown platforms : ${o.platform.join( ' ' )}` );
  _.assert( _.path.isAbsolute( o.entryDirPath ), () => `Epects absolute path o.appPath, but got ${o.appPath}` );
  _.assert( _.strIs( o.prefix ) );
  _.sure( _.strDefined( o.entryDirPath ), `Neither {-o.entryDirPath-} is defined nor config has defined path::entry` );
  _.sure( _.fileProvider.isDir( o.entryDirPath ), `Not a dir : ${o.entryDirPath}` );
  _.sure
  (
    o.allowingMissed || ( _.fileProvider.fileExists( o.appPath ) && !_.fileProvider.isDir( o.appPath ) ),
    () => `Does not exist file : ${o.appPath}`
  );
  _.sure
  (
    o.allowingNotInPath || _.longHas( _.process.pathsRead(), o.entryDirPath )
    , () => `entryDirPath is not in the environment variable $PATH`
    + `\nentryDirPath : ${o.entryDirPath}`
    + `\n$PATH :\n  ${_.process.pathsRead().join( '\n  ' )}`
  );

  let appPath = o.appPath;
  debugger;
  if( o.relative )
  appPath = _.path.relative( o.entryDirPath, o.appPath );
  debugger;

  appPath = _.path.nativize( appPath );

  let counter = 0;

  o.platform.forEach( ( platform ) => installFor( platform ) );

  if( o.logger && o.verbosity === 1 )
  o.logger.log( ` + Added ${counter} entrie(s) ${_.path.moveTextualReport( o.entryDirPath, o.appPath )}` );

  return counter;

  function shellRelativePosix()
  {
    return `
#!/bin/bash
dirPath=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# dirPath=$0;
# dirPath=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P )
# dirPath=$( cd "$(dirname "\${BASH_SOURCE[0]}")" ; pwd -P )
# echo BASH_SOURCE[0]:\${BASH_SOURCE[0]}
# echo dirPath:\${dirPath}
# echo appPath:${appPath}
# ${o.prefix}\${dirPath}/${appPath} "$@"
${o.prefix}\${dirPath}/${appPath} "$@"
`
  }

  function shellRelativeWindows()
  {
    return `
@echo off
${o.prefix}%~dp0${appPath} %*
`
  }

  function installFor( platform )
  {
    let entryTerminalPath = _.path.join( o.entryDirPath, o.name );
    if( platform === 'windows' )
    entryTerminalPath += '.bat';
    let shellFile = shellRelativePosix();
    if( platform === 'windows' )
    shellFile = shellRelativeWindows();

    if( o.logger && o.verbosity >= 2 )
    o.logger.log( ` + Add entry ${_.path.moveTextualReport( entryTerminalPath, o.appPath )}` );

    _.fileProvider.fileWrite( entryTerminalPath, shellFile );

    if( o.addingRights !== null )
    _.fileProvider.rightsAdd( entryTerminalPath, o.addingRights );

    counter += 1;
  }

}

systemEntryAdd.defaults =
{
  logger : 0,
  verbosity : 0,
  entryDirPath : null, // where to add
  appPath : null, // where to run
  prefix : 'node ', //
  name : null,
  platform : null,
  relative : 1, // whether path is relative, other test routine
  addingRights : 0o777, // rights to be able to run this file ( all rights )
  allowingMissed : null, // ( test routine ) error if program is absent
  allowingNotInPath : null, // error if entryDirPath
  forcing : 0, // make all to run the routine ( test routine )
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

  pathsRead, /* qqq : cover */

  systemEntryAdd, /* qqq : cover */
  /* xxx qqq : implement entryRemove */

}

_.mapExtend( Self, Extension );
_.assert( _.routineIs( _.process.start ) );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
