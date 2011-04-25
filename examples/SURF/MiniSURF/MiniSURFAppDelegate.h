//
//  MiniSURFAppDelegate.h
//  MiniSURF
//
//  Created by Jonathan Saggau on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MiniSURFViewController;

@interface MiniSURFAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MiniSURFViewController *viewController;

@end
