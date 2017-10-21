/*
 * Copyright (c) 2013-2016 by appPlant GmbH. All rights reserved.
 *
 * APPAudioPlayerPlugin.m
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

#import "APPAudioPlayerPlugin.h"
#import "APPAudio.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface APPAudioPlayerPlugin()

// Instance of the audio player which contains all implementation.
@property (nonatomic, retain) APPAudioPlayer* audioPlayer;
// Tracking URL
@property (nonatomic, copy) NSString* trackingUrl;

@end

@implementation APPAudioPlayerPlugin

@synthesize audioPlayer, trackingUrl;

#pragma mark -
#pragma mark Life Cycle

/**
 * Initialize the audioplayer instance for later usage.
 */
- (void) pluginInitialize
{
    audioPlayer = [[APPAudioPlayer alloc] init];
    trackingUrl = @"";
    audioPlayer.delegate = self;
}

#pragma mark -
#pragma mark Interface

/**
 * Setup tracking function.
 *
 * @param [ CDVInvokedUrlCommand ] command Contains the URL as a string.
 *
 * @return [ Void ]
 */
- (void) setup:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        trackingUrl = [command.arguments objectAtIndex:0];

        [self succeedWithTrackId:command andFireEvent:@"setup"];
    }];
}

/**
 * Play song or resume at current position.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) play:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [audioPlayer play];
    }];
}

/**
 * Jump to next track and start playing.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) playNext:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [audioPlayer playNext];
    }];
}

/**
 * Pause and remember current position.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) pause:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [audioPlayer pause];
    }];
}

/**
 * Stop playing sounds and clear the queue.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) stop:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [audioPlayer stop];
    }];
}

/**
 * Add or replace the song to the queue.
 *
 * @param [ CDVInvokedUrlCommand ] command Contains the song.
 *
 * @return [ Void ]
 */
- (void) queue:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSMutableArray* audios = [[NSMutableArray alloc] init];
        NSArray* songs     = [command.arguments objectAtIndex:0];
        NSDictionary* opts = [command.arguments objectAtIndex:1];

        BOOL playFlag    = [[opts objectForKey:@"play"] boolValue];
        BOOL replaceFlag = [[opts objectForKey:@"replace"] boolValue];

        for (int i = 0; i < [songs count]; i++) {
            NSDictionary* song = [songs objectAtIndex:i];
            APPAudio* audio    = [[APPAudio alloc] initWithDict:song];

            [audios addObject:audio];
        }

        [audioPlayer queue:audios play:playFlag replace:replaceFlag];

        [self succeedWithTrackId:command andFireEvent:@"queue"];
    }];
}

/**
 * Get ID of the current track.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) currentTrack:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [self succeedWithTrackId:command andFireEvent:NULL];
    }];
}

/**
 * Smooth transition of volume from 0 to 1.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) fadeInVolume:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [audioPlayer fadeInVolume];
        [self succeedWithTrackId:command andFireEvent:@"fadein"];
    }];
}

/**
 * Smooth transition of volume from 1 to 0.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) fadeOutVolume:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [audioPlayer fadeOutVolume];
        [self succeedWithTrackId:command andFireEvent:@"fadeout"];
    }];
}

#pragma mark -
#pragma mark APPAudioPlayerDelegate

/**
 * Invoked by audio player if a song failed to play.
 *
 * @param [ APPAudio ] The song.
 *
 * @return [ Void ]
 */
- (void) didFailPlayingAudio:(APPAudio*)audio
{
    [self fireEvent:@"fail" withAudio:audio];
}

/**
 * Invoked by audio player when started playing a song.
 *
 * @param [ APPAudio ] The song.
 *
 * @return [ Void ]
 */
- (void) didStartPlayingAudio:(APPAudio*)audio
{
    [self makeRestCall:audio.id withEvent:@"start"];
    [self fireEvent:@"start" withAudio:audio];
}

/**
 * Invoked by audio player when paused a song.
 *
 * @param [ APPAudio ] The song.
 *
 * @return [ Void ]
 */
- (void) didPausePlayingAudio:(APPAudio*)audio
{
    [self makeRestCall:audio.id withEvent:@"pause"];
    [self fireEvent:@"pause" withAudio:audio];
}

/**
 * Invoked by audio player when finished a song.
 *
 * @param [ APPAudio ] The song.
 *
 * @return [ Void ]
 */
- (void) didFinishPlayingAudio:(APPAudio*)audio
{
    [self makeRestCall:audio.id withEvent:@"finish"];
    [self fireEvent:@"finish" withAudio:audio];
    
    APPAudio* nextAudio = audioPlayer.getNextAudio;
    if ( nextAudio && SYSTEM_VERSION_LESS_THAN(@"10.0"))
    {
        [self didStartPlayingAudio:nextAudio];
    }
}

/**
 * Invoked by audio player when stopped playing songs.
 *
 * @param [ APPAudio ] The last playing song.
 *
 * @return [ Void ]
 */
- (void) didStopPlayingAudio:(APPAudio*)audio
{
    [self fireEvent:@"stop" withAudio:audio];
}

#pragma mark -
#pragma mark Helper

/**
 * Invoke the callback and fire the event if given.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 * @param [ NSString* ] event Optional name of the event to fire.
 *
 * @return [ Void ]
 */
- (void) succeedWithTrackId:(CDVInvokedUrlCommand*)command andFireEvent:(NSString*)event
{
    APPAudio* audio = audioPlayer.currentAudio;
    NSString* song  = audio ? [audio encodeToJSON] : NULL;
    CDVPluginResult *result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:song];

    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];

    if (event) {
        [self fireEvent:event withAudio:audio];
    }
}

/**
 * Fire the specified event on JS side.
 *
 * @param [ NSString* ] event The name of the event to fire.
 * @param [ APPAudio* ] audio The current audio.
 *
 * @return [ Void ]
 */
- (void) fireEvent:(NSString*)event withAudio:(APPAudio*)audio
{
    NSString* song = audio ? [audio encodeToJSON] : NULL;

    NSString* js;
    js = [NSString stringWithFormat:
          @"cordova.plugins.audioPlayer.fireEvent('%@', %@)", event, song];

    [self.commandDelegate evalJs:js];
}


/**
 * Make REST call.
 *
 * @param [ NSString* ] trackId the trackId of current song.
 * @param [ NSString* ] eventType the type of the triggered event.
 *
 * @return [ Void ]
 */
- (void) makeRestCall:(NSString*)trackId withEvent:(NSString*)eventType
{
    if (![trackingUrl isEqualToString:@""] ) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setHTTPMethod:@"POST"];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&trackId=%@&eventType=%@", trackingUrl, trackId, eventType]]];

        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;

        [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];

    }
}

@end
