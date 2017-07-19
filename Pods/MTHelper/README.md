### 开发中常用的非控件型工具类
     该工具类库全面支持cocosPods工具,通过cocosPods可以根据具体的粒度使用该库中的某个类或者是按功能的业务场景需求为完成某个功能的几个类。

##  使用方法
* 1 新建Podfile文件
    在所在项目的根目录中创建Podfile文件，文件中的内容大概如下：
<pre><code>
source 'git@119.29.138.123:devframe/mt-spec.git' //必须指定该库的repo
source ‘https://github.com/CocoaPods/Specs.git‘ //当Podfile文件需要导入其他的公有库时，必须指定公有库的repo
target 'MTFrameDevVesison' do //项目的Tegets 名称
     #pod 'MTHelper'  //将导入下面的有的模块
     pod 'MTAppHelper/MTCommHelper' //导出下面的MTCommHelper模块
     pod 'MTAppHelper/MTString'
     pod 'MTAppHelper/MTEDCryption'
     pod 'MTAppHelper/MTJson'
     pod 'MTAppHelper/MTImage'
end
</code></pre>
* 2 在Podfile 文件所在目录执行命令：pod install 或者 pod update
* 3 安装完成后，会增加一个.xcworkspace工作区，打开该工作区。Done !
