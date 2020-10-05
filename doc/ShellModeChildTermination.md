### Shell mode termination results on GitHub:

| Signal  | Windows | Linux | MacOS |
| ------- | ------- | ----- | ----- |
| SIGINT  | 0       | 0     | 1     |
| SIGTERM | 0       | 0     | 1     |
| SIGKILL | 0       | 0     | 1     |
| SIGSTOP | X       | 2     | 2     |
| SIGHUP  | X       | 0     | 1     |

### Shell mode termination results on local machine:

| Signal  | Windows | CentOs | MacOS |
| ------- | ------- | ------ | ----- |
| SIGINT  | 0       | 1      | 1     |
| SIGTERM | 0       | 1      | 1     |
| SIGKILL | 0       | 1      | 1     |
| SIGSTOP | X       | 2      | 2     |
| SIGHUP  | X       | 1      | 1     |

**Legend**:
X - Signal is not supported<br>
0 - Child continues to work<br>
1 - Child is terminated<br>
2 - Child is paused<br>