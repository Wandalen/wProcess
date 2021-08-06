( function _Basic_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../node_modules/Tools' );

  _.include( 'wPathBasic' );
  _.include( 'wGdf' );
  _.include( 'wBlueprint' );
  _.include( 'wConsequence' );
  _.include( 'wFilesBasic' );
  
  if( Config.interpreter === 'browser' )
  _.include( 'wFilesHttp' )

  module[ 'exports' ] = _global_.wTools;
}

})();
