//
//  UubeeCaptureSessionManager.h
//  Facevisa
//
//  Created by cwluo on 15/4/24.
//  Copyright (c) 2015年 facevisa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


#define UubeePixelFormatType_32BGRA                        1
#define UubeePixelFormatType_420YpCbCr8BiPlanarFullRange   2

@protocol UubeeCaptureSessionManagerDelegate;

typedef enum tagUubeeCaptureFlashMode{
    UubeeCaptureFlashModeOff  = 0,
    UubeeCaptureFlashModeOn   = 1,
    UubeeCaptureFlashModeAuto = 2
}UubeeCaptureFlashMode;


typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);

@interface UubeeCaptureSessionManager : NSObject
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDevice *inputCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *inputVideoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *inputAudioDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput* videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput* audioDataOutput;
@property (nonatomic, assign) int previewColorFormat;


@property (nonatomic, assign) id <UubeeCaptureSessionManagerDelegate> delegate;



- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect FrontCamera:(BOOL)front ColorFormat:(int)format;

- (void)takePicture:(DidCapturePhotoBlock)block;
- (void)switchCamera:(BOOL)isFrontCamera;
- (void)touchFocusPointOfInterest:(CGPoint)point;
@end


@protocol UubeeCaptureSessionManagerDelegate <NSObject>

@optional
- (void)didCapturePhoto:(UIImage*)stillImage;
- (void)getImage:(UIImage *)bufferImage;
#if !TARGET_OS_SIMULATOR
#endif
@end
