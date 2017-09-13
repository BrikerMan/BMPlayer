# VIMediaCache

[中文说明](https://mp.weixin.qq.com/s/v1sw_Sb8oKeZ8sWyjBUXGA)

Cache media file while play media using AVPlayerr.

VIMediaCache use AVAssetResourceLoader to control AVPlayer download media data.

### CocoaPods

`pod 'VIMediaCache'`

### Usage

    NSURL *url = [NSURL URLWithString:@"https://mvvideo5.meitudata.com/571090934cea5517.mp4"];
    
    VIResourceLoaderManager *resourceLoaderManager = [VIResourceLoaderManager new];
    self.resourceLoaderManager = resourceLoaderManager;
    
    AVPlayerItem *playerItem = [resourceLoaderManager playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

### Contact

vvitozhang@gmail.com

### License

MIT
