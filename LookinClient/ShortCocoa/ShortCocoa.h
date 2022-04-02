//
//  ShortCocoa.h
//  ShortCocoa
//
//  Copyright © 2018 hughkli. All rights reserved.
//

#import "ShortCocoaCore.h"
#import "ShortCocoa+Layout.h"
#import "ShortCocoa+String.h"
#import "ShortCocoa+UIToolkit.h"
#import "ShortCocoa+Others.h"

/**
 快速教程
 
 【attributedString 拼接】
 // 生成一个 NSAttributedString，并且设置 font 为 20 大小的系统字体，设置 foregroundColor 为 rgb(10, 20, 30)
 $(@"abc").font(@20).textColor(@"10, 20, 30").attrString;
 
 // 生成一个 NSMutableAttributedString，并且设置其 font, textColor，lineHeight，然后增加下划线效果(即 NSUnderlineStyleAttributeName)
 $(@"abc").font(UIFontObj).textColor(UIColorObj).lineHeight(22).underline.mAttrString;
 
 // 生成一个包含图片的 NSAttributedString，内容为：@"ca[图片]b"
 $(@"a").addImage(UIImageObj, 0, 1, 2).add(@"b").prepend(@"c").attrString;
 
 // 生成一个 NSAttributedString，内容为：@"a[空白间距]bc[图片]"，其中 @"a"是12号红色字体，@"b"是13号绿色字体，@"c"是14号蓝色字体，然后这个字符串整体行高为 23pt
 $(@"a").textColor(@"red").font(@12)
 .addSpace(5)
 .add($(@"b").textColor(@"green").font(@13))
 .add($(@"c").textColor(@"blue").font(@14))
 .addImage(UIImageObj, 0, 0, 0)
 .lineHeight(23).attrString;
 
 
 【frame 布局】
 // 等价于 view.frame = CGRectMake(30, 40, 10, 20)
 $(view).width(10).height(20).x(30).y(40);
 
 // 调用 sizeToFit，然后在 superview 里垂直居中、y 值设置为 20
 $(view).sizeToFit.horAlign.y(20);
 
 // 把 label 宽度设置为 “button 的宽度值”、把高度设置为”view 的高度值 + 10“、水平移动到 midX 为 30 的位置、在 superview 里垂直居中
 $(label).width(button.$width).height(view.$height + 10).midX(30).verAlign;
 
 // 把 view1、view2、view3 整体在 superview 里水平居中，然后整体移动到距离 superview 底部为 20 的位置
 // tips：你可以像这样同时包装多个对象整体调整，即使其中某个对象为 nil 也无所谓
 $(view1, view2, view3).groupHorAlign.groupBottom(20);
 
 
 【view 操作】
 // 创建一个 UIButton 并设置它的一些属性，最后赋值给 self.button
 self.button = $(UIButton).textColor(@"red").font(@12).text(@"hello").alpha(0.5).addTo(self.view).get;
 
 // 将 label, button, imageView 的 hidden 属性设置为 YES
 $(label, button, imageView).hide;
 
 */


/**
 该框架带来的好处不赘述，该框架可能带来的坏处是：
 1）为了看懂你使用 ShortCocoa 书写的代码，你的同事也必须花时间了解 ShortCocoa 的语法。
 （你可以考虑避免使用某些好用但学习成本较高的方法，比如 heightToFit，或上面的 attributedString 拼接教程中的最后一个例子）
 
 2）为了参数灵活而丢失了编译期类型检查，比如 $(button).textColor(@"red") 方法可以传入 UIColor, @"red", @"#aabbcc" 等各种合法对象，但如果你传入了诸如 UIFont 等错误类型也仍然可以通过编译。
 （Debug 模式下，这些类型错误会在运行时通过 NSAssert 警告你）
 
 3）增加了维护复杂度，比如之前你们可以通过全文搜索 "hidden =" 来快速定位到所有可能更改 hidden 属性的代码，但现在由于多了 $(view).hide 这个语法，仅仅搜索 "hidden =" 就不够了。
 （该框架主要用在“attrString 拼接”、“布局”、“view 操作”三个场景中，你可以避免在 “view 操作” 场景中使用该框架，因为操作 view 的代码本来就不复杂，因此使用该框架带来的效率提升也就不是特别明显。而 attrString 和布局的原生代码很繁琐又往往集中在一处不需全文搜索，因此很适合使用该框架处理）
 */


/**
 可能的命名空间冲突：
 1）该框架默认占用了 $() 这个语法，请确保你的项目中没有别的 #define $(...) 。你也可以更改为其他语法，比如你想用 "ooo(label, button)" 这种语法，那直接把下面 define 里的 "$" 改成 "ooo" 即可
 2）该框架给 UIView/NSView 增加了以下分类方法：$x, $midX, $midY, $y, $midY, $maxY, $width, $height, $size, $bestSize, $bestWidth, $bestHeight，详见 ShortCocoa+Layout.h
 3）该框架给 CALayer 增加了以下分类方法：$x, $midX, $midY, $y, $midY, $maxY, $width, $height, $size, 详见 ShortCocoa+Layout.h
 */
#define $(...) ShortCocoaMake(__VA_ARGS__)
