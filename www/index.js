/* global cordova:false */

/*!
 * Module dependencies.
 */

var exec = cordova.require('cordova/exec');

var AudioPlayer = {

    play: function(success, failure) {
        exec(success, failure, "AudioPlayer", "play", []);
    },

    pause: function(success, failure) {
        exec(success, failure, "AudioPlayer", "pause", []);
    },


    playURL: function(urlString, songTitle, albumTitle, artistName, success, failure) {
        exec(success, failure, "AudioPlayer", "playURL", [urlString, songTitle, albumTitle, artistName]);
    },
    addNextURL: function(success, failure) {
        exec(success, failure, "AudioPlayer", "addNextURL", [urlString]);
    },
    playNext: function(success, failure) {
        exec(success, failure, "AudioPlayer", "playNext", []);
    }

};