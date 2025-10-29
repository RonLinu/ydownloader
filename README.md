
Experimental web application to download videos on the user PC.

This is a work in progress!

Goal: this web application uses a different solution than Electron or
  similar packages to run a JavaScript application that can:
  - give access to the operating system to execute system utilities.
  - offer a graphical user interface using a standard HTML/CSS web page.

To do that, a simple and lightweight solution is to use a WebSocket server
that acts as a bridge between the web page and the operating system.

NOTE 1: ONLY the WebSocket server is needed on the user PC.
The total storage needed on the user PC is (beside Node.js):
  - about 3K for the web server
  - about 170K for the 'ws' websocket library

   The web page itself is hosted on GitHub.

NOTE 2: the WebSocket server MUST open the web page by itself to tell the JavaScript
  running the web page which socket port to connect to AND to authenticate the connection.

  This information is passed in the fragment identifier appended to the page URL.

  Opening the web page directly without the correct fragment identifier will issue
  an error message. A dummy fragment identifier will not work either because
  the fragment identifier is different each time the WebSocket server is started.

-------------------------------------
INSTALLATION OF THE WEBSOCKET SERVER:

- Node.js must be installed on your system, if not already installed
- yt-dlp and ffmepg utilities must be installed and in your PATH
- download the "websocket" directory and put it on your drive
- (Linux/MacOS only: insure xterm terminal is installed)

To run:
- Linux/MacOS: start with ydownloader.sh
- Windows:     start with ydownloader.vbs

The WebSocket server will automatically open the web application using your default browser.
This mimics the simplicity of tarting a desktop application.
