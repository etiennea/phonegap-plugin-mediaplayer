
> An audio player where you can queue remote urls, to create a music player app

## Killer features

- Supports playlists
- Support lockscreen info
- Triggers an event when play has stopped

## Installation

This requires phonegap 5.0+ ( current stable v1.0.0 )

```
phonegap plugin add phonegap-plugin-mediaplayer
```

## Supported Platforms

- iOS

## Quick Example

```javascript

MediaPlayer.play();

MediaPlayer.pause();

MediaPlayer.playURL(urlString, songTitle, albumTitle, artistName, imgUrl);

MediaPlayer.queueUrl('http://myserver/assets/mp3-1.mp3');

MediaPlayer.next();

```

## Future updates

- Support next prev pause buttons on lockscreen
- Support flac