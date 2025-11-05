
webpage    = process.argv[2]
socketport = process.argv[3]

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
    fragment = '#,' + process.platform + ',' + socketport
    launchBrowser( webpage, fragment )

# --------------------------------------
wss.on 'error', (err) ->
    if err.code is 'EADDRINUSE'
        console.error 'Port', socketport, 'is already in use'
        launchBrowser(webpage, '#BUSY')
    else
        firstline = err.message.split('\n')[0]
        console.error 'WebSocket server error:', firstline
        launchBrowser(webpage, '#ERROR')

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
        console.log 'Client disconnected'
        process.exit 0

   # When server receives a command from client
    ws.on 'message', (message) ->
        command = JSON.parse(message)

        console.log 'Server received:', command.cmd
        switch command.action
            when 'exec'
                exec command.cmd,  { timeout: command.timeout }, (error, stdout, stderr) ->
                    timeoutFlag = ''
                    if error and error.killed then timeoutFlag = '#TIMEOUT'
                    ws.send "#{stdout} ~~~ #{stderr} ~~~ #{error} ~~~ #{timeoutFlag}"
            when 'js'
                console.log command.cmd
                try
                    result = eval command.cmd
                catch
                    result = '#ERROR: JavaScript evaluation failed'
                ws.send result
                            
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

# --------------------------------------
launchBrowser = (webpage, fragment) ->
    console.log 'Launching default browser at', webpage
    openBrowser webpage + fragment

# --------------------------------------
shutdown = ->
    if timeout
        console.log 'Client did not respond in time. Server closed.'
        process.exit 1
