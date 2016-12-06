/*
 * Copyright (c) 2013-2016 by appPlant GmbH. All rights reserved.
 *
 * APPAudioPlayer.m
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

#import "APPAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface APPAudioPlayer() {
    AVQueuePlayer* player;
}

// Contains all queued audio objects
@property (nonatomic, strong) NSMutableDictionary* songs;

@end

@implementation APPAudioPlayer;

#pragma mark -
#pragma mark Life Cycle

/**
 * @abstract Setup audio and observers.
 *
 * @return [ Void ]
 */
- (id) init
{
    self = [super init];

    [self observeCommandCenter];
    [self observeNotificationCenter];
    [self setupAudioSession];
    [self setupAudioPlayer];

    _songs = [NSMutableDictionary dictionary];

    return self;
}

/**
 * @abstract Cleanup memory.
 *
 * @return [ Void ]
 */
- (void) dealloc
{
    [player removeObserver:self forKeyPath:@"status" context:NULL];
    [player removeObserver:self forKeyPath:@"currentItem" context:NULL];
    [player removeObserver:self forKeyPath:@"timeControlStatus" context:NULL];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    player = NULL;
    _songs = NULL;
}

#pragma mark -
#pragma mark Init

/**
 * @abstract Setup playback for audio session.
 *
 * @return [ Void ]
 */
- (void) setupAudioSession
{
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayback error:NULL];

    [[AVAudioSession sharedInstance]
     setActive:YES error:NULL];
}

/**
 * @abstract Setup audio player.
 *
 * @return [ Void ]
 */
- (void) setupAudioPlayer
{
    player = [[AVQueuePlayer alloc] init];

    player.allowsExternalPlayback = TRUE;
    player.actionAtItemEnd        = AVPlayerActionAtItemEndAdvance;
    player.volume                 = 1.0f;

    [player addObserver:self forKeyPath:@"status" options:0 context:NULL];
    [player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
    [player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:NULL];
}

/**
 * @abstract Observe the notification center to react on certain events.
 *
 * @return [ Void ]
 */
- (void) observeNotificationCenter
{
    NSNotificationCenter* center = [NSNotificationCenter
                                    defaultCenter];

    [center addObserver:self
               selector:@selector(didFinishPlayingAudio:)
                   name:AVPlayerItemDidPlayToEndTimeNotification
                 object:NULL];

    [center addObserver:self
               selector:@selector(didFailPlayingAudio:)
                   name:AVPlayerItemFailedToPlayToEndTimeNotification
                 object:NULL];

    [center addObserver:self
               selector:@selector(onAudioSessionEvent:)
                   name:AVAudioSessionInterruptionNotification
                 object:NULL];
}

/**
 * @abstract Observe the remote play pause buttons.
 *
 * @return [ Void ]
 */
- (void) observeCommandCenter
{
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter
                                     sharedCommandCenter];

    [center.pauseCommand addTargetWithHandler:
     ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent* e) {
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

    [center.playCommand addTargetWithHandler:
     ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent* e) {
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
     }];

    [center.stopCommand addTargetWithHandler:
     ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent* e) {
         [self stop];
         return MPRemoteCommandHandlerStatusSuccess;
     }];

    [center.nextTrackCommand addTargetWithHandler:
     ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent* e) {
         [self playNext];
         return MPRemoteCommandHandlerStatusSuccess;
     }];
}

#pragma mark -
#pragma mark Interface

/**
 * @abstract Get the current song.
 *
 * @return [ APPAudio ]
 */
- (APPAudio*) getCurrentAudio
{
    return [_songs valueForKey:player.currentItem.description];
}

/**
 * @abstract Add the song to the queue.
 *
 * @param [ APPAudio ] song The audio song to add to the queue.
 * @param [ Bool ] play Set to true to start playing at the current position
 *                      of the queue.
 * @param [ Bool ] replace Set to true to clear the queue before.
 *
 * @return [ Void ]
 */
- (void) queue:(NSArray*)songs play:(BOOL)startPlaying replace:(BOOL)replaceFlag
{
    if (replaceFlag) {
        [self resetPlayerAndInformDelegate:NO];
    }

    for (APPAudio* song in songs) {
        [self addAudio:song];
    }

    if (startPlaying) {
        [self play];
    }
}

