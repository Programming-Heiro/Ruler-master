# Ruler
> 一个简单的可以测量平面长度和面积的App   

![Xcode 9.0+](https://img.shields.io/badge/Xcode-9.0%2B-blue.svg)
![iOS 11.0+](https://img.shields.io/badge/iOS-11.0%2B-blue.svg)
![Swift 4.0+](https://img.shields.io/badge/Swift-4.0%2B-orange.svg)





## Compatibility

- Swift 4.0
- iOS 11.0
- Xcode 9.0


## Feature
#### 核心功能模块:

1. **平面检测**：程序运行的第一个步骤，提取环境信息，在对应位置的AR场景中提取可供测量的平面信息。
2. **长度测量**：对检测成功的平面进行标记，并计算两个标记点之间的长度。
3. **面积检测**：对检测成功的平面进行标记，并计算由多个标记点构成闭合图形的面积。



#### 辅助功能模块：
1. **文字提示框**：用于提示用户进行正确的操作和用于显示测量结果信息。
2. **可视化动态平面**：辅助测量工具，将检测成功的平面可视化，方便用户定位和标记。
3. **聚焦框**：辅助测量工具，用于检测标记中心点周围的位置信息是否充足。
4. **中心检测光标**：辅助测量工具，用于提示当前位置添加标记点的条件是否充分。
5. **线段长度三维文字显示**：用于记录保存每两条线段之间的长度信息，并在对应位置进行标记显示。 



#### 其他功能模块
1. **截屏保存**：可对当前的AR场景进行截图保存，记录测量信息。
2. **场景重启**：若当前AR场景发生了中断等故障，重新初始化AR场景。
3. **单位转换**：测量结果单位之间的互相转换。


## Preview
* 用户操作界面  
<img src="https://github.com/Programming-Heiro/Ruler-master/blob/master/screenshots/image007.jpg" width="175" alt="")/>
<img src="https://github.com/Programming-Heiro/Ruler-master/blob/master/screenshots/image008.jpg" width="175" alt="")/>

* 长度测量  
![](https://github.com/Programming-Heiro/Ruler-master/blob/master/screenshots/1.gif)

* 设置界面  
![](https://github.com/Programming-Heiro/Ruler-master/blob/master/screenshots/2.gif)

* 面积测量  
![](https://github.com/Programming-Heiro/Ruler-master/blob/master/screenshots/3.gif)



## Author
* Liu youliang

## License
Copyright @2019 Liuyouliang
