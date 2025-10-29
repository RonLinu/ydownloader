
Experimental web application to download videos on the user PC.

This is a work in progress!

Goal: this web application uses a WebSocket server which much lighter, even though  
less powerfull, than packages like Electron to run a JavaScript application that can:  
  - give access to the operating system to execute system utilities.
  - offer a graphical user interface using a standard HTML/CSS web page.

NOTE 1: ONLY the WebSocket server is needed on the user PC to run this web app.  
The total storage needed on the user PC is (beside Node.js):
  - about 3K for the web server
  - about 170K for the 'ws' websocket library

   The web page itself is hosted on GitHub.

NOTE 2: it is the WebSocket server itself that opens the web page by launching the default browser  
of the operating system. It is a convenient and automated process that is necessary to pass  
information to the JavaScript running the web app. This information is the web socket port and a security  
session identifier that are passed in the fragment identifier appended to the web page URL.

  Opening the web page directly without the correct fragment identifier will issue an error message.  
  A dummy fragment identifier will not work either becausethe fragment identifier is different each time  
  the WebSocket server is started.

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
