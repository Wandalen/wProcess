
console.log( 'Child process start' );

process.on( 'SIGTERM', () =>
{
  console.log( 'Child process received SIGTERM' );
  process.exit( 0 );
})

process.on( 'exit', () =>
{
  console.log( 'Child process received exit' );
})

setTimeout( () =>
{
  console.log( 'timeout' )
}, 10000 )
