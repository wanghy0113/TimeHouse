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
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.backgroundColor = [UIColor whiteColor];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL launchBefore = [defaults objectForKey:@"launchBefore"];
    
    /*
     Now for test
     */
    if (!launchBefore) {
        NSDictionary* color0 = @{@"red":@0.816,@"green":@0.816,@"blue":@0.816,@"alpha":@1.0};
        NSDictionary* color1 = @{@"red":@0.878,@"green":@0.341,@"blue":@0.882,@"alpha":@1.0};
        NSDictionary* color2 = @{@"red":@0.0,@"green":@0.902,@"blue":@0.231,@"alpha":@1.0};
        NSDictionary* color3 = @{@"red":@0.0,@"green":@0.667,@"blue":@0.988,@"alpha":@1.0};
        NSDictionary* color4 = @{@"red":@0.941,@"green":@0.745,@"blue":@0.0,@"alpha":@1.0};
        NSDictionary* color5 = @{@"red":@0.655,@"green":@0.518,@"blue":@0.353,@"alpha":@1.0};
        NSDictionary* color6 = @{@"red":@1.0,@"green":@0.0,@"blue":@0.349,@"alpha":@1.0};
        NSDictionary* color7 = @{@"red":@1.0,@"green":@0.647,@"blue":@0.0,@"alpha":@1.0};
        NSDictionary* color8 = @{@"red":@0.690,@"green":@0.910,@"blue":@0.408,@"alpha":@1.0};
        NSArray* colors = [[NSArray alloc] initWithObjects:color0, color1,color2,color3,color4,color5,color6,color7,color8,nil];
        [defaults setObject:colors forKey:@"Colors"];
        
        NSDictionary* categories = @{@"Uncategorized":@0,@"Food":@1,@"Entertainment":@2,@"Work":@3,@"Study":@4,@"Sport":@5,@"Shop":@6,@"Transport":@7};
        [defaults setObject:categories forKey:@"Category"];
        
        
        NSArray* quikstarts = [[NSArray alloc] init];
        [defaults setObject:quikstarts forKey:@"Quickstarts"];
        launchBefore = YES;
    }
    
    
    
    
    //check if events have been added to this time point, if not, add events
   
    NSString* lastDate = (NSString*)[defaults objectForKey:@"lastUpdateDay"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* today = [formatter stringFromDate:[NSDate date]];
    
    if (![lastDate isEqual:today]) {
        //if we should start to add regular events
        THCoreDataManager* dataManager = [THCoreDataManager sharedInstance];
        NSArray* daily = [dataManager getRegularEventsModelByDate:[NSDate date] ofType:THDAILYEVENT];
        NSArray* eventArray = [daily arrayByAddingObjectsFromArray:[dataManager getRegularEventsModelByDate:[NSDate date] ofType:THWEEKLYEVENT]];
        if ([eventArray count]>0) {

        for(EventModel* eventModel in eventArray)
        {
            NSString* guid = [[NSUUID UUID] UUIDString];
            [dataManager addEventWithGuid:guid withEventModel:eventModel withDate:today];
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
    NSString* lastDate = [defaults stringForKey:@"lastUpdateDay"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* today = [formatter stringFromDate:[NSDate date]];
    if (![lastDate isEqual:today]) {
        THCoreDataManager* dataManager = [THCoreDataManager sharedInstance];
        NSArray* daily = [dataManager getRegularEventsModelByDate:[NSDate date] ofType:THDAILYEVENT];
        daily = [daily arrayByAddingObjectsFromArray:[dataManager getRegularEventsModelByDate:[NSDate date] ofType:THWEEKLYEVENT]];
        if ([daily count]>0) {
            for(EventModel* eventModel in daily)
            {
                NSString* guid = [[NSUUID UUID] UUIDString];
                [dataManager addEventWithGuid:guid withEventModel:eventModel withDate:today];
            }
            [defaults setObject:today forKey:@"lastUpdateDay"];
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
