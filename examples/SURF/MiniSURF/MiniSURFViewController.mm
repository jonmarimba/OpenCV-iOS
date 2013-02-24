//
//  MiniSURFViewController.m
//  MiniSURF
//
//  Created by Jonathan Saggau on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MiniSURFViewController.h"
#import "OpenCVUtilities.h"
#import "findObjOpenCV.h"

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/nonfree/nonfree.hpp>

#include <iostream>
#include <vector>

@implementation MiniSURFViewController


- (void)initImages
{
    //TODO: don't use cached UIImages
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    UIImage *img = [UIImage imageNamed:@"IPDCLogo.png"];
    objectToFind = [OpenCVUtilities CreateGRAYIplImageFromUIImage:img];
    
    UIImage *otherImg = [UIImage imageNamed:@"Banner.png"];
    image = [OpenCVUtilities CreateGRAYIplImageFromUIImage:otherImg];
}

- (void)awakeFromNib
{
    [self initImages];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//Magic
- (void)findObject
{
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    cv::initModule_nonfree();
    CvMemStorage* storage = cvCreateMemStorage(0);
    static CvScalar colors[] = 
    {
        {{0,0,255}},
        {{0,128,255}},
        {{0,255,255}},
        {{0,255,0}},
        {{255,128,0}},
        {{255,255,0}},
        {{255,0,0}},
        {{255,0,255}},
        {{255,255,255}}
    };
    if( !objectToFind || !image )
    {
        NSLog(@"Missing object or image");
        return;
    }
    
    CvSize objSize = cvGetSize(objectToFind);
    IplImage* object_color = cvCreateImage(objSize, 8, 3);
    cvCvtColor( objectToFind, object_color, CV_GRAY2BGR );
    
    CvSeq *objectKeypoints = 0, *objectDescriptors = 0;
    CvSeq *imageKeypoints = 0, *imageDescriptors = 0;
    int i;
    CvSURFParams params = cvSURFParams(500, 1);
    
    double tt = (double)cvGetTickCount();
    NSLog(@"Finding object descriptors");
    cvExtractSURF( objectToFind, 0, &objectKeypoints, &objectDescriptors, storage, params );
	
    NSLog(@"Object Descriptors: %d", objectDescriptors->total);
    cvExtractSURF( image, 0, &imageKeypoints, &imageDescriptors, storage, params );
	
    NSLog(@"Image Descriptors: %d", imageDescriptors->total);
    tt = (double)cvGetTickCount() - tt;
	
    NSLog(@"Extraction time = %gms", tt/(cvGetTickFrequency()*1000.));
    CvPoint src_corners[4] = {{0,0}, {objectToFind->width,0}, {objectToFind->width, objectToFind->height}, {0, objectToFind->height}};
    CvPoint dst_corners[4];
	CvSize size = cvSize(image->width > objectToFind->width ? image->width : objectToFind->width,
						 objectToFind->height+image->height);
    output = cvCreateImage(size,  8,  1 );
    cvSetImageROI( output, cvRect( 0, 0, objectToFind->width, objectToFind->height ) );
    cvCopy( objectToFind, output );
	cvResetImageROI( output );
    cvSetImageROI( output, cvRect( 0, objectToFind->height, output->width, output->height ) );
    cvCopy( image, output );
    cvResetImageROI( output );

    NSLog(@"Locating Planar Object");
#ifdef USE_FLANN
 	NSLog(@"Using approximate nearest neighbor search");
#endif
    if( locatePlanarObject( objectKeypoints, objectDescriptors, imageKeypoints,
                           imageDescriptors, src_corners, dst_corners ))
    {
        for( i = 0; i < 4; i++ )
        {
            CvPoint r1 = dst_corners[i%4];
            CvPoint r2 = dst_corners[(i+1)%4];
            cvLine( output, cvPoint(r1.x, r1.y+objectToFind->height ),
                   cvPoint(r2.x, r2.y+objectToFind->height ), colors[8] );
        }
    }
    vector<int> ptpairs;
    NSLog(@"finding Pairs");
#ifdef USE_FLANN
    flannFindPairs( objectKeypoints, objectDescriptors, imageKeypoints, imageDescriptors, ptpairs );
#else
    findPairs( objectKeypoints, objectDescriptors, imageKeypoints, imageDescriptors, ptpairs );
#endif
    for( i = 0; i < (int)ptpairs.size(); i += 2 )
    {
        CvSURFPoint* r1 = (CvSURFPoint*)cvGetSeqElem( objectKeypoints, ptpairs[i] );
        CvSURFPoint* r2 = (CvSURFPoint*)cvGetSeqElem( imageKeypoints, ptpairs[i+1] );
        cvLine( output, cvPointFrom32f(r1->pt),
               cvPoint(cvRound(r2->pt.x), cvRound(r2->pt.y+objectToFind->height)), colors[8] );
    }
    
    NSLog(@"Converting Output");
    UIImage *convertedOutput = [OpenCVUtilities UIImageFromGRAYIplImage:output];

    NSLog(@"Opening Stuff");
    [imageView setImage:convertedOutput];
    cvReleaseImage(&object_color);
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{    
    UIImage *convertedObject = [OpenCVUtilities UIImageFromGRAYIplImage:objectToFind];
    [imageView setImage:convertedObject];
    
    [self performSelector:@selector(findObject) withObject:nil afterDelay:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setImageView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@synthesize imageView;
- (void)dealloc
{
    if (NULL != objectToFind) 
    {
        cvReleaseImage(&objectToFind);
    }
    
    if (NULL != image) 
    {
        cvReleaseImage(&image);
    }
    
    if (NULL != output) 
    {
        cvReleaseImage(&output);
    }
    
    [imageView release];
    [super dealloc];
}

@end
