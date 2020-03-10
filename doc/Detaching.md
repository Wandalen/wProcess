
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

**Legend**

1 - Parent doesn't wait until detached child exits.<br>
2 - Parent waits until detached child exits.

### Output of detached process with different stdio

##### stdio:inherit

| Mode  |                         Description                         |
| ----- | ----------------------------------------------------------- |
| spawn | No output from detached child in console of parent process. |
| fork  | No output from detached child in console of parent process. |
| shell | No output from detached child in console of parent process. |

##### stdio:pipe

| Mode  |                                 Description                                 |
| ----- | --------------------------------------------------------------------------- |
| spawn | Parent process can obtain output from stdout stream of detached child       |
| fork  | Parent process can obtain output from stdout stream of detached child       |
| shell | Output of detached process is printed in console window of detached process |


##### stdio:ignore

| Mode  |                                 Description                                 |
| ----- | --------------------------------------------------------------------------- |
| spawn | Output of detached child is redirected to /dev/null                         |
| fork  | Output of detached child is redirected to /dev/null                         |
| shell | Output of detached process is printed in console window of detached process |


### Summary
- Mode `exec` doesn't support detaching in current version of node - 13.10.1.
- Parent process doesn't wait for child to exit if `stdio` is set to `inherit` or `ignore`
- Output of detached child can be consumed by parent process if `stdio` is set to `pipe`.<br>
In this case parent will not exit automatically and will be waiting until child process exits.