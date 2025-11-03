
webpage    = process.argv[2]
socketport = process.argv[3]

fragmentId = ''         # url fragment identifier
timeout    = true       # delay for client to respond
activeClient = null     # only one client accepted at a time

if socketport is '' or webpage is ''
    console.log 'Syntax: node websocket.js <web_app_url> <socket_port>'
    process.exit 0

WebSocket = require 'ws'            # to install: npm install ws
{exec} = require 'child_process'

wss = new WebSocket.Server { port: socketport }

# --------------------------------------
wss._server.on 'listening', ->
    # Port opened successfully
    console.log 'WebSocket server listening on port', socketport

    # Client (browser) must respond within 10 sec or server will close
    setTimeout shutdown, 10000

    # Launch client (browser)
    fragmentId = '#' + randomHex() + ',' + process.platform + ',' + socketport
    launchBrowser( fragmentId )

# --------------------------------------
wss.on 'error', (err) ->
    if err.code is 'EADDRINUSE'
        console.error 'Port', socketport, 'is already in use'
        launchBrowser('#BUSY')
    else
        firstline = err.message.split('\n')[0]
        console.error 'WebSocket server error:', firstline
        launchBrowser('#ERROR')

# --------------------------------------
# When client connects
wss.on 'connection', (ws) ->
    if activeClient
        ws.close(1000, 'Only one client allowed at a time');
        return

    activeClient = ws

    console.log 'Client connected'
    timeout = false       # cancel automatic shutdown

    # When the client disconnects
    ws.on 'close', () ->
        activeClient = null
        console.log 'Client disconnected'
        process.exit 0

   # When server receives a command from client
    ws.on 'message', (message) ->
        values = JSON.parse(message)

        # Reject any command without correct fragment identifier
        if values.id isnt fragmentId
            console.error 'Incorrect fragment identifier received'
            return

        switch values.action
            when 'run'
                console.log 'Server received:', values.cmd
                exec values.cmd, (error, stdout, stderr) ->
                    ws.send "#{stdout} #{stderr} #{error}"

# ---------------------------------------------------------------------
openBrowser = (url) ->
    switch process.platform
        when 'win32'
            exec "start #{url}"       # Windows
        when 'linux'
            exec "xdg-open '#{url}'"  # Linux and others
        when 'darwin'
            exec "open '#{url}'"      # macOS
        else
            console.error 'Unsupported operating system'
            process.exit 1

# ----------------------------
randomHex = ->
  Math.floor(Math.random() * 0xFFFFFFFF)  # random 32-bit integer
    .toString(16)                         # convert to hex
    .padStart(8, '0')                     # ensure 8 characters

# --------------------------------------
launchBrowser = (fragmentId) ->
    console.log 'Launching default browser at', webpage
    openBrowser webpage + fragmentId

# --------------------------------------
shutdown = ->
    if timeout
        console.log 'Client did not respond in time. Server closed.'
        process.exit 1
