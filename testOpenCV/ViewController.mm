//
//  ViewController.m
//  testOpenCV
//
//  Created by ashen on 16/3/9.
//  Copyright © 2016年 Ashen. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import "UubeeCaptureSessionManager.h"
#import <opencv2/videoio/cap_ios.h>

#import "ScanBankCardView.h"

#define cvCopyImage( src, dst )  cvCopy( src, dst, 0 )


@interface ViewController ()<CvVideoCameraDelegate,UubeeCaptureSessionManagerDelegate> {
        cv::Mat cvImage;
}
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic,strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) UIView *bgkView;
@property (nonatomic, strong) UubeeCaptureSessionManager *captureManager;
@property (nonatomic, strong) ScanBankCardView *overLayView;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.captureManager = [[UubeeCaptureSessionManager alloc] init];
    _captureManager.delegate = self;
    
    [_captureManager configureWithParentLayer:self.bgkView previewRect:self.bgkView.bounds FrontCamera:NO ColorFormat:1];
    [_captureManager.session startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgkView  = [[UIView alloc] initWithFrame:self.view.bounds];
    _bgkView.backgroundColor = [UIColor whiteColor];
    self.bgkView.userInteractionEnabled = YES;

    [self.view addSubview:_bgkView];
    
    _overLayView = [[ScanBankCardView alloc] initWithFrame:self.view.bounds];
    _overLayView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_overLayView];
    
    
//    [self test2];
}
- (void)test1 {
        CGRect rect = [UIScreen mainScreen].bounds;
        self.imageView.frame = rect;

    
        UIImage *image = [UIImage imageNamed:@"Z.jpg"];
        // Convert UIImage * to cv::Mat
        UIImageToMat(image, cvImage);
        if (!cvImage.empty()) {
            cv::Mat gray;
            // Convert the image to grayscale;
            cv::cvtColor(cvImage, gray, CV_RGBA2GRAY);
            // Apply Gaussian filter to remove small edges
            cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
            // Calculate edges with Canny
            cv::Mat edges;
            cv::Canny(gray, edges, 0, 60);
            // Fill image with white color
            cvImage.setTo(cv::Scalar::all(255));
            // Change color on edges
            cvImage.setTo(cv::Scalar(0,128,255,255),edges);
            // Convert cv::Mat to UIImage* and show the resulting image
            self.imageView.image = MatToUIImage(cvImage);
        }
}

- (void)test2 {
    
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
//    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    [self.videoCamera start];
    
    //    [self.videoCamera stop];
    
}

- (void)processImage:(cv::Mat &)image
{
//    cv::Mat gray;
//    // Convert the image to grayscale;
//    cv::cvtColor(image, gray, CV_RGBA2GRAY);
//    // Apply Gaussian filter to remove small edges
//    cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
//    // Calculate edges with Canny
//    cv::Mat edges;
//    cv::Canny(gray, edges, 0, 60);
//    // Fill image with white color
//    image.setTo(cv::Scalar::all(255));
//    // Change color on edges
//    image.setTo(cv::Scalar(0,128,255,255),edges);
//    // Convert cv::Mat to UIImage* and show the resulting image
////    self.imageView.image = MatToUIImage(image);
//
    
    
     UIImage * uploadImage = [self compressImage:MatToUIImage(image)];
    
     uploadImage = [self imageFromImage:uploadImage inRect:CGRectMake(90, ((uploadImage.size.height - (uploadImage.size.width - 180) * 53.98 / 85.60)) / 2 - 30,  uploadImage.size.width - 180, (uploadImage.size.width - 180) * 53.98 / 85.60)];
    
    [self test5:uploadImage];
    
    
//    [self test2_1:MatToUIImage(image)];
    
//     UIImageWriteToSavedPhotosAlbum(uploadImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    
}
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

- (UIImage *)compressImage:(UIImage *)imgSrc
{
    CGSize size = CGSizeMake(640, imgSrc.size.height /(imgSrc.size.width / 640 )) ;
    
    UIGraphicsBeginImageContext(size);
    CGRect rect = {{0,0}, size};
    [imgSrc drawInRect:rect];
    UIImage *compressedImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImg;
}


- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
}


