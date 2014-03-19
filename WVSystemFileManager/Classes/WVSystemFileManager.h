
/**
 * WVSystemFileManager.h
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

#import <Foundation/Foundation.h>

enum {
    WVFileTypeUnknown = 0,
    WVFileTypeGroup,
    WVFileTypePicture,
    WVFileTypeVideo,
    WVFileTypeMusic,
    WVFileTypeDocument,
};
typedef NSInteger WVFileType;


/* info keys */
extern NSString* WVFileItemInfoPersistentID;    /* PersistentID of music */
extern NSString* WVFileItemInfoTitleKey;        /* Title of music */
extern NSString* WVFileItemInfoAlbumTitleKey;   /* Album Title of music */
extern NSString* WVFileItemInfoArtistKey;       /* Artist of music */

#pragma mark - WVFileItem
@interface WVFileItem : NSObject {
@private
    NSString*       _url;
    NSString*       _filename;
    NSDate*         _modifyDate;
    WVFileType      _fileType;
    long long       _filesize;
    NSDictionary*   _info;
}

@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* filename;
@property (nonatomic, strong) NSDate* modifyDate;
@property (nonatomic, assign) WVFileType fileType;
@property (nonatomic, assign) long long filesize;
@property (nonatomic, strong) NSDictionary* info;

@end

#pragma mark - WVSystemFileManager
/* result will be the array of WVFileItem */
typedef void(^WVSystemFileManagerCompletionBlock)(BOOL successed, NSArray* result);

@interface WVSystemFileManager : NSObject
+ (id)defaultManager;

- (void)allPhotoGroups:(WVSystemFileManagerCompletionBlock)completion;
- (void)allPhotos:(WVSystemFileManagerCompletionBlock)completion;
- (void)photosInGroup:(WVFileItem* )group completion:(WVSystemFileManagerCompletionBlock)completion;

- (void)allMusic:(WVSystemFileManagerCompletionBlock)completion;
- (void)allVideos:(WVSystemFileManagerCompletionBlock)completion;

@end
