
if( typeof module !== 'undefined' )
require( '..' );
require( 'wFiles' );
var _ = wTools;

/**/

// 

debugger
var execPath = `"option: "value with space""`;

var splits = _.strSplit({
  src : execPath,
  delimeter : [ ' ' ],
      quoting : 1,
      quotingPrefixes : [ "'", '"', "`" ],
      quotingPostfixes : [ "'", '"', "`" ],
      preservingEmpty : 0,
      preservingQuoting : 1,
      stripping : 1
});

// 

// var splits = _.strSplit({
//   src : 'node some/path.js "option: "value    with   space""',
//   delimeter : [ ' ',"'", '"', "`" ],
//   quoting : 0,
//   preservingEmpty : 0,
//   preservingQuoting : 0,
//   stripping : 0
// });