int i = 1;
- (void)getImage:(UIImage *)bufferImage {
    
    i++;
//    if (i % 2 == 0) {
    
        //轮廓检测
        cv::Mat iamge;
        UIImageToMat(bufferImage, iamge);
        [self processImage:iamge];

        i = 1;
        //模板匹配
        //[self test2_1:bufferImage];
//    }
}

//模板匹配
- (void)test2_1:(UIImage *)image{
    IplImage    *img;
    IplImage    *tpl;
    IplImage    *res;
    CvPoint        minloc, maxloc;
    double        minval, maxval;
    int            img_width, img_height;
    int            tpl_width, tpl_height;
    int            res_width, res_height;
    
    /* load reference image */
    
//    UIImage *image = [UIImage imageNamed:@"res.png"];
    img = [self convertToIplImage:image];//cvLoadImage("Z.jpg", CV_LOAD_IMAGE_COLOR );
    
    /* always check */
    if( img == 0 ) {
        return;
    }
    
    /* load template image */
    UIImage *image1 = [UIImage imageNamed:@"Z.jpg"];
    tpl = [self convertToIplImage:image1];//cvLoadImage("Z.jpg", CV_LOAD_IMAGE_COLOR );
    
    /* always check */
    if( tpl == 0 ) {
        return;
    }
    
    /* get image's properties */
    img_width  = img->width;
    img_height = img->height;
    tpl_width  = tpl->width;
    tpl_height = tpl->height;
    res_width  = img_width - tpl_width + 1;
    res_height = img_height - tpl_height + 1;
    
    
//    NSLog(@"%d, %d", res_width, res_height);
    
    /* create new image for template matching computation */
    res = cvCreateImage( cvSize( res_width, res_height ), 32, 1 );
    /* choose template matching method to be used */
    cvMatchTemplate( img, tpl, res, CV_TM_SQDIFF);
//    cvNormalize(res, res, 1, 0, CV_MINMAX);
//    float fTemp = 0.0;
//    for (int i=0;i<res->width;i++)
//    {
//        for (int j=0;j<res->height;j++)
//        {
//            fTemp = CV_IMAGE_ELEM(res,float,j,i);  //获得匹配结果的匹配度值
//            if (fTemp >= 1.00) {
//                NSLog(@"OK %.2f", fTemp);
//            }
//        }
//    }
//    
    
    cvMinMaxLoc( res, &minval, &maxval, &minloc, &maxloc);

    NSLog(@"a %.2f, %.2f", minval, maxval);
    
    /* draw red rectangle */
    cvRectangle( img,
                minloc,
                cvPoint( minloc.x + tpl_width, minloc.y + tpl_height ),
                cvScalar(0,0,255));
    
    
//    self.imageView.image = [self convertToUIImage:img];
    if (minval <= 50204540.00) {
        NSLog(@"OK");
        UIImageWriteToSavedPhotosAlbum([self convertToUIImage:img], self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    
    
    /* display images */
    //    cvNamedWindow( "reference", CV_WINDOW_AUTOSIZE );
    //    cvNamedWindow( "template", CV_WINDOW_AUTOSIZE );
    //    cvShowImage( "reference", img );
    //    cvShowImage( "template", tpl );
    
    /* wait until user press a key to exit */
    //    cvWaitKey( 0 );
    
    //    /* free memory */
    //    cvDestroyWindow( "reference" );
    //    cvDestroyWindow( "template" );
    cvReleaseImage( &img );
    cvReleaseImage( &tpl );
    cvReleaseImage( &res );
}




- (void)test3 {
    cv::Mat I;
    
    UIImage *image = [UIImage imageNamed:@"Z.jpg"];
    // Convert UIImage * to cv::Mat
    UIImageToMat(image,I);
    
    cv::cvtColor(I,I,CV_BGR2GRAY);
    
    cv::Mat contours;
    cv::Canny(I,contours,125,350);
    cv::threshold(contours,contours,128,255,cv::THRESH_BINARY);
    
//    cv::namedWindow("Canny");
//    cv::imshow("Canny",contours);
//    cv::waitKey();
    self.imageView.image = MatToUIImage(I);
}

-(IplImage*)convertToIplImage:(UIImage*)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplImage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplImage->imageData, iplImage->width, iplImage->height, iplImage->depth, iplImage->widthStep, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    IplImage *ret = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, ret, CV_RGB2BGR);
    cvReleaseImage(&iplImage);
    return ret;
}
/// IplImage类型转换为UIImage类型
-(UIImage*)convertToUIImage:(IplImage*)image
{
    cvCvtColor(image, image, CV_BGR2RGB);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width, image->height, image->depth, image->depth * image->nChannels, image->widthStep, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}


