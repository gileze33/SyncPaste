//
//  SPAAppDelegate.m
//  SyncPaste
//
//  Created by Giles Williams on 11/07/2013.
//  Copyright (c) 2013 Giles Williams. All rights reserved.
//

#import "SPAAppDelegate.h"
#import <Dropbox/Dropbox.h>
#import "TestFlight.h"

@implementation SPAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:24/255.0f green:83/255.0f blue:109/255.0f alpha:1.0f]];
    
    [TestFlight takeOff:@"877180c7-5fca-4daa-80fd-b7857065bd62"];
    
    DBAccountManager* accountMgr =
    [[DBAccountManager alloc] initWithAppKey:@"1bk8j66dsextk4j" secret:@"t4bnllw0sso8hq6"];
    [DBAccountManager setSharedManager:accountMgr];
    
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"loginStateChanged"
         object:nil];
        
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
        
        return YES;
    }
    return NO;
}


@end
