
## Information about behaviour of detaching option with different stdio and mode

### Execution

| mode/stdio | inherit | pipe | ignore |
| ---------- | ------- | ---- | ------ |
| spawn      | 1       | 2    | 1      |
| fork       | 1       | 2    | 1      |
| shell      | 1       | 2    | 1      |
| exec       | 0       | 0    | 0      |

**Legend**

0 - mode doesn't support detaching<br>
1 - parent doesn't wait for child's termination, child ignores parent's termination<br>
2 - parent waits for child to exit

### Output

| mode/stdio | inherit | pipe | ignore |
| ---------- | ------- | ---- | ------ |
| spawn      | 1       | 2    | 1      |
| fork       | 1       | 2    | 1      |
| shell      | 1       | 2    | 1      |
| exec       | 0       | 0    | 0      |

**Legend**

0 - mode doesn't support detaching<br>
1 - no output from detached child<br>
2 - output from detached child