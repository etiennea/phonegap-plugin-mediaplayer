//
//  GBBackgroundAudioPlayer.m
//  audioplayer
//
//  Created by Vadim Fainshtein on 1/16/14.
//  Updated by Etienne Adriaenssen 06/10/15
//
//   MIT
//

#import "GBBackgroundAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation GBAudioPlayer;


- (id) init{
    self = [super init];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    player = [[AVQueuePlayer alloc]init];
    player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    
    player.volume = 1.0f;
    [player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    return self;
}

-(void)didFinish{
    NSLog(@"did finish");

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [_delegate didFinishPlayingSong];
 
    //   [self play];
}

-(void)addNextURLWithString:(NSString*)urlString{
    NSLog(@"url:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:urlString];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    [player insertItem:self.playerItem afterItem:nil];
}

-(void)playURL:(NSString*) urlString withSongTitle:(NSString*)songTitle andAlbumTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName andImg:(NSString*)Img{
    NSLog(@"url:%@",urlString);
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Img]]];
    
    MPMediaItemArtwork* artwork = 	[[MPMediaItemArtwork alloc]initWithImage:image];
    NSDictionary *nowPlaying = @{MPMediaItemPropertyTitle: songTitle,
                                 MPMediaItemPropertyArtist: artistName,
                                 MPMediaItemPropertyAlbumTitle: albumTitle,
                                 MPMediaItemPropertyArtwork: artwork};
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
    [player removeAllItems];
    [self addNextURLWithString:urlString];
    [self play];
}

-(void)play{
    [player play];
}

-(void)clear{
    [player removeAllItems];
}

-(void)playNext{
    [player advanceToNextItem];
}

-(void)fadeOutVolume
{
    AVPlayerItem *myAVPlayerItem = player.currentItem;
    AVAsset *myAVAsset = myAVPlayerItem.asset;
    NSArray *audioTracks = [myAVAsset tracksWithMediaType:AVMediaTypeAudio];

    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {

        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
        [audioInputParams setVolumeRampFromStartVolume:1.0 toEndVolume:0 timeRange:CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(5, 1))];
        [allAudioParams addObject:audioInputParams];

    }

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    [myAVPlayerItem setAudioMix:audioMix];
}

-(void)fadeInVolume
{
    AVPlayerItem *myAVPlayerItem = player.currentItem;
    AVAsset *myAVAsset = myAVPlayerItem.asset;
    NSArray *audioTracks = [myAVAsset tracksWithMediaType:AVMediaTypeAudio];

    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {

        AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
        [audioInputParams setVolumeRampFromStartVolume:0 toEndVolume:1.0 timeRange:CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(5, 1))];
        [allAudioParams addObject:audioInputParams];

    }

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    [myAVPlayerItem setAudioMix:audioMix];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"observer player:%ld",(long)player.status);
    NSLog(@"observer playeritem:%ld",(long)player.currentItem.status);
    
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"player status:%ld",(long)player.status);
            
        } else if (player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else  if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"]) {
        if (player.currentItem.status == AVPlayerStatusReadyToPlay) {
            // [player play];
            NSLog(@"playeritem status:%ld",(long)player.currentItem.status);
            
        } else if (player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    }
}

-(void)pause{
    [player pause];
}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [player removeObserver:self forKeyPath:@"status" context:nil];
}

- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
            
            case UIEventSubtypeRemoteControlTogglePlayPause:[self playPause:nil];
            
            break;
            
            default: break;
        }
    }
}

- (IBAction)playPause:(id)sender {
    
    if (player.rate == 1.0){
        
        [player pause];
    } else if (player.rate == 0.0) {
        
        [player play];
    }
}

- (NSString *)OSStatusToStr:(OSStatus)st
{
    switch (st) {
        case kAudioFileUnspecifiedError:
        return @"kAudioFileUnspecifiedError";
        
        case kAudioFileUnsupportedFileTypeError:
        return @"kAudioFileUnsupportedFileTypeError";
        
        case kAudioFileUnsupportedDataFormatError:
        return @"kAudioFileUnsupportedDataFormatError";
        
        case kAudioFileUnsupportedPropertyError:
        return @"kAudioFileUnsupportedPropertyError";
        
        case kAudioFileBadPropertySizeError:
        return @"kAudioFileBadPropertySizeError";
        
        case kAudioFilePermissionsError:
        return @"kAudioFilePermissionsError";
        
        case kAudioFileNotOptimizedError:
        return @"kAudioFileNotOptimizedError";
        
        case kAudioFileInvalidChunkError:
        return @"kAudioFileInvalidChunkError";
        
        case kAudioFileDoesNotAllow64BitDataSizeError:
        return @"kAudioFileDoesNotAllow64BitDataSizeError";
        
        case kAudioFileInvalidPacketOffsetError:
        return @"kAudioFileInvalidPacketOffsetError";
        
        case kAudioFileInvalidFileError:
        return @"kAudioFileInvalidFileError";
        
        case kAudioFileOperationNotSupportedError:
        return @"kAudioFileOperationNotSupportedError";
        
        case kAudioFileNotOpenError:
        return @"kAudioFileNotOpenError";
        
        case kAudioFileEndOfFileError:
        return @"kAudioFileEndOfFileError";
        
        case kAudioFilePositionError:
        return @"kAudioFilePositionError";
        
        case kAudioFileFileNotFoundError:
        return @"kAudioFileFileNotFoundError";
        
        default:
        return @"unknown error";
    }
}

@end