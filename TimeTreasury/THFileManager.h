//
//  THFileManager.h
//  TimeTreasury
//
//  Created by WangHenry on 5/28/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THFileManager : NSObject

+(instancetype)sharedInstance;



-(UIImage*)loadImageWithFileName:(NSString*)name;
-(void)saveImage:(UIImage*)image withFileName:(NSString*)name;
-(void)renameFile:(NSString*)oldName withNewName:(NSString*)newName;
-(NSURL*)getAudioURLWithName:(NSString*)name;
-(BOOL)writeContentOfURL:(NSURL*)provider to:(NSURL*)receiver;
-(NSURL*)getPhotoURLWithName:(NSString*)name;
@end
