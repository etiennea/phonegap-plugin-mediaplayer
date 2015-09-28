
> An audio player where you can queue remote urls, to create a music player app

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

MediaPlayer.queueUrl('http://myserver/assets/mp3-1.mp3');

MediaPlayer.clearQueue('http://myserver/assets/mp3-1.mp3');

MediaPlayer.next();

MediaPlayer.queueLength(function(l){});

```