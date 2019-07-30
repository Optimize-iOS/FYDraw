//
//  LazyScroll.h
//  LazyScrollView
//
//  Copyright (c) 2015-2018 Alibaba. All rights reserved.
//

#ifndef LazyScroll_h
#define LazyScroll_h

#import "TMLazyItemViewProtocol.h"
#import "TMLazyItemModel.h"
#import "TMLazyReusePool.h"
#import "TMLazyModelBucket.h"
#import "UIView+TMLazyScrollView.h"
#import "TMLazyScrollView.h"

#endif /* LazyScroll_h */

/*********************************************************************************************/
 /*    Lazy Scroll View 实现方式，在实现过程中解决什么问题？
  
  (1)怎样实现 View 在 ScrollView 中实现复用；
  (2)这里问一个问题使用 Scroll View 创建展示的 View 当前 View 超出展示 View 时会回收吗？怎么样做到的？
  (3)设置自动添加 View 怎么实现？
  (4)

 
  （1）View 中在实现复用基础是返回 View 使用基础上，尝试从复用池中获取对应的 View，如果不存在就重新创建
  创建在 reusePool 包含字典，然后把当前 identifier 映射保存为 key: values 来保存 mutableset 保存在 view 数据。
  
  
  位置 --> 排序 --> 查找
  显示的 View --> 回收 --> 创建、复用
  
  
  
 */
/*********************************************************************************************/
