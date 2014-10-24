//
//  THCategoryProcessor.h
//  TimeTreasury
//
//  Created by WangHenry on 10/24/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THCategoryProcessor : NSObject

+(UIColor*)categoryColor:(NSInteger)categoryIndex;

+(NSDictionary*)categoryDictionary:(NSInteger)categoryIndex;

+(NSString*)categoryString:(NSInteger)categoryIndex;

+(BOOL)categoryIsActive:(NSInteger)categoryIndex;

+(NSArray*)getActiveCategories;

+(NSArray*)getInactiveCategories;
@end
