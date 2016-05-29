//
//  AudioPlayerPlugin.m
//  audioPlayerPlugin
//
//  Initially created by Vadim Fainshtein on 1/16/14.
//  Updated by Etienne Adriaenssen 06/10/15
//  Updated again to contrain support for the MPNowPlayingInfoCenter and tracking of plays event when in the bacground. In need of a refactor / cleanup
//
//   MIT
//

#import "MediaPlayer.h"

@implementation MediaPlayer

NSString *trackingUrl = @"test";

-(void)setup:(CDVInvokedUrlCommand*)command{
    NSLog(@"setup");
    
    if ([command.arguments objectAtIndex:0]){
        trackingUrl = [command.arguments objectAtIndex:0];
    }
    NSLog(@"trackingUrl:%@", trackingUrl);
}

-(void)currentTrack:(CDVInvokedUrlCommand*)command{
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    NSString *currentTrack = [audioPlayer getCurrentItem];
    NSLog(@"currentTrack:%@", currentTrack);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:currentTrack];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)playNext:(CDVInvokedUrlCommand*)command{
    NSLog(@"playNext");
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    [audioPlayer playNext];
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

-(void)pause:(CDVInvokedUrlCommand*)command{
    NSLog(@"pause");
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    [audioPlayer pause];
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

-(void)play:(CDVInvokedUrlCommand*)command{
    NSLog(@"play");
    if (!audioPlayer){
        audioPlayer = [[GBAudioPlayer alloc]init];
        audioPlayer.delegate = self;
    }
    [audioPlayer play];
}

-(void)clear:(CDVInvokedUrlCommand*)command{
    NSLog(@"play");
    [audioPlayer clear];
}

-(void)fadeIn:(CDVInvokedUrlCommand*)command{
    NSLog(@"play");
    [audioPlayer fadeInVolume];
}

-(void)fadeOut:(CDVInvokedUrlCommand*)command{
    NSLog(@"play");
    [audioPlayer fadeOutVolume];
}

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

@end
