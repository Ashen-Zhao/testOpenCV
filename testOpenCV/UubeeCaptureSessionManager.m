//
//  UubeeCaptureSessionManager.m
//  Facevisa
//
//  Created by cwluo on 15/4/24.
//  Copyright (c) 2015年 facevisa. All rights reserved.
//

#import "UubeeCaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
//#import "UIImage+Resize.h"


@interface UubeeCaptureSessionManager ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) AVCaptureDevice * frontCamera;
@property (nonatomic, strong) AVCaptureDevice * backCamera;
@end

@implementation UubeeCaptureSessionManager

#if !TARGET_OS_SIMULATOR

- (id)init {
    self = [super init];
    if (self != nil) {
        _previewColorFormat = UubeePixelFormatType_32BGRA;
        _preview = [[UIView alloc]init];
    }
    return self;
}

- (void)dealloc {
    [self.session stopRunning];
    self.previewLayer = nil;
    self.session = nil;
    self.inputVideoDevice = nil;
    self.inputCamera = nil;
    self.inputAudioDevice = nil;
    self.stillImageOutput = nil;
    self.videoDataOutput = nil;
}

- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect FrontCamera:(BOOL)front ColorFormat:(int)format{
    self.preview = parent;
    self.previewColorFormat = format;
    
    UITapGestureRecognizer * tapFocus = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchFocus:)];
    tapFocus.numberOfTapsRequired = 1;
    tapFocus.numberOfTouchesRequired = 1;
    [self.preview addGestureRecognizer:tapFocus];
    
    //1、队列
    [self createQueue];
    
    //2、session
    [self addSession];
    
    //3、previewLayer
    [self addVideoPreviewLayerWithRect:preivewRect];
    [parent.layer addSublayer:self.previewLayer];
    
    //4、input
    [self addVideoInputFrontCamera:front];
    
    //5、still image output
    [self addStillImageOutput];
    
    //6. video data output
    [self addVideoDataOutput];
}

- (void)touchFocus:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:self.preview];
    
    [self touchFocusPointOfInterest:touchPoint];
}

