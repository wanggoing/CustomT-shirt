//
//  UIImage+Category.h
//  CustomT-shirt
//
//  Created by wangzhaohui on 2019/6/13.
//  Copyright © 2019 wangzhaohui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Category)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color original:(UIImage*)originalImage;

+ (UIImage *)drawMaskImage:(CGSize)contetnSize maskFrame:(CGRect)maskFrame alphaImage:(UIImage*)alphaImage maskImage:(UIImage*)maskImage;

+ (UIImage *)colorImage:(UIImage *)origImage withColor:(UIColor *)color;

+(UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

+ (UIImage*)imageWithUIView:(UIView*)view;
@end

NS_ASSUME_NONNULL_END
