//
//  TextView.h
//  CustomT-shirt
//
//  Created by wangzhaohui on 2019/6/14.
//  Copyright © 2019 wangzhaohui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TextViewDelegate;
@interface TextView : UIView

- (id)init;

- (void)setScale:(CGFloat)scale;
+ (void)setActiveTextView:(nullable TextView*)view;
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight;

@property (nonatomic, strong)   UILabel *label;
@property (nonatomic, copy)     NSString *text;

@property (nonatomic, weak) id <TextViewDelegate> delegate;

@end

@protocol TextViewDelegate <NSObject>

- (void)didTouchTextView:(TextView*)view;

@end

NS_ASSUME_NONNULL_END
