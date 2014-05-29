$ = require("../vendor/jquery/jquery")
previewTemplate = require("../html/popover.jade")
_ = require("../vendor/underscore/underscore")
Q = require("../../node_modules/q")

require "../css/content.css"

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

        $popup.find('.kitt-link-preview-title').text title or ""
        $popup.find('.kitt-link-preview-description').text desc or ""
        $popup.find('.kitt-link-preview-image').attr("src", img) or ""

        $popup.find('.kitt-link-preview-spinner').hide()
        $popup.find('.kitt-link-preview-content').show()

      $("body").scalebreaker('refresh')
    , 200


  onPreview = (url) ->
    $('body').scalebreaker {
      dialogContent: $(previewTemplate())
      dialogPosition: 'bottom'
    }
    $('body').scalebreaker('show')

    $('body').on 'dialogHidden.jq-scalebreaker', ->
      # Give it time to finish the anmimation.
      _.delay ->
        $('body').scalebreaker('destroy')
      , 200

    $popup = $('#salsita-bf7gv34dbf29r3gr-modal-content')
    $popup.find('.kitt-link-preview-spinner').show()
    $popup.find('.kitt-link-preview-content').hide()

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
    chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
      console.log "message received:", request.event
      switch request.event
        when "preview"
          console.log "processing preview", request
          onPreview request.url

          
)(_jQuery)
