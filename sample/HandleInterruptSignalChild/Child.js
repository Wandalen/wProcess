
console.log( 'Child process start' );

process.on( 'SIGINT', () => 
{
  console.log( 'Child process received SIGINT from parent.' );
})
setTimeout( () => 
{
}, 5000 )