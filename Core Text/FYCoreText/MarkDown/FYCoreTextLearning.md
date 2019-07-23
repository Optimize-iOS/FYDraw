#  iOS 优化 - Core Text 

iOS 在富文本进行复杂的排版实现，可以使用 Core Text 来实现图片，链接点击效果。在 Core Text 和 UIWebView 相比，Core Text 是在后台渲染，占用的内存更小的特点。


Core Text  是基于在处理文字和文字的底层的技术实现，

Quartz 可以直接实现处理字体和字形，将文字渲染到界面上，也是基础库中唯一一个可以处理字体的模块。
因此在实现排版的过程中 Core Text 需要把显示文本内容，位置，字体，字形直接上传给 Quartz。相比于其他的控件，Core Text 直接与 Quartz 进行交互所以显示加载的速度会更快速。


这里有个问题就是在使用 Core Text 显示控件的时候，Core Text 在实际架构中具体显示位置？
（1）Core Graphics 是什么关系？
（2）对于上层和 UILabel，UITextView 和 UITextField 又是什么关系呢？


## Core Text VS UIWebView 

（1）Core Text 占用内存更少，渲染更快  
为什么 占用内存较少，渲染更快呢？这样产生的原因是什么？有什么机制可以证明。

（2）Core Text 在执行渲染前就可以获取当前显示内容的高度，通过 CTFrame，UIWebView 实现渲染实现之后获取到
CTFrame 是什么？在 Core Text 中起到什么作用？
UIWebView 是怎么获取高度的？而且是怎么和 iOS 原生框架进行交互的？

（3）Core Text 的 CTFrame 可以在后台线程渲染，UIWebVie 只能在主线程渲染。
CTFrame 为什么可以支持在后台渲染，怎么实现？
ASDK 在后台渲染的机制是怎么实现的？

（4）Core Text 可以实现很好的交互效果，但是 UIWebView 在实现交互就需要 Javascript 来实现，在交互中存在卡顿。

YYKit 为什么会比目前仅仅对 Core Text 封装实现的效果更好？？



// FYCoreText 排版引擎

FYDisplayView 中的方法可以进行进行拆分：
（1）显示用的类：只作为显示的内容不做为他的事情；CTDisplayView 
（2）一个模型类：承载显示的数据                       //CTTextData
（3）一个排版类：实现文字内容的排版                         CTFrameParser
（4）一个配置类：实现排版时可以配置的项                  CTFrameParserConfig

排版引擎在获取字符串流的情况下来通过基本设置，NSString 字符来生成对应的 NSAttributeString 再生成对用的 CTFramesetter，在通过 CTFramesetter 这个基本设置生成对应的 CTFrame 然后通过绘制显示在 DisplayView 上重新 Draw 绘制。

CTFrame 是设置在绘制时显示的画布，表示在当前富文本绘制显示 Size 大小内容区域；
CTLine 表示在绘制显示中一行的内容；
CTRun 表示在当前行中块的概念，这个区分化块的行为是根据设置 NSAttributes 字体设置的格式来进行决定的。
虽然我们不能手动创建 CTRun 的过程，但是可以通过 CTRunDelegate 来进行设置该块在绘制时高度、宽度排列对其样式的基本信息！！！


参考地址：https://juejin.im/entry/57ce6d5767f3560057b3002c

在绘制过程中需要了解当前图片占用宽高；
CFFrame：可以当做画布，画布范围是由 CGPath 来决定的；
CTLine：是组成 CFFrame 的基础部件，CTLine 表示是一行，这个基础部件由 CTRun 组合而成的；
CTRun：是组成 CTLine 的最小结构，每个 CTRun 可以看做是一个块，不需要自己手动创建，是由 NSAttributedString 属性来决定，系统自动生成的。每一个 CTRun 对应的属性是不同的。

CTFramesetter：是一个工厂，创建 CTFrame，在同一个界面上可以包含多个 CTFrame。

线的种类：
在绘制显示线的基础上线可以分为一下几种：基准线、小写线、大写线、上缘线和下缘线。

> 文字样式很多，每一个字符显示都可以归功于字体，字体显示过程中有很多的基础知识。
例如：磅值、样式、基线、连字等等 ......


UITextFiled :

UITextView : 大量的文本




