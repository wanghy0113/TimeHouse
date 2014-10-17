//
//  THFileManager.m
//  TimeTreasury
//
//  Created by WangHenry on 5/28/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THFileManager.h"

@interface THFileManager()

@end


@implementation THFileManager

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id singleton = nil;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

-(NSString*)getPathWithFileName:(NSString*)fileName
{
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString* path = [url.path stringByAppendingPathComponent:fileName];
    return path;
}

//save image
-(void)saveImage:(UIImage*)image withFileName:(NSString*)name
{
    if (image!=nil) {
        
      //  path = [path stringByAppendingPathComponent:name];
        NSData* data = UIImageJPEGRepresentation(image, 0);
        [data writeToFile:[self getPathWithFileName:name] atomically:YES];
        
    }
}


//load image
-(UIImage*)loadImageWithFileName:(NSString*)name
{
    UIImage* image  = [UIImage imageWithContentsOfFile:[self getPathWithFileName:name]];
    return image;
}

//change a file's name, used when a new audio file is added
-(void)renameFile:(NSString *)oldName withNewName:(NSString *)newName
{
    NSString* oldPath = [self getPathWithFileName:oldName];
    NSString* newPath = [self getPathWithFileName:newName];
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
    NSLog(@"successfully rename file:%@ to filr:%@",oldPath, newPath);
}

-(void)writeContentOfFile:(NSURL*)provider to:(NSURL*)receiver
{
    NSData* data = [NSData dataWithContentsOfURL:provider];
    [data writeToURL:receiver atomically:YES];
}

-(NSURL*)getPhotoURLWithName:(NSString *)name
{
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:name];
    return url;
}

//get the path of an audio with a given name
-(NSURL*)getAudioURLWithName:(NSString *)name
{
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:name];
    return url;
}
@end
