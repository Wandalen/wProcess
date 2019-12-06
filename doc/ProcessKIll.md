#### Difference between in behaviour of process.kill and childprocess.kill on Windows and Unix

|           Method            |             Windows             |              Unix               |            Gracefull exit            |
| --------------------------- | ------------------------------- | ------------------------------- | ------------------------------------ |
| process.kill( pid, signal ) | exitCode : 1, exitSignal : null      | exitCode : null, exitSignal : signal | Only on Unix, Win - process will die |
| childprocess.kill( signal ) | exitCode : null, exitSignal : signal | exitCode : null, exitSignal : signal | Only on Unix, Win - process will die |


**Notes**:

Gracefull exit - possibility to catch termination signal to do some work before exit and then use process.exit( 0 ) to exit with zero code.

[Node.Js Signal Events](https://nodejs.org/api/process.html#process_signal_events)<br>

Windows does not support sending signals, but Node.js offers some emulation with process.kill(), and childprocess.kill().<br>
Sending signal 0 can be used to test for the existence of a process. Sending SIGINT, SIGTERM, and SIGKILL cause the unconditional<br>
termination of the target process.<br>
Sending of `SIGKILL` cause termination on all platforms.<br>
