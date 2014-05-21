$ = require("../vendor/jquery/jquery")
previewTemplate = require("../html/popover.jade")
_ = require("../vendor/underscore/underscore")
Q = require("../../node_modules/q")

require "../vendor/bootstrap/bootstrap"
require "../vendor/bootstrap/bootstrap.css"

require "../css/content.css"

require "../vendor/bootstrap-modal/bootstrap-modal-bs3patch.css"
require "../vendor/bootstrap-modal/bootstrap-modal.css"
require "../vendor/bootstrap-modal/bootstrap-modal"
require "../vendor/bootstrap-modal/bootstrap-modalmanager"

require('../vendor/jquery-ui-scalebreaker/jquery-ui-1.10.4.custom.min')
require('../vendor/jquery-ui-scalebreaker/jq-scalebreaker.css')
require('../vendor/jquery-ui-scalebreaker/jq-scalebreaker')

preview = require("./preview.coffee")


# Make sure we don't overwrite page's real $.
_jQuery = $.noConflict(true)


(($) ->

  # `bootstrap-modal` BS3 patch.
  $g_spinner = $("""
    <div class="loading-spinner" style="width: 200px; margin-left: -100px;">
      <div class="progress progress-striped active">
        <div class="progress-bar" style="width: 100%;"></div>
      </div>
    </div>
  """)
  

  showPreview = (title, desc, img) ->
    # Delay for a while to make sure popup is hidden.
    _.delay ->
      # Set the translated popup fields
      do ($popup = null) ->
        $popup = $('#salsita-bf7gv34dbf29r3gr-modal-content')

        $popup.find('.title').text title or ""
        $popup.find('.description').text desc or ""
        $popup.find('.preview-image').attr("src", img) or ""

        $popup.find('.spinner').hide()
        $popup.find('.content').show()
    , 200


  onPreview = (url) ->
    $('body').scalebreaker('show')

    $popup = $('#salsita-bf7gv34dbf29r3gr-modal-content')
    $popup.find('.spinner').show()
    $popup.find('.content').hide()

    preview.getData(url)
      .then (res) ->

        res = JSON.parse(res)
        image = res.images?[0].url
        showPreview res.title, res.description, image
      .fail (err) ->
        console.log "Error rendering preview!", err
        $("body").scalebreaker('hide')
        _.defer ->
          window.alert('Failed to load page preview')


  $ ->
    $('body').scalebreaker {
      dialogContent: $(previewTemplate())
      dialogPosition: 'bottom',
      debug: true
    }

    chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
      console.log "message received:", request.event
      switch request.event
        when "preview"
          console.log "processing preview", request
          onPreview request.url

          
)(_jQuery)