- (void)touchFocusPointOfInterest:(CGPoint)point
{
    
    if (self.backCamera.isFocusPointOfInterestSupported &&[self.backCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error = nil;
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [self.backCamera lockForConfiguration:&error];
        if (error == noErr) {
            [self.backCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            [self.backCamera setFocusPointOfInterest:CGPointMake(point.x,point.y)];
        //操作完成后，记得进行unlock。
            [self.backCamera unlockForConfiguration];
        }
    }
}

/**
 *  创建一个队列，防止阻塞主线程
 */
- (void)createQueue {
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
}

/**
 *  session
 */
- (void)addSession {
    AVCaptureSession *tmpSession = [[AVCaptureSession alloc] init];
    self.session = tmpSession;
    //设置质量
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
    }
    else{
        self.session.sessionPreset = AVCaptureSessionPresetMedium;
    }
}

/**
 *  相机的实时预览页面
 *
 *  @param previewRect 预览页面的frame
 */
- (void)addVideoPreviewLayerWithRect:(CGRect)previewRect {
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewRect;
    self.previewLayer = preview;
}

/**
 *  添加输入设备
 *
 *  @param front 前或后摄像头
 */
- (void)addVideoInputFrontCamera:(BOOL)front {
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices) {
        //UubeeDLog(@"Device name: %@", [device localizedName]);
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                //UubeeDLog(@"Device position : back");
                _backCamera = device;
                
                if ([_backCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                    
                    NSError *error = nil;
                    //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
                    [_backCamera lockForConfiguration:&error];
                    [_backCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                    //操作完成后，记得进行unlock。
                    [_backCamera unlockForConfiguration];
                }
                
                if ([_backCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
                    NSError *error = nil;
                    [_backCamera lockForConfiguration:&error];
                    _backCamera.flashMode = AVCaptureTorchModeOff;
                    [_backCamera unlockForConfiguration];
                }
                
                
                
                
                

            }  else {
                //UubeeDLog(@"Device position : front");
                _frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontCamera error:&error];
        if (!error) {
            if ([self.session canAddInput:frontFacingCameraDeviceInput]) {
                [self.session addInput:frontFacingCameraDeviceInput];
                self.inputVideoDevice = frontFacingCameraDeviceInput;
                self.inputCamera = _frontCamera;
            } else {
                //NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_backCamera error:&error];
        if (!error) {
            if ([self.session canAddInput:backFacingCameraDeviceInput]) {
                [self.session addInput:backFacingCameraDeviceInput];
                self.inputVideoDevice = backFacingCameraDeviceInput;
                self.inputCamera = _backCamera;
            } else {
                //NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}

/**
 *  添加输出设备
 */
- (void)addStillImageOutput {
    AVCaptureStillImageOutput *tmpOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];//输出jpeg
    tmpOutput.outputSettings = outputSettings;
    
    if ([self.session canAddOutput:tmpOutput]){
        [self.session addOutput:tmpOutput];
        self.stillImageOutput = tmpOutput;
    }
    else{
        //NSLog(@"Couldn't add still image output");
    }
}

-(void)addVideoDataOutput {
    AVCaptureVideoDataOutput* tmpOutput = [[AVCaptureVideoDataOutput alloc] init];

    dispatch_queue_t queue = dispatch_queue_create("myVideoDataQueue", NULL);
    [tmpOutput setSampleBufferDelegate:self queue:queue];
    switch (self.previewColorFormat)
    {
        case UubeePixelFormatType_420YpCbCr8BiPlanarFullRange:
            tmpOutput.videoSettings = [NSDictionary
                                       dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                             kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                       forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
            break;
        case UubeePixelFormatType_32BGRA:
            tmpOutput.videoSettings = [NSDictionary
                                       dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                             kCVPixelFormatType_32BGRA]
                                       forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
            break;
        default:
            break;
    }
    
    if ([self.session canAddOutput:tmpOutput]) {
        [self.session addOutput:tmpOutput];
        self.videoDataOutput = tmpOutput;
    }
    else{
        //NSLog(@"Couldn't add video data output");
    }
}


#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if ([_delegate respondsToSelector:@selector(getImage:)]) {
        [_delegate getImage:[self imageFromSampleBuffer:sampleBuffer]];
    }
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationDown];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    return image;
}

#pragma mark - actions
/**
 *  拍照
 */
- (void)takePicture:(DidCapturePhotoBlock)block {
    AVCaptureConnection *videoConnection = [self findVideoConnection];
    [videoConnection setVideoScaleAndCropFactor:1.0f];
    
    //NSLog(@"about to request a capture from: %@", _stillImageOutput);
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) {
//            //NSLog(@"attachements: %@", exifAttachments);
        } else {
            //NSLog(@"no attachments");
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        //image = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationUp];
        //UIImage* newImage = [image rotatedByDegrees:90];
        //NSLog(@"originImage:%@", [NSValue valueWithCGSize:image.size]);
        if (block) {
            block(image);
        } else if ([_delegate respondsToSelector:@selector(didCapturePhoto:)]) {
            [_delegate didCapturePhoto:image];
        }
    }];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

/**
 *  切换前后摄像头
 *
 *  @param isFrontCamera YES:前摄像头  NO:后摄像头
 */
- (void)switchCamera:(BOOL)isFrontCamera {
    if (!_inputVideoDevice) {
        return;
    }
    [_session beginConfiguration];
    
    [_session removeInput:_inputVideoDevice];
    
    [self addVideoInputFrontCamera:isFrontCamera];
    
    [_session commitConfiguration];
}

#pragma mark ---------------private--------------
- (AVCaptureConnection*)findVideoConnection {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    return videoConnection;
}
#endif

@end
