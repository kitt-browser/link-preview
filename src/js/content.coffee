$ = require("../vendor/jquery/jquery")
template = require("../html/popover.jade")
_ = require("../vendor/underscore/underscore")
Q = require("../../node_modules/q")

require "../vendor/bootstrap/bootstrap"
require "../vendor/bootstrap/bootstrap.css"

require "../css/content.css"

require "../vendor/bootstrap-modal/bootstrap-modal-bs3patch.css"
require "../vendor/bootstrap-modal/bootstrap-modal.css"
require "../vendor/bootstrap-modal/bootstrap-modal"
require "../vendor/bootstrap-modal/bootstrap-modalmanager"

preview = require("./preview.coffee")


# Make sure we don't overwrite page's real $.
_jQuery = $.noConflict(true)


(($) ->

  $modal = null

  # `bootstrap-modal` BS3 patch.
  $.fn.modal.defaults.spinner = $.fn.modalmanager.defaults.spinner = """
    <div class="loading-spinner" style="width: 200px; margin-left: -100px;">
      <div class="progress progress-striped active">
        <div class="progress-bar" style="width: 100%;"></div>
      </div>
    </div>
  """
  

  showPreview = (title, desc, img) ->
    # Delay for a while to make sure popup is hidden.
    _.delay ->
      # Set the translated popup fields
      $modal.find(".modal-header .title").text title or ""
      $modal.find("#content .description").text desc or ""
      $modal.find("#content .preview-image").attr("src", img) or ""

      $modal.modal "show"
    , 200


  onPreview = (url) ->
    $("body").modalmanager "loading"

    console.log('getData')

    preview.getData(url)
      .then (res) ->
        res = JSON.parse(res)
        image = res.images?[0].url
        showPreview res.title, res.description, image
      .fail (err) ->
        console.log "Error rendering preview!", err
        $("body").modalmanager "removeLoading"
        _.defer ->
          window.alert('Failed to load page preview')


  $ ->
    $modal = $(template())
    $("body").append $modal
    $modal.modal {show: false}

    chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
      console.log "message received:", request.event
      switch request.event
        when "preview"
          console.log "processing preview", request
          onPreview request.url

          
)(_jQuery)
