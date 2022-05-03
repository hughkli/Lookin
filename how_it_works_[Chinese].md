# Lookin 原理及 5 个开发难点

Lookin 是一款 iOS 开发时常用的调试软件。

作为作者，本文将首次介绍它的运作原理、5 个开发难点及解决方案。

如果你要做类似的调试软件，本文可能会帮你少踩一些坑。

桌面端代码：https://github.com/hughkli/Lookin
iOS 端代码：https://github.com/QMUI/LookinServer

![](https://cdnfile.lookin.work/static_images/doc0412/doc_1.png)

## 竞品对比
![](https://cdnfile.lookin.work/static_images/doc0412/doc_2.png)

抛开不太好用的 Xcode UI Inspector 不谈，它的主要竞品是国外收费的 Reveal。

概括来说，二者在刷新速度等性能方面差异不大，但 Reveal 作为收费、成熟的商业团队产品，功能更全更稳定，文档完善，且有着很好的迭代节奏。

而 Lookin 功能较少、迭代较慢，尤其在布局约束调试方面很弱，但有着免费开源的优点，且不乏测距、变量名显示等小的亮点功能。

更多细节对比可以参阅一篇网友文章： 《A Side-By-Side Comparison of Two Great iOS Views Debugging Tools》：https://betterprogramming.pub/a-side-by-side-comparison-of-two-great-ios-views-debugging-tools-85fefbf69881
![](https://cdnfile.lookin.work/static_images/doc0412/doc_3.png)

## 主要原理
![](https://cdnfile.lookin.work/static_images/doc0412/doc_4.png)

当你在 macOS 端点击“刷新”时，大概会发生以下过程：

* 你需要先在你的 iOS 项目中集成 LookinServer 这个 framework，然后它可以和 LookinClient 收发数据
* 先通过 Ping/Pong 确认 iOS 端没有处于后台、断点等无法响应的情况
* Server 端收到 Hierarchy 请求后，遍历所有 View，然后把信息打包发给 Client 端，Client 端重新组装为图层树
* Server 端陆续收集每一个 View 的截图、属性列表，然后先后打包发送给 Client 端，以供 Client 端渲染出更详细的数据，这个过程可能长达 3 ～ 10 秒
* Client 端会把“当前用户正在操作哪些 views”的信息不断告知 Server 端，Server 端会据此调整当前打包任务的优先级，以求优先打包收集那些用户关注的 View 信息

以上就是原理了，总结来说非常简单，就是典型的 C/S 架构：Client 端请求需要的信息，Server 端通过 Runtime 接口拿到数据后，打包发回给 Client 端就好了。

但要把实际产品落地的话，还有很多的细节问题要处理，下面会罗列出当时花了不少时间去尝试解决的问题。

## 困难点

### iOS 程序员如何学习写 macOS 程序？
这似乎不是个值得讨论的“技术问题”，但实际上，这恰恰是最现实、最花时间的问题，主要是两个痛苦点：
* 和年轻的 UIKit 比起来，AppKit 的历史包袱很重，很多 API 非常晦涩难用
* 由于从业者少，macOS 的开发资料极少，遇到 Bug 之类的完全搜不出来，要自己踩坑

当时的我可能花了 150 个小时在这方面。

### 如何在 macOS 和 iOS 之间传输数据？

当时觉得这个问题非常底层非常 geek，但后来惊喜地发现其实有大量的第三方库可以直接使用，比如：Peertalk、CocoaAsyncSocket、GCDWebServer、MultipeerConnectivity……

由于时间关系，当时只尝试了 Peertalk，因此我无法比较它们的优劣。

但 Peertalk 只能帮你单向传输数据而不保证送达，就像 UDP 一样。比如 Server 端处于后台、主线程卡住等情况就收不到数据。因此你需要在它的基础上封装一层类似 HTTP 风格的接口出来，还要处理 timeout、多台 iOS 设备同时连接、双端版本校验、断链重试、一个请求多个回复等各种细节。

我在解决了上述部分细节问题后，把通讯部分独立出了一个组件：https://github.com/hughkli/KKConnector

### 如何正确渲染展开/折叠图像？
![](https://cdnfile.lookin.work/static_images/doc0412/doc_5.png)

如上图，我们在展开/折叠图层时，图像会跟随变化，直觉上很自然，但这个“变化”的规则到底是什么呢？
 
最初的错误想法是：给每个 View 都截一张图片，那么“展开/折叠”就是改变这个图片的 Z-Index。换句话说，如果把全部节点都折叠起来只留下一个 UIWindow，那么就把所有图片的 Z-Index 置为 0 即可。

但实践发现行不通，如下图所示，界面的渲染并不是简单的“把每个图层叠放在一起”，还有 ClipsToBounds 等各种逻辑。 
![](https://cdnfile.lookin.work/static_images/doc0412/doc_6.png)

对此，Lookin 和 Reveal 的最终做法是：利用 drawViewHierarchyInRect 或 renderInContext 这两个 API 给每个 UIView/CALayer 都生成两张截图：
1. 包含所有 subviews 的截图，我们称之为 GroupScreenshot
2. 把所有 subviews 都隐藏然后进行截图，我们称之为 SoloScreenshot

然后：

3. 当一个节点被展开时，使用 SoloScreenshot 去渲染这个节点
4. 当一个节点被收起时，使用 GroupScreenshot 去渲染这个节点

### 如何渲染 3D 图像？

![](https://cdnfile.lookin.work/static_images/doc0412/doc_7.gif)

最初的 0.9.3 beta 版本的方案：
* 使用普通的 CALayer
* 利用 layer.contents 属性来渲染图片
* 利用 transform 属性来实现变换：移动、放大缩小、左右旋转

上述方案效果其实不差。事实上，你目前在 iOS 端使用[[NSNotificationCenter defaultCenter] 
postNotificationName:@"Lookin_3D" object:nil]触发的 3D 效果仍然是使用这个方案实现的。

但它有三个问题：

* 代码复杂晦涩

试图单独实现”移动/放大缩小/左右旋转“里的某个效果很简单，但如果结合起来，则代码复杂度会指数级上升。你必须非常 tricky 地控制 transform、sublayerTransform、anchor 等属性以及各个图层之间的关系，才能模拟出符合直觉的“推拉摇移”的交互体验。如果再加上“上下旋转”（即目前 Lookin 的“自由旋转”），则代码就彻底到了无法维护的程度。

* 边框闪烁问题

如下图，图层都有 1pt 的 border，且这个 border 也会跟随 layer.transform 被放大和缩小，而当它被缩小到小于 1px 时就会消失。在用户的视角看来，就是边框会随着用户操作不停地闪烁。虽然不影响使用但是体验很粗糙。

![](https://cdnfile.lookin.work/static_images/doc0412/doc_8.png)

* 没有好看的光影效果

下图是目前最新版本 Lookin 里面的光影效果（不过文档这里受限于 GIF 所以色块比较明显），这是普通的 CALayer 无法实现的。

![](https://cdnfile.lookin.work/static_images/doc0412/doc_9.gif)

那除了 CALayer 还有哪些可能的解决方案呢？

OpenGL 和 Metal 这类 API 太过底层，Unity3d 之类的第三方框架又太过笨重，因此最终 Lookin 和 Reveal 都选择了 Apple 官方早于 2012 年引入的 SceneKit，它是一套专门用来构建 3D 场景的高层 API。它使得你在不接触 Shader 等底层概念的情况下，去操作光照、模型、材质、摄像机等对象。

比如同样是改变视角，相比于上文提到的绞尽脑汁对 CALayer 的各种 transform 进行组合，这里只需要几行代码设置一个 Camera 对象并修改它的位置等属性即可：

![](https://cdnfile.lookin.work/static_images/doc0412/doc_10.png)

至于光影效果，则只需要添加一个灯光对象即可：

![](https://cdnfile.lookin.work/static_images/doc0412/doc_11.png)

关于 SceneKit 更加详细的介绍，可以查看官方文档，或者在 Lookin github 仓库中查看 LookinPreviewView.m 这个文件。

但话说回来，相比于 CALayer，SceneKit 确实也有一个小小缺陷：不允许图层边长超过 16384px，因此需要对那些特别长的 iOS 页面做特殊处理，比如降采样或直接跳过。

### 如何加快刷新速度？

也就是如何缩短”从启动 Lookin 到界面渲染完成“的时间。

首先我们要知道时间都花在了哪里，以下是一个典型耗时：

* 0.1s —— Client 端的“刷新”指令传输到 Server 端
* 0.2s —— Server 端预处理，主要是遍历 iVar 以实现“显示 view 变量名”，以及一些 AutoLayout Constraints 的处理
* 0.4s —— Server 端对 500 个 views 的基本信息进行序列化
* 0.4s —— Server 端对 500 个 views 的属性列表进行序列化
* 6.0s —— Server 端对 500 个 views 生成 1000 张截图（上文“如何正确渲染图层树的展开/折叠图像”部分解释了为什么一个 view 要截两张图）
* 6.0s —— Server 端把 1000 张图片（大概几十 MB）传输到 Client 端
* 0.3s —— Client 端将所有数据反序列化并渲染出来

可以看出，如果不做任何特殊处理的话，单次刷新时间可能会达到 10 秒以上。

为此我做了很多尝试，以下是比较成功的策略：

* 分批异步加载数据

Server 端一边收集数据、一边向 Client 端传输数据，而非所有数据都收集完之后才一并发送给 Client 端。

但就像”5 个线程反而比 500 个线程更快“那样，这里也存在一个 trade off。因为这里的数据传输有一个类似“慢启动”的过程，所以 100M 的数据合成一个请求进行发送，肯定比拆成 100 个 1M 请求的总体时间要快非常多。

那理论上便存在一个最佳的“任务拆分”策略，并且它应该根据传输速度、传输量、设备性能等因素进行动态调整。不过能力所限，我最终采取的简化策略是：“处理的数据量达到了 xx”后就拆分为一个传输任务，并且试出来了一些 Magic Number 写死到了代码里，目前看起来效果还行。

* 优先渲染用户看得到的图层

在持续数十秒的刷新过程中，Client 端会不断地把当前“被用户展开”的图层信息发送给 Server 端，而 Server 端会据此调整序列化任务的顺序，优先把用户关心的图层的信息发送过去。

另外，我们注意到顶层的 UIWindow、UITransitionView、UIDropShadowView 等接近 10 个系统全屏 view 的 SoloScreenshot 在 99% 的情况下都是空白的，因此也可以晚点处理它们。

* 跳过不常用的图层

典型的比如下面这个键盘的 View，99% 的 Debug 场景都不会关心它，那么我们就可以直接跳过，这样一下就省了几十个图层。

![](https://cdnfile.lookin.work/static_images/doc0412/doc_12.png)

* 预渲染背景色

有非常多的 View 其实是纯色的，因此我们只传输一个 view.backgroundColor 属性值即可，无需浪费时间去截取和传输它那巨大的图片。

但我们显然无法 100% 确定一个 view 究竟是不是纯色的，因此这里只作为一个预渲染的策略，加快用户对于刷新速度的感性认知。

* 修改 View 属性时做区分策略

你可以在 Lookin Client 端实时修改各种属性。如果你修改的是 Frame、BackgroundColor 这样的属性，由于它们会改变 UI，因此不得不重新拉取它以及所有上层 View 的图像数据。但如果你只是改了 UserInteractionEnabled，那显然不需要更新。因此需要做相关的策略进行区分。

以上是成功的策略，但我同样做过很多最终失败的尝试：

* 降低图像分辨率

既然图像的抓取和传输占据了 90% 的时间，那么我们是否可以降低图像分辨率以加快速度呢？毕竟我们只是 Debug 而已，不需要那么清晰的图像。

但事实证明，通过 drawViewHierarchyInRect 或 renderInContext 进行截图时，效率最高的采集图像倍数是“和当前设备屏幕倍数一致”的倍数。换句话说，在三倍屏设备上，采集“三倍”图像的时间和采集“一倍”图像的时间差不多，甚至前者更快。

因此，降低分辨率对总体效率的提升就不那么明显了，考虑到低清晰度会显著降低用户体验，我最终放弃了这个策略。

* 不传输图像

我们进行 Web 开发 UI Debug 时，从来没有用到过 3D 图像，那凭什么做 iOS Debug 就一定要 3D 图像呢？

因此，我模仿了 Chrome 的 Debug 方式，交互大概类似下图。当你在 Lookin 里操作图层时，在 iOS 设备上会采用“高亮”之类的方式提示你选中了哪一个 View，具体的属性值也会实时传输。

由于不需要传输图像，因此刷新速度不到 0.3s。我甚至直接取消了“刷新”按钮改成了实时模式：操作 iOS 界面时，Lookin 会自动更新数据。

但花了一个月开发完毕后，用了一天，我就放弃了它 —— 实在是太难用太别扭了（原谅我很难用语言去描述体验这种东西）。

我觉得原因是 Web 界面比较简单，没有太多的 View 之间的遮盖，因此 2D 就够了。但 iOS 的 Views 在 Z 轴方向往往非常深、层层叠叠，所以必须用 3D 才行。（但也不排除纯粹是 iOS 开发的习惯问题）
![](https://cdnfile.lookin.work/static_images/doc0412/doc_13.png)
