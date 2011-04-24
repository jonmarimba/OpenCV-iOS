//
//  Utilities.h
//  FaceDetect
//
//  Created by Alasdair Allan on 15/12/2009.
//  Copyright 2009 University of Exeter. All rights reserved.
//
//  Much modified by Jonathan Saggau 03/2011

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import "opencv/cv.h"


@interface OpenCVUtilities : NSObject {

}

// These DO copy the image data out of the UIImage.  It's safe to 
// deallocate the UIImage and continue to use the IplImage.
+ (IplImage *)CreateGRAYIplImageFromUIImage:(UIImage *)image;
+ (IplImage *)CreateBGRAIplImageFromUIImage:(UIImage *)image;

// these DO NOT copy the underlying data (for speed), do don't deallocate
// the underlying data (usually the iplImage itself) until you're done with
// the UIImage!
+ (UIImage *)UIImageFromBGRIplImage:(IplImage *)bgrImage;
+ (UIImage *)UIImageFromRGBIplImage:(IplImage *)bgrImage;
+ (UIImage *)UIImageFromBGRAIplImage:(IplImage *)bgraImage;
+ (UIImage *)UIImageFromGRAYIplImage:(IplImage *)grayImage;

@end
