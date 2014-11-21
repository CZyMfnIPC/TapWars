//
//  P2PTapWarAdvAppDelegate.h
//  P2PTapWarAdv
//
//  Created by Andrew Claus on 6/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class P2PTapWarAdvViewController;

@interface P2PTapWarAdvAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    P2PTapWarAdvViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet P2PTapWarAdvViewController *viewController;

@end

