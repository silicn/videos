//
//  ImagePickViewController.m
//  AudioDemo
//
//  Created by silicn on 2019/5/29.
//  Copyright © 2019 SILICN. All rights reserved.
//

#import "ImagePickViewController.h"
#import <AVFoundation/AVFoundation.h>

#define  kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@interface ImagePickViewController ()<AVCapturePhotoCaptureDelegate>

@property (nonatomic , strong)AVCaptureSession *session;

@property (nonatomic, strong)AVCaptureDevice *device;

@property (nonatomic, strong)AVCaptureDeviceInput *videoInput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@property (nonatomic, strong) AVCapturePhotoOutput * photoOutput;

@property (nonatomic ,strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) UIImageView *showImageView;

@property (nonatomic, assign) BOOL isUsingFrontFacingCamera;


@end

@implementation ImagePickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.session = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:&error];
    if (error == nil) {
        
    }
    
    if (@available(iOS 10,*)) {
        self.photoOutput = [AVCapturePhotoOutput new];
        NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
        AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
        [self.photoOutput setPhotoSettingsForSceneMonitoring:settings];
//        [self.photoOutput capturePhotoWithSettings:settings delegate:self];
    }else{
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
    }
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }

    if (@available(iOS 10,*)) {
        if ([self.session canAddOutput:self.photoOutput]) {
            [self.session addOutput:self.photoOutput];
        }
    }else{
        if ([self.session canAddOutput:self.stillImageOutput]) {
            [self.session addOutput:self.stillImageOutput];
        }
    }
    
    
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = CGRectMake(0, 100, kScreenWidth, kScreenWidth);
    self.previewLayer.position = CGPointMake(kScreenWidth/2, kScreenHeight/2);
    
    self.previewLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGFloat centerX = kScreenWidth/2;
    CGSize size = self.view.bounds.size;
    CGPoint center = CGPointMake(kScreenWidth/2, kScreenWidth/2);
    UIBezierPath *bezierpath = [UIBezierPath bezierPath];
    // draw circle
    [bezierpath addArcWithCenter:center
                          radius:kScreenWidth/2 - 20
                      startAngle:0
                        endAngle:M_PI * 2
                       clockwise:YES];
    // draw mask
    [bezierpath addLineToPoint:CGPointMake(centerX, 0)];
    [bezierpath addLineToPoint:CGPointMake(0,0)];
    [bezierpath addLineToPoint:CGPointMake(0, size.height)];
    [bezierpath addLineToPoint:CGPointMake(size.width, size.height)];
    [bezierpath addLineToPoint:CGPointMake(size.width,0)];
    [bezierpath addLineToPoint:CGPointMake(centerX, 0)];
    
    bezierpath.lineWidth = 0.001;
    [bezierpath closePath];
    shapeLayer.path = bezierpath.CGPath;
//    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor whiteColor].CGColor;

   
    
    [self.previewLayer addSublayer:shapeLayer];
    
    [self.view.layer addSublayer:self.previewLayer];
    
    self.isUsingFrontFacingCamera = NO;
    
    [self.session startRunning];
    
    [_device lockForConfiguration:nil];
    
    if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        _device.focusMode = AVCaptureFlashModeAuto;
    }
    [_device unlockForConfiguration];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    btn.frame = CGRectMake(0, 0, 100, 30);
    btn.center = CGPointMake(kScreenWidth/2 - 100, self.view.center.y + 300);
    
    [btn setTitle:@"拍照" forState:UIControlStateNormal];
    
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(photo) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    switchBtn.frame = CGRectMake(0, 0, 100, 30);
    switchBtn.center = CGPointMake(kScreenWidth/2 + 100, self.view.center.y + 300);
    
    [switchBtn setTitle:@"转换" forState:UIControlStateNormal];
    
    [self.view addSubview:switchBtn];
    
    [switchBtn addTarget:self action:@selector(switchPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.showImageView = [[UIImageView alloc]init];
    
    self.showImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
    
    self.showImageView.center = CGPointMake(kScreenWidth/2 , kScreenHeight/2);
    
    [self.view addSubview:self.showImageView];
    
    self.showImageView.hidden  = YES;
    
    
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)checkPersmission{
    AVAuthorizationStatus status  = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        NSLog(@"相机权限没有获取到");
        return NO;
    }else{
        return YES;
    }
}

- (void)switchPhoto
{
    AVCaptureDevicePosition desiredPosition;
    if (self.isUsingFrontFacingCamera){
        desiredPosition = AVCaptureDevicePositionBack;
    }else{
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
    
    self.isUsingFrontFacingCamera = !self.isUsingFrontFacingCamera;


}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光模式和曝光点
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        //设置对焦动画
    }
    
}



- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error  API_AVAILABLE(ios(10.0)){
    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithData:data];
    
    NSLog(@"%@",NSStringFromCGSize(image.size));
    
    UIImage *squareImage = [self cropSquareImage:image];
    
    self.showImageView.image= squareImage;
    self.showImageView.hidden = NO;
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:5.0];
}

- (void)photo {
    
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    if (@available(iOS 10,*)) {
        NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
        AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
        [self.photoOutput capturePhotoWithSettings:settings delegate:self];
    }else{
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:jpegData];
            self.showImageView.hidden = NO;
            self.showImageView.image = image;

            [self performSelector:@selector(dismiss) withObject:nil afterDelay:5.0];

        }];
    }
    
}


- (void)dismiss
{
    self.showImageView.hidden = YES;
}


-(UIImage *)cropSquareImage:(UIImage *)image{
    
    
    image = [self fixOrientationWithImage:image];
    
    CGImageRef sourceImageRef = [image CGImage];//将UIImage转换成CGImageRef
    
    CGFloat _imageWidth = image.size.width * image.scale;
    CGFloat _imageHeight = image.size.height * image.scale;
    CGFloat _width = _imageWidth > _imageHeight ? _imageHeight : _imageWidth;
    CGFloat _offsetX = (_imageWidth - _width) / 2;
    CGFloat _offsetY = (_imageHeight - _width) / 2;
    
    CGRect rect = CGRectMake(_offsetX, _offsetY, _width, _width);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);//按照给定的矩形区域进行剪裁
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    NSLog(@"new = %@   %d",NSStringFromCGSize(newImage.size),newImage.imageOrientation);
    return newImage;
}

- (UIImage *)fixOrientationWithImage:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
