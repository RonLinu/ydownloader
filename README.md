
Experimental web application to download videos using the well known download utilities:  
- yt-dlp
- ffmepg

Goal: create a web interface using a WebSocket server instead of a packager like Electron to run  
JavaScript code with access to the operating system.  
The application would have very low disk usage, about 170K bytes on the user computer (excluding Node.js).

The web page itself is hosted on GitHub. Only the WebSocket server is needed on the user computer.

NOTE: it is the WebSocket server that opens the web page by launching the default browser.  
This makes the web application as easy to launch as a real desktop application.  

This automated process is necessary to pass information to the JavaScript running the web application.  
This information is the web socket port number and the user platform. Both are passed in the fragment  
identifier appended to the web page URL.

Trying to open the web page using a bookmark, a link, pasting or typing the url will issue an error message.
  
-------------------------------------
INSTALLATION OF THE WEBSOCKET SERVER:

Assuming Node.js, yt-dlp and ffmpeg are already installed and included in your PATH.  
On Linux, xterm terminal must be installed.

Just copy the "websocket" directory provided in this repo.

To run the web application, go in your 'websocket' directory:  
<pre>
On Windows:       start with 'ydownloader.vbs'
On Linux/MacOS:   start with 'ydownloader.sh'
</pre>

-----------------------------------------------
If Node.js, yt-dlp and ffmpeg are NOT installed.

Download 'Node.js' latest version at: https://nodejs.org/en/download  
This is an archive file for Linux/MacOS or an msi file for Windows.

Download 'yt-dlp' latest version at: https://github.com/yt-dlp/yt-dlp/releases   
This is a single executable.

Download 'ffmpeg' latest version at: https://github.com/BtbN/FFmpeg-Builds/releases  
This is an archive file (zip or tar-xz).  
Just extract the files contained in the 'bin' directory of the zip file.

Copy ALL yt-dlp and ffmepg files in a directory of your choice and add it to your PATH.
