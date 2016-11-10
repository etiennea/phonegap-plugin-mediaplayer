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

@interface APPAudioPlayerPlugin()

// Instance of the audio player which contains all implementation.
@property (nonatomic, retain) GBAudioPlayer* audioPlayer;
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
    audioPlayer = [[GBAudioPlayer alloc] init];
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
- (void) setup:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        trackingUrl = [command.arguments objectAtIndex:0];
        
        NSAssert(trackingUrl != nil, @"[AudioPlayer] Setup failed!");
        
        [self succeeded:command];
    }];
}

/**
 * Play song or resume at current position.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) play:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [audioPlayer play];
        [self succeeded:command];
    }];
}

/**
 * Jump to next track and start playing.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) playNext:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [audioPlayer playNext];
        [self succeeded:command];
    }];
}

/**
 * Pause and remember current position.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) pause:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [audioPlayer pause];
        [self succeeded:command];
    }];
}

/**
 * Stop playing sounds and clear the queue.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) stop:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [audioPlayer clear];
        [self succeeded:command];
    }];
}

/**
 * Add or replace the song to the queue.
 *
 * @param [ CDVInvokedUrlCommand ] command Contains the song.
 *
 * @return [ Void ]
 */
- (void) queue:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSDictionary* song = [command.arguments objectAtIndex:0];
        NSDictionary* opts = [command.arguments objectAtIndex:1];
        
        NSAssert(song != nil, @"[AudioPlayer] Missing song!");
        NSAssert(opts != nil, @"[AudioPlayer] Missing opts!");
        
        // TODO next
        
        [self succeeded:command];
    }];
}

/**
 * Get ID of the current track.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) currentTrack:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* track = [audioPlayer getCurrentItem];

        CDVPluginResult* pluginResult;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsString:track];
    
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
    }];
}

/**
 * Smooth transition of volume from 0 to 1.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) fadeInVolume:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [audioPlayer fadeInVolume];
        [self succeeded:command];
    }];
}

/**
 * Smooth transition of volume from 1 to 0.
 *
 * @param [ CDVInvokedUrlCommand ] command The callback function.
 *
 * @return [ Void ]
 */
- (void) fadeOutVolume:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [audioPlayer fadeOutVolume];
        [self succeeded:command];
    }];
}

-(void)playURL:(CDVInvokedUrlCommand*)command{
    
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    NSString* urlString;
    NSString* songTitle;
    NSString* artist;
    NSString* albumTitle;
    NSString* Img;
    NSString* trackId;
    
    if ([command.arguments objectAtIndex:0]){
        urlString =[command.arguments objectAtIndex:0];
    }
    else{
        return;
    }
    if ([command.arguments objectAtIndex:1]){
        songTitle =[command.arguments objectAtIndex:1];
    }
    if ([command.arguments objectAtIndex:2]){
        albumTitle =[command.arguments objectAtIndex:2];
    }
    if ([command.arguments objectAtIndex:3]){
        artist =[command.arguments objectAtIndex:3];
    }
    if ([command.arguments objectAtIndex:4]){
        Img =[command.arguments objectAtIndex:4];
    }
    if ([command.arguments objectAtIndex:5]){
        trackId =[command.arguments objectAtIndex:5];
    }
    
    NSLog(@"playURL: %@", trackId);
    [audioPlayer playURL:urlString withSongTitle:songTitle andAlbumTitle:albumTitle andArtistName:artist andImg:Img andTrackId:trackId];
}

-(void)addNextURL:(CDVInvokedUrlCommand*)command{
    
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    
    NSString* urlString;
    NSString* songTitle;
    NSString* artist;
    NSString* albumTitle;
    NSString* Img;
    NSString* trackId;
    
    if ([command.arguments objectAtIndex:0]){
        urlString =[command.arguments objectAtIndex:0];
    }
    else{
        return;
    }
    if ([command.arguments objectAtIndex:1]){
        songTitle =[command.arguments objectAtIndex:1];
    }
    if ([command.arguments objectAtIndex:2]){
        albumTitle =[command.arguments objectAtIndex:2];
    }
    if ([command.arguments objectAtIndex:3]){
        artist =[command.arguments objectAtIndex:3];
    }
    if ([command.arguments objectAtIndex:4]){
        Img =[command.arguments objectAtIndex:4];
    }
    if ([command.arguments objectAtIndex:5]){
        trackId =[command.arguments objectAtIndex:5];
    }
    NSLog(@"addNextURL: %@", trackId);
    [audioPlayer addNextURLWithString:urlString withSongTitle:songTitle andAlbumTitle:albumTitle andArtistName:artist andImg:Img andTrackId:trackId];
}

#pragma mark -
#pragma mark GBAudioPlayerDelegate

-(void)didFinishPlayingSong{
    NSLog(@"didFinishPlayingSong");

    if ([self.webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView*)self.webView stringByEvaluatingJavaScriptFromString:@"if(window && window.MediaPlayer){ window.MediaPlayer.ended() }"];
    }
    
    //Sends trackid
    if(![trackingUrl  isEqual: @"test"]){
        NSLog(@"play tracking");
        NSString *currentTrack = [audioPlayer getCurrentItem];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&trackId=%@", trackingUrl, currentTrack]]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        
        //NSData *oResponseData =
        [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        
        if([responseCode statusCode] != 200){
            NSLog(@"Error getting %@, HTTP status code %li", trackingUrl, (long)[responseCode statusCode]);
        }
    }
}

#pragma mark -
#pragma mark Helper

/**
 * Simply invokes the callback without any parameter.
 */
- (void) succeeded:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result
                                callbackId:command.callbackId];
}

@end
