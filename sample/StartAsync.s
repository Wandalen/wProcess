let _ = require( '..' );
_.include( 'wFiles' )

/* How to execute command asynchronously */

// var o =
// { execPath : 'node -e "console.log(\'Node:\',process.pid)"', mode : 'spawn', stdio : 'pipe', detaching : 1 }
// _.process.start( o );

// console.log( 'Shell:', o.process.pid )

let ChildProcess = require( 'child_process')


let cprocess = ChildProcess.spawn( 'node -e "console.log(\'Node:\',process.pid)"', [], { cwd : __dirname, stdio : 'inherit', shell : true } )

console.log( 'Shell:', cprocess.pid )