- (void)openCV {
    
    UIImage *image = [UIImage imageNamed:@"Z.jpg"];
    // Convert UIImage * to cv::Mat
    UIImageToMat(image, cvImage);
    
    IplImage* imgQie=NULL;
    IplImage* imgSrc =  [self convertToIplImage:image]; //cvLoadImage("Z.jpg", CV_LOAD_IMAGE_COLOR);//加载图像

    IplImage* img_gray = cvCreateImage(cvGetSize(imgSrc), IPL_DEPTH_8U, 1);//创建灰度图，定义灰度图
    cvCvtColor(imgSrc, img_gray, CV_BGR2GRAY);//灰度图的转换函数
    cvThreshold(img_gray, img_gray, 50, 255, CV_THRESH_BINARY_INV);// CV_THRESH_BINARY_INV使得背景为黑色，字符为白色，这样找到的最外层才是字符的最外层
    
//    cvShowImage("ThresholdImg", img_gray);//显示灰度图像

    
    CvSeq* contours = NULL;//可增长的序列，不是固定的序列,存储轮廓信息的链表头
    CvSeq* contours1 = NULL;
    CvMemStorage* storage = cvCreateMemStorage(0);//用来创建一个内存存储器，来统一管理各种动态对象的内存
    // 上面源图片有瑕疵可以用腐蚀，膨胀来祛除
    IplImage* imgPeng = cvCreateImage(cvGetSize(imgSrc), IPL_DEPTH_8U, 1);
    IplImage* imgFu = cvCreateImage(cvGetSize(imgSrc), IPL_DEPTH_8U, 1);
    
    cvErode(img_gray, imgFu, NULL, 1);//腐蚀函数
//    cvNamedWindow("腐蚀", CV_WINDOW_AUTOSIZE);
//    cvShowImage("腐蚀", imgFu);
    
    cvDilate(imgFu,imgPeng,NULL,11);
//    cvNamedWindow("膨胀", CV_WINDOW_AUTOSIZE);
//    cvShowImage("膨胀", imgPeng);
    
    int count = cvFindContours(imgPeng, storage, &contours, sizeof(CvContour), CV_RETR_EXTERNAL);//轮廓检验返回的是轮廓的个数
    printf("轮廓个数：%d", count);
    
    int idx = 0;
    char szName[56] = { 0 };
    
    
    int tempCount = 0;
    for (CvSeq* c = contours; c != NULL; c = c->h_next)
    {
        CvRect rc = cvBoundingRect(c, 0);
        
//        if (rc.width/rc.height<=5||rc.height<1||rc.width<1)
//        {
//            continue;     //这里可以根据轮廓的大小进行筛选
//        }
        
        cvDrawRect(imgSrc, cvPoint(rc.x-10, rc.y-3), cvPoint(rc.x + rc.width-6, rc.y + rc.height-3), CV_RGB(255, 0, 0));
        IplImage* imgNo = cvCreateImage(cvSize(rc.width, rc.height), IPL_DEPTH_8U, 3);// //为分割后的单个字符分配一个存储空间
        cvSetImageROI(imgSrc, rc); //基于给定的矩形设置图像的ROI(感兴趣区域)
        cvCopyImage(imgSrc, imgNo);//将ROI复制到imgNo
        cvResetImageROI(imgSrc);//释放基于给定的矩形设置图像的ROI
        sprintf(szName, "wnd_%d", idx++);
//        cvNamedWindow(szName);
//        cvShowImage(szName, imgNo); //如果想切割出来的图像从左到右排序，或从上到下，可以比较rc.x,rc.y;
        
        IplImage* imgQie = imgNo;
        IplImage* imgQiegray = cvCreateImage(cvGetSize(imgQie), IPL_DEPTH_8U, 1);//创建灰度图，定义灰度图
        cvCvtColor(imgQie, imgQiegray, CV_BGR2GRAY);//灰度图的转换函数
        cvThreshold(imgQiegray, imgQiegray, 70, 255, CV_THRESH_BINARY_INV);// CV_THRESH_BINARY_INV使得背景为黑色，字符为白色，这样找到的最外层才是字符的最外层
//        cvShowImage("灰度二", imgQiegray);//显示灰度图像
        
        
        int count1 = cvFindContours(imgQiegray, storage, &contours1, sizeof(CvContour), CV_RETR_EXTERNAL);//轮廓检验返回的是轮廓的个数

        printf("轮廓个数：%d", count1);

        //嵌套在里面再进行处理，在定位出后在处理。
        int idx1 = 0;
        //int i = 0;
        char szName1[56] = { 0 };
        
        
        int i = 0;
        //int a[100];
        CvRect rc1[100],temp;
        int tempCount1 = 0;
        for (CvSeq* c1 = contours1; c1 != NULL; c1 = c1->h_next)
        {
            rc1[i] = cvBoundingRect(c1, 0);//得到所有外部轮廓的
            //a[i] = rc.x;
            i++;
        }
        for (int j = 0; j <19; j++)
        {
            for (i = 0; i<19- j; i++)
                if (rc1[i].x>rc1[i + 1].x)
                {
                    temp = rc1[i];
                    rc1[i] = rc1[i + 1];//由小到小依次排序
                    rc1[i + 1] = temp;
                }
            
            
        }
        
        for (i = 0; i<count1; i++)
        {
            if (rc1[i].width>rc1[i].height)
            {
                continue;     //这里可以根据轮廓的大小进行筛选
            }
            
            cvDrawRect(imgQie, cvPoint(rc1[i].x, rc1[i].y), cvPoint(rc1[i].x + rc1[i].width, rc1[i].y + rc1[i].height), CV_RGB(255, 0, 0));
            IplImage* imgNo1 = cvCreateImage(cvSize(rc1[i].width, rc1[i].height), IPL_DEPTH_8U, 3);// //为分割后的单个字符分配一个存储空间
            cvSetImageROI(imgQie, rc1[i]); //基于给定的矩形设置图像的ROI(感兴趣区域)
            cvCopyImage(imgQie, imgNo1);//将ROI复制到imgNo
            cvResetImageROI(imgQie);//释放基于给定的矩形设置图像的ROI
            
            sprintf(szName1, "wnd_%d", idx1++);
//            cvNamedWindow(szName1);
//            cvShowImage(szName1, imgNo1); //如果想切割出来的图像从左到右排序，或从上到下，可以比较rc.x,rc.y;
//            cvReleaseImage(&imgNo1);
            
        }
//        cvReleaseImage(&imgNo);
        
        
    }
    
//    cvNamedWindow("src");
//    cvShowImage("src", imgSrc);
//    cvWaitKey(0);
//    cvReleaseMemStorage(&storage);
//    cvReleaseImage(&imgSrc);
//    cvReleaseImage(&img_gray);
//    cvReleaseImage(&imgQie);
//    //cvReleaseImage(&imgQiegray);
//    cvDestroyAllWindows();
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test4 {
    cv::Mat src = cv::imread("Z.jpg",CV_BGR2GRAY);
    cv::Mat hsv;
    GaussianBlur(src,hsv,cv::Size(5,5),0,0);
    
    // Quantize the gray scale to 30 levels
    int gbins = 16;
    int histSize[] = {gbins};
    // gray scale varies from 0 to 256
    float granges[] = {0,256};
    const float* ranges[] = { granges };
    cv::MatND hist;
    // we compute the histogram from the 0-th and 1-st channels
    int channels[] = {0};
    
    //calculate hist
    calcHist( &hsv, 1, channels, cv::Mat(), // do not use mask
             hist, 1, histSize, ranges,
             true, // the histogram is uniform
             false );
    //find the max value of hist
    double maxVal=0;
    minMaxLoc(hist, 0, &maxVal, 0, 0);
    
    int scale = 20;
    cv::Mat histImg;
    histImg.create(500,gbins*scale,CV_8UC3);
    
    //show gray scale of hist image
    for(int g=0;g<gbins;g++){
        float binVal = hist.at<float>(g,0);
        int intensity = cvRound(binVal*255);
        rectangle( histImg, cv::Point(g*scale,0),
                  cv::Point((g+1)*scale - 1,binVal/maxVal*400),
                  CV_RGB(0,0,0),
                  CV_FILLED );
    }
    cv::imshow("histImg",histImg);
    
    //threshold processing
    cv::Mat hsvRe;
    threshold( hsv, hsvRe, 64, 255,cv::THRESH_BINARY);
}


int thresh = 50;
IplImage* img = 0;
IplImage* img0 = 0;
CvMemStorage* storage = 0;
CvPoint pt[4];
const char* wndname = "Square Detection Demo";

// helper function:
// finds a cosine of angle between vectors
// from pt0->pt1 and from pt0->pt2
double angle( CvPoint* pt1, CvPoint* pt2, CvPoint* pt0 )
{
    double dx1 = pt1->x - pt0->x;
    double dy1 = pt1->y - pt0->y;
    double dx2 = pt2->x - pt0->x;
    double dy2 = pt2->y - pt0->y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

// returns sequence of squares detected on the image.
// the sequence is stored in the specified memory storage
int findSquares4( IplImage* img, CvMemStorage* storage )
{
    CvSeq* contours;
    int i, c, l, N = 11;
    CvSize sz = cvSize( img->width & -2, img->height & -2 );
    IplImage* timg = cvCloneImage( img ); // make a copy of input image
    IplImage* gray = cvCreateImage( sz, 8, 1 );
    IplImage* pyr = cvCreateImage( cvSize(sz.width/2, sz.height/2), 8, 3 );
    IplImage* tgray;
    CvSeq* result;
    double s, t;
    // create empty sequence that will contain points -
    // 4 points per square (the square's vertices)
    CvSeq* squares = cvCreateSeq( 0, sizeof(CvSeq), sizeof(CvPoint), storage );
    
    // select the maximum ROI in the image
    // with the width and height divisible by 2
    cvSetImageROI( timg, cvRect( 0, 0, sz.width, sz.height ));
    
    // down-scale and upscale the image to filter out the noise
    cvPyrDown( timg, pyr, 7 );
    cvPyrUp( pyr, timg, 7 );
    tgray = cvCreateImage( sz, 8, 1 );
    
//    // find squares in every color plane of the image
    for( c = 0; c < 3; c++ )
    {
//        // extract the c-th color plane
        cvSetImageCOI( timg, c+1 );
        cvCopy( timg, tgray, 0 );
//
        // try several threshold levels
        for( l = 0; l < N; l++ )
        {
            // hack: use Canny instead of zero threshold level.
            // Canny helps to catch squares with gradient shading
            if( l == 0 )
            {
                // apply Canny. Take the upper threshold from slider
                // and set the lower to 0 (which forces edges merging)
                cvCanny( tgray, gray, 0, thresh, 5 );
                // dilate canny output to remove potential
                // holes between edge segments
                cvDilate( gray, gray, 0, 1 );
            }
            else
            {
                // apply threshold if l!=0:
                //     tgray(x,y) = gray(x,y) < (l+1)*255/N ? 255 : 0
                cvThreshold( tgray, gray, (l+1)*255/N, 255, CV_THRESH_BINARY );
            }
            
            
            // find contours and store them all as a list
            cvFindContours( gray, storage, &contours, sizeof(CvContour),
                           CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0) );
            
            // test each contour
            while( contours )
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                
                result = cvApproxPoly( contours, sizeof(CvContour), storage,
                                      CV_POLY_APPROX_DP, cvContourPerimeter(contours)*0.02, 0 );
               
               
                NSLog(@"ashen %d, %.2f", result->total, cvContourArea(result,CV_WHOLE_SEQ));
                
                if( result->total == 4 &&
                   fabs(cvContourArea(result,CV_WHOLE_SEQ)) > 10000 &&
                   cvCheckContourConvexity(result))
                {
                    
                    s = 0;
                    
                    for( i = 2; i < 5; i++ )
                    {
                        
                    t = fabs(angle((CvPoint*)cvGetSeqElem( result, i % 4 ),
                                           (CvPoint*)cvGetSeqElem( result, i-2 ),
                                           (CvPoint*)cvGetSeqElem( result, i-1 )));
                        s = s > t ? s : t;
                    }
                
                    if( s < 0.3) {
                        NSLog(@"getOK");
                        return 1;
                    }
                }
                
                // take the next contour
                contours = contours->h_next;
            }
        }
    }
    
    // release all the temporary images
    cvReleaseImage( &gray );
    cvReleaseImage( &pyr );
    cvReleaseImage( &tgray );
    cvReleaseImage( &timg );
    
    return 0;
}


