//
//  MiniSURFViewController.h
//  MiniSURF
//
//  Created by Jonathan Saggau on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniSURFViewController : UIViewController {
    UIImageView *imageView;
    
@private
    IplImage* objectToFind;
    IplImage* image;
    IplImage* output;
}

@property(nonatomic, retain)IBOutlet UIImageView *imageView;

@end
