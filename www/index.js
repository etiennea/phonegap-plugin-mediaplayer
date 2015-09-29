/* global cordova:false */

/*!
 * Module dependencies.
 */

var exec = cordova.require('cordova/exec');

var MediaPlayer = {

    play: function(success, failure) {
        exec(success, failure, "MediaPlayer", "play", []);
    },

    pause: function(success, failure) {
        exec(success, failure, "MediaPlayer", "pause", []);
    },


    playURL: function(urlString, songTitle, albumTitle, artistName, imgUrl, success, failure) {
        exec(success, failure, "MediaPlayer", "playURL", [urlString, songTitle, albumTitle, artistName, imgUrl]);
    },
    addNextURL: function(success, failure) {
        exec(success, failure, "MediaPlayer", "addNextURL", [urlString]);
    },
    playNext: function(success, failure) {
        exec(success, failure, "MediaPlayer", "playNext", []);
    },
    ended: function() {
        console.log('Playlist ended')
    }

};

module.exports = MediaPlayer;