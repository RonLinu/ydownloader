
Experimental web application to download videos on the user PC.

This is a work in progress...

Goal: this web application uses a WebSocket server that is much lighter, even though  
less powerfull, than packagers like Electron to run a JavaScript application that can:  
  - have access to the operating system to execute system utilities
  - have a graphical user interface using HTML/CSS

NOTE 1: only the WebSocket server is needed on the user PC to run this web application.  
The total storage needed on the user PC is (beside Node.js):
  - about 3K for the web server
  - about 170K for the 'ws' websocket library

   The web page itself is hosted on GitHub.

NOTE 2: it is the WebSocket server itself that opens the web page by launching the default browser  
of the user PC. This makes the web application as easy to launch as a real desktop application.  
This convenient and automated process is also necessary to pass information to the JavaScript  
running the web application. This information is the web socket port number, a security session  
identifier and the user platform, all are passed in the fragment identifier appended to the web page URL.

Opening the web page using a bookmark, a link, pasting or typing the url will issue an error message.
  
-------------------------------------
INSTALLATION OF THE WEBSOCKET SERVER:

- Node.js must be installed on your system (if not already installed)
- yt-dlp and ffmepg utilities must be installed and in your PATH
- ensure xterm terminal is installed (Linux only)
- download the "websocket" directory and copy anywhere on user PC

To run the web application, go in the 'websocket' directory:
- On Windows:       start with ydownloader.vbs
- On Linux/MacOS:   start with ydownloader.sh

The WebSocket server will automatically open the web application using your default browser.
