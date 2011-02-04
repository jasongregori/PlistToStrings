//
//  PlistToStringsViewController.h
//  PlistToStrings
//
//  Created by Jason Gregori on 11/10/10.
//  Copyright 2010 MySpace, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlistToStringsViewController : UIViewController {

}
@property (nonatomic, retain) IBOutlet UITextField *pathField;
@property (nonatomic, retain) IBOutlet UITextField *extField;
@property (nonatomic, retain) IBOutlet UITextField *rename;
@property (nonatomic, retain) IBOutlet UITextField *matches;

- (IBAction)convert;

@end

