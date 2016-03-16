//
//  ScanBankCardView.h
//  uubeeSIV
//
//  Created by ashen on 16/3/3.
//  Copyright © 2016年 ashen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanBankCardView : UIView
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *takePhotoBtn;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *lblShow;
@property (nonatomic, strong) CAShapeLayer *fillLayer;
@end
