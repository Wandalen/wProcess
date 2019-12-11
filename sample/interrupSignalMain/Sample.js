

process.on( 'SIGINT', () => 
{
  console.log( 'Parent received SIGINT from controlling terminal' )
  process.exit( 0 );
})

console.log( 'Please enter CTRL+C combination...' )

setTimeout( () => {}, 10000 )