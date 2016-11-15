/*
 * Copyright (c) 2013-2016 by appPlant GmbH. All rights reserved.
 *
 * APPAudioPlayer.h
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

#import <AVFoundation/AVFoundation.h>

@protocol APPAudioPlayerDelegate <NSObject>

- (void) didFinishPlayingAudio;

@end

@interface APPAudioPlayer : NSObject

-(void)playNext;
-(void)playURL:(NSString*) urlString withSongTitle:(NSString*)songTitle andAlbumTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName andImg:(NSString*)Img andTrackId:(NSString*)trackId;
-(void)pause;
-(void)addNextURLWithString:(NSString*) urlString withSongTitle:(NSString*)songTitle andAlbumTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName andImg:(NSString*)Img andTrackId:(NSString*)trackId;
-(void)play;
-(void)clear;
-(void)fadeOutVolume;
-(void)fadeInVolume;

@property (nonatomic, copy) NSString *getCurrentItem;
@property (nonatomic, assign) id<APPAudioPlayerDelegate> delegate;

@end
