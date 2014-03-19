/**
 * WVSystemFileManager.c
 * Access to system photos, music, videos.
 *
 * MIT licence follows:
 *
 * Copyright (C) 2014 Wenva <lvyexuwenfa100@126.com>
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "WVSystemFileManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

NSString* WVFileItemInfoPersistentID    = @"WVFileItemInfoPersistentID";    /* PersistentID of music */
NSString* WVFileItemInfoTitleKey        = @"WVFileItemInfoTitleKey";        /* Title of music */
NSString* WVFileItemInfoAlbumTitleKey   = @"WVFileItemInfoAlbumTitleKey";   /* Album Title of music */
NSString* WVFileItemInfoArtistKey       = @"WVFileItemInfoArtistKey";       /* Artist of music */


#pragma mark - WVFileItem(implementation)
@implementation WVFileItem

@synthesize url = _url;
@synthesize filename = _filename;
@synthesize modifyDate = _modifyDate;
@synthesize fileType = _fileType;
@synthesize filesize = _filesize;
@synthesize info = _info;

- (NSString* )description {
    return [NSString stringWithFormat:@"FileItem{url:%@, filename:%@, modifyDate:%@, fileType:%d, filesize:%lld}", self.url, self.filename, self.modifyDate, self.fileType, self.filesize];
}
@end

#pragma mark - WVSystemFileManager(implementation)
@implementation WVSystemFileManager
+ (id)defaultManager {
    static WVSystemFileManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WVSystemFileManager alloc] init];
    });
    
    return manager;
}

- (void)allPhotoGroups:(WVSystemFileManagerCompletionBlock)completion {
    
}

- (void)allPhotos:(WVSystemFileManagerCompletionBlock)completion {
    
}

- (void)photosInGroup:(WVFileItem* )group completion:(WVSystemFileManagerCompletionBlock)completion {
}

- (void)allMusic:(WVSystemFileManagerCompletionBlock)completion {
    
    NSMutableArray* result = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *query = [[MPMediaQuery alloc] init];
        
        MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeAnyAudio] forProperty:MPMediaItemPropertyMediaType];
        [query addFilterPredicate:predicate];

            for (MPMediaItem *song in query.items) {
                WVFileItem *item = [[WVFileItem alloc] init];

                NSURL* url = [song valueForProperty:MPMediaItemPropertyAssetURL];
                item.url =[url absoluteString];
                item.filename = [NSString stringWithFormat:@"%@.%@", [song valueForProperty: MPMediaItemPropertyTitle], [url pathExtension]];
                
                item.fileType = WVFileTypeMusic;
                item.modifyDate = [song valueForProperty:MPMediaItemPropertyReleaseDate];
                
                /* Title & Album & Artist & PersistentID */
                NSDictionary* info = [NSMutableDictionary dictionary];
                NSString* title = [song valueForKey:MPMediaItemPropertyTitle];
                if (title) {
                    [info setValue:title forKey:WVFileItemInfoTitleKey];
                }

                NSString* albumTitle = [song valueForKey:MPMediaItemPropertyAlbumTitle];
                if (albumTitle) {
                    [info setValue:albumTitle forKey:WVFileItemInfoAlbumTitleKey];
                }
                
                NSString* artist = [song valueForKey:MPMediaItemPropertyArtist];
                if (artist) {
                    [info setValue:artist forKey:WVFileItemInfoArtistKey];
                }
                
                NSNumber* persistentID = [song valueForKey:MPMediaItemPropertyPersistentID];
                if (persistentID) {
                    [info setValue:persistentID forKey:WVFileItemInfoPersistentID];
                }
                item.info = [NSDictionary dictionaryWithDictionary:info];
                
                [result addObject:item];
            }
        
        if (completion) completion(YES, [NSArray arrayWithArray:result]);
    });

}

- (void)allVideos:(WVSystemFileManagerCompletionBlock)completion {
    NSMutableArray* result = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *localVideo = [[MPMediaQuery alloc] init];

        MPMediaPropertyPredicate *albumNamePredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeAnyVideo]forProperty:MPMediaItemPropertyMediaType];
        [localVideo addFilterPredicate:albumNamePredicate];
        
        NSArray *itemsFromGenericQuery = [localVideo items];
        for (MPMediaItem *video in itemsFromGenericQuery)
        {
            WVFileItem *item = [[WVFileItem alloc] init];

            NSURL* url = [video valueForProperty:MPMediaItemPropertyAssetURL];
            item.url =[url absoluteString];
            item.filename = [NSString stringWithFormat:@"%@.%@", [video valueForProperty: MPMediaItemPropertyTitle], [url pathExtension]];
            item.fileType = WVFileTypeVideo;
            
            NSDictionary* info = [NSMutableDictionary dictionary];
            NSNumber* persistentID = [video valueForKey:MPMediaItemPropertyPersistentID];
            if (persistentID) {
                [info setValue:persistentID forKey:WVFileItemInfoPersistentID];
            }
            item.info = [NSDictionary dictionaryWithDictionary:info];
            
            [result addObject:item];
        }

        if (completion) completion(YES, [NSArray arrayWithArray:result]);

    });

}


@end