/**
 * @abstract Start or resume the audio player and inform the delegate
 * by invoking didStartPlayingAudio.
 *
 * @return [ Void ]
 */
- (void) play
{
    [player play];
    
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        [self didStartPlayingAudio];
    }
}

/**
 * @abstract Jump to the next available song.
 *
 * @return [ Void ]
 */
- (void) playNext
{
    [player advanceToNextItem];
}

/**
 * @abstract Pause the audio player and inform the delegate
 * by invoking didPausePlayingAudio.
 *
 * @return [ Void ]
 */
- (void) pause
{
    [player pause];
    
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        [self didPausePlayingAudio];
    }
}

/**
 * @abstract Stop the audio player and remove all queued songs.
 *
 * @return [ Void ]
 */
- (void) stop
{
    [self resetPlayerAndInformDelegate:YES];
}

/**
 * @abstract Transit volume from 1 to 0.
 *
 * @return [ Void ]
 */
- (void) fadeOutVolume
{
    [self setVolumeFromStartVolume:1.0 toEndVolume:0.0];
}

/**
 * @abstract Transit volume from 0 to 1.
 *
 * @return [ Void ]
 */
- (void) fadeInVolume
{
    [self setVolumeFromStartVolume:0.0 toEndVolume:1.0];
}

#pragma mark -
#pragma mark Internal

/**
 * @abstract Add audio to the queue.
 *
 * @param [ APPAudio ] song The audio to add.
 *
 * @return [ Void ]
 */
- (void) addAudio:(APPAudio*)song
{
    AVURLAsset *asset  = [[AVURLAsset alloc]
                          initWithURL:song.file options:NULL];

    AVPlayerItem* item = [[AVPlayerItem alloc]
                          initWithAsset:asset];

    [_songs setValue:song forKey:item.description];
    [player insertItem:item afterItem:NULL];
}

/**
 * @abstract Remove all queued songs.
 *
 * @return [ Void ]
 */
- (void) resetPlayerAndInformDelegate:(BOOL)eventFlag
{
    [player removeAllItems];
    [_songs removeAllObjects];

    if (eventFlag) {
        [self didStopPlayingAudio];
    }
}

/**
 * @abstract Sets a volume ramp to apply during the specified timeRange.
 *
 * @param [ Float ] startVolume The volume where to start from.
 * @param [ Float ] endVolume The volume where to end.
 *
 * @return [ Void ]
 */
- (void) setVolumeFromStartVolume:(float)startVolume toEndVolume:(float)endVolume
{
    AVPlayerItem* playerItem    = player.currentItem;
    AVAsset* asset              = playerItem.asset;
    NSArray* tracks             = [asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray* audioParams = [NSMutableArray array];

    for (AVAssetTrack* track in tracks)
    {
        CMTimeRange range = CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(5, 1));

        AVMutableAudioMixInputParameters* params =
        [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];

        [params setVolumeRampFromStartVolume:startVolume
                                 toEndVolume:endVolume
                                   timeRange:range];

        [audioParams addObject:params];

    }

    AVMutableAudioMix* audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:audioParams];
    [playerItem setAudioMix:audioMix];
}

/**
 * @abstract Set the current now playing info for the center.
 *
 * @param [ APPAudio ] song Contains all infos about the song.
 *                          Setting to nil will clear it.
 *
 * @return [ Void ]
 */
