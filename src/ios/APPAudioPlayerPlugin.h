/*
 * Copyright (c) 2013-2016 by appPlant GmbH. All rights reserved.
 *
 * APPAudioPlayerPlugin.h
 *
 * Created by Vadim Fainshtein    on 01/16/14.
 * Updated by Etienne Adriaenssen on 06/10/15.
 *
 * @APPPLANT_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apache License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://opensource.org/licenses/Apache-2.0/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPPLANT_LICENSE_HEADER_END@
 */

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "APPAudioPlayer.h"

@interface APPAudioPlayerPlugin : CDVPlugin <APPAudioPlayerDelegate>

// Setup tracking function.
- (void) setup:(CDVInvokedUrlCommand*)command;
// Start/resume playing the current song.
- (void) play:(CDVInvokedUrlCommand*)command;
// Play next song in queue.
- (void) playNext:(CDVInvokedUrlCommand*)command;
// Pause current playing song.
- (void) pause:(CDVInvokedUrlCommand*)command;
// Remove all songs in the queue and stop playing.
- (void) stop:(CDVInvokedUrlCommand*)command;
// Queue the specified song.
- (void) queue:(CDVInvokedUrlCommand*)command;
// Get infos about the current track.
- (void) currentTrack:(CDVInvokedUrlCommand*)command;
// Smooth transition of volume from 0 to 1.
- (void) fadeInVolume:(CDVInvokedUrlCommand*)command;
// Smooth transition of volume from 1 to 0.
- (void) fadeOutVolume:(CDVInvokedUrlCommand*)command;

@end
