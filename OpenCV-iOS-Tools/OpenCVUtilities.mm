//
//  Utilities.m
//  FaceDetect
//
//  Created by Alasdair Allan on 15/12/2009.
//  Copyright 2009 University of Exeter. All rights reserved.
//

#import "OpenCVUtilities.h"
#import "opencv/cv.h"

//experimental NEON assembly greyscale conversion
//#include "neon_convert.h"

static CGColorSpaceRef colorSpace = NULL;
static CGColorSpaceRef gryColorSpace = NULL;

@implementation OpenCVUtilities

#pragma mark Utility Methods

//TODO: remove unnecessary copy
+ (IplImage *)CreateGRAYIplImageFromUIImage:(UIImage *)image {
	IplImage *bgraImage = [[self class] CreateBGRAIplImageFromUIImage:image];
    IplImage *gryImage = cvCreateImage(cvGetSize(bgraImage), IPL_DEPTH_8U, 1);
    cvCvtColor(bgraImage, gryImage, CV_RGBA2GRAY);
    cvReleaseImage(&bgraImage);
    return gryImage;
}

+ (IplImage *)CreateBGRAIplImageFromUIImage:(UIImage *)image {
	CGImageRef imageRef = image.CGImage;
	
	if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            //TODO: Handle the error appropriately.
            return nil;
        }
    }
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 4);
	cvCvtColor(iplimage, ret, CV_RGBA2BGRA);
	cvReleaseImage(&iplimage);
	return ret;
}

+(UIImage *)UIImageFromIplImage:(IplImage *)image bitmapInfo:(CGBitmapInfo)bitmapInfo
{
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            //TODO: Handle the error appropriately.
            return nil;
        }
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              image->imageData, 
                                                              image->imageSize,
                                                              NULL);
    
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, bitmapInfo,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);    
	return ret;
}

+ (UIImage *)UIImageFromRGBIplImage:(IplImage *)rgbImage;
{
    CGBitmapInfo bitmapInfo = kCGImageAlphaNone|kCGBitmapByteOrderDefault;
    return [[self class] UIImageFromIplImage:rgbImage bitmapInfo:bitmapInfo];
}

+ (UIImage *)UIImageFromBGRIplImage:(IplImage *)bgrImage 
{
    CGBitmapInfo bitmapInfo = kCGImageAlphaNone|kCGBitmapByteOrder32Little;
    return [[self class] UIImageFromIplImage:bgrImage bitmapInfo:bitmapInfo];
}

+ (UIImage *)UIImageFromBGRAIplImage:(IplImage *)bgraImage 
{
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst|kCGBitmapByteOrder32Little;
    return [[self class] UIImageFromIplImage:bgraImage bitmapInfo:bitmapInfo];
}

+ (UIImage *)UIImageFromGRAYIplImage:(IplImage *)image
{
	if (gryColorSpace == NULL) {
        gryColorSpace = CGColorSpaceCreateDeviceGray();
        if (gryColorSpace == NULL) {
            //TODO: Handle the error appropriately.
            return nil;
        }
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              image->imageData, 
                                                              image->imageSize,
                                                              NULL);
    
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										gryColorSpace, kCGImageAlphaNone,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);    
	return ret;
}


@end
