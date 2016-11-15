//
//  GBBackgroundAudioPlayer.m
//  audioplayer
//
//  Created by Vadim Fainshtein on 1/16/14.
//  Updated by Etienne Adriaenssen 06/10/15
//
//   MIT
//

#import "APPAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface APPAudioPlayer() {
    AVQueuePlayer* player;
}

@property (nonatomic, strong) id playerObserver;
@property (nonatomic, strong) id playerItem;

@end

@implementation APPAudioPlayer;

NSString *KVOcontext = @"GBAudioPlayer";
NSString *currentItem = @"0";
int currentIndex = 1;
NSMutableArray *done = nil;

NSMutableArray *titles = nil;
NSMutableArray *artists = nil;
NSMutableArray *albums = nil;
NSMutableArray *ids = nil;
NSMutableArray *imgs = nil;



- (id) init{
    self = [super init];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    //This code manages the remote play pause buttons
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"toggle button pressed");
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"toggle button pressed");
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    //end remote
    
    //trigger javascript next
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
     
    player = [[AVQueuePlayer alloc]init];
    player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    
    player.allowsExternalPlayback = TRUE;
    
    player.volume = 1.0f;
    [player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    return self;
}

-(void)didFinish{
    NSLog(@"did finish javascript");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_delegate didFinishPlayingAudio];
}

- (void) onAudioSessionEvent: (NSNotification *) notification
{
    //Check the type of notification, especially if you are sending multiple AVAudioSession events here
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification received!");
        
        //Check to see if it was a Begin interruption
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            NSLog(@"Interruption began!");
            
        } else {
            NSLog(@"Interruption ended!");
            //Resume your audio
            [player play];
        }
    }
}

-(void)addNextURLWithString:(NSString*) urlString withSongTitle:(NSString*)songTitle andAlbumTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName andImg:(NSString*)Img andTrackId:(NSString*)trackId{
    //NSLog(@"url:%@",urlString);
    
    NSURL *url=[NSURL URLWithString:urlString];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    
    [player insertItem:self.playerItem afterItem:nil];
    
    //assets
    [titles addObject:songTitle];
    [artists addObject:artistName];
    [albums addObject:albumTitle];
    [imgs addObject:Img];
    [ids addObject:trackId];
    
}


-(void)playURL:(NSString*) urlString withSongTitle:(NSString*)songTitle andAlbumTitle:(NSString*)albumTitle andArtistName:(NSString*)artistName andImg:(NSString*)Img andTrackId:(NSString*)trackId{
    
    titles = [NSMutableArray arrayWithObjects: songTitle, nil];
    artists = [NSMutableArray arrayWithObjects: artistName, nil];
    albums = [NSMutableArray arrayWithObjects: albumTitle, nil];
    imgs = [NSMutableArray arrayWithObjects: Img, nil];
    ids = [NSMutableArray arrayWithObjects: trackId, nil];
    done = [NSMutableArray arrayWithObjects: @"test", nil];
    
    currentIndex = 1;
    
    NSURL *url = [NSURL URLWithString:Img];
    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
        MPMediaItemArtwork* artwork =   [[MPMediaItemArtwork alloc]initWithImage:image];
        NSDictionary *nowPlaying = @{
                                     MPMediaItemPropertyTitle: songTitle,
                                     MPMediaItemPropertyArtist: artistName,
                                     MPMediaItemPropertyAlbumTitle: albumTitle,
                                     MPMediaItemPropertyArtwork: artwork
                                     };
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
    }];
    [downloadPhotoTask resume];
    
    [player removeAllItems];
    if (player != nil && ![currentItem isEqual: @"0"])
        [player removeObserver:self forKeyPath:@"currentItem"];
    [self addNextURLWithString:urlString withSongTitle:songTitle andAlbumTitle:albumTitle andArtistName:artistName andImg:Img andTrackId:trackId];
    [self play];
    [player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:&KVOcontext];
    currentItem = trackId;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == &KVOcontext) {
        //AVPlayerItem *playerItem = [player currentItem];
        NSLog(@"T %@ / %@, Code %i", [ids objectAtIndex:currentIndex], currentItem, currentIndex);
        NSLog(@"bool %i", [done containsObject:currentItem]);
        //if (player.status == AVPlayerStatusReadyToPlay) {
            
        //[ids objectAtIndex:currentIndex] == currentItem &&
            
            if([done containsObject:currentItem] == 0){
                
                [done addObject:currentItem];
                  currentIndex = currentIndex + 1;
             currentItem = [ids objectAtIndex:currentIndex];
                
                if((currentIndex + 1) < [ids count]){
                
                
//                    //UIImage *image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: [imgs objectAtIndex:currentIndex]]]];
//                    //MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc] initWithImage:image2];
//                    NSDictionary *nowPlaying = @{MPMediaItemPropertyTitle: [titles objectAtIndex:currentIndex],
//                                                 MPMediaItemPropertyArtist: [artists objectAtIndex:currentIndex],
//                                                 MPMediaItemPropertyAlbumTitle: [albums objectAtIndex:currentIndex],
//                                                 //MPMediaItemPropertyArtwork: artwork
//                                                 };
//                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
//                    
                    NSURL *url = [NSURL URLWithString: [imgs objectAtIndex:currentIndex]];
                    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
                        MPMediaItemArtwork* artwork =   [[MPMediaItemArtwork alloc]initWithImage:image];
                        NSDictionary *nowPlaying = @{
                                                     MPMediaItemPropertyTitle: [titles objectAtIndex:currentIndex],
                                                     MPMediaItemPropertyArtist: [artists objectAtIndex:currentIndex],
                                                     MPMediaItemPropertyAlbumTitle: [albums objectAtIndex:currentIndex],
                                                     MPMediaItemPropertyArtwork: artwork
                                                     };
                        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlaying];
                    }];
                    [downloadPhotoTask resume];
                    
                } else {
                    currentItem = @"end";
                }
            }
        //}
    }
}

-(NSString *)getCurrentItem{
    return currentItem;
}

-(void)play{
    [player play];
    //[_delegate didPlay]; //should fire event to be able to update interface accordingly
}

-(void)clear{
    NSLog(@"clearqueue");
    done = [NSMutableArray arrayWithObjects: @"test", nil];
    currentIndex = 0;
    [player removeAllItems];
   
}

-(void)playNext{
    NSLog(@"playNext");
    currentIndex = currentIndex + 1;
    [player advanceToNextItem];
}

-(void)pause{
    [player pause];
    //[_delegate didPause]; //should fire event to be able to update interface accordingly
}

-(void)fadeOutVolume
{
    NSLog(@"fadeOutTest");
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
    NSLog(@"fadeInTest");
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

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"observer player:%ld",(long)player.status);
//    NSLog(@"observer playeritem:%ld",(long)player.currentItem.status);
//
//    if (object == player && [keyPath isEqualToString:@"status"]) {
//        if (player.status == AVPlayerStatusReadyToPlay) {
//            NSLog(@"player status:%ld",(long)player.status);
//
//        } else if (player.status == AVPlayerStatusFailed) {
//            NSLog(@"AVPlayerStatusFailed");
//        }
//    } else  if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"]) {
//        if (player.currentItem.status == AVPlayerStatusReadyToPlay) {
//            // [player play];
//            NSLog(@"playeritem status:%ld",(long)player.currentItem.status);
//
//        } else if (player.status == AVPlayerStatusFailed) {
//            NSLog(@"AVPlayerStatusFailed");
//        }
//    }
//}



- (void)dealloc {
    //[self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [player removeObserver:self forKeyPath:@"status" context:nil];
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
