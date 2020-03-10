
## Information about behaviour of detaching option with different stdio and mode

### Execution

| mode/stdio | inherit | pipe | ignore |
| ---------- | ------- | ---- | ------ |
| spawn      | 1       | 2    | 1      |
| fork       | 1       | 2    | 1      |
| shell      | 1       | 2    | 1      |
| exec       | 0       | 0    | 0      |

**Legend**

0 - Mode doesn't support detaching<br>
1 - Parent doesn't wait for child's termination, child ignores parent's termination<br>
2 - Parent waits for child to exit

### Output

| mode/stdio | inherit | pipe | ignore |
| ---------- | ------- | ---- | ------ |
| spawn      | 1       | 2    | 1      |
| fork       | 1       | 2    | 1      |
| shell      | 3       | 3    | 3      |
| exec       | 0       | 0    | 0      |

**Legend**

0 - Mode doesn't support detaching<br>
1 - Output of detached child is not printed anywhere<br>
2 - Parent can receive output from detached child via stdout stream<br>
3 - Parent can't receive output from detached child. Output of detached process is printed in console window created for detached process.