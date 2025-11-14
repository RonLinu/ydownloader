
server = serverHandler()    # start socket communication with server

window.onload = ->
    # Focus on video URL field when page is loaded
    document.getElementById('videoUrl').focus()

resolutions = [
    '360p (LD)', '480p (SD)', '720p (HD)', '1080p (full HD)',
    '1440p (2K)', '2160p (4K)', '4320p (8K)', 'No cap'
]

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

# *********************************************************************

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
    # Check if new server version is available in 'latestServerCode' variable
    match = window.latestServerCode.match(/#\d+(\.\d+)?/)
    if not match? then return
    
    if match[0] > server.version()
        msg = '''The WebSocket server has an update available.<br>
                <br>
                Do you want to update now?<br><br>'''

        reply = await askConfirm('', 'warning', msg)

        if reply.isConfirmed
            server.update(window.latestServerCode)
            update = await server.read()
            if update is 'Success'
                msg = '''The update was successfull!<br>
                        <br>
                        The application must be restarted for the update to take effect.'''
            else
                msg = '''The update has failed.<br>
                        <br>
                        This is problably due to unexpected file/folder permissions.'''
            showAlert('Update status', '', msg)

# --------------------------------------
# 'Help' button
document.getElementById('help').onclick = ->
    msg = window.help
    if server.platform() is 'linux'
        # Add Linux 'xterm' to the list of dependencies
        msg = msg.replace('</pre>', '- <b>xterm</b>  terminal utility</pre>')

    showAlert('Help', '', msg, 'left')

# --------------------------------------
# 'About' button
document.getElementById('about').onclick = ->
    msg = '''
        A web interface for <i>yt-dlp</i> video download utility<br>
        <br>
        \u00A9 2025 - RonLinu
        '''
    showAlert('YDownloader 1.1a', '', msg)

# --------------------------------------
# 'Check dependencies' button
document.getElementById('dependencies').onclick = ->
    results = ''
    missingCount = 0

    failCross = '&#x2718;'
    goodCheck = '&#x2714;'

    gatherResults = (name, result) ->
        results += "<b>#{name}&nbsp;</b><span style='color: "
        regex = /is not|not found|#TIMEOUT/i
        if regex.test(result)
            results += "red;'>#{failCross}</span><br>"
            missingCount++
        else
            results += "green;'>#{goodCheck}</span><br>"

    # Show a wait dialog with a progress animation
    Swal.fire
      title: 'Please wait'
      text: 'Checking is in progress...'
      showConfirmButton: false
      allowOutsideClick: false
      didOpen: () -> Swal.showLoading()

    # Start sequence of tests, one dependency at a time
    server.exec('yt-dlp --version')
    result = await server.read()
    gatherResults 'yt-dlp', result

    server.exec('ffmpeg -version')
    result = await server.read()
    gatherResults 'ffmpeg', result

    if server.platform() is 'linux'
        server.exec('xterm -version')
        result = await server.read()
        gatherResults 'xterm ', result

    if missingCount
        plural  = if missingCount > 1 then 'cies are' else 'cy is'
        results += "\n #{missingCount} dependen#{plural} missing!"
    else
        results += '\nAll good!'

    Swal.close()
    showAlert 'Status of dependencies', '', "<pre>#{results}</pre>"

# --------------------------------------
getVideoFolder = ->
    switch server.platform()
        when 'win32'  then '%USERPROFILE%\\Videos'
        when 'linux'  then '$HOME/Videos'
        when 'darwin' then '$HOME/Movies'

# --------------------------------------
# 'Open video folder' button
document.getElementById('openfolder').onclick = ->
    videoFolder = getVideoFolder()

    cmd = switch server.platform()
        when 'win32'
            """explorer "#{videoFolder}" """
        when 'linux'
            """xdg-open "#{videoFolder}" """
        when 'darwin'
            """open "#{videoFolder}" """

    msg = '''If the video folder does not appear,<br>
            look behind the browser window or in the task bar.<br>
            <br>
            <i>click Ok to open the folder</i>'''

    answer = await showAlert('Notice', '', msg)

    if answer.isConfirmed
        server.exec(cmd)

# --------------------------------------------------------------------
# 'Download' button click
document.getElementById('download').onclick = ->

    # Local function to check URL validity
    isValidUrl = (url) ->
        try
            urlObj = new URL(url)
            urlObj.protocol is 'http:' or urlObj.protocol is 'https:'
        catch
            false

    url = document.getElementById('videoUrl').value.trim()

    if not url
        showAlert('', 'error', 'The URL field is empty.')
        return
    else if not isValidUrl(url)
        showAlert('', 'error', 'The URL is not valid.')
        return

    option_resolution = ''
    option_subtitles  = ''
    option_merging    = '--merge-output-format mkv --remux-video mkv '
    option_playlist   = ''
    
    # Ignore playlist, just download the main video (not reliable)
    index = url.indexOf("&list")
    if index != -1 then option_playlist = '--no-playlist '

    selectedResolution = document.querySelector('input[name="resolutions"]:checked').value

    option_resolution = switch selectedResolution 
        when 'No cap'
            '-f bestvideo+bestaudio/best ' # '-f best '
        else
            resolution = parseInt(selectedResolution)
            '-f "bv[height<=' + resolution + ']+ba/b[height<=' + resolution + ']" '

    # Extract abbreviations of selected subtitle languages into an array
    checkedLanguages = document.querySelectorAll('input[name="language"]:checked')
    abbreviations = []
    abbreviations.push(languages[checked.value]) for checked in checkedLanguages

    if abbreviations.length
        subtitles = abbreviations.join(",")
        option_subtitles = '--write-sub --ignore-errors --write-auto-subs --sub-langs ' + subtitles + ' --embed-subs '

    ytdlp_cmd = 'yt-dlp ' +
         '--concurrent-fragments 2 ' +
         '--no-warnings ' +
         '-P "' + getVideoFolder() + '" ' +
         option_resolution +
         option_playlist +
         option_subtitles +
         option_merging +
         '--embed-metadata ' +
         '--buffer-size 16M ' +
         '"' + url + '"'

    console.log ytdlp_cmd
    
    final_cmd = switch server.platform()
        when 'win32'
            """cmd /c start "" cmd /k #{ytdlp_cmd} """
        when 'linux'
            """xterm -geometry 150x24 -e sh -c '#{ytdlp_cmd}; echo; bash' """
        when 'darwin'
            """osascript -e 'tell application "Terminal" to do script "#{ytdlp_cmd}; do shell'" """

    server.exec(final_cmd, 0)    # 0 = no timeout to download videos

