/*
 * Copyright (c) 2013-2016 by appPlant GmbH. All rights reserved.
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

#import "APPAudio.h"

@interface APPAudio ()

// Contains all audio properties specified by the user.
@property(nonatomic, retain) NSDictionary* dict;

@end

@implementation APPAudio

@synthesize dict;

#pragma mark -
#pragma mark Initialization

/**
 * Initialize the object with the given options.
 *
 * @param [ NSDictionary* ] dictionary The properties specified by the user.
 */
- (id) initWithDict:(NSDictionary*)dictionary
{
    self = [self init];

    self.dict = dictionary;

    return self;
}

#pragma mark -
#pragma mark Attributes

/**
 * The tracking ID.
 */
- (NSString*) id
{
    return [dict objectForKey:@"id"];
}

/**
 * The title of the song.
 */
- (NSString*) title
{
    return [dict objectForKey:@"title"];
}

/**
 * The name of the album.
 */
- (NSString*) album
{
    return [dict objectForKey:@"album"];
}

/**
 * The name of the artist.
 */
- (NSString*) artist
{
    return [dict objectForKey:@"artist"];
}

/**
 * An URL (local or remote) where to get the file.
 */
- (NSURL*) file
{
    return [NSURL URLWithString:[dict objectForKey:@"file"]];
}

/**
 * An URL (local or remote) where to get the cover image.
 */
- (NSURL*) cover
{
    return [NSURL URLWithString:[dict objectForKey:@"cover"]];
}

@end
