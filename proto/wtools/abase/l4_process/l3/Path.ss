( function _Path_ss_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;

_.assert( _.object.isBasic( _.path ) );

// --
// path
// --

/**
 * Returns path for main module (module that running directly by node).
 * @returns {String}
 * @function realMainFile
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function realMainFile()
{
  return _.process.realMainFile();
}

//

/**
 * Returns path dir name for main module (module that running directly by node).
 * @returns {String}
 * @function realMainDir
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function realMainDir()
{
  return _.process.realMainDir();
}

//

/**
 * Returns absolute path for file running directly by node
 * @returns {String}
 * @throws {Error} If passed any argument.
 * @function effectiveMainFile
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function effectiveMainFile()
{
  return _.process.effectiveMainFile();
}

//

/**
 * Returns path dirname for file running directly by node
 * @returns {String}
 * @throws {Error} If passed any argument.
 * @function effectiveMainDir
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function effectiveMainDir()
{
  _.assert( arguments.length === 0, 'Expects no arguments' );

  let result = this.dir( this.effectiveMainFile() );

  return result;
}

// --
// declare
// --

let Extension =
{
  realMainFile,
  realMainDir,

  effectiveMainFile,
  effectiveMainDir,
};

Object.assign( _.path, Extension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _.path;

})();
