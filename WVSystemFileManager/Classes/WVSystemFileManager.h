
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



/* property keys */
extern NSString* WVFilePropertyURL;
extern NSString* WVFilePropertyFilename;
extern NSString* WVFilePropertyDate;
extern NSString* WVFilePropertyFileType;
extern NSString* WVFilePropertyFileSize;

extern NSString* WVFilePropertyTitle;           /* Title of music */
extern NSString* WVFilePropertyAlbumTitle;      /* Album Title of music */
extern NSString* WVFilePropertyArtist;          /* Artist of music */
extern NSString* WVFilePropertyPersistentID;    /* PersistentID of music */

#pragma mark - WVSystemFileManager
typedef void(^WVSystemFileManagerCompletionBlock)(BOOL successed, NSArray* files);

@interface WVSystemFileManager : NSObject
+ (id)defaultManager;

- (void)allPhotoGroups:(WVSystemFileManagerCompletionBlock)completion;
- (void)allPhotos:(WVSystemFileManagerCompletionBlock)completion;
- (void)photosInGroup:(NSURL* )url completion:(WVSystemFileManagerCompletionBlock)completion;

- (void)allMusic:(WVSystemFileManagerCompletionBlock)completion;
- (void)allVideos:(WVSystemFileManagerCompletionBlock)completion;

@end

#pragma mark - 
@interface NSMutableDictionary(WVSystemFileManager)
- (void)setAnyValue:(id)value forKey:(NSString *)key;
@end
