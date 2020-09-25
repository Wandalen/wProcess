## Information about subroutines of routine `start`.

### Subroutine `handleClose`

Executed:

  * If process exits on its own
  * If process was terminated
  * If process was not spawned due to error( unknown command, file doesn't exist )

Not Executed:

  * If detached mode when parent exits before child
  * If ChildProcess method throws an error on early stage

### Subroutine `handleError`

Executed:

  * If process could not be spawned
  * If process could not be killed
  * If process could not receive the message( IPC )

Not Executed:

  * If ChildProcess method throws an error on early stage
  * If spawned process/command throws an error


### Subroutine `end`

Is always executed in regular mode.
In detached mode is executed when child process exits before parent or parent disconnects the child.
