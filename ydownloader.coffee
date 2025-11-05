
# ********************** WEBSOCKET HANDLER ****************************
serverHandler = ->
    switch location.hash
        when '#BUSY'
            document.body.innerHTML = 'WebSocket already in use'
            throw new Error document.body.innerHTML
        when '#ERROR'
            document.body.innerHTML = 'WebSocket connection error'
            throw new Error document.body.innerHTML

    serverReply = ''
    os   = location.hash.split(',')[1]
    port = location.hash.split(',')[2]

    if parseInt('0' + port) not in [1024..49151] or os not in ['win32','linux','darwin']
        document.body.innerHTML = 'This web application must be started by the WebSocket server.'
        console.log os, port
        throw new Error document.body.innerHTML

    socket = new WebSocket "ws://localhost:#{port}/ws"

    socket.onopen = (event) ->
        console.log 'WebSocket connection established'

    socket.onclose = (event) ->
        console.log 'WebSocket connection closed'
        document.body.innerHTML = 'WebsScoket connection closed'

    socket.onmessage = (event) ->
        serverReply = event.data.trim()

    # ----------------------------------
    exec = ( command, timeout=5000 ) ->
        serverReply = ''
        cmd = JSON.stringify
            action: 'exec'
            cmd: command
            timeout: timeout
        socket.send cmd

    js = ( command, timeout=5000 ) ->
        serverReply = ''
        cmd = JSON.stringify
            action: 'js'
            cmd: command
            timeout: timeout
        socket.send cmd

    coffee = ( func, timeout=5000 ) ->
        todo  = func.toString()
        # Remove function header and last closing brace
        arr = todo.split('\n').slice(1,-1)

        # Remove last 'return'
        [..., last] = arr
        newLast = last.replace('return', '')
        arr[arr.length - 1] = newLast        
        command = arr.join('\n')
        js( command,timeout )
    
    message  = -> serverReply

    platform = -> os
    
    { exec, js, coffee, message, platform }

# Start socket handler as a closure
server = serverHandler()

# ******************* END OF WEBSOCKET HANDLER ************************

window.onload = ->
    # Focus on video URL field when page is loaded
    document.getElementById('videoUrl').focus()

# --------------------------------------
languages =
    'Afrikaans'   : 'af'
    'Amharic'     : 'am'
    'Arabic'      : 'ar'
    'Basque'      : 'eu'
    'Bengali'     : 'bn'
    'Bulgarian'   : 'bg'
    'Catalan'     : 'ca'
    'Chinese'     : 'zh'
    'Croatian'    : 'hr'
    'Czech'       : 'cs'
    'Danish'      : 'da'
    'Dutch'       : 'nl'
    'English'     : 'en'
    'Esperanto'   : 'eo'
    'Estonian'    : 'et'
    'Filipino'    : 'fil'
    'Finnish'     : 'fi'
    'French'      : 'fr'
    'Galician'    : 'gl'
    'German'      : 'de'
    'Greek'       : 'el'
    'Hebrew'      : 'he'
    'Hindi'       : 'hi'
    'Hungarian'   : 'hu'
    'Icelandic'   : 'is'
    'Indonesian'  : 'id'
    'Irish'       : 'ga'
    'Italian'     : 'it'
    'Japanese'    : 'ja'
    'Korean'      : 'ko'
    'Latvian'     : 'lv'
    'Lithuanian'  : 'lt'
    'Malay'       : 'ms'
    'Norwegian'   : 'no'
    'Romanian'    : 'ro'
    'Russian'     : 'ru'
    'Serbian'     : 'sr'
    'Slovak'      : 'sk'
    'Slovenian'   : 'sl'
    'Spanish'     : 'es'
    'Swahili'     : 'sw'
    'Swedish'     : 'sv'
    'Tamil'       : 'ta'
    'Telugu'      : 'te'
    'Thai'        : 'th'
    'Turkish'     : 'tr'
    'Ukrainian'   : 'uk'
    'Vietnamese'  : 'vi'
    'Welsh'       : 'cy'
    'Xhosa'       : 'xh'
    'Zulu'        : 'zu'

