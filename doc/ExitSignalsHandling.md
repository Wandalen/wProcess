## Information about exit signal handling in Node.JS 

### Sending signal to child process

| Signal  | Windows | Unix |
| ------- | ------- | ---- |
| SIGINT  | 0       | 1    |
| SIGTERM | 0       | 1    |
| SIGKILL | 0       | 0    |

**Legend**

0 - process.on handler will not be executed, child process will be killed<br>
1 - process.on handler will be executed, child process can override default behaviour( exit )

### Receiving signal in main process

|      Signal      | Windows | Unix |
| ---------------- | ------- | ---- |
| SIGINT( CTRL+C ) | 1       | 1    |
| SIGTERM          | 0       | 1    |
| SIGKILL          | 0       | 0    |

**Legend**

0 - process.on handler will not be executed<br>
1 - process.on handler will be executed

### Sending signal to child process with blocked event lopp

| Signal  | Windows | Unix |
| ------- | ------- | ---- |
| SIGINT  | 0       | 1    |
| SIGTERM | 0       | 0    |
| SIGKILL | 0       | 0    |

**Legend**

0 - process.on handler will not be executed, child process will be killed<br>
1 - process.on handler will not be executed, child process will continue to work

**Notes**:
Process with blocked event loop can't be terminated from command line with combination `CTRL+C`, only by kill command.


### appExitHandlerRepair

|   Called in   | Windows | Unix |
| ------------- | ------- | ---- |
| Main process  | 1       | 1    |
| Child process | 0       | 1    |

**Legend**

0 - process will be terminated
1 - process will exit gracefully


### Summary

Windows does not support sending signals. Sending `SIGINT`, `SIGTERM`, and `SIGKILL` cause the unconditional termination of the target process.<br>
Windows can handle `SIGINT` signal if it was sent from terminal.<br>
Unix-like systems have no problem with sending and handling of `SIGINT` and `SIGTERM` signals.<br>
Sending of `SIGKILL` cause termination on all platforms.<br>
Process with blocked event loop can be terminated by sending `SIGINT`, `SIGTERM`, `SIGKILL` on Windows and `SIGTERM`, `SIGKILL` on Unix-like systems.