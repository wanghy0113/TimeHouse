//
//  THSettingFacade.h
//  TimeTreasury
//
//  Created by WangHenry on 10/25/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCoreDataManager.h"
@interface THSettingFacade : NSObject

+(UIColor*)categoryColor:(NSInteger)categoryIndex onlyActive:(BOOL)only;

+(void)setCategoryColor:(NSInteger)categoryIndex withColor:(UIColor*)color;

+(NSDictionary*)categoryDictionary:(NSInteger)categoryIndex;

+(NSString*)categoryString:(NSInteger)categoryIndex onlyActive:(BOOL)only;

+(void)setCategoryString:(NSInteger)categoryIndex withString:(NSString*)string;

+(BOOL)categoryIsActive:(NSInteger)categoryIndex;

+(void)setCategoryActive:(NSInteger)categoryIndex withActive:(BOOL)active;

+(NSArray*)getActiveCategories;

+(NSArray*)getInactiveCategories;

+(NSArray*)getAllCategories;

+(BOOL)shouldAlertForEvents;

+(void)setAlertForEvents:(BOOL)should;

@end
