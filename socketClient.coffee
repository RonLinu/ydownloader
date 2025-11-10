###
 This single function is executed on a browser client to handles the socket
 communication with a socket server running on Node.js.

 Its main purpose is to execute system commands and scripts with system
 level access using Node.js.

 There are few sub-functions provided to:
 - send a system command to be executed at server side
 - send a script code to be executed at server side
 - assign data to a server variable to be used by the script code (if needed)
 - read the return data of a system command or a script code execution
 - return the platform detected at server side, immune to browser spoofing
 - return the server version
 - update "live" the server script
###

window.socketClient = ->
    fragment = location.hash.split(',')
    
    switch
        when fragment[0] is '#BUSY'
            document.body.innerHTML = 'The application is already in use in another tab or browser'
            throw new Error 'WebScoket already in use'
        when fragment[0] is '#ERROR'
            document.body.innerHTML = 'WebSocket connection error'
            throw new Error 'WebSocket connection error'

    serverVersion  = fragment[0]
    serverPlatform = fragment[1]
    socketPort     = fragment[2]

    serverReply = ''

    if parseInt('0' + socketPort) not in [1024..49151] or serverPlatform not in ['win32','linux','darwin']
        document.body.innerHTML = 'The application MUST be started by the WebSocket server.'
        console.log "Incorrect parameters", serverPlatform, socketPort
        throw new Error document.body.innerHTML

    socket = new WebSocket "ws://localhost:#{socketPort}/ws"

    socket.onopen = (event) ->
        console.log 'WebSocket connection established'

    socket.onclose = (event) ->
        console.log 'WebSocket connection closed'
        document.body.innerHTML = 'WebsScoket connection closed'

    # ----------------------------------
    
    # Return the operating system name detected at the server side
    serversion = -> serverVersion
    
    platform = -> serverPlatform

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

    # Update "live" the WebSocket server script (experimental)
    update = (data) ->
        cmd = JSON.stringify
            action: 'update'
            cmd: data
        socket.send cmd

    # Wait for server to finish execution of a system command or script
    # and return any result
    read = (timeout=5000) ->
      new Promise (resolve) ->
        socket.onmessage = (event) ->
            resolve event.data.trim()

        # Timeout in milliseconds
        setTimeout ->
            resolve '#TIMEOUT'
        , timeout

    { serversion, platform, update, exec, script, send, read }
