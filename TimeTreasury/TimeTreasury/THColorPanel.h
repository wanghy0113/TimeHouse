//
//  THColorPanel.h
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THColorPanel : NSObject
+(UIColor*)getColorFromCategory:(NSString*)category;
+(UIColor*)getColor:(NSDictionary*)dict;

@end
