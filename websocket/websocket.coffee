
webpage    = process.argv[2]
socketport = process.argv[3]
timer = true

if socketport is '' or webpage is ''
    console.log 'Syntax: node websocket.js <web_app_url> <socket_port>'
    process.exit 0

WebSocket = require 'ws'            # to install: npm install ws
{exec} = require 'child_process'

wss = new WebSocket.Server { port: socketport }

wss._server.on 'listening', ->
    # code to execute when port is opened successfully
    console.log "WebSocket server is listening on port #{socketport}"
    setTimeout shutdown, 5000       # client must respond within 5 sec
    launchBrowser( getId() )

# --------------------------------------
wss.on 'error', (err) ->
    if err.code is 'EADDRINUSE'
        console.error "Port #{socketport} is already in use."
        launchBrowser('#BUSY')
    else
        firstline = err.message.split('\n')[0]
        console.error 'WebSocket server error:', firstline

# --------------------------------------
# When a client connects
wss.on 'connection', (ws) ->
    console.log 'Client connected'
    timer = false       # cancel automatic shutdown
    
    # When the client disconnects
    ws.on 'close', () ->
        console.log 'Client disconnected'
        ws.close()
        process.exit 0

   # When server receives a command from client
    ws.on 'message', (message) ->
        values = JSON.parse(message)

        # Reject any command without the correct fragment identifier
        #~ if values.id isnt identifier
            #~ console.error "Incorrect identifier received"
            #~ return

        switch values.action
            when 'run'
                ws.send "#{values.action},#{values.tag},start"
                console.log "Server received: #{values.cmd}"
                exec values.cmd, (error, stdout, stderr) ->
                    if error
                        console.log "#{error}\n #{stderr}"
                ws.send "#{values.action},#{values.tag},done"

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
getId = ->
    "##{socketport}"

# --------------------------------------
launchBrowser = (identifier) ->
    console.log "Launching default browser at: #{webpage}"
    openBrowser webpage + identifier

shutdown = ->
    if timer
        console.log "Client does not respond. Closing port #{socketport}."
        process.exit 1
