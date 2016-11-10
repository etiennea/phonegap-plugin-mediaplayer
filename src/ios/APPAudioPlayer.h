//
//  GBBackgroundAudioPlayer.h
//  audioplayer
//
//  Created by Vadim Fainshtein on 1/16/14.
//  Updated by Etienne Adriaenssen 06/10/15
//
//   MIT
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@class AVQueuePlayer;


@protocol GBAudioPlayerDelegate <NSObject>

-(void)didFinishPlayingSong;

@end

@interface GBAudioPlayer : NSObject  {
    AVQueuePlayer   *player;
}

-(void)playNext;
-(void)playURL:(NSString*) urlString withSongTitle:(NSString*)songTitle andAlbumTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName andImg:(NSString*)Img andTrackId:(NSString*)trackId;
-(void)pause;
-(void)addNextURLWithString:(NSString*) urlString withSongTitle:(NSString*)songTitle andAlbumTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName andImg:(NSString*)Img andTrackId:(NSString*)trackId;
-(void)play;
-(void)clear;
-(void)fadeOutVolume;
-(void)fadeInVolume;

@property (nonatomic, copy) NSString *getCurrentItem;
@property (nonatomic, assign) id<GBAudioPlayerDelegate> delegate;
@property (nonatomic, strong) id playerObserver;
@property (nonatomic, strong) id playerItem;

@end