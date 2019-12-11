## Node.js signals

|  Signal  |                                          Description                                          | Can be sent on Windows | Can be handled on Windows | Can be sent on Unix | Can be handled on Unix | Can terminate process |
| -------- | --------------------------------------------------------------------------------------------- | ---------------------- | ------------------------- | ------------------- | ---------------------- | --------------------- |
| SIGINT   | Sent to a process by its controlling terminal<br> when a user wishes to interrupt the process | +                      | Main                      | +                   | Main,Child             | +                     |
| SIGTERM  | Sent to a process to request its termination                                                  | +                      | -                         | +                   | Main,Child             | +                     |
| SIGKILL  | Sent to a process to cause it to terminate immediately                                        | +                      | -                         | +                   | -                      | +                     |
| SIGSTOP  | Instructs the operating system to stop a process for later resumption                         | -                      | -                         | +                   | -                      | -                     |
| SIGUSR1  | Is reserved by Node.js to start the debugger                                                  | -                      | Main                      | +                   | Main,Child             | -                     |
| SIGPIPE  | Write on a pipe with no one to read it. Is ignored in Node.js by default                      | -                      | -                         | +                   | Main,Child             | -                     |
| SIGHUP   | Sent to a process when its controlling terminal is closed. See notes for details              | -                      | Main,Child?               | +                   | Main,Child             | +                     |
| SIGBREAK | Is delivered on Windows when `Ctrl`+`Break` is pressed.                                       | -                      | Main,Child?               | -                   | -                      | -                     |
| SIGWINCH | Is delivered when the console has been resized                                                | -                      | Main,Child?               | +                   | Main,Child             | -                     |
| SIGBUS   | Access to an undefined portion of a memory object                                             | -                      | ?                         | +                   | Main,Child             | +                     |
| SIGFPE   | Floating-point error                                                                          | -                      | ?                         | +                   | Main,Child             | +                     |
| SIGSEGV  | Illegal storage access                                                                        | -                      | ?                         | +                   | Main,Child             | +                     |
| SIGILL   | Illegal instruction                                                                           | -                      | ?                         | +                   | Main,Child             | +                     |

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
  
#### Windows vs Unix

Sending signals:

  - Windows suppports only sending of `SIGINT`, `SIGTERM`, and `SIGKILL` signals that cause the unconditional termination of the target process.
  - Unix-like systems have no problem with sending signals.
  - Sending of `SIGKILL` cause termination on all platforms.
  - Process with blocked event loop can be terminated by sending `SIGINT`, `SIGTERM`, `SIGKILL` on Windows and `SIGTERM`, `SIGKILL` on Unix-like systems.

Receiving signals:
  
  - Windows can handle `SIGINT` signal if it was sent from controlling terminal,otherwise proces will be terminated. 
  - Unix-like systems have no problems with signals handling.