// the function draws all the squares in the image
void drawSquares( IplImage* img, CvSeq* squares )
{
    CvSeqReader reader;
    IplImage* cpy = cvCloneImage( img );
    int i;
    
    // initialize reader of the sequence
    cvStartReadSeq( squares, &reader, 0 );
    
    // read 4 sequence elements at a time (all vertices of a square)
    for( i = 0; i < squares->total; i += 4 )
    {
        CvPoint* rect = pt;
        int count = 4;
        
        // read 4 vertices
        memcpy( pt, reader.ptr, squares->elem_size );
        CV_NEXT_SEQ_ELEM( squares->elem_size, reader );
        memcpy( pt + 1, reader.ptr, squares->elem_size );
        CV_NEXT_SEQ_ELEM( squares->elem_size, reader );
        memcpy( pt + 2, reader.ptr, squares->elem_size );
        CV_NEXT_SEQ_ELEM( squares->elem_size, reader );
        memcpy( pt + 3, reader.ptr, squares->elem_size );
        CV_NEXT_SEQ_ELEM( squares->elem_size, reader );
        
        // draw the square as a closed polyline
        cvPolyLine( cpy, &rect, &count, 1, 1, CV_RGB(0,255,0), 3, CV_AA, 0 );
    }
    
    // show the resultant image
//    cvShowImage( wndname, cpy );
    cvReleaseImage( &cpy );
}



