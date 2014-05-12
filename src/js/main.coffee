$ = require("../vendor/jquery/jquery")
_ = require("../vendor/underscore/underscore")

$.support.cors = true

sendMessage = (msg) ->
  chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
    console.log "sending message to", tabs[0], msg
    chrome.tabs.sendMessage tabs[0].id, msg, (response) ->
      console.log response


menu = chrome.contextMenus.create(
  id: "previewContextMenu"
  title: "preview"
  contexts: ["link"]
  enabled: true
)


chrome.contextMenus.onClicked.addListener (info) ->
  return unless info.menuItemId == menu
  sendMessage {event: "preview", url: info.linkUrl}


chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  switch request.command
    when "http"
      {url, type} = request
      console.log "received http command", url, type
      $.ajax {
        url: url
        type: type
        success: (data) ->
          console.log "success"
          sendResponse {err: null, data: data}
        error: (err) ->
          console.log "error", err
          sendResponse {err: err}
      }

      return true

