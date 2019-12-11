
console.log( 'Child process start' );

process.on( 'SIGINT', () =>
{
  console.log( 'Child process received SIGINT' );
  process.exit( 0 );
})

process.on( 'exit', () =>
{
  console.log( 'Child process received exit' );
})

process.stdin.resume();

setTimeout( () =>
{
}, 5000 )
