//
//  AudioPlayerPlugin.m
//  audioPlayerPlugin
//
//  Created by Vadim Fainshtein on 1/16/14.
//  Updated by Etienne Adriaenssen 06/10/15
//
//   MIT
//

#import "MediaPlayer.h"

@implementation MediaPlayer

-(void)playNext:(CDVInvokedUrlCommand*)command{
      [self.commandDelegate runInBackground:^{
    NSLog(@"playNext");
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    [audioPlayer playNext];
            }];
}
-(void)playURL:(CDVInvokedUrlCommand*)command{
    NSLog(@"playURL");
  [self.commandDelegate runInBackground:^{
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    NSString* urlString;
    NSString* songTitle;
    NSString* artist;
    NSString* albumTitle;
    NSString* Img;
    
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


    [audioPlayer playURL:urlString withSongTitle:songTitle andAlbumTitle:albumTitle andArtistName:artist andImg:Img];
      }];
}

-(void)pause:(CDVInvokedUrlCommand*)command{
    NSLog(@"pause");
  [self.commandDelegate runInBackground:^{
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    [audioPlayer pause];
  }];
}

-(void)addNextURL:(CDVInvokedUrlCommand*)command{
    NSLog(@"addNextURL");
  [self.commandDelegate runInBackground:^{
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    NSString* urlString = [command.arguments objectAtIndex:0];
    [audioPlayer addNextURLWithString:urlString];
        }];
}

-(void)play:(CDVInvokedUrlCommand*)command{
    NSLog(@"play");
  [self.commandDelegate runInBackground:^{
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    [audioPlayer play];
      }];
}

-(void)didFinishPlayingSong{
    NSLog(@"didFinishPlayingSong");
  [self.commandDelegate runInBackground:^{
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.MediaPlayer.ended()"];
        }];
}

@end