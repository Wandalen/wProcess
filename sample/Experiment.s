var _ = require( '..')

let tree2 =
{
  executionTime : [ 25, 100 ],
}

_.process._startTree( tree2 );

let tree1 =
{
  executionTime : [ 25, 100 ],
  onEnd : () =>
  {
    _.process.children({ pid : tree1.rootOp.pnd.pid, format : 'list' })
    .then( ( children ) =>
    {
      children.forEach( ( pnd ) =>
      {
        let tree2ContainsPnd = _.longHas( tree2.alive, pnd.pid ) || _.longHas( tree2.terminated, pnd.pid );

        if( tree2ContainsPnd )
        {
          console.log( `tree1.alive has pid: ${pnd.pid}`, _.longHas( tree1.alive, pnd.pid ));
          console.log( `tree1.alive has ppid: ${pnd.ppid}`, _.longHas( tree1.alive, pnd.ppid ));
          console.log( `tree1.terminated has pid: ${pnd.pid}`, _.longHas( tree1.terminated, pnd.pid ));
          console.log( `tree1.terminated has ppid: ${pnd.ppid}`, _.longHas( tree1.terminated, pnd.ppid ));
          throw _.err( 'Found bug' );
        }
      })
      return null;
    })
  }
}

_.process._startTree( tree1 );