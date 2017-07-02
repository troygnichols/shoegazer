let tag = document.createElement('script')
tag.src = 'http://www.youtube.com/iframe_api'

console.log("Setting up youtube player")

const firstScriptTag = document.getElementsByTagName('script')[0]
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

let player

window.onYouTubeIframeAPIReady = function() {
  console.log('onYouTubeIframeAPIReady')

  // const videoId = getVideoId()
  const videoId = 'fllbdNMwAvY'
  console.log('videoId', videoId)
  player = makePlayer(videoId)
}

function getVideoId() {
  const url = document.getElementById('player-container')
    .getAttribute('data-url')
  const parts = url.split("/")
  return parts[parts.length - 1]
}

function makePlayer(videoId) {
  new YT.Player('player', {
    height: 390,
    width: 640,
    videoId: videoId,
    events: {
      onReady: onPlayerReady,
      onStateChange: onPlayerStateChange
    }
  })
}

function onPlayerReady(event) {
  console.log('onPlayerReady', event)
  // event.target.playVideo()
}

function onPlayerStateChange(event) {
  if (event.data == YT.PlayerState.ENDED) {
    console.log("video ended")
  }
}

export default {}
