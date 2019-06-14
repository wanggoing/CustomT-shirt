//
//  ViewController.m
//  CustomT-shirt
//
//  Created by wangzhaohui on 2019/6/13.
//  Copyright © 2019 wangzhaohui. All rights reserved.
//

#import "ViewController.h"
#import "SupportView.h"
#import "UIImage+Category.h"
#import "StickerView.h"
#import "TextView.h"

@interface ViewController ()<StickerViewDelegate, TextViewDelegate>

@property (nonatomic, strong) SupportView *supportView;
@property (nonatomic, strong) UIImageView *bringView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self setTitle:@"T-shirt"];
    [self.supportView.imageView setImage:[UIImage imageNamed:@"timg"]];
    [self.view addSubview:self.supportView];
    [self.view addSubview:self.bringView];
    
    
    CGSize groundSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
    // 1.创建最大宽度透明图片
    UIImage * alphaImage = [UIImage imageWithColor:[UIColor clearColor] size:groundSize];
    // 2.获取蒙版图片 并且使用白色渲染蒙版图片 (使用白色渲染是为了消除蒙版图片的灰度值)
    UIImage * masksImage = [UIImage imageWithColor:[UIColor whiteColor] original:[UIImage imageNamed:@"make"]];
    // 3.将第二步中的图片与第三部中的图片进行合并
    UIImage *ZImage = [UIImage drawMaskImage:groundSize maskFrame:CGRectMake(110, 80, 190,320) alphaImage:alphaImage maskImage:masksImage];
    // 4.背景图片透明区域填充颜色
    self.supportView.imageView.image = [UIImage colorImage:self.supportView.imageView.image withColor:[UIColor whiteColor]];
    // 5.使用新蒙版图与背景图进行蒙层操作 产出蒙层图片
    UIImage *maskedImage = [UIImage maskImage:[UIImage imageWithUIView:self.supportView.imageView] withMask:ZImage];
    // 6.使用蒙层图片
    [self.bringView setImage:maskedImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewTouch)];
    [self.view addGestureRecognizer:tap];
    
    UIButton *addSticker = [UIButton buttonWithType:UIButtonTypeCustom];
    [addSticker setTitle:@"添加贴纸" forState:UIControlStateNormal];
    [addSticker setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addSticker addTarget:self action:@selector(onAddSticker) forControlEvents:UIControlEventTouchUpInside];
    [addSticker.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [addSticker setFrame:CGRectMake(20, self.view.frame.size.width+100, 80, 30)];
    [self.view addSubview:addSticker];
    
    UIButton *addText = [UIButton buttonWithType:UIButtonTypeCustom];
    [addText setTitle:@"添加文字" forState:UIControlStateNormal];
    [addText setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addText addTarget:self action:@selector(onAddText) forControlEvents:UIControlEventTouchUpInside];
    [addText.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [addText setFrame:CGRectMake(120, self.view.frame.size.width+100, 80, 30)];
    [self.view addSubview:addText];
}

- (void)onViewTouch {
    [StickerView setActiveStickerView:nil];
    [TextView setActiveTextView:nil];
}

#pragma mark - delegate
- (void)didTouchStickerView:(StickerView *)view {
    [TextView setActiveTextView:nil];
}
- (void)didTouchTextView:(TextView *)view {
    [StickerView setActiveStickerView:nil];
}

#pragma mark - button click
- (void)onAddSticker {
    StickerView *view = [[StickerView alloc] initWithImage:[UIImage imageNamed:@"sticker"]];
    [view setDelegate:self];
    [view setScale:.2f];
    [StickerView setActiveStickerView:view];
    [view setCenter:self.supportView.center];
    [self.supportView addSubview:view];
}
- (void)onAddText {
    TextView *view = [[TextView alloc] init];
    [view setDelegate:self];
    [view setText:@"定制T-shirt"];
    [TextView setActiveTextView:view];
    [view setCenter:self.supportView.center];
    [view sizeToFitWithMaxWidth:0.3*self.supportView.frame.size.width lineHeight:0.1*self.supportView.frame.size.width];
    [self.supportView addSubview:view];
}

#pragma mark - lazy
- (SupportView *)supportView {
    if (!_supportView) {
        _supportView = [[SupportView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
        _supportView.backgroundColor = [UIColor blackColor];
    }
    return _supportView;
}
- (UIImageView *)bringView {
    if (!_bringView) {
        _bringView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    }
    return _bringView;
}
@end
