//
//  PlistToStringsAppDelegate.h
//  PlistToStrings
//
//  Created by Jason Gregori on 11/10/10.
//  Copyright 2010 MySpace, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlistToStringsViewController;

@interface PlistToStringsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PlistToStringsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PlistToStringsViewController *viewController;

@end

