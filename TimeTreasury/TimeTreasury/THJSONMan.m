//
//  THJSONMan.m
//  TimeTreasury
//
//  Created by WangHenry on 10/17/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THJSONMan.h"

@implementation THJSONMan

+(NSArray*)getValueForKey:(NSString*)key
{
 
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"JsonDataStore" withExtension:@"json"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSError* error;
    NSDictionary* parsedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"error: %@",error);
    }
    
    return [parsedObject objectForKey:key];

}

+(BOOL)deleteValue:(NSString*)value forKey:(NSString*)key
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"JsonDataStore" withExtension:@"json"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSError* error;
    NSMutableDictionary* parsedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"error: %@",error);
        return false;
    }
    
    NSMutableArray* array = [parsedObject objectForKey:key];
    [array removeObject:value];
    [parsedObject setObject:array forKey:key];
    NSData* modifiedData = [NSJSONSerialization dataWithJSONObject:parsedObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"error: %@",error);
        return false;
    }
    NSLog(@"modified parsedObject:%@", parsedObject);
    [modifiedData writeToURL:url
                     options:NSDataWritingAtomic|NSDataWritingFileProtectionNone
                       error:&error];
    if (error) {
        NSLog(@"error: %@",error);
        return false;
    }
    return true;
}


+(BOOL)AddValue:(NSString*)value forKey:(NSString*)key
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"JsonDataStore" withExtension:@"json"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSError* error;
    NSDictionary* parsedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"error: %@",error);
        return false;
    }
    
    NSMutableArray* array = [parsedObject objectForKey:key];
    [array addObject:value];
    [parsedObject setValue:array forKey:key];
    NSData* modifiedData = [NSJSONSerialization dataWithJSONObject:parsedObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"error: %@",error);
        return false;
    }
    return [modifiedData writeToURL:url atomically:YES];
}
@end
