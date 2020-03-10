var ChildProcess = require( 'child_process' );
var path = require( 'path' );

let o = 
{ 
  shell : false, detached : true, stdio : 'pipe', windowsHide : true,
}

var p = ChildProcess.spawn
( 
  'node', 
  [ path.join( __dirname, 'Detached.js' ) ],
  o 
)

// var p = ChildProcess.fork
// ( 
//   path.join( __dirname, 'Detached.js' ),
//   [],
//   o 
// )

if( p.disconnect )
p.disconnect();
p.unref();

p.stdout.on( 'data', data => console.log( data.toString() ) )

setTimeout(  () => 
{
  console.log( p.pid )
  process.exit();
  
},2000)


