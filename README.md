## 介绍
KKGestureLockView是一个非常方便使用的Gesture Lock控件，只需要简单的几步便可以在你的app中实现如安卓那样的手势解锁的效果。其实之前并不看好这种解锁的方式，不过上次发现支付宝iOS新版app中使用了这样的形式来进行功能的解锁，觉得也还方便。此控件有几个概念先说明一下:

<img  width="426" height="631" src="https://raw.github.com/kejinlu/KKGestureLockView/master/pic.png"/> 

* 在控件中，每一个节点叫做一个gesture node,当手势经过某个节点的时候，那么这个节点便进入选中状态，成为最终passcode序列中的一部分
*	每一个节点可以有两种状态，一种是普通状态，一种是选中状态，可以分别为这两种状态设置节点的图片：`normalGestureNodeImage`和`selectedGestureNodeImage`
*	连线也是可以自定义的，可以通过`lineColor`和`lineWidth`来设置连线的颜色和宽度
* 节点所在的容器称之为`contentView`，contentView到KKGestureLockView的四边距离使用`contentInsets`来描述，手势在KKGestureLockView的区域内是不会被结束的，但是Line连线的绘制只会在contentView的区域内
* 节点的个数以及每行的节点数都是可以自定义的，分别通过`numberOfGestureNodes`和`gestureNodesPerRow`进行设置；每一个节点按照从左到右从上到下的方式进行编号，编号从0开始；为了支持多于10个节点的情况，所以passcode并没有使用节点序号直接串联，而是使用半角逗号分隔所有选中节点的序号， 比如上图中的passcode即为 `0,1,4`
* 提供了三个delegate方法，用于通知delegate相关的事件


##用法
控件的源码在`KKGestureLockView/Source`目录下,且自带了一个仿支付宝解锁界面的例子（例子的图片资源取自支付宝app解压缩后的资源图片）:

    self.lockView.normalGestureNodeImage = [UIImage imageNamed:@"gesture_node_normal.png"];
    self.lockView.selectedGestureNodeImage = [UIImage imageNamed:@"gesture_node_selected.png"];
    self.lockView.lineColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
    self.lockView.lineWidth = 12;
    self.lockView.delegate = self;
    self.lockView.contentInsets = UIEdgeInsetsMake(150, 20, 100, 20);
    
<img  width="320" height="566" src="https://raw.github.com/kejinlu/KKGestureLockView/master/screenshot.png"/> 

一般情况下9个节点便够用了，当然如果你想多弄些节点也不是不可以：
<img  width="384" height="512" src="https://raw.github.com/kejinlu/KKGestureLockView/master/screenshot2.png"/> 
