// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"
let token = getMetaContentByName("channel_token");

let socket = new Socket("/socket", {params: {token: token}})

function getMetaContentByName(name,content){
  var content = (content==null)?'content':content;
  var meta = document.querySelector("meta[name='"+name+"']");
  if(meta !== null && meta !== undefined) {
    return meta.getAttribute(content);
  }
  return "";
}

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("organization:all", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
