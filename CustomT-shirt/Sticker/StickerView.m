//
//  StickerView.m
//  CustomT-shirt
//
//  Created by wangzhaohui on 2019/6/13.
//  Copyright © 2019 wangzhaohui. All rights reserved.
//

#import "StickerView.h"
#import "UIView+Category.h"

@implementation StickerView
{
    UIButton *_deleteButton;
    UIButton *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width+15, image.size.height+15)];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.layer.allowsEdgeAntialiasing = true;
        _imageView.center = self.center;
        [self addSubview:_imageView];
        
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_deleteButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        _deleteButton.center = CGPointMake(_imageView.frame.origin.x, _imageView.frame.origin.y);
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _circleView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_circleView setImage:[UIImage imageNamed:@"icon_circle"] forState:UIControlStateNormal];
        _circleView.center = CGPointMake(_imageView.width+_imageView.frame.origin.x, _imageView.height+_imageView.frame.origin.y);
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_circleView];
        
        
        _scale = 1;
        _arg = 0;
        
        [self initGestures];
    }
    return self;
}
- (void)initGestures {
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_imageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
}

+ (void)setActiveStickerView:(nullable StickerView*)view;
{
    static StickerView *activeView = nil;
    if(view != activeView)
    {
        [activeView setAvtive:NO];
        activeView = view;
        [activeView setAvtive:YES];
    }
}
- (void)setAvtive:(BOOL)active
{
    _deleteButton.hidden = !active;
    _circleView.hidden = !active;
    
    _imageView.layer.borderColor = [UIColor yellowColor].CGColor;
    _imageView.layer.borderWidth = (active) ? 1/_scale : 0;
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    [[self class] setActiveStickerView:self];
    if (_delegate && [_delegate respondsToSelector:@selector(didTouchStickerView:)]) {
        [_delegate didTouchStickerView:self];
    }
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveStickerView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        _initialPoint = self.center;
    }
    
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    
    /*
     *限制StickerView中心点不能移动超出编辑区域
     */
    if (self.superview.size.width < self.center.x) {
        self.centerX = self.superview.size.width;
    }
    if (self.centerX < 0) {
        self.centerX = 0;
    }
    if (self.superview.size.height < self.center.y) {
        self.centerY = self.superview.size.height;
    }
    if (self.centerY < 0) {
        self.centerY = 0;
    }
}

- (void)circleViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1;
    static CGFloat tmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        tmpR = sqrt(p.x*p.x + p.y*p.y);
        tmpA = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg   = _initialArg + arg - tmpA;
    [self setScale:MIN(_initialScale * R / tmpR, 10)];
}
- (void)setScale:(CGFloat)scale
{
    [self setScale:scale andScaleY:scale];
}
- (void)setScale:(CGFloat)scaleX andScaleY:(CGFloat)scaleY
{
    _scale = MIN(scaleX, scaleY);
    self.transform = CGAffineTransformIdentity;
    _imageView.transform = CGAffineTransformMakeScale(scaleX, scaleY);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_imageView.width)) / 2 - 5;
    rct.origin.y += (rct.size.height - (_imageView.height)) / 2 - 5;
    rct.size.width  = _imageView.width+10;
    rct.size.height = _imageView.height+10;
    self.frame = rct;
    
    _imageView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _imageView.layer.borderWidth = 1/_scale;
}
-(void)pushedDeleteBtn:(id)sender
{
    StickerView *nextTarget = nil;
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i)
    {
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[StickerView class]])
        {
            nextTarget = (StickerView*)view;
            break;
        }
    }
    
    if(nextTarget==nil)
    {
        for(NSInteger i=index-1; i>=0; --i)
        {
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[StickerView class]])
            {
                nextTarget = (StickerView*)view;
                break;
            }
        }
    }
    [[self class] setActiveStickerView:nil];
    [self removeFromSuperview];
}
@end
