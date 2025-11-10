
socket = socketClient()    # start communication with socket server

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
do ->
    # Check if new server version is available INSIDE window.serverCopy variable
    match = window.serverCopy.match /#\d+(\.\d+)?/
    if not match?
        return
        
    versionOnFile = match[0]

    if versionOnFile > socket.serversion()
        msg = 'The WebSocket server has an update available.<br><br>'
        msg += 'Do you want to update now?<br><br>'
        msg += '<i>The new version we will take effect on the next launch</i>'

        reply = await askConfirm('', 'warning', msg)

        if reply.isConfirmed
            socket.update(window.serverCopy)
            result = await socket.read()
            showAlert('Update status', '', result)

# --------------------------------------
getVideoFolder = ->
    switch socket.platform()
        when 'win32' then '%USERPROFILE%\\Videos'
        when 'linux' then '$HOME/Videos'
        when 'darwin' then '$HOME/Movies'

# --------------------------------------------------------------------
# 'Open video folder' button click
document.getElementById('openfolder').onclick = ->
    videoFolder = getVideoFolder()

    cmd = switch socket.platform()
        when 'win32'
            """explorer "#{videoFolder}" """
        when 'linux'
            """xdg-open "#{videoFolder}" """
        when 'darwin'
            """open "#{videoFolder}" """

    msg = 'If the video folder does not appear,<br>'
    msg += 'look behind the browser window or in the task bar.<br>'
    msg += '<br><i>click Ok to open the folder</i>'

    answer = await showAlert('Notice', '', msg)

    if answer.isConfirmed
        socket.exec(cmd)

# --------------------------------------------------------------------
# 'About' button click
document.getElementById('about').onclick = ->
    msg = '''
        A web interface for <i>yt-dlp</i> video download utility
        <br><br>
        \u00A9 2025 - RonLinu
        '''
    showAlert('YDownloader 1.0', '', msg)

# --------------------------------------------------------------------
# 'Check dependencies' button click
document.getElementById('dependencies').onclick = ->
    results = ''
    failCross = '&#x2718;'
    goodCheck = '&#x2714;'

    gather_results = (name, result) ->
        results += "<b>#{name}&nbsp;</b><span style='color: "
        if /is not|not found|#TIMEOUT/i.test result
            results += "red;'>#{failCross}</span><br>"
        else
            results += "green;'>#{goodCheck}</span><br>"

    # Show a wait dialog with a progress animation
    Swal.fire
      title: 'Please wait'
      text: 'Checking is in progress...'
      showConfirmButton: false
      allowOutsideClick: false
      didOpen: () ->
        Swal.showLoading()

    # Start sequence of tests, one dependency at a time
    socket.exec('yt-dlp --version')
    result = await socket.read()
    gather_results 'yt-dlp', result

    socket.exec('ffmpeg -version')
    result = await socket.read()
    gather_results 'ffmpeg', result

    if socket.platform() is 'linux'
        socket.exec('xterm -version')
        result = await socket.read()
        gather_results 'xterm ', result

    if results.indexOf(failCross) == -1
        results += '\nAll good!'
    else
        howmany = results.split(failCross).length - 1
        plural  = if howmany > 1 then 'dependencies are' else 'dependency is'
        results += "\n #{howmany} #{plural} missing!"

    Swal.close()
    showAlert 'Status of dependencies', '', "<pre>#{results}</pre>"

# --------------------------------------------------------------------
# 'Help' button click
document.getElementById('help').onclick = ->
    msg = window.HELP
    if socket.platform() is 'linux'
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

    ytdlp_cmd = 'yt-dlp ' +
         '--concurrent-fragments 2 ' +
         '--no-warnings ' +
         '-P "' + getVideoFolder() + '" ' +
         option_resolution +
         option_subtitles +
         option_merging +
         '--embed-metadata ' +
         '--buffer-size 16M ' +
         '"' + url + '"'

    final_cmd = switch socket.platform()
        when 'win32'
            """cmd /c start "" cmd /k #{ytdlp_cmd} """
        when 'linux'
            """xterm -geometry 150x24 -e sh -c '#{ytdlp_cmd}; echo; bash' """
        when 'darwin'
            """osascript -e 'tell application "Terminal" to do script "#{ytdlp_cmd}; do shell'" """

    socket.exec(final_cmd, 0)    # 0 = no timeout to download videos

