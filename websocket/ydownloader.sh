cd "$(dirname "$0")"

npx kill-port 8080

node websocket.js file:///home/ronald/Documents/CoffeeScript/ydownloader/index.html 8080

#~ node websocket.js https://ronlinu.github.io/ydownloader 8080
