//
//  Scan.m
//  DepthRenderer
//
//  Created by Aaron Thompson on 5/14/18.
//  Copyright © 2019 Standard Cyborg. All rights reserved.
//

#import <ModelIO/ModelIO.h>
#import <SceneKit/SceneKit.h>
#import <SSZipArchive/SSZipArchive.h>
#import <StandardCyborgFusion/StandardCyborgFusion.h>
#import <UIKit/UIKit.h>
#import <standard_cyborg/sc3d/ColorImage.hpp>

#import "Scan.h"

@interface Scan ()
// Declared here so the Compression category below can resolve it too.
+ (NSString * _Nullable)_thumbnailPathForPLYPath:(NSString *)plyPath;
@end

@implementation Scan {
    SCNGeometrySource *_vertexSource;
    SCNGeometrySource *_normalSource;
    SCNGeometrySource *_colorSource;
    SCPointCloud *_pointCloud;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    static NSDateFormatter *__datetimeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __datetimeFormatter = [[NSDateFormatter alloc] init];
        __datetimeFormatter.dateFormat = @"yyyy-MM-dd--HH-mm-ss";
    });
    
    return [__datetimeFormatter stringFromDate:date];
}
 
- (instancetype)initWithPointCloud:(SCPointCloud *)pointCloud
                         thumbnail:(UIImage * _Nullable)thumbnail
                         meshTexturing:(id _Nullable)meshTexturing
{
    self = [super init];
    if (self) {
        _pointCloud = pointCloud;
        _thumbnail = thumbnail;
        _dateCreated = [NSDate date];
        
        // Removed meshTexturing assignment - we don't need it anymore
    }
    return self;
}

- (instancetype)initWithPLYPath:(NSString *)path
{
    self = [super init];
    if (self) {
        // Save this off for later lazy loading of data from the PLY file
        _plyPath = path;
        
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        _dateCreated = attributes[NSFileCreationDate];
        
        NSString *thumbnailPath = [[self class] _thumbnailPathForPLYPath:path];
        _thumbnail = [UIImage imageWithContentsOfFile:thumbnailPath];
    }
    return self;
}

- (BOOL)writeToContainerPath:(NSString *)containerPath error:(NSError **)errorOut
{
    BOOL success = YES;
    NSString *plyFilename = [NSString stringWithFormat:@"Scan-%@.ply", [Scan stringFromDate:_dateCreated]];
    NSString *plyPath = [containerPath stringByAppendingPathComponent:plyFilename];
    NSString *jpegPath = [[self class] _thumbnailPathForPLYPath:plyPath];
    
    // Write the 2D image alongside the PLY. A missing thumbnail must not stop the
    // point cloud itself from being saved, which is what used to happen: -writeToFile:
    // on nil data returns NO and took the whole save down with it.
    if (_thumbnail != nil) {
        @autoreleasepool {
            NSData *jpegData = UIImageJPEGRepresentation(_thumbnail, 0.8);
            success = [jpegData writeToFile:jpegPath options:NSDataWritingAtomic error:errorOut];
        }
    }

    if (success) {
        success = [_pointCloud writeToPLYAtPath:plyPath];
    }
    
    if (!success && errorOut != NULL) {
        *errorOut = [NSError errorWithDomain:NSCocoaErrorDomain code:0
                                    userInfo:@{ NSLocalizedDescriptionKey : plyPath }];
    }
    
    if (success) {
        _plyPath = plyPath;
    }
    
    return success;
}

- (BOOL)deleteFilesWithError:(NSError **)errorOut
{
    BOOL success = YES;
    
    if (_plyPath != nil) {
        NSString *thumbnailPath = [[self class] _thumbnailPathForPLYPath:_plyPath];
        success = success && [[NSFileManager defaultManager] removeItemAtPath:_plyPath error:errorOut];
        success = success && [[NSFileManager defaultManager] removeItemAtPath:thumbnailPath error:errorOut];
    }
    
    return success;
}

- (SCPointCloud *)pointCloud
{
    if (_pointCloud == nil) {
        [self _loadDataFromPLY];
    }
    
    return _pointCloud;
}

- (SCNGeometrySource *)vertexSource
{
    if (_vertexSource == nil) {
        _vertexSource = [[self pointCloud] buildVertexGeometrySource];
    }
    
    return _vertexSource;
}

- (SCNGeometrySource *)normalSource
{
    if (_normalSource == nil) {
        _normalSource = [[self pointCloud] buildNormalGeometrySource];
    }
    
    return _normalSource;
}

- (SCNGeometrySource *)colorSource
{
    if (_colorSource == nil) {
        _colorSource = [[self pointCloud] buildColorGeometrySource];
    }
    
    return _colorSource;
}

- (void)_loadDataFromPLY
{
    _pointCloud = [[SCPointCloud alloc] initWithPLYPath:_plyPath normalizeNormals:YES];
}

+ (NSString * _Nullable)_thumbnailPathForPLYPath:(NSString *)plyPath {
    return [plyPath stringByReplacingOccurrencesOfString:@".ply" withString:@".jpeg"];
}

@end

@implementation Scan (Compression)

- (NSURL *)writeCompressedPLY
{
    NSString *plyPath = _plyPath;
    
    // Create a better filename with date and time
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:_dateCreated];
    NSString *fileName = [NSString stringWithFormat:@"RHL_Scan_%@.ply.zip", dateString];
    NSString *zipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    if (plyPath == nil) {
        NSString *tempPLYName = [NSString stringWithFormat:@"RHL_Scan_%@.ply", dateString];
        plyPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempPLYName];
        
        [_pointCloud writeToPLYAtPath:plyPath];
    }

    NSMutableArray<NSString *> *filesToZip = [NSMutableArray arrayWithObject:plyPath];

    // Bundle the 2D image in with the point cloud. A saved scan already has its
    // JPEG on disk next to the PLY; a scan that has not been saved yet needs it
    // written out to the temporary directory first. Both share the PLY's base
    // name, so the two files stay paired inside the zip.
    NSString *jpegPath = [[self class] _thumbnailPathForPLYPath:plyPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (jpegPath != nil) {
        if (![fileManager fileExistsAtPath:jpegPath] && self.thumbnail != nil) {
            @autoreleasepool {
                NSData *jpegData = UIImageJPEGRepresentation(self.thumbnail, 0.8);
                [jpegData writeToFile:jpegPath options:NSDataWritingAtomic error:NULL];
            }
        }

        if ([fileManager fileExistsAtPath:jpegPath]) {
            [filesToZip addObject:jpegPath];
        }
    }

    [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:filesToZip];

    return [NSURL fileURLWithPath:zipPath];
}

- (NSURL *)writeUSDZ
{
    NSURL *USDZURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"Scan.usdz"];
    
    BOOL success = [_pointCloud writeToUSDZAtPath:[USDZURL path]];
    
    return success ? USDZURL : nil;
}

@end
