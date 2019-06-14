//
//  SupportView.m
//  CustomT-shirt
//
//  Created by wangzhaohui on 2019/6/13.
//  Copyright © 2019 wangzhaohui. All rights reserved.
//

#import "SupportView.h"

@implementation SupportView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
    }
    return self;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end
