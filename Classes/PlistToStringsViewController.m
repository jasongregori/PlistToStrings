//
//  PlistToStringsViewController.m
//  PlistToStrings
//
//  Created by Jason Gregori on 11/10/10.
//  Copyright 2010 MySpace, Inc. All rights reserved.
//

#import "PlistToStringsViewController.h"

#import <pwd.h>

@implementation PlistToStringsViewController
@synthesize pathField, extField, rename, matches;

- (void)showError:(NSError *)error {
  [[[[UIAlertView alloc] initWithTitle:@"ERROR"
                               message:[error localizedDescription]
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil]
    autorelease]
   show];
}

- (NSString *)sanitizeString:(NSString *)string {
  return [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]
          stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

- (IBAction)convert {
  NSString *path = pathField.text;
  NSString *ext = extField.text;
  NSString *name = ([rename.text length] ? rename.text : nil);
  NSArray *keys = ([self.matches.text length]
                   ? [self.matches.text componentsSeparatedByString:@", "]
                   : nil);
  
  if (keys) {
    // make them all uppercase so case does not matter
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in keys) {
      [array addObject:[key uppercaseString]];
    }
    keys = array;
  }
  
  // Desktop
  NSString *startPath = nil;
#if TARGET_IPHONE_SIMULATOR
  NSString *logname = [NSString stringWithCString:getenv("LOGNAME") encoding:NSUTF8StringEncoding];
	struct passwd *pw = getpwnam([logname UTF8String]);
	NSString *home = pw ? [NSString stringWithCString:pw->pw_dir encoding:NSUTF8StringEncoding] : [@"/Users" stringByAppendingPathComponent:logname];
	startPath = [NSString stringWithFormat:@"%@/Desktop", home];
#else
	startPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
#endif
  NSString *savePath = [[startPath stringByAppendingPathComponent:@"_PlistToStrings"]
                        stringByAppendingPathComponent:[path lastPathComponent]];
  
  // go through each file
  NSError *error;
  NSArray *subPaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:&error];
  if (!subPaths) {
    [self showError:error];
  }
  
  for (NSString *subpath in [subPaths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.lastPathComponent contains[cd] %@", ext]]) {
    //    for (NSString *subpath in [subPaths pathsMatchingExtensions:[NSArray arrayWithObject:ext]]) {
    // change it and save it
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:subpath]];
    NSMutableString *strings = [NSMutableString string];
    
    NSArray *allKeys = [plist allKeys];
    if (keys) {
      allKeys = [allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uppercaseString IN %@", keys]];
    }
    
    for (NSString *key in [allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
      if (!keys || [keys containsObject:key]) {
        // only copy if its matched
        [strings appendFormat:@"\n\"%@\" = \"%@\";\n", [self sanitizeString:key], [self sanitizeString:[plist objectForKey:key]]];
      }
    }
    
    if ([strings length] > 0) {
      // new path
      NSString *newPath = nil;
      
      if (name) {
        newPath = [savePath stringByAppendingPathComponent:
                   [[subpath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.strings", name]]];
      }
      else {
        newPath = [savePath stringByAppendingPathComponent:
                   [[subpath stringByDeletingPathExtension] stringByAppendingPathExtension:@"strings"]];
      }
      
      // make sure the path to this new file exists
      NSError *error;
      if (![[NSFileManager defaultManager] createDirectoryAtPath:[newPath stringByDeletingLastPathComponent]
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error]) {
        [self showError:error];
      }
      
      // save it to the same relative path but in the save path
      if (![strings writeToFile:newPath atomically:YES encoding:NSUTF16StringEncoding error:&error]) {
        [self showError:error];
      }
    }
  }
}

- (void)dealloc {
  self.pathField = nil;
  self.extField = nil;
  self.rename = nil;
  self.matches = nil;
  
  [super dealloc];
}

@end
