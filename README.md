# readInfo
# 阅读信息

## 第三方插件使用说明

1. 使用 FlutterJsonBeanFactory 插件 做json序列化操作
2. 使用 flutterImgSync 做资源R文件生成

## 编译说明

### 1. flutter 添加 macos 和 windows等系统支持
```shell
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

#关于web支持，release默认支持，跑一下flutter build web 就会自动安装web sdk
 ```


### 2. 因为有些第三方库还没有适配空安全，run的时候注意加上下面的参数，去除空安全错误
```shell
#使用html解析器，避免 下载cavaskit 出错导致白屏
flutter build web --web-renderer html --no-sound-null-safety --release
flutter build web --no-sound-null-safety --release
```

### 3. 编译macos 或者windows命令
```shell
 flutter build macos --no-sound-null-safety --release

```

### 4. 修改数据库实体类后，使用如下命令重新生成
```shell
fvm flutter pub run build_runner build --delete-conflicting-outputs

```

# todo
- [ ] 从发现页重复点击一本小说，可能生成多个历史记录的问题
- [ ] 多源搜索功能
- [ ] 阅读历史展示简化