resolutions = [
    '360p (LD)', '480p (SD)', '720p (HD)', '1080p (full HD)',
    '1440p (2K)', '2160p (4K)', 'No cap', 'Audio only'
]

# *********************************************************************

do ->
    # Create checkbox panel with all supported languages
    container = document.querySelector('.checkbox-grid')

    for language of languages
        # Create a label element
        label = document.createElement('label')

        # Create the checkbox input element
        checkbox = document.createElement('input')
        checkbox.type = 'checkbox'
        checkbox.name = 'language'
        checkbox.value = language

        if language in ['English'] then checkbox.checked = true

        # Append the checkbox into the label
        label.appendChild(checkbox)

        # Add the label text node (for example "English")
        label.appendChild(document.createTextNode(language))

        # Append the label to the container
        container.appendChild(label)

# --------------------------------------
do ->
    # Create radio button panel with all supported video resolutions
    for resolution, index in resolutions
        # Select the fieldset container where radio buttons are grouped
        container = document.querySelector('.radio-section')

        # Create a radio button
        radio = document.createElement('input')
        radio.type  = 'radio'
        radio.id    = index         # unique id
        radio.name  = 'resolutions' # group name
        radio.value = resolution

        if resolution is '720p (HD)' then radio.checked = true

        # Create label element for the radio button
        label = document.createElement('label')
        label.setAttribute('for', resolution)
        label.textContent = resolution

        # Append radio button and label to the container
        container.appendChild(radio)
        container.appendChild(label)

        # Add line break for layout
        brTag = document.createElement('br')
        container.appendChild(brTag)

# --------------------------------------
showAlert = (title, icon, msg, textalign='center') ->
    Swal.fire
        title: title
        html: "<div style='text-align: #{textalign}; font-size: 16px;'>#{msg}</div>"
        icon: icon
        confirmButtonText: 'OK'
        allowOutsideClick: false

# --------------------------------------
askConfirm = (title, icon, msg, textalign='center') ->
    Swal.fire
        title: title
        html: "<div style='text-align: #{textalign}; font-size: 16px;'>#{msg}</div>"
        icon: icon
        showCancelButton: true
        confirmButtonText: 'Yes'
        cancelButtonText: 'No'
        focusCancel: true
        allowOutsideClick: false

# --------------------------------------
getVideoFolder = ->
    switch server.platform()
        when 'win32' then '%USERPROFILE%\\Videos'
        when 'linux' then '$HOME/Videos'
        when 'darwin' then '$HOME/Movies'

# --------------------------------------------------------------------
# 'Open video folder' button click
document.getElementById('openfolder').onclick = ->
    videoFolder = getVideoFolder()

    cmd = switch server.platform()
        when 'win32'
            """explorer "#{videoFolder}" """
        when 'linux'
            """xdg-open "#{videoFolder}" """
        when 'darwin'
            """open "#{videoFolder}" """

    msg = 'If you don’t see the video folder showing up,<br>'
    msg += 'look behind the browser window or in the task bar.<br>'
    msg += '<br><i>click Ok to open the folder</i>'

    answer = await showAlert('Notice', '', msg)
    if answer.isConfirmed
        server.exec(cmd)

# --------------------------------------------------------------------
# 'About' button click
document.getElementById('about').onclick = ->
    msg = '''
        YDownloader 0.9<br><br>
        Using CoffeeScript 2.7<br><br>
        \u00A9 2025 - RonLinu
        '''
    showAlert('', '', msg)
    
    #~ todo = ->
        #~ 'This is a test<br>' + 
        #~ 'to execute CoffeeScript code directly on the server<br>' +
        #~ 'and using the capability of Node.js'
                
    #~ readit = ->
        #~ if not server.message()
            #~ setTimeout readit, 250
            #~ return
        #~ showAlert('', '', server.message())
  
    #~ server.coffee(todo)
    #~ setTimeout readit, 250
    
# --------------------------------------------------------------------
# 'Check dependencies' button click
document.getElementById('dependencies').onclick = ->
    results = ''

    gather_results = (name, result) ->
        results += "<b>#{name}&nbsp;</b><span style='color: "
        if /is not|not found|#TIMEOUT/i.test result
            results += "red;'>&#x2718;</span><br>"
        else
            results += "green;'>&#x2714;</span><br>"

    check_ytdlp = ->
        if not server.message()
            setTimeout check_ytdlp, 250
            return
            
        gather_results 'yt-dlp', server.message()
        server.exec('ffmpeg -version')
        setTimeout check_ffmpeg, 250

    check_ffmpeg = ->
        if not server.message()
            setTimeout check_ffmpeg, 250
            return
        gather_results 'ffmpeg', server.message()
        server.exec('xterm -version')
        setTimeout check_xterm, 250

    check_xterm = ->
        if server.platform() is 'linux'
            if not server.message()
                setTimeout check_xterm, 250
                return
            gather_results 'xterm ', server.message()

        Swal.close()
        showAlert 'Status of dependencies', '', "<pre>#{results}</pre>"

    # Show a wait dialog
    Swal.fire
      title: 'Please wait'
      text: 'Checking is in progress...'
      showConfirmButton: false
      allowOutsideClick: false
      didOpen: () ->
        Swal.showLoading()

    # Start the sequence of tests, one dependency at a time
    server.exec('yt-dlp --version')
    setTimeout check_ytdlp, 250

# --------------------------------------------------------------------
# 'Help' button click
document.getElementById('help').onclick = ->
    msg = window.HELP
    if server.platform() is 'linux'
        # Add Linux 'xterm' to the list of dependencies
        msg = msg.replace('</pre>', '- <b>xterm</b>  terminal utility</pre>')

    showAlert('Help', '', msg, 'left')

# --------------------------------------
# 'Download' button click
document.getElementById('download').onclick = ->

    # Local function to check URL validity
    isValidUrl = (url) ->
        try
            urlObj = new URL(url)
            urlObj.protocol is 'http:' or urlObj.protocol is 'https:'
        catch
            false
    # ------------------------------------

    url = document.getElementById('videoUrl').value.trim()

    if not url
        showAlert('', 'error', 'The Video URL field is empty.')
        return
    else if not isValidUrl(url)
        showAlert('', 'error', 'The Video URL is not valid.')
        return

    # Remove any playlist, just download the main video
    index = url.indexOf("?list")
    if index != -1 then url = url.slice(0, index)

    option_resolution = ''
    option_subtitles  = ''
    option_merging    = ''

    selectedResolution = document.querySelector('input[name="resolutions"]:checked').value

    if selectedResolution is 'No cap'
        option_resolution = '-f best '
    else if selectedResolution is 'Audio only'
        option_resolution = '-x --audio-format mp3 '
    else
        # Extract resolution number
        resolution = parseInt(selectedResolution)
        option_resolution = '-f "bv[height<=' + resolution + ']+ba/b[height<=' + resolution + ']" '


    if selectedResolution isnt 'Audio only'
        option_merging = '--merge-output-format mkv --remux-video mkv '

        # Extract abbreviations of selected subtitle languages into an array
        checkedLanguages = document.querySelectorAll('input[name="language"]:checked')
        abbreviations = []
        abbreviations.push(languages[checked.value]) for checked in checkedLanguages

        if abbreviations.length
            subtitles = abbreviations.join(",")
            option_subtitles = '--write-sub --ignore-errors --write-auto-subs --sub-langs ' + subtitles + ' --embed-subs '

    videoFolder = getVideoFolder()

    ytdlp_cmd = 'yt-dlp ' +
         '--concurrent-fragments 2 ' +
         '--no-warnings ' +
         '-P "' + videoFolder + '" ' +
         option_resolution +
         option_subtitles +
         option_merging +
         '--embed-metadata ' +
         '--buffer-size 16M ' +
         '"' + url + '"'

    final_cmd = switch server.platform()
        when 'win32'
            """cmd /c start "" cmd /k #{ytdlp_cmd} """
        when 'linux'
            """xterm -geometry 150x24 -e sh -c '#{ytdlp_cmd}; echo; bash' """
        when 'darwin'
            """osascript -e 'tell application "Terminal" to do script "#{ytdlp_cmd}; do shell'" """

    server.exec(final_cmd, 0)    # 0=no timeout to download videos
