
Experimental web application to download videos using the well known video download utilities:  
- yt-dlp for video download
- ffmepg for video format conversion

My goal is to create a web interface that can run JavaScript code with system level access using a WebSocket  
server acting as a bridge between a browser and the operating system instead of a packager like Electron.

The web application itself is hosted on GitHub, only the WebSocket server is needed on the user computer.  
The WebSocket server has a very low disk usage: about 175K bytes.

Once started, it is the WebSocket server itself that starts the default browser with the correct web page.  
This makes the web application as easy to launch as a real desktop application.  

The WebSocket server can accept commands and mini-scripts from the web application through a socket and  
executes them with system level access.

The automated lauching process of the default browser is necessary to pass some information to the JavaScript  
running in the browser. This information is the socket port number, the user platform and the server version.  
All are passed in the fragment identifier appended to the web page URL.

Trying to reload, to open the web page using a bookmark, a link or pasting/typing the url will issue an error message.
  
-------------------------------------
INSTALLATION OF THE WEBSOCKET SERVER:

Assuming Node.js, yt-dlp and ffmpeg are already installed and included in the PATH.  
On Linux, xterm terminal must be installed.

Just copy the "websocket" directory provided in this repo.

To run the web application, go in your 'websocket' directory:  
<pre>
On Windows:       start with 'ydownloader.vbs'
On Linux/MacOS:   start with 'ydownloader.sh'
</pre>

-----------------------------------------------
If some utilities are NOT installed. The following download links can be usefull.

Download 'Node.js' latest version at: https://nodejs.org/en/download  
This is an archive file for Linux/MacOS or an msi file for Windows.

Download 'yt-dlp' latest version at: https://github.com/yt-dlp/yt-dlp/releases   
This is a single executable.

Download 'ffmpeg' latest version at: https://github.com/BtbN/FFmpeg-Builds/releases  
This is an archive file (zip or tar-xz).  
Just extract the files contained in the 'bin' directory of the zip file.

Copy ALL yt-dlp and ffmepg files in a directory of your choice and add it to your PATH.
