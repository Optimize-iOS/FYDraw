//
//  FYImageFormat.h
//  YYTextDemo
//
//  Created by JackJin on 2019/7/16.
//  Copyright © 2019 ibireme. All rights reserved.
//

#ifndef FYImageFormat_h
#define FYImageFormat_h

#endif /* FYImageFormat_h */

/**
 目前常见图片的格式
 静态图片格式：PNG、JPEG、WebP 和 BPG
 动态图片格式：GIF、APNG、WebP 和 BPG
 
 腾讯：TPG
 Apple：HEIF
 
 
 图片格式详解：
 https://blog.ibireme.com/2015/11/02/mobile_image_benchmark/
 
 
 PNG：
 参考地址：
 
 设计主要是用来代替 GIF 格式的图片，所以在设计的机构上和 GIF 差不多。PNG 也只支持无损压缩，在压缩的时候也是存在上限。相对于 JPEG 和 GIF 最大的区别就是支持完全透明通道。
 
 
 
 常用 PNG 使用 SDK：
 libpng
 
 
 JPEG：
 参考地址：
 https://www.cnblogs.com/Arvin-JIN/p/9133745.html
 https://zh.wikipedia.org/wiki/JPEG
 是图片压缩中最为常见的格式，只支持有损压缩来实现，可以实现精确的压缩比。采用以图像质量来换取储存空间的做法，在我们常见的设备上多数支持 CPU 对 JPEG 硬解码和硬编码工作。
 采用有损压缩就意味着对图片一些数据要做额外的抛弃，通过牺牲图片的质量来实现压缩的效果。
 
JPEG 的编码过程可以分为：
 （1）图像分割：图像分割方式方式采用 8*8 的数据分割形式，来单独处理这些小块
 （2）颜色空间转换 RGB -> YCbCr：就是会把当前 image 的图片颜色模型由 RGB 改为 YCbCr 形式来表示
 （3）离散余弦变换：
 （4）数据量化：通过两个标准的量化系数矩阵，来处理转换后的数据模型 YCbCr。把我们生成的 8*8 图片获取的数据来更多生成 0，然后把数据改变为一维数组。
     在此过程中我们可以把量化后矩阵 * 一个系数来控制更多的 0 或者 更少的 0，也就是我们所说的系数。此过程处理后的图片数据是不可逆的。
 （5）哈夫曼编码：哈夫曼编码是所有压缩算法的基础，基本原理是根据数据中元素使用频率，调整元素的编码长度，得到更高的压缩比。
 
 
 常用的 JPEG 使用 SDK:
 libJpeg | openJpeg 
 
 PNG：
 参考地址：
 
 APNG：
 参考地址：
 https://aotu.io/notes/2016/11/07/apng/index.html
 
 
 
 */

