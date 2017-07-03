const playerContainer = document.getElementById('player-container')

if (playerContainer !== null) {

  let tag = document.createElement('script')
  tag.src = 'http://www.youtube.com/iframe_api'

  console.log("Setting up youtube player")

  const firstScriptTag = document.getElementsByTagName('script')[0]
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

  let player

  window.onYouTubeIframeAPIReady = function() {
    const videoId = getVideoId()
    player = makePlayer(videoId)
  }

  function getVideoId() {
    return playerContainer.getAttribute('data-video-id')
  }

  function makePlayer(videoId) {
    new YT.Player('player', {
      height: 380,
      width: 640,
      videoId: videoId,
      events: {
        onReady: onPlayerReady,
        onStateChange: onPlayerStateChange
      }
    })
  }

  function onPlayerReady(event) {
    showControls()
    if (checkAutoPlay()) {
      event.target.playVideo();
    }
  }

  function onPlayerStateChange(event) {
    console.log("youtube player state changed", event)
    if (event.data == YT.PlayerState.ENDED) {
      goToNextVideo()
    }
    else if (event.data == YT.PlayerState.UNSTARTED) {
      // error playing video
      // TODO: maybe log this somehow so it can be marked and removed eventually?
      console.log("Could not play video, skipping to next")
      goToNextVideo()
    }
  }

  function showControls() {
    var ctrlPanel = document.getElementsByClassName('player-controls')[0]
    ctrlPanel.removeAttribute('hidden')
  }

  function goToNextVideo() {
    document.getElementById('next-video').submit()
  }

  function checkAutoPlay() {
    return playerContainer.getAttribute('data-autoplay') == 'yes'
  }
}

export default {}