- (void)test5:(UIImage *)image {

    storage = cvCreateMemStorage(0);
    
//    for (NSString *name in names) {
    
//        UIImage *image = [UIImage imageNamed:name];
        // Convert UIImage * to cv::Mat
        
        img0 = [self convertToIplImage:image]; //cvLoadImage( names[i], 1 );
    
        //        img0 = cvLoadImage([name UTF8String], 1);
        if( !img0 )
        {
//            continue;
        }
        img = cvCloneImage( img0 );
        
        // find and draw the squares
        
    
        
//        self.imageView.image = [self convertToUIImage:img];
  
    if (findSquares4( img, storage )) {
        UIImageWriteToSavedPhotosAlbum([self convertToUIImage:img], self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        
    }
        cvReleaseImage( &img );
        cvReleaseImage( &img0 );
        
        cvClearMemStorage( storage );
        
    
//    }
    

}



//提取轮廓
- (void)test6 {
    IplImage* src = NULL;
    IplImage* img = NULL;
    IplImage* dst = NULL;
    
    CvMemStorage* storage = cvCreateMemStorage (0);;
    CvSeq* contour = 0;
    int contours = 0;
    CvScalar external_color;
    CvScalar hole_color;
    
    UIImage *image = [UIImage imageNamed:@"Z.jpg"];
    
    src = [self convertToIplImage:image];//cvLoadImage ("Z.jpg", 1);
    img = cvCreateImage (cvGetSize(src), IPL_DEPTH_8U, 1);
    dst = cvCreateImage (cvGetSize(src), src->depth, src->nChannels);
    
    cvCvtColor (src, img, CV_BGR2GRAY);
    cvThreshold (img, img, 100, 200, CV_THRESH_BINARY);
    contours = cvFindContours (img, storage, &contour, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    
    for (;contour != 0; contour = contour->h_next)
    {
        external_color = CV_RGB(rand()&255, rand()&255, rand()&255);
        hole_color = CV_RGB(rand()&255, rand()&255, rand()&255);
        cvDrawContours (dst, contour, external_color, hole_color, 1, 2, 8);
    }
    
    
    self.imageView.image = [self convertToUIImage:dst];
    cvReleaseMemStorage (&storage);
    cvReleaseImage (&src);
    cvReleaseImage (&img);
    cvReleaseImage (&dst);
}

@end