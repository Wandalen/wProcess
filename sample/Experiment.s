var _ = require( '..')

let mainTree =
{
  executionTime : [ 50, 150 ],
  spawnPeriod : [ 25, 50 ],
}

let additionalReady = runAdditionalTrees( 5 )
let mainReady = _.process._startTree( mainTree );
let snapshots = [];

let timer = _.time.periodic( 10, () =>
{
  if( !_.process.isAlive( mainTree.rootOp.pnd.pid ) )
  return true;

  _.process.children({ pid : mainTree.rootOp.pnd.pid, format : 'list' })
  .thenGive( ( snapshot ) =>
  {
    if( snapshot.length > 1 )
    snapshots.push( snapshot )
  })
  return true;
})

mainReady
.then( () =>
{
  timer.cancel();

  // console.log( _.toJs( mainTree.list ) )

  snapshots.forEach( ( snapshot ) =>
  {
    snapshot.forEach( ( targetPnd ) =>
    {
      let result = mainTree.list.filter( ( treePnd ) =>
      {
        return treePnd.pid === targetPnd.pid;
      })

      _.assert( result.length === 1, `Main tree does not have pnd: ${targetPnd}` );

      let resultPnd = result[ 0 ];

      _.assert( resultPnd.ppid === targetPnd.ppid, `Ppid changed.\nTree pnd: ${_.toJs( resultPnd )}\nSnapshot pnd: ${_.toJs( targetPnd )}` );
    })
  })

  return additionalReady;
})



function runAdditionalTrees( n )
{
  let cons = [];
  for( let i = 0; i < n; i++ )
  {
    let tree =
    {
      executionTime : [ 25, 100 ],
      spawnPeriod : [ 25, 50 ],
      max : 10
    }
    _.process._startTree( tree );
    cons.push( tree.ready )
  }
  return _.Consequence.AndKeep( ... cons );
}