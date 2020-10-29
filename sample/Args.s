let _ = require( '..' );

_.process.waitForTermination({ pnd : process, timeOut : 100 } ).catch( ( err ) => 
{
 console.log( err)
 console.log( err.reason )
  return null;
})