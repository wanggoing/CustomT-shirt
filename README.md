#### 高仿美图定制，先看效果

![t-shirt.gif](https://upload-images.jianshu.io/upload_images/2105719-ae05b54a6369909c.gif?imageMogr2/auto-orient/strip)

#### 思路

###### 1.以下图像按顺序称为A、B两个图像。

|                              A                               |                              B                               |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![timg.png](https://upload-images.jianshu.io/upload_images/2105719-416816ea3a7c9a0f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) | ![make.png](https://upload-images.jianshu.io/upload_images/2105719-e85a035028e1d95c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) |
###### 2.将B图像按照合适的位置及大小，放在A图像之上，结果如下

![c.png](https://upload-images.jianshu.io/upload_images/2105719-38313848f3a86ad1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###### 3.取两个图像的交集部分

![s.png](https://upload-images.jianshu.io/upload_images/2105719-7b3fcdbeb192226c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###### 4.将交集部分颜色改为透明。形成一张根据B图像形状信息改变A图像相应颜色通道信息的新图像。

#### 代码片段：

>创建```UIScrollView```子类，这将是最终贴纸、文字部分内容的显示区域。在```UIScrollView```中创建一个```UIImageView```作为T-shirt的背景图像显示。

>1.创建一张与```UIScrollView```子类大小相同的图像。
```
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height); //宽高 1.0只要有值就够了
UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
CGContextRef context = UIGraphicsGetCurrentContext();

CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
CGContextFillRect(context, rect);//用这个颜色填充这个上下文

UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
UIGraphicsEndImageContext();

return image;
}
```
>2.将蒙版图像(上文中B图像)使用白色渲染一次(消除蒙版图片的灰度值)
```
+ (UIImage *)imageWithColor:(UIColor *)color original:(UIImage*)originalImage
{
UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
CGContextRef context = UIGraphicsGetCurrentContext();
CGContextTranslateCTM(context, 0, originalImage.size.height);
CGContextScaleCTM(context, 1.0, -1.0);
CGContextSetBlendMode(context, kCGBlendModeNormal);
CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
CGContextClipToMask(context, rect, originalImage.CGImage);
[color setFill];
CGContextFillRect(context, rect);
UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
return newImage;
}
```
>3.背景图片透明区域填充颜色
```
+ (UIImage *)colorImage:(UIImage *)origImage withColor:(UIColor *)color
{
UIGraphicsBeginImageContextWithOptions(origImage.size, YES, 0);
CGContextRef context = UIGraphicsGetCurrentContext();

CGContextSetFillColorWithColor(context, [color CGColor]);
CGContextFillRect(context, (CGRect){ {0,0}, origImage.size} );

CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, origImage.size.height);
CGContextConcatCTM(context, flipVertical);
CGContextDrawImage(context, (CGRect){ {0,0}, origImage.size }, [origImage CGImage]);

UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();

return image;
}
```
>4.使用新蒙版图与背景图进行蒙层操作 产出蒙层图片
```
+(UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
CGImageRef maskRef = maskImage.CGImage;
CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
CGImageGetHeight(maskRef),
CGImageGetBitsPerComponent(maskRef),
CGImageGetBitsPerPixel(maskRef),
CGImageGetBytesPerRow(maskRef),
CGImageGetDataProvider(maskRef), NULL, false);

CGImageRef sourceImage = [image CGImage];
CGImageRef imageWithAlpha = sourceImage;
//add alpha channel for images that don't have one (ie GIF, JPEG, etc...)
//this however has a computational cost
if (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNone) {
//        imageWithAlpha = CopyImageAndAddAlphaChannel(sourceImage);
}

CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);

CGImageRelease(mask);

//release imageWithAlpha if it was created by CopyImageAndAddAlphaChannel
if (sourceImage != imageWithAlpha) {
CGImageRelease(imageWithAlpha);
}

UIImage* retImage = [UIImage imageWithCGImage:masked];
CGImageRelease(masked);

return retImage;
}
```
#### 原理

- 使用上下文```CGContextRef```对象创建与```背景图像(T-shirt)```大小相同的```全透明图像```
- 使用白色渲染```蒙版图像```
- 将```蒙版图像```根据```CGRect```信息放入```全透明图像```的合适位置合成一张与```背景图像(T-shirt)```大小相同的```新图像```
- 将```背景图像(T-shirt)```与上步中产出的```新图像```取交集，生成最终使用的```蒙层图像```
- 将```蒙层图像```加载在```背景图像(T-shirt)```之上，因为```蒙层图像```边缘透明指定定区域透明，所以在视觉显示效果上，T-shirt还是以完整状态显示，在```蒙层图像```与```背景图像(T-shirt)```之间添加贴纸对象与文字对象时，就可以实现不规则蒙层遮挡。达到在指定区域绘制T-shirt的目的。
通过截面GIF看一下

![section.gif](https://upload-images.jianshu.io/upload_images/2105719-5829fd77d4d2ac4f.gif?imageMogr2/auto-orient/strip)

###### ~~通过PS制作一张中间透明的T-shirt的图片放在背景T-shirt之上也能达到相同的效果，至于我为什么这么做，额...~~

###### ~~假设一件T-shirt有10种颜色，每种颜色都要P一次...~~
