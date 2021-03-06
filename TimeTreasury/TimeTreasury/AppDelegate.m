//
//  AppDelegate.m
//  TimeTreasury
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "AppDelegate.h"
#import "THCoreDataManager.h"
#import "Event.h"
#import "EventModel.h"
#import "THDateProcessor.h"
#import "THSettingFacade.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.backgroundColor = [UIColor whiteColor];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* launchBefore = [defaults objectForKey:@"Launchbefore"];
    
    /*
     Now for test
     */
    if (!launchBefore) {
        [THSettingFacade resetSettings];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"Launchbefore"];
    }
    
    
    
    
    //check if events have been added to this time point, if not, add events
   
    NSString* lastDate = (NSString*)[defaults objectForKey:@"lastUpdateDay"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* today = [formatter stringFromDate:[NSDate date]];
    NSDate* todayWithoutTime = [THDateProcessor dateWithoutTime:[NSDate date]];
    if (![lastDate isEqual:today]) {
        //if we should start to add regular events
        THCoreDataManager* dataManager = [THCoreDataManager sharedInstance];
        NSArray* eventArray = [dataManager getEventsByStatus:UNFINISHED];
        if ([eventArray count]>0) {
            for(Event* event in eventArray)
            {
                EventModel* model = event.eventModel;
                if (event.eventDay<todayWithoutTime&&(model.type.integerValue==THDAILYEVENT||model.type.integerValue==THWEEKLYEVENT||model.type.integerValue==THMONTHLYEVENT)) {
                    [dataManager deleteEvent:event];
                }
            }
        }
        
        NSArray* daily = [dataManager getRegularEventsModelByDate:[NSDate date] ofType:THDAILYEVENT];
        eventArray = [daily arrayByAddingObjectsFromArray:[dataManager getRegularEventsModelByDate:[NSDate date] ofType:THWEEKLYEVENT]];
        if ([eventArray count]>0) {
            for(EventModel* eventModel in eventArray)
            {
                NSString* guid = [[NSUUID UUID] UUIDString];
                [dataManager addEventWithGuid:guid withEventModel:eventModel withDay:todayWithoutTime];
            }
        }
        [defaults setObject:today forKey:@"lastUpdateDay"];
        
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //check if events have been added to this time point, if not, add events
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* lastDate = (NSString*)[defaults objectForKey:@"lastUpdateDay"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* today = [formatter stringFromDate:[NSDate date]];
    NSDate* todayWithoutTime = [THDateProcessor dateWithoutTime:[NSDate date]];
    if (![lastDate isEqual:today]) {
        //if we should start to add regular events
        THCoreDataManager* dataManager = [THCoreDataManager sharedInstance];
        NSArray* eventArray = [dataManager getEventsByStatus:UNFINISHED];
        if ([eventArray count]>0) {
            for(Event* event in eventArray)
            {
                EventModel* model = event.eventModel;
                if (event.eventDay<todayWithoutTime&&(model.type.integerValue==THDAILYEVENT||model.type.integerValue==THWEEKLYEVENT||model.type.integerValue==THMONTHLYEVENT)) {
                    [dataManager deleteEvent:event];
                }
            }
        }
        
        NSArray* daily = [dataManager getRegularEventsModelByDate:[NSDate date] ofType:THDAILYEVENT];
        eventArray = [daily arrayByAddingObjectsFromArray:[dataManager getRegularEventsModelByDate:[NSDate date] ofType:THWEEKLYEVENT]];
        if ([eventArray count]>0) {
            for(EventModel* eventModel in eventArray)
            {
                NSString* guid = [[NSUUID UUID] UUIDString];
                [dataManager addEventWithGuid:guid withEventModel:eventModel withDay:todayWithoutTime];
            }
        }
        [defaults setObject:today forKey:@"lastUpdateDay"];
        
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




@end
