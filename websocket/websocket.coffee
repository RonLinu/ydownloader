
webpage    = process.argv[2]
socketport = process.argv[3]

if webpage is '' or socketport is ''
    console.log 'Syntax: node websocket.js <application_url> <socket_port>'
    process.exit 0

WebSocket = require('ws')       # installed with: npm install ws
{exec} = require('child_process')

wss = new WebSocket.Server { port: socketport }

# --------------------------------------
wss.on 'error', (err) ->
    if err.code is 'EADDRINUSE'
        console.error "Port #{socketport} is already in use."
    else
        firstline = err.message.split('\n')[0]
        console.error 'WebSocket server error:', firstline
    process.exit 1  

# --------------------------------------
# When a client connects
wss.on 'connection', (ws) ->
    console.log 'Client connected'

    # When the client disconnects
    ws.on 'close', () ->
        console.log 'Client disconnected'

   # When server receives a command from client
    ws.on 'message', (message) ->
        values = JSON.parse(message)

        # Reject any command without the correct fragment identifier
        if values.id isnt identifier
            console.error "Incorrect identifier received"
            return

        switch values.action
            when "exit"
                console.log 'Client disconnected'
                ws.close()
                process.exit 0
            when "run"
                exec values.cmd, (error, stdout, stderr) ->
                  if error
                    console.error "Error: #{error}"
                    console.error "stderr: #{stderr}"
                  else
                    ws.send "stdout: #{stdout}"

# ---------------------------------------------------------------------
console.log "WebSocket server running on port: #{socketport}"
  
# ----------------------------
randomHex = ->
  Math.floor(Math.random() * 0xFFFFFFFF)  # random 32-bit integer
    .toString(16)                         # convert to hex
    .padStart(8, '0')                     # ensure 8 characters
    
# ----------------------------
openUrl = (url) ->
    switch process.platform
        when 'darwin'
            exec "open '#{url}'"      # macOS
        when 'win32'
            exec "start #{url}"       # Windows
        else
            exec "xdg-open '#{url}'"  # Linux and others

# --------------------------------------

identifier = "##{randomHex()},#{socketport}"

console.log "Opening webpage with default browser: #{webpage}"
openUrl webpage + identifier
