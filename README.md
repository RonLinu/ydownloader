
Experimental web application to download videos on the user PC.

Goal: to create a web application using a WebSocket server instead of a packager like Electron  
to run a JavaScript application that can have access to the operating system to execute system utilities.  
This solution has a very low disk usage, about 170K bytes on the user machine.

The web page itself is hosted on GitHub. Only a WebSocket server is needed on the user machine.

NOTE: it is this WebSocket server that opens the web page by launching the default browser of  
the user machine. This makes the web application as easy to launch as a real desktop application.  

This automated process is necessary to pass information to the JavaScript running the web application.  
This information is the web socket port number and the user platform, both are passed in the fragment  
identifier appended to the web page URL.

Opening the web page using a bookmark, a link, pasting or typing the url will issue an error message.
  
-------------------------------------
INSTALLATION OF THE WEBSOCKET SERVER:

- Node.js must be installed on your system (if not already installed)
- copy the "websocket" directory provided in this repo on the user machine
- Linux only: ensure xterm terminal is installed, available in any repositories

Download 'yt-dlp' latest version at: https://github.com/yt-dlp/yt-dlp/releases  
This is a single executable.

Download 'ffmpeg' latest version at: https://github.com/BtbN/FFmpeg-Builds/releases  
This is an archive file (zip or tar-xz).  
Just extract the files contained in the 'bin' directory of the zip file.

Copy all these files into your 'websocket' directory.

Add your 'websocket' directory to your PATH.

To run the web application, go in your 'websocket' directory:
<pre>
On Windows:       start with 'ydownloader.vbs'
On Linux/MacOS:   start with 'ydownloader.sh'
</pre>
The WebSocket server will automatically open the web application using your default browser.