- (void) setNowPlayingInfo:(APPAudio*)song
{
    NSURLSession* http = [NSURLSession sharedSession];
    NSURLSessionDownloadTask* downloadCoverTask;

    if (!song) {
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:NULL];
        return;
    }

    NSDictionary* nowPlaying = @{
                                 MPMediaItemPropertyTitle: song.title,
                                 MPMediaItemPropertyArtist: song.artist,
                                 MPMediaItemPropertyAlbumTitle: song.album
                                 };

    [[MPNowPlayingInfoCenter defaultCenter]
     setNowPlayingInfo:nowPlaying];

    downloadCoverTask = [http downloadTaskWithURL:song.cover completionHandler:^(NSURL* url, NSURLResponse* res, NSError* e) {
        NSData* data = [NSData dataWithContentsOfURL:url];
        UIImage* img = [UIImage imageWithData:data];

        if (img) {
            MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc]
                                           initWithImage:img];
            
            NSMutableDictionary* nowPlayingWithArtwork = [nowPlaying mutableCopy];
            [nowPlayingWithArtwork setValue:artwork
                                     forKey:MPMediaItemPropertyArtwork];
            
            [[MPNowPlayingInfoCenter defaultCenter]
             setNowPlayingInfo:nowPlayingWithArtwork];
        }
    }];

    [downloadCoverTask resume];
}

/**
 * @abstract Check if the delegate has implemented the specified method.
 *
 * @param [ SEL ] event The selector to check for implementation.
 *
 * @return [ Bool ]
 */
- (BOOL) delegateRespondsTo:(SEL)event
{
    return (_delegate && [_delegate respondsToSelector:event]);
}

#pragma mark -
#pragma mark Callbacks

/**
 * @abstract Invoked by observing the notifcation center.
 *
 * @return [ Void ]
 */
- (void) didStartPlayingAudio
{
    if ([self delegateRespondsTo:@selector(didStartPlayingAudio:)]) {
        [_delegate didStartPlayingAudio:self.currentAudio];
    }
}

/**
 * @abstract Invoked by observing the notifcation center.
 *
 * @return [ Void ]
 */
- (void) didPausePlayingAudio
{
    if ([self delegateRespondsTo:@selector(didPausePlayingAudio:)]) {
        [_delegate didPausePlayingAudio:self.currentAudio];
    }
}

/**
 * @abstract Invoked by observing the notifcation center.
 *
 * @return [ Void ]
 */
- (void) didFinishPlayingAudio:(NSNotification*)notification
{
    if ([self delegateRespondsTo:@selector(didFinishPlayingAudio:)]) {
        [_delegate didFinishPlayingAudio:self.currentAudio];
    }
}

/**
 * @abstract Invoked by observing the notifcation center.
 *
 * @return [ Void ]
 */
- (void) didStopPlayingAudio
{
    if ([self delegateRespondsTo:@selector(didStopPlayingAudio:)]) {
        [_delegate didStopPlayingAudio:self.currentAudio];
    }
}

/**
 * @abstract Invoked by observing the notifcation center.
 *
 * @return [ Void ]
 */
- (void) didFailPlayingAudio:(NSNotification*)notification
{
    if ([self delegateRespondsTo:@selector(didFailPlayingAudio:)]) {
        [_delegate didFailPlayingAudio:self.currentAudio];
    }
}

/**
 * @abstract Will be notified when the system has interrupted the audio session
 * and when the interruption has ended.
 *
 * @param [ NSNotification ] notification Check the notification's userInfo
 *                                        dictionary for the interruption type.
 *
 * @return [ Void ]
 */
- (void) onAudioSessionEvent:(NSNotification*)notification
{
    if (![notification.name isEqualToString:AVAudioSessionInterruptionNotification])
        return;

    id interruptType = [notification.userInfo
                        valueForKey:AVAudioSessionInterruptionTypeKey];

    NSNumber* typeEnd = [NSNumber numberWithInt:
                        AVAudioSessionInterruptionTypeEnded];

    if (![interruptType isEqualToNumber:typeEnd])
        return;

    [player play];
}

/**
 * @abstract Called by the player whenever the value of the status property or
 * currentItem property has been changed.
 *
 * @param [ NSString ] keyPath The name of the changed property.
 *
 * @return [ Void ]
 */
- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {

    APPAudio* audio = self.currentAudio;

    if ([keyPath isEqualToString:@"currentItem"]) {
        [self setNowPlayingInfo:audio];
    }

    if (!audio || SYSTEM_VERSION_LESS_THAN(@"10.0"))
        return;

    if (player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        [self didPausePlayingAudio];
    } else
    if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying && player.status == AVPlayerStatusReadyToPlay) {
        [self didStartPlayingAudio];
    }
}

@end
