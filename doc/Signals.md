## Node.js signals

|  Signal  |                                          Description                                          | Windows | Unix | Can be listened |
| -------- | --------------------------------------------------------------------------------------------- | ------- | ---- | --------------- |
| SIGINT   | Sent to a process by its controlling terminal<br> when a user wishes to interrupt the process | +       | +    | +               |
| SIGTERM  | Sent to a process to request its termination                                                  | -       | +    | +               |
| SIGKILL  | Sent to a process to cause it to terminate immediately                                        | +       | +    | -               |
| SIGSTOP  | Instructs the operating system to stop a process for later resumption                         | -       | +    | -               |
| SIGUSR1  | Is reserved by Node.js to start the debugger                                                  | +       | +    | +               |
| SIGPIPE  | Write on a pipe with no one to read it. Is ignored in Node.js by default                      | -       | +    | +               |
| SIGHUP   | Sent to a process when its controlling terminal is closed. See notes for details              | +       | +    | +               |
| SIGBREAK | Is delivered on Windows when `Ctrl`+`Break` is pressed.                                       | +       | +    | -               |
| SIGWINCH | Is delivered when the console has been resized                                                | +       | +    | +               |
| SIGBUS   | Access to an undefined portion of a memory object                                             | ?       | +    | +               |
| SIGFPE   | Floating-point error                                                                          | ?       | +    | +               |
| SIGSEGV  | Illegal storage access                                                                        | ?       | +    | +               |
| SIGILL   | Illegal instruction                                                                           | ?       | +    | +               |

[Node.Js Signal Events](https://nodejs.org/api/process.html#process_signal_events)<br>
[List of Linux signals](http://man7.org/linux/man-pages/man7/signal.7.html)

#### Notes:

- **SIGHUP**: 
  Is generated on Windows when the console window is closed, and on other platforms under various similar conditions.<br>
  It can have a listener installed, however Node.js will be unconditionally terminated by Windows about 10 seconds later.<br>
  On non-Windows platforms, the default behavior of SIGHUP is to terminate Node.js
  
- **SIGWINCH**:
  Is delivered when the console has been resized.<br> 
  On Windows, this will only happen on write to the console when the cursor is being moved, or when a readable tty is used in raw mode.
  
- **SIGBUS**, **SIGFPE**, **SIGSEGV**, **SIGILL**:
  When not raised artificially using process.kill, inherently leave the process in a state from which it is not safe to attempt to call JS listeners.<br> 
  Doing so might lead to the process hanging in an endless loop, since listeners attached using process.on() are called asynchronously and therefore unable to correct the underlying problem.