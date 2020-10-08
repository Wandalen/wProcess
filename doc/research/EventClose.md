## Event close

This doc shows when event `close` of child process is called.

     ╔════════════════════════════════════════════════════════════════════════╗
     ║       mode               ipc          disconnecting      close event   ║
     ╟────────────────────────────────────────────────────────────────────────╢
     ║       spawn             false             false             true       ║
     ║       spawn             false             true              true       ║
     ║       spawn             true              false             true       ║
     ║       spawn             true              true              false      ║
     ║       fork              true              false             true       ║
     ║       fork              true              true              false      ║
     ║       shell             false             false             true       ║
     ║       shell             false             true              true       ║
     ╚════════════════════════════════════════════════════════════════════════╝

Summary:

* Options `stdio` and `detaching` don't affect `close` event.
* Mode `spawn`: IPC is optionable. Event close is not called if disconnected process had IPC enabled.
* Mode `fork` : IPC is always enabled. Event close is not called if process is disconnected.
* Mode `shell` : IPC is not available. Event close is always called.