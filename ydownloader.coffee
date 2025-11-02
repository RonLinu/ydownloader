
# ********************** WEBSOCKET HANDLING ***************************
socket = null
platform = location.hash.split(',')[1]

do ->
    switch location.hash
        when '#BUSY'
            document.body.innerHTML = 'WebSocket already in use'
            throw new Error "Stop execution: socket already in use"
        when '#ERROR'
            document.body.innerHTML = 'WebSocket connection error'
            throw new Error "Stop execution: socket connection error"

    port     = location.hash.split(',')[2]
    
    if parseInt('0' + port) not in [8080..8089]
        msg = 'This web application must be started by the WebSocket server.'
        document.body.innerHTML = msg
        throw new Error "Stop execution: trying to launch browser directly"

    socket = new WebSocket "ws://localhost:#{port}/ws"
    
    socket.onopen = (event) ->
        console.log 'WebSocket connection established'

    socket.onclose = (event) ->
        console.log 'WebSocket connection closed'
        document.body.innerHTML = 'Application closed.'
        #~ image_file = "resources/closed.png"
        #~ document.body.innerHTML = ""
        #~ document.body.style.display = 'flex'
        #~ document.body.style.justifyContent = 'center'
        #~ img = document.createElement 'img'
        #~ img.src = image_file
        #~ document.body.appendChild img

    socket.onmessage = (event) ->
        # Dispatcher for received messages (to be implemented if needed)
        console.log event.data

# --------------------------------------
socket_send = ( action, command, tag ) ->
    cmd = JSON.stringify
        id: location.hash
        action: action
        cmd: command
        tag: tag
    socket.send cmd

# ******************* END OF WEBSOCKET HANDLING ***********************

window.addEventListener 'beforeunload', (event) ->
    # Terminate the external socket server program
    socket_send( 'exit', '', 'EXIT' )

# --------------------------------------
window.onload = ->
    # Conveniently focus on video URL field
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

# --------------------------------------
askConfirm = (title, icon, msg) ->
    Swal.fire
        title: title
        html: msg
        icon: icon
        showCancelButton: true
        confirmButtonText: 'Yes'
        cancelButtonText: 'No'
        focusCancel: true

# --------------------------------------
getVideoFolder = ->
    switch platform
        when 'win32' then '%USERPROFILE%\\Videos'
        when 'linux' then '$HOME/Videos'
        when 'darwin' then '$HOME/Movies'

# --------------------------------------------------------------------
openVideoFolder = ->            # closure
  once = true
  ->
    videoFolder = getVideoFolder()

    cmd = switch platform
        when 'win32'
            """explorer "#{videoFolder}" """
        when 'linux'
            """xdg-open "#{videoFolder}" """
        when 'darwin'
            """open "#{videoFolder}" """

    if once
        once = false
        msg = 'If you don’t see the video folder showing up,<br>'
        msg += 'look in your task bar OR behind the browser window.<br>'
        msg += '<br><i>This note is shown only once per session</i>'
        await showAlert('Quick note', '', msg)

    socket_send( 'run', cmd, 'OPEN FOLDER')

# 'Open video folder' button click
document.getElementById('openfolder').onclick = openVideoFolder()

# --------------------------------------------------------------------
# 'About' button click
document.getElementById('about').onclick = ->
    msg = '''
        YDownloader 0.8<br><br>
        Using CoffeeScript 2.7<br><br>
        \u00A9 2025 - RonLinu
        '''

    showAlert('', '', msg)

# --------------------------------------------------------------------
# 'Help' button click
document.getElementById('help').onclick = ->
    showAlert('Help', '', window.HELP, 'left')

# --------------------------------------------------------------------
# 'Exit' button click
document.getElementById('exit').onclick = ->
    result = await askConfirm('', 'question',
        'This will terminate the application.<br><br>Are you sure?')

    if result.isConfirmed
        socket.close()

# --------------------------------------
# 'Generate yt-dlp command' button click
document.getElementById('download').onclick = ->

    # Local function to check URL validity
    isValidUrl = (string) ->
        try
            urlObj = new URL(string)
            urlObj.protocol is 'http:' or urlObj.protocol is 'https:'
        catch
            false
    # ------------------------------------

    url = document.getElementById('videoUrl').value.trim()

    if not url
        showAlert('', 'error', 'The Video URL field is empty.')
        return
    else if not isValidUrl(url)
        showAlert('', 'error', 'The Video URL is invalid.')
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

    final_cmd = switch platform
        when 'win32'
            """cmd /c start "" cmd /k #{ytdlp_cmd} """
        when 'linux'
            """xterm -geometry 150x24 -e sh -c '#{ytdlp_cmd}; echo; bash' """
        when 'darwin'
            """osascript -e 'tell application "Terminal" to do script "#{ytdlp_cmd}; do shell'" """

    socket_send( 'run', final_cmd, 'YT-DLP' )
