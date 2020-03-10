
## Information about behaviour of detaching option with different stdio and mode

### Support

| mode  | supports detaching |
| ----- | ------------------ |
| spawn | +                  |
| fork  | +                  |
| shell | +                  |
| exec  | -                  |

### What happens to the main process depending on option stdio

| mode/stdio | inherit | pipe | ignore |
| ---------- | ------- | ---- | ------ |
| spawn      | 1       | 2    | 1      |
| fork       | 1       | 2    | 1      |
| shell      | 1       | 2    | 1      |

This behaviour is same on Windows,Linux and MacOS

**Legend**

1 - Parent doesn't wait until detached child exits.<br>
2 - Parent waits until detached child exits.

### Output of detached process with different stdio

##### stdio:inherit

| Mode  | Windows | Linux | MacOS |
| ----- | ------- | ----- | ----- |
| spawn | 1       | 2     | 2     |
| fork  | 1       | 2     | 2     |
| shell | 1       | 2     | 2     |

**Legend**

1 - No output from detached child in console of parent process.<br>
2 - Detached child process prints output to console of parent process.

##### stdio:pipe


| Mode  | Windows | Linux | MacOS |
| ----- | ------- | ----- | ----- |
| spawn | 1       | 1     | 1     |
| fork  | 1       | 1     | 1     |
| shell | 2       | 1     | 1     |

**Legend**

1 - Parent process can obtain output from stdout stream of detached child
2 - Output of detached process is printed in console window of detached process


##### stdio:ignore

| Mode  | Windows | Linux | MacOS |
| ----- | ------- | ----- | ----- |
| spawn | 1       | 1     | 1     |
| fork  | 1       | 1     | 1     |
| shell | 2       | 1     | 1     |

**Legend**

1 - Output of detached child is redirected to /dev/null 
2 - Output of detached process is printed in console window of detached process

### Summary
- Mode `exec` doesn't support detaching in current version of node - 13.10.1.
- Parent process doesn't wait for child to exit if `stdio` is set to `inherit` or `ignore`
- Output of detached child can be consumed by parent process if `stdio` is set to `pipe`.<br>
In this case parent will not exit automatically and will be waiting until child process exits.