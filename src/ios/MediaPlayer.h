//
//  AudioPlayerPlugin.h
//  audioPlayerPlugin
//
//  Created by Vadim Fainshtein on 1/16/14.
//  Updated by Etienne Adriaenssen 06/10/15
//
//   MIT
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "GBBackgroundAudioPlayer.h"



@interface MediaPlayer : CDVPlugin <GBAudioPlayerDelegate>{
    GBAudioPlayer* audioPlayer;
}

-(void)setup:(CDVInvokedUrlCommand*)command;
-(void)currentTrack:(CDVInvokedUrlCommand*)command;
-(void)playNext:(CDVInvokedUrlCommand*)command;
-(void)playURL:(CDVInvokedUrlCommand*)command;
-(void)pause:(CDVInvokedUrlCommand*)command;
-(void)addNextURL:(CDVInvokedUrlCommand*)command;
-(void)play:(CDVInvokedUrlCommand*)command;
-(void)clear:(CDVInvokedUrlCommand*)command;
-(void)fadeIn:(CDVInvokedUrlCommand*)command;
-(void)fadeOut:(CDVInvokedUrlCommand*)command;

@property (nonatomic, copy) NSString* callbackID;
@end