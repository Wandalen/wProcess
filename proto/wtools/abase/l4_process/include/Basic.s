( function _Basic_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );

  _.include( 'wPathBasic' );
  _.include( 'wGdf' );
  _.include( 'wBlueprint' );
  _.include( 'wConsequence' );
  _.include( 'wFiles' );

  module[ 'exports' ] = _global_.wTools;
}

})();
