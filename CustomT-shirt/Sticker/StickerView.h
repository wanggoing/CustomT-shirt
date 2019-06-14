//
//  StickerView.h
//  CustomT-shirt
//
//  Created by wangzhaohui on 2019/6/13.
//  Copyright © 2019 wangzhaohui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol StickerViewDelegate;
@interface StickerView : UIView

@property (nonatomic, strong)   UIImageView * imageView;

@property (nonatomic, weak) id <StickerViewDelegate> delegate;

- (id)initWithImage:(UIImage *)image;

+ (void)setActiveStickerView:(nullable StickerView*)view;

- (void)setScale:(CGFloat)scale;

@end

@protocol StickerViewDelegate <NSObject>

- (void)didTouchStickerView:(StickerView*)view;

@end

NS_ASSUME_NONNULL_END
