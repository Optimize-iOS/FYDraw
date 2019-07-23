//
//  YYTextLine.h
//  YYText <https://github.com/ibireme/YYText>
//
//  Created by ibireme on 15/3/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  CTLine | position | isVertical
//  通过当前绘制 文本帧 Frame 中 每一行 line 以及每一行开始位置 position 来计算当前行位置
//  以及当前 Line 中 run 中是否存在附件 | 获取附件宽高保存

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#if __has_include(<YYText/YYText.h>)
#import <YYText/YYTextAttribute.h>
#else
#import "YYTextAttribute.h"
#endif

@class YYTextRunGlyphRange;

NS_ASSUME_NONNULL_BEGIN

/**
 A text line object wrapped `CTLineRef`, see `YYTextLayout` for more.
 */
@interface YYTextLine : NSObject

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position vertical:(BOOL)isVertical; //垂直

@property (nonatomic) NSUInteger index;     ///< line index
@property (nonatomic) NSUInteger row;       ///< line row
@property (nullable, nonatomic, strong) NSArray<NSArray<YYTextRunGlyphRange *> *> *verticalRotateRange; ///< Run rotate range

//CTLine 在 Core Text 中初始化布局
@property (nonatomic, readonly) CTLineRef CTLine;   ///< CoreText line
@property (nonatomic, readonly) NSRange range;      ///< string range
@property (nonatomic, readonly) BOOL vertical;      ///< vertical form

//当前字体 bounds 一些基本信息
@property (nonatomic, readonly) CGRect bounds;      ///< bounds (ascent + descent)
@property (nonatomic, readonly) CGSize size;        ///< bounds.size
@property (nonatomic, readonly) CGFloat width;      ///< bounds.size.width
@property (nonatomic, readonly) CGFloat height;     ///< bounds.size.height
@property (nonatomic, readonly) CGFloat top;        ///< bounds.origin.y
@property (nonatomic, readonly) CGFloat bottom;     ///< bounds.origin.y + bounds.size.height
@property (nonatomic, readonly) CGFloat left;       ///< bounds.origin.x
@property (nonatomic, readonly) CGFloat right;      ///< bounds.origin.x + bounds.size.width

//字体显示的底部 | 上部 基线 
@property (nonatomic)   CGPoint position;   ///< baseline position
@property (nonatomic, readonly) CGFloat ascent;     ///< line ascent
@property (nonatomic, readonly) CGFloat descent;    ///< line descent
@property (nonatomic, readonly) CGFloat leading;    ///< line leading
@property (nonatomic, readonly) CGFloat lineWidth;  ///< line width
@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;

//保存在 line 中相关信息：附件、附件范围和附件矩形
@property (nullable, nonatomic, readonly) NSArray<YYTextAttachment *> *attachments; ///< YYTextAttachment
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRanges;     ///< NSRange(NSValue)
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRects;      ///< CGRect(NSValue)

@end


typedef NS_ENUM(NSUInteger, YYTextRunGlyphDrawMode) {
    /// No rotate.
    YYTextRunGlyphDrawModeHorizontal = 0,
    
    /// Rotate vertical for single glyph.
    YYTextRunGlyphDrawModeVerticalRotate = 1,
    
    /// Rotate vertical for single glyph, and move the glyph to a better position,
    /// such as fullwidth punctuation.
    YYTextRunGlyphDrawModeVerticalRotateMove = 2,
};

/**
 A range in CTRun, used for vertical form.
 CTRun 中 Range 用来垂直形状
 */
@interface YYTextRunGlyphRange : NSObject
@property (nonatomic) NSRange glyphRangeInRun;
@property (nonatomic) YYTextRunGlyphDrawMode drawMode;
+ (instancetype)rangeWithRange:(NSRange)range drawMode:(YYTextRunGlyphDrawMode)mode;
@end

NS_ASSUME_NONNULL_END
