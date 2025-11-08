
# This single function handles the socket communication between this 
# client (browser) and the socket server. 

# Few subfunctions let the client:
# - send a system command to be executed at server side
# - send a script code to be executed at server side
# - assign data to a server variable to be used by the script code (if needed)
# - read the return data of a system command or a script code execution
# - return the platform detected at server side, more reliable than client side

window.socketClient = ->
    switch location.hash
        when '#BUSY'
            document.body.innerHTML = 'The application is already in use'
            throw new Error 'WebScoket already in use'
        when '#ERROR'
            document.body.innerHTML = 'WebSocket connection error'
            throw new Error 'WebSocket connection error'

    serverReply = ''
    os   = location.hash.split(',')[1]
    port = location.hash.split(',')[2]

    if parseInt('0' + port) not in [1024..49151] or os not in ['win32','linux','darwin']
        document.body.innerHTML = 'This application must be started by the WebSocket server.'
        console.log "Incorrect parameters", os, port
        throw new Error document.body.innerHTML

    socket = new WebSocket "ws://localhost:#{port}/ws"

    socket.onopen = (event) ->
        console.log 'WebSocket connection established'

    socket.onclose = (event) ->
        console.log 'WebSocket connection closed'
        document.body.innerHTML = 'WebsScoket connection closed'

    # ----------------------------------
    
    # Return the operating system detected at the server side
    platform = -> os

    # Send a system command to be executed at server side
    exec = (command, timeout=5000) ->
        serverReply = ''
        cmd = JSON.stringify
            action: 'exec'
            cmd: command
            timeout: timeout
        socket.send cmd

    # Send a CoffeeScript code (translated to JavaScript) to be executed
    # at server side with access to Node.js capabilities
    script = (func, timeout=5000) ->
        code  = func.toString()
        serverReply = ''
        cmd = JSON.stringify
            action: 'script'
            cmd: "(#{code})();"
            timeout: timeout
        socket.send cmd

    # Send data (primitive or object) to server to be saved in the
    # 'data' server variable, usefull before calling script command
    send = (data) ->
        cmd = JSON.stringify
            action: 'send'
            cmd: data
        socket.send cmd

    # Wait for server to finish with a system command or script execution
    # and return any result
    read = (timeout=5000) ->
      new Promise (resolve) ->
        socket.onmessage = (event) ->
            resolve event.data.trim()

        # Timeout in milliseconds
        setTimeout ->
            resolve '#TIMEOUT'
        , timeout

    { platform, exec, script, send, read }
