#! /usr/bin/env node

if( typeof module !== 'undefined' )
{
  let _ = require( 'wTools' );
  _.include( 'wAppBasic' );
}

let _ = wTools;
let o =
{
  execPath : _.path.join( __dirname, 'AppArgs.js' ),
  // mode : 'shell',
}
_.appExitHandlerRepair();
_.shellNodePassingThrough( o );