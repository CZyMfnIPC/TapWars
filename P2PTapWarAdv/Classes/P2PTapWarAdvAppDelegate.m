//
//  P2PTapWarAdvAppDelegate.m
//  P2PTapWarAdv
//
//  Created by Andrew Claus on 6/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "P2PTapWarAdvAppDelegate.h"
#import "P2PTapWarAdvViewController.h"

@implementation P2PTapWarAdvAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
