//
//  THJSONMan.h
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THJSONMan : UIView

+(NSArray*)getValueForKey:(NSString*)key;

+(BOOL)deleteValue:(NSString*)value forKey:(NSString*)key;




@end
