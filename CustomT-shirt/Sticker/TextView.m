//
//  TextView.m
//  CustomT-shirt
//
//  Created by wangzhaohui on 2019/6/14.
//  Copyright © 2019 wangzhaohui. All rights reserved.
//

#import "TextView.h"
#import "UIView+Category.h"

#define kShadowOffset        CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)
#define FontSize 30

@implementation TextView
{
    UIButton *_deleteButton;
    UIButton *_circleView;
    UIButton *_editorView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    BOOL _isShowToast;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 132, 132)];
    if (self) {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.backgroundColor = [UIColor clearColor];
        _label.minimumScaleFactor = 1/20;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentLeft;
        _label.shadowColor = nil;
        _label.textColor = [UIColor redColor];
        _label.shadowOffset = kShadowOffset;
        [self addSubview:_label];
        
        CGSize size = [_label sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)];
        _label.frame = CGRectMake(5, 5, size.width, size.height);
        self.frame = CGRectMake(0, 0, size.width + 20, size.height +20);
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(0, 0, 20, 20);
        _deleteButton.center = CGPointMake(_label.frame.origin.x, _label.frame.origin.y);
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _circleView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_circleView setImage:[UIImage imageNamed:@"icon_circle"] forState:UIControlStateNormal];
        _circleView.center = CGPointMake(_label.width+_label.left+10, _label.height+_label.top+10);
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_circleView];
        
        _scale = 1;
        _arg = 0;
        
        [self setScale:1];
        [self initGestures];
    }
    return self;
}
- (void)initGestures {
    _label.userInteractionEnabled = YES;
    [_label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_label addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
}
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight
{
    self.transform = CGAffineTransformIdentity;
    _label.transform = CGAffineTransformIdentity;
    
    CGSize size = [_label sizeThatFits:CGSizeMake(width / (15/FontSize), FLT_MAX)];
    _label.frame = CGRectMake(16, 16, size.width, size.height);
    
    CGFloat viewW = (_label.width);
    CGFloat viewH = _label.font.lineHeight;
    
    CGFloat ratio = MIN(width / viewW, lineHeight / viewH);
    [self setScale:ratio];
}

+ (void)setActiveTextView:(nullable TextView*)view
{
    static TextView *activeView = nil;
    if(view != activeView)
    {
        [activeView setAvtive:NO];
        activeView = view;
        [activeView setAvtive:YES];
    }
}
- (void)setAvtive:(BOOL)active
{
    if (_text.length==0)
    {
        _deleteButton.hidden = YES;
        _circleView.hidden = YES;
        _editorView.hidden = YES;
        _label.layer.borderWidth = 0;
    }
    else
    {
        _deleteButton.hidden = !active;
        _circleView.hidden = !active;
        _editorView.hidden = !active;
        _label.layer.borderColor = [UIColor yellowColor].CGColor;
        _label.layer.borderWidth = (active) ? 1/_scale : 0;
    }
}

- (void)setText:(NSString *)text
{
    if(![text isEqualToString:_text])
    {
        _text = text;
        if (_text.length>0)
        {
            _label.text = _text;
        }
    }
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    [[self class] setActiveTextView:self];
    if (_delegate && [_delegate respondsToSelector:@selector(didTouchTextView:)]) {
        [_delegate didTouchTextView:self];
    }
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveTextView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    
    /*
     *限制TextView中心点不能移动超出编辑区域
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
    
    _arg = _initialArg + arg - tmpA;
    [self setScale:MAX(_initialScale * R / tmpR, 15/200.0)];
}
- (void)setScale:(CGFloat)scale
{
    _scale = MIN(scale, scale);
    self.transform = CGAffineTransformIdentity;
    _label.transform = CGAffineTransformMakeScale(scale, scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_label.width)) / 2 -5;
    rct.origin.y += (rct.size.height - (_label.height)) / 2 -5;
    rct.size.width  = _label.width  + 10;
    rct.size.height = _label.height + 10;
    self.frame = rct;
    
    _label.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _label.layer.borderWidth = 1/_scale;
}
- (void)pushedDeleteBtn:(id)sender
{
    TextView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i)
    {
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[TextView class]])
        {
            nextTarget = (TextView*)view;
            break;
        }
    }
    
    if(nextTarget == nil)
    {
        for(NSInteger i=index-1; i>=0; --i)
        {
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[TextView class]])
            {
                nextTarget = (TextView*)view;
                break;
            }
        }
    }
    [[self class] setActiveTextView:nil];
    [self removeFromSuperview];
}
@end
