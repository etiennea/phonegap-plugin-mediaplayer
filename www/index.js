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

    playURL: function(urlString, songTitle, albumTitle, artistName, imgUrl, trackId, success, failure) {
        exec(success, failure, "MediaPlayer", "playURL", [urlString, songTitle, albumTitle, artistName, imgUrl, trackId]);
    },
    addNextURL: function(urlString, songTitle, albumTitle, artistName, imgUrl, trackId, success, failure) {
        exec(success, failure, "MediaPlayer", "addNextURL", [urlString, songTitle, albumTitle, artistName, imgUrl, trackId]);
    },
    playNext: function(success, failure) {
        exec(success, failure, "MediaPlayer", "playNext", []);
    },
    ended: function() {
        console.log('Playlist ended')
        //replace this function
    },
    clear: function(success, failure) {
        //clear the queue
        exec(success, failure, "MediaPlayer", "clear", []);
    },
    fadeIn: function(success, failure) {
        exec(success, failure, "MediaPlayer", "fadeIn", []);
    },
    fadeOut: function(success, failure) {
        exec(success, failure, "MediaPlayer", "fadeOut", []);
    },
    setup: function(trackingUrl, success, failure) {
        //egg http://trackme.com/track?user=123
        //will add &trackId=123
        exec(success, failure, "MediaPlayer", "setup", [trackingUrl]);
    },
    currentTrack: function(success, failure) {
        //return currentrack id
        exec(success, failure, "MediaPlayer", "currentTrack", []);
    },
};

module.exports = MediaPlayer;