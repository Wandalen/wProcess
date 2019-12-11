
console.log( 'Child process start' );

process.on( 'SIGINT', () => 
{
  console.log( 'Child process received SIGINT from parent.' );
  process.exit( 0 );
})
setTimeout( () => 
{
}, 5000 )