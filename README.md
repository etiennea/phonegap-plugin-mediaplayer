

<p align="right">
    <a href="https://github.com/katzer/phonegap-plugin-mediaplayer/tree/example">EXAMPLE :point_right:</a>
</p>

Cordova Audio Player Plug-in
==========================

[Cordova][cordova] plugin to stream remote audio data.

### Plugin's Purpose
This cordova plug-in provides the ability to queue remote urls and create playlists. To gauge a songs media penetration it's possible to track the amount of network calls from an apps instance.


## Overview
1. [Supported Platforms](#supported-platforms)
2. [Installation](#installation)
3. [ChangeLog](#changelog)
4. [Usage](#usage)


## Supported Platforms
- __iOS__ (_including iOS8_)


## Installation
The plugin can either be installed from git repository, from local file system through the [Command-line Interface][CLI].

### Local development environment
From master:
```bash
# ~~ from master branch ~~
cordova plugin add https://github.com/katzer/phonegap-plugin-mediaplayer.git
```
from a local folder:
```bash
# ~~ local folder ~~
cordova plugin add cordova-plugin-audioplayer --searchpath path
```

To remove the plug-in, run the following command:
```bash
cordova plugin rm cordova-plugin-audioplayer
```


## ChangeLog
#### Version 1.0.0dev (02.12.2016)
- queue Tracks
- start playing the queue
- pause/resume playing the queue
- clear the queue
- fade in/out
- register callbacks on playback events

#### Known issues


## Usage
The plugin creates the object `cordova.plugins.audioPlayer` with  the following methods:

1. [audioPlayer.play][play]
2. [audioPlayer.queue][queue]
3. [audioPlayer.pause][pause]
4. [audioPlayer.resume][resume]
5. [audioPlayer.stop][stop]
6. [audioPlayer.playNext][playNext]
7. [audioPlayer.setup][setup]
8. [audioPlayer.fadeInVolume][fadeInVolume]
9. [audioPlayer.fadeOutVolume][fadeOutVolume]
10. [audioPlayer.getCurrentTrack][getCurrentTrack]

### Plugin initialization
The plugin and its methods are not available before the *deviceready* event has been fired.

```javascript
document.addEventListener('deviceready', function () {
    // cordova.plugins.audioPlayer is now available
}, false);
```

### Play a song
Initialize a new queue, append a song object to it and start palying.

```javascript
var song = {
    id: '22',
    title: 'California Lullabye',
    album: 'The Beautiful Machine',
    artist: 'Josh Woodward',
    file: 'https://www.joshwoodward.com/mp3/JoshWoodward-TheBeautifulMachine-01-CaliforniaLullabye.mp3',
    cover: 'https://upload.wikimedia.org/wikipedia/en/5/54/Public_image_ltd_album_cover.jpg'
}

var callbackFunc = function() {
    console.log('Song started');
}

cordova.plugins.audioPlayer.play(song, callbackFunc);

```


### Queue a song
Append one ore more song objects to the existing queue (Initialize a new one if there is none).
It's possible to replace the existing playlist by setting the replace flag to true.
If play is set to true the playback is started on appending the track. 

```javascript
var song1 = {
    id: '22',
    title: 'California Lullabye',
    album: 'The Beautiful Machine',
    artist: 'Josh Woodward',
    file: 'https://www.joshwoodward.com/mp3/JoshWoodward-TheBeautifulMachine-01-CaliforniaLullabye.mp3',
    cover: 'https://upload.wikimedia.org/wikipedia/en/5/54/Public_image_ltd_album_cover.jpg'
}
var song2 = {
    id: '11',
    title: 'Let it in',
    album: 'Ashes',
    artist: 'Josh Woodward',
    file: 'https://www.joshwoodward.com/mp3/Ashes/JoshWoodward-Ashes-01-LetItIn.mp3',
    cover: 'https://upload.wikimedia.org/wikipedia/en/5/54/Public_image_ltd_album_cover.jpg'
}

var callbackFunc = function() {
    console.log('Song started');
}

var failureCallback = function(reason) {
    console.log('Error:' + reason);
}

var options = {
    replace: false, 
    play: false,
};

cordova.plugins.audioPlayer.queue([song1, song2], options, callbackFunc, failureCallback);

```

### Pause playback
Pause playback.
```javascript
var callback = function() {
    console.log('Song paused');
};
cordova.plugins.audioPlayer.pause(callback);
```

### Resume playback
Resume playback after pause.
```javascript
var callback = function() {
    console.log('Playback resumed');
};
cordova.plugins.audioPlayer.resume(callback);
```

### Stop playback and clear playlist
Stop playing and clears the actual queue.
```javascript
var callback = function() {
    console.log('Playback stopped');
};
cordova.plugins.audioPlayer.stop(callback);
```

### Skip a track
Got to the next track.
```javascript
var callback = function() {
    console.log('Skiped track');
};
cordova.plugins.audioPlayer.playNext(callback);
```

### Set a trackingUrl
Set a trackingUrl.

```javascript
var url = 'www.an-example-url.com/this/one/is/invalid';
var successCallback = function() {
    console.log('Url succesfully added');
};
var failureCallback = function() {
    console.log('Some error occured');
};
cordova.plugins.audioPlayer.setup(url, successCallback, failureCallback);
```

### Fade out volume
Fade the volume out.
```javascript
var callback = function() {
    console.log('muted');
};
cordova.plugins.audioPlayer.fadeOutVolume(callback);
```

### Fade in volume
Fade in the volume.
```javascript
var callback = function() {
    console.log('faded in volume');
};
cordova.plugins.audioPlayer.fadeInVolume(callback);
```

### Get currently played track
Get information about the currently played track.
```javascript
var callback = function(id) {
    console.log('Song ' + id + 'is played.');
};
cordova.plugins.audioPlayer.getCurrentTrack(callback);
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

This software is released under the [Apache 2.0 License][apache2_license].

© 2013-2016 appPlant GmbH, All rights reserved


[cordova]: https://cordova.apache.org
[CLI]: http://cordova.apache.org/docs/en/edge/guide_cli_index.md.html#The%20Command-line%20Interface

[play]: #play-a-song
[queue]: #queue-a-song
[pause]: #pause-playback
[resume]: #resume-playback
[stop]: #stop-playback-and-clear-playlist
[playNext]: #skip-a-track
[setup]: #set-a-trackingurl
[fadeInVolume]: #fade-out-volume
[fadeOutVolume]: #fade-in-volume
[getCurrentTrack]: #get-currently-played-track

[enable]: #prevent-the-app-from-going-to-sleep-in-background
[apache2_license]: http://opensource.org/licenses/Apache-2.0
