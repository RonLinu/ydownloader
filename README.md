
Experimental web application to download videos on the user PC.

Why: this web application uses a different solution than Electron or
  similar packages to run a JavaScript application that can:
  - give access to the operating system to execute system utilities.
  - offer a graphical user interface using a standard HTML/CSS web page.

To do that, a simple and lightweight solution is to use a web socket server
that acts as a bridge between the web page and the operating system.

NOTE 1: ONLY the web socket server is needed on the user PC.
The total storage needed on the user PC is (beside Node.js):
  - about 3K for the web server
  - about 170K for the 'ws' websocket library

   The web page itself is hosted on GitHub.

NOTE 2: the server MUST open the web page by itself to tell the JavaScript
  running the web page which socket port to use AND to authenticate the connection.

  This information is passed in the fragment identifier appended to the page URL.

  If the web page is opened without the correct fragment identifier,
  an error message will tell so. A dummy fragment identifier will not work either
  because the identifier is different each time the server is started.

-------------------------------------
INSTALLATION OF THE WEB SOCKET SERVER:

- Node.js must be installed on your system, if not already
- yt-dlp and ffmepg utilities must be installed and in your PATH
- add the "websocket" directory provided here on your drive
- (Linux/MacOS only: insure xterm terminal is installed)

To run:
 - Linux/MacOS: start with ydownloader.sh
- Windows:     start with ydownloader.vbs

The server will (should :) automatically open the web application using your default browser.
