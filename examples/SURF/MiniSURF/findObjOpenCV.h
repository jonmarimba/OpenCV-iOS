//
//  findObjOpenCV.h
//  MiniSURF
//
//  Created by Jonathan Saggau on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

using namespace std;

// define whether to use approximate nearest-neighbor search
#define USE_FLANN

double
compareSURFDescriptors( const float* d1, const float* d2, double best, int length );

int
naiveNearestNeighbor( const float* vec, int laplacian,
                     const CvSeq* model_keypoints,
                     const CvSeq* model_descriptors );
void
findPairs( const CvSeq* objectKeypoints, const CvSeq* objectDescriptors,
          const CvSeq* imageKeypoints, const CvSeq* imageDescriptors, vector<int>& ptpairs );

void
flannFindPairs( const CvSeq*, const CvSeq* objectDescriptors,
               const CvSeq*, const CvSeq* imageDescriptors, vector<int>& ptpairs );

/* a rough implementation for object location */
int
locatePlanarObject( const CvSeq* objectKeypoints, const CvSeq* objectDescriptors,
                   const CvSeq* imageKeypoints, const CvSeq* imageDescriptors,
                   const CvPoint src_corners[4], CvPoint dst_corners[4] );