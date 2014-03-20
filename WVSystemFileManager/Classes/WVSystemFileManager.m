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

NSString* WVFilePropertyURL = @"WVFilePropertyURL";
NSString* WVFilePropertyFilename = @"WVFilePropertyFilename";
NSString* WVFilePropertyDate = @"WVFilePropertyDate";
NSString* WVFilePropertyFileType = @"WVFilePropertyFileType";
NSString* WVFilePropertyFileSize = @"WVFilePropertyFileSize";
NSString* WVFilePropertyTitle = @"WVFilePropertyTitle";
NSString* WVFilePropertyAlbumTitle = @"WVFilePropertyAlbumTitle";
NSString* WVFilePropertyArtist = @"WVFilePropertyArtist";
NSString* WVFilePropertyPersistentID = @"WVFilePropertyPersistentID";


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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        NSMutableArray* files = [NSMutableArray array];
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!group) {
                if (completion) completion(YES, files);
            }
            
            NSMutableDictionary* property = [NSMutableDictionary dictionary];
            [property setAnyValue:[group valueForProperty:ALAssetsGroupPropertyURL] forKey:WVFilePropertyURL];
            [property setAnyValue:[group valueForProperty:ALAssetsGroupPropertyName] forKey:WVFilePropertyFilename];
            [property setAnyValue:[NSNumber numberWithInteger:WVFileTypeGroup] forKey:WVFilePropertyFileType];
            [files addObject:property];
        } failureBlock:^(NSError *error) {
            if (completion) completion(NO, nil);
        }];
    });
}

- (NSDictionary* )propertyForAsset:(ALAsset* )asset {
    NSMutableDictionary* property = nil;
    if (asset) {
        property = [NSMutableDictionary dictionary];
        [property setAnyValue:[asset valueForProperty:ALAssetPropertyAssetURL] forKey:WVFilePropertyURL];
        [property setAnyValue:[[asset defaultRepresentation] filename] forKey:WVFilePropertyFilename];
        [property setAnyValue:[NSNumber numberWithInteger:WVFileTypePicture] forKey:WVFilePropertyFileType];
        [property setAnyValue:[NSNumber numberWithLongLong:[[asset defaultRepresentation] size]] forKey:WVFilePropertyFileSize];
        [property setAnyValue:[asset valueForProperty:ALAssetPropertyDate] forKey:WVFilePropertyDate];
    }
    return property ? [NSDictionary dictionaryWithDictionary:property] : nil;
}

- (void)allPhotos:(WVSystemFileManagerCompletionBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        NSMutableArray* files = [NSMutableArray array];
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!group) {
                if (completion) completion(YES, files);
            }
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                NSDictionary* property = [self propertyForAsset:result];
                if (property) {
                    [files addObject:property];
                }
            }];
            
        } failureBlock:^(NSError *error) {
            if (completion) completion(NO, nil);
        }];
    });
}

- (void)photosInGroup:(NSURL* )url completion:(WVSystemFileManagerCompletionBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        NSMutableArray* files = [NSMutableArray array];
        [library groupForURL:url resultBlock:^(ALAssetsGroup *group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                NSDictionary* property = [self propertyForAsset:result];
                if (property) {
                    [files addObject:property];
                }
            }];
            
            if (completion) completion(YES, files);
        } failureBlock:^(NSError *error) {
            if (completion) completion(NO, nil);
        }];
    });
}

- (NSDictionary* )propertyForMediaItem:(MPMediaItem* )mediaItem fileType:(WVFileType)type {
    NSMutableDictionary* property = nil;
    if (mediaItem) {
        property = [NSMutableDictionary dictionary];
        NSURL* url = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        NSString* extension = [url pathExtension];
        if (NSOrderedSame == [extension compare:@"m4v" options:NSCaseInsensitiveSearch]
            ||NSOrderedSame == [extension compare:@"mp4" options:NSCaseInsensitiveSearch]
            ||NSOrderedSame == [extension compare:@"mov" options:NSCaseInsensitiveSearch]) {
            if (type != WVFileTypeVideo) {
                return nil;
            }
        }
        
        [property setAnyValue:url forKey:WVFilePropertyURL];
        [property setAnyValue:[NSString stringWithFormat:@"%@.%@", [mediaItem valueForProperty: MPMediaItemPropertyTitle], extension] forKey:WVFilePropertyFilename];
        [property setAnyValue:[NSNumber numberWithInteger:type] forKey:WVFilePropertyFileType];
        
        if (type == WVFileTypeMusic) {
            [property setAnyValue:[mediaItem valueForProperty:MPMediaItemPropertyTitle] forKey:WVFilePropertyTitle];
            [property setAnyValue:[mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:WVFilePropertyAlbumTitle];
            [property setAnyValue:[mediaItem valueForProperty:MPMediaItemPropertyArtist] forKey:WVFilePropertyArtist];
            [property setAnyValue:[mediaItem valueForProperty:MPMediaItemPropertyPersistentID] forKey:WVFilePropertyPersistentID];
        }
    }
    return property ? [NSDictionary dictionaryWithDictionary:property] : nil;
}

- (void)allMusic:(WVSystemFileManagerCompletionBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *query = [[MPMediaQuery alloc] init];
        NSMutableArray* files = [NSMutableArray array];
        
        MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeAnyAudio] forProperty:MPMediaItemPropertyMediaType];
        [query addFilterPredicate:predicate];
        for (MPMediaItem *item in query.items) {
            NSDictionary* property = [self propertyForMediaItem:item fileType:WVFileTypeMusic];
            if (property) [files addObject:property];
        }
        
        if (completion) completion(YES, [NSArray arrayWithArray:files]);
    });

}

- (void)allVideos:(WVSystemFileManagerCompletionBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *query = [[MPMediaQuery alloc] init];
        NSMutableArray* files = [NSMutableArray array];

        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeAnyVideo]forProperty:MPMediaItemPropertyMediaType];
        [query addFilterPredicate:predicate];
        
        for (MPMediaItem *item in query.items) {
            NSDictionary* property = [self propertyForMediaItem:item fileType:WVFileTypeVideo];
            if (property) [files addObject:property];
        }
        
        if (completion) completion(YES, [NSArray arrayWithArray:files]);
    });
}

@end

@implementation NSMutableDictionary (WVSystemFileManager)
- (void)setAnyValue:(id)value forKey:(NSString *)key {
    if (value) {
        [self setValue:value forKey:key];
    }
}

@end
