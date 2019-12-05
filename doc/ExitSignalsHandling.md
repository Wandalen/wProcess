## Information about exit signal handling in Node.JS 

### Sending signal to child process

| Signal  | Windows | Unix |
| ------- | ------- | --- |
| SIGINT  | 0       | 1   |
| SIGTERM | 0       | 1   |
| SIGKILL | 0       | 0   |

**Legend**

0 - process.on handler will not be executed, child process will be killed<br>
1 - process.on handler will be executed, child process can override default behaviour( exit )

### Receiving signal in main process

|      Signal      | Windows | Unix |
| ---------------- | ------- | --- |
| SIGINT( CTRL+C ) | 1       | 1   |
| SIGTERM          | 0       | 1   |
| SIGKILL          | 0       | 0   |

**Legend**

0 - process.on handler will not be executed<br>
1 - process.on handler will be executed

### Sending signal to child process with blocked event lopp

| Signal  | Windows | Unix |
| ------- | ------- | --- |
| SIGINT  | 0       | 1   |
| SIGTERM | 0       | 0   |
| SIGKILL | 0       | 0   |

**Legend**

0 - process.on handler will not be executed, child process will be killed<br>
1 - process.on handler will not be executed, child process will continue to work

**Notes**:
Process with blocked event loop can't be terminated from command line with combination `CTRL+C`, only by kill command.