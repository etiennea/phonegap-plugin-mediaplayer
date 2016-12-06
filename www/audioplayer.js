/* global cordova:false */

/*
    Copyright 2013-2016 appPlant GmbH

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    'License'); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
*/

var exec = require('cordova/exec');

/**
 * Setup tracking function.
 *
 * @param [ String ] url The web URL where to send tracking infos.
 * @param [ Function ] success Optional success callback.
 * @param [ Function ] failure Optional failure callback.
 *
 * @return [ Void ]
 */
exports.setup = function (url, success, failure) {

    if (!(typeof url == 'string' && url.match(/^http/i))) {
        failure('Invalid tracking url');
        return;
    }

    exec(success, null, 'AudioPlayer', 'setup', [url]);
};

/**
 * Start playing the specified song or at the current queue position.
 *
 * @param [ Object ] song Optional hash containing all required infos.
 *      id: The tracking ID.
 *      title: The title of the song.
 *      album: The name of the album.
 *      artist: The name of the artist.
 *      file: An URL (local or remote) where to get the file.
 *      cover: An URL (local or remote) where to get the cover image.
 * @param [ Function ] callback Optional callback.
 *
 * @return [ Void ]
 */
exports.play = function (song, callback) {
    var isSongGiven = (typeof song != 'function') && (typeof song != 'undefined');

    if (isSongGiven) {
        exports.queue(song, { replace: false, play: true }, callback);
    } else {
        callback = song;
        exec(callback, null, 'AudioPlayer', 'play', []);
    }
};

// Alias for method `play`
exports.resume = exports.play;

/**
 * Jump to next song and start playing the track.
 *
 * @param [ Function ] callback Optional callback.
 *
 * @return [ Void ]
 */
exports.playNext = function (callback) {
    exec(callback, null, 'AudioPlayer', 'playNext', []);
};

/**
 * Add the specified song to the end of the queue.
 *
 * @param [ Object ] songs An Array of hashes containing all required information.
 *      id: The tracking ID.
 *      title: The title of the song.
 *      album: The name of the album.
 *      artist: The name of the artist.
 *      file: An URL (local or remote) where to get the file.
 *      cover: An URL (local or remote) where to get the cover image.
 * @param [ Object ] options A hash containg various flags.
 *      replace: Set to true to replace the queue.
 *      play: Set to true to start playing immediatly.
 * @param [ Function ] success Optional success callback.
 * @param [ Function ] failure Optional failure callback.
 *
 * @return [ Void ]
 */
exports.queue = function(songs, options, success, failure) {
    //transform to array if only one song is passed
    if (!Array.isArray(songs)) songs = [songs];

    var invalidIds = [];

    //validate songObjects
    songs.forEach(function(songObject, index){
        var isValid = exports.isValidSong(songObject);

        if (!isValid) {
            invalidIds.push(index);
        }
    });

    //break if invalid songs were passed
    if (invalidIds.length > 0) {
        failure('Incomplete song(s) at indices: ' + invalidIds.join(', '));
    } else {
        //dispatch cordova action
        exec(success, failure, 'AudioPlayer', 'queue', [songs, options]);
    }
};

/**
 * Pause the current track.
 * Use play or resume after to continue.
 *
 * @param [ Function ] callback Optional callback.
 *
 * @return [ Void ]
 */
exports.pause = function (callback) {
    exec(callback, null, 'AudioPlayer', 'pause', []);
};

/**
 * Stop playing and clear the queue.
 *
 * @param [ Function ] callback Optional callback.
 *
 * @return [ Void ]
 */
exports.stop = function (callback) {
    exec(callback, null, 'AudioPlayer', 'stop', []);
};

/**
 * Fade the volume of the track from 0 to 1.
 *
 * @param [ Function ] callback Optional callback.
 *
 * @return [ Void ]
 */
exports.fadeInVolume = function (callback) {
    exec(callback, null, 'AudioPlayer', 'fadeInVolume', []);
};

/**
 * Fade the volume of the track from 1 to 0.
 *
 * @param [ Function ] callback Optional callback.
 *
 * @return [ Void ]
 */
exports.fadeOutVolume = function (callback) {
    exec(callback, null, 'AudioPlayer', 'fadeOutVolume', []);
};

/**
 * Get the id of the current track.
 *
 * @param [ Function ] callback Function to execute with the ID of the track.
 *
 * @return [ Void ]
 */
exports.getCurrentTrack = function (callback) {
    exec(callback, null, 'AudioPlayer', 'currentTrack', []);
};


/********
 * UTIL *
 ********/
/**
 * Validates the given song regarding completeness.
 *
 * @param [ Object ] song The song to validate for.
 *
 * @return [ Boolean ]
 */
exports.isValidSong = function (song) {
    var attrs = ['id', 'title', 'album', 'artist', 'file', 'cover'];

    if (!song)
        return false;

    for (var index = 0, attr = attrs[index]; index < attrs.length; index++) {
        if (!song[attr]) return false;
    }

    return true;
};


/**********
 * EVENTS *
 **********/

exports._listener = {};

/**
 * Fire event with given arguments.
 *
 * @param [ String ] event The event's name.
 * @param {args*} The callback's arguments.
 *
 * @return [ Void ]
 */
exports.fireEvent = function (event) {
    var args     = Array.apply(null, arguments).slice(1),
        listener = this._listener[event];

    if (!listener)
        return;

    for (var i = 0; i < listener.length; i++) {
        var fn    = listener[i][0],
            scope = listener[i][1];

        fn.apply(scope, args);
    }
};

/**
 * Register callback for given event.
 *
 * @param [ String ] event The event's name.
 * @param [ Function ] callback The function to be exec as callback.
 * @param [ Object ] scope The callback function's scope.
 *
 * @return [ Void ]
 */
exports.on = function (event, callback, scope) {

    if (typeof callback !== "function")
        return;

    if (!this._listener[event]) {
        this._listener[event] = [];
    }

    var item = [callback, scope || window];

    this._listener[event].push(item);
};

/**
 * Unregister callback for given event.
 *
 * @param [ String ] event The event's name.
 * @param [ Function ] callback The function to be exec as callback.
 *
 * @return [ Void ]
 */
exports.un = function (event, callback) {
    var listener = this._listener[event];

    if (!listener)
        return;

    for (var i = 0; i < listener.length; i++) {
        var fn = listener[i][0];

        if (fn == callback) {
            listener.splice(i, 1);
            break;
        }
    }
};
