//
//  YYText.h
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/2/25.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  控件实现 类似于在 UIKit 里面实现的 UILabel 类似
//  但是在初始化和渲染操作过程中可以支持各种富文本或者图文混排
//
//  富文本是针对于 UILabel | UITextView | UIEditTextView 这些简单设置文本显示
//  图文混排是针对于 图片和文字实现杂乱排序工作 形容来说你中有我我中有你
//
//  只需要弄清楚下面几个问题。
// （1）怎么实现组合 NSAttributeString 字符
// （2）如何计算在生成 CTFrame|CTLine|CTRun 三者之间布局计算
// （3）在添加一些额外的参数例如：Border|Shadow 怎么计算
// （4）是怎么执行进行绘制是：CTFrameDraw|CTLineDraw|CTRunDraw
// （5）在字符中添加 icon | 添加 image 后怎么做处理
//
//


#pragma mark - （1）怎么实现组合 NSAttributeString 字符
/*
 *这个实现在 NSAttributedString+YYText | NSParagraphStyle+YYText 中实现
 *通过分类的形式定义来定义接口实现
 *自定义 KEY 值针对 Value 来实现对应的字典
 *
 *
 *
 *
 *
 **/

#pragma mark - （2）如何计算在生成 CTFrame|CTLine|CTRun 三者之间布局计算
/*
 *这个实现在 YYTextLayout 中实现
 *这里有点小坑，因为在做数据处理计算过程中调用大量的 Frame 中 Line 然后在调用 Run 逐步计算三者在布局上位置
 *最后在每一次遍历的后执行对应的 CTFrameDraw | CTLineDraw | CTRunDraw
 *这个需要做很细查看 TODO TODO
 *
 *
 *
 *
 **/

#pragma mark - （3）在添加一些额外的参数例如：Border|Shadow 怎么计算
/*
 *
 *
 *
 *
 *
 *
 *
 *
 **/

#pragma mark - （4）是怎么执行进行绘制是：CTFrameDraw|CTLineDraw|CTRunDraw
/*
 *这个实现也是在 YYTextLayout 里面进行实现的，通过方法封装 drawInContext 来进行实现
 *在实际的调用是在 YYLabel | YYTextView 中通过 YYTextAsyncLayer 里面的工作类委托协议
 *然后通过当前类的 属性 block 属性来进行方法传递和调用
 *
 *
 *
 *
 *
 **/

#pragma mark - （5）在字符中添加 icon | 添加 image 后怎么做处理
/*
 *这个实现也是在 YYTextLayout 里面进行实现的，通过 drawInContext 判断当前 YYTextAttachment 是否是
 *图片 然后通过使用图片啦
 *
 *
 *
 *
 *
 *
 **/


#import <UIKit/UIKit.h>

//包括当前 <YYText/YYtext.h>

#if __has_include(<YYText/YYText.h>)
FOUNDATION_EXPORT double YYTextVersionNumber;
FOUNDATION_EXPORT const unsigned char YYTextVersionString[];
#import <YYText/YYLabel.h>
#import <YYText/YYTextView.h>
#import <YYText/YYTextAttribute.h>
#import <YYText/YYTextArchiver.h>
#import <YYText/YYTextParser.h>
#import <YYText/YYTextRunDelegate.h>
#import <YYText/YYTextRubyAnnotation.h>
#import <YYText/YYTextLayout.h>
#import <YYText/YYTextLine.h>
#import <YYText/YYTextInput.h>
#import <YYText/YYTextDebugOption.h>
#import <YYText/YYTextKeyboardManager.h>
#import <YYText/YYTextUtilities.h>
#import <YYText/NSAttributedString+YYText.h>
#import <YYText/NSParagraphStyle+YYText.h>
#import <YYText/UIPasteboard+YYText.h>
#else
#import "YYLabel.h"
#import "YYTextView.h"
#import "YYTextAttribute.h"
#import "YYTextArchiver.h"
#import "YYTextParser.h"
#import "YYTextRunDelegate.h"
#import "YYTextRubyAnnotation.h"
#import "YYTextLayout.h"
#import "YYTextLine.h"
#import "YYTextInput.h"
#import "YYTextDebugOption.h"
#import "YYTextKeyboardManager.h"
#import "YYTextUtilities.h"
#import "NSAttributedString+YYText.h"
#import "NSParagraphStyle+YYText.h"
#import "UIPasteboard+YYText.h"
#endif
