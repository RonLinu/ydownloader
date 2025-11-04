
Experimental web application to download videos on the user PC.

Goal: to create a web application using a WebSocket server that is much lighter, even though  
less powerfull, than packagers like Electron to run a JavaScript application that still can  
have access to the operating system to execute system utilities.

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
- only copy the "websocket" directory on the user machine
- install yt-dlp and ffmepg utilities on the user machine, ensure they are in your PATH
- Linux only: ensure xterm terminal is installed

On Linux, yt-dlp and ffmpeg are available in repositories.
On Windows, you have to download them for their websites.

To run the web application, go in the 'websocket' directory:
- On Windows:       start with ydownloader.vbs
- On Linux/MacOS:   start with ydownloader.sh

The WebSocket server will automatically open the web application using your default browser.
