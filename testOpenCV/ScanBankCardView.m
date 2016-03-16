//
//  ScanBankCardView.m
//  uubeeSIV
//
//  Created by ashen on 16/3/3.
//  Copyright © 2016年 ashen. All rights reserved.
//

#import "ScanBankCardView.h"

@implementation ScanBankCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
        _headerView.backgroundColor = [UIColor blackColor];
        [self addSubview:_headerView];
        
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame= CGRectMake(0, 15, 40, 44);
//        [_backBtn setImage:[UIImage sdkImageNamed:@"btn_nav_back"] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 10, 12, 20)];
        [self addSubview:_backBtn];
        
        
        
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashBtn.frame = CGRectMake(self.frame.size.width - 40, 15, 40, 44);
//        [_flashBtn setImage:[UIImage sdkImageNamed:@"iconfont-shanguangdeng"] forState:UIControlStateNormal];
        [_flashBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 10, 8, 10)];
        [self addSubview:_flashBtn];
        
        
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 100 ) / 2, 20, 100, 30)];
        lblTitle.text = @"扫描银行卡";
        lblTitle.font = [UIFont boldSystemFontOfSize:18];
        [lblTitle setTextColor:[UIColor whiteColor]];
        [_headerView addSubview:lblTitle];
        
        
        UIView *cardFrame = [[UIView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height - (self.frame.size.width - 30) * 54 / 85) * 3 / 5 - 60, self.frame.size.width - 30, (self.frame.size.width - 30) * 54 / 85)];
        cardFrame.layer.borderColor = [UIColor whiteColor].CGColor;
        cardFrame.layer.borderWidth = 1.2;
//        cardFrame.layer.cornerRadius = 12;
        [self addSubview:cardFrame];
        
        
        UILabel *lblTips = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(cardFrame.frame) + 10, self.frame.size.width - 30, 30)];
        lblTips.text = @"将银行卡正面置于此区域,并尝试对齐扫描框边缘";
        lblTips.textColor = [UIColor whiteColor];
        lblTips.textAlignment = NSTextAlignmentCenter;
        lblTips.font = [UIFont systemFontOfSize:13];
        [self addSubview:lblTips];
        
        _takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _takePhotoBtn.frame = CGRectMake((self.frame.size.width - 50) / 2,  self.frame.size.height - 110, 50, 50);
//        [_takePhotoBtn setImage:[UIImage sdkImageNamed:@"iconfont-xiangji"] forState:UIControlStateNormal];
        _takePhotoBtn.tintColor = [UIColor whiteColor];
        [self addSubview:_takePhotoBtn];
        
        self.imgV = [[UIImageView alloc] initWithFrame:self.frame];
        _imgV.backgroundColor = [UIColor blackColor];
        _imgV.alpha = 0;
        _imgV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imgV];
        
        
        
        _lblShow = [[UILabel alloc] initWithFrame:CGRectMake(10, self.center.y - 30, self.frame.size.width - 20, 40)];
        _lblShow.textColor = [UIColor whiteColor];
        _lblShow.font = [UIFont boldSystemFontOfSize:24];
        _lblShow.textAlignment = NSTextAlignmentCenter;
        _lblShow.alpha = 0;
        [self addSubview:_lblShow];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,64, self.bounds.size.width, self.bounds.size.height) cornerRadius:0];
    
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(15, (self.frame.size.height - (self.frame.size.width - 30) * 54 / 85) * 3 / 5 - 60, self.frame.size.width - 30, (self.frame.size.width - 30) * 54 / 85) cornerRadius:0];
    
    [path appendPath:framePath];
    [path setUsesEvenOddFillRule:YES];
    
    self.fillLayer = [CAShapeLayer layer];
    
    _fillLayer.path = path.CGPath;
    
    _fillLayer.fillRule =kCAFillRuleEvenOdd;
    
    _fillLayer.fillColor = [UIColor blackColor].CGColor;
    
    _fillLayer.opacity = 0.3;
    
    [self.layer addSublayer:_fillLayer];
}

@end
