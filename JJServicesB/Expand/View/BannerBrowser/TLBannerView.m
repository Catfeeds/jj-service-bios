//
//  XNBannerView.m
//  MOOM
//
//  Created by 田磊 on 16/4/12.
//  Copyright © 2016年 田磊. All rights reserved.
//

#import "TLBannerView.h"
#import "TLBannerCell.h"

#define SCROLL_TIME_INTERVAL 2.5

@interface TLBannerView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) NSMutableArray *urls;
@property (nonatomic,weak)  NSTimer *timer;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,assign) NSUInteger currentPage;
@property (nonatomic,strong) UICollectionView *bannerCollectionView;


@end

static NSString * const XNBannerCellID = @"XNBannerCellID ";

@implementation TLBannerView
- (void)dealloc
{
    [self.timer invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
    
        _urls = [NSMutableArray array];
        _isAuto = YES;
        
        
        UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
        fl.itemSize = frame.size;
        fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        fl.minimumLineSpacing = 0.0;
        fl.minimumInteritemSpacing = 0.0;
        
        self.bannerCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:fl];
        self.bannerCollectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bannerCollectionView];
        self.bannerCollectionView.pagingEnabled = YES;
        self.bannerCollectionView.delegate = self;
        self.bannerCollectionView.dataSource = self;
        [self.bannerCollectionView  registerClass:[TLBannerCell class] forCellWithReuseIdentifier:XNBannerCellID];
        self.bannerCollectionView .showsHorizontalScrollIndicator = NO;
        [self.bannerCollectionView  setContentOffset:CGPointMake(self.frame.size.width, 0)];
        
        if (_isAuto) {
            
            CGFloat pageControlHeight = 25.0;
            UIPageControl *tmpPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - pageControlHeight, self.frame.size.width, pageControlHeight)];
            [self addSubview:tmpPageControl];
            _pageControl = tmpPageControl;
            _pageControl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
            //  _pageControl.pageIndicatorTintColor = [UIColor redColor];
            _pageControl.numberOfPages = self.urls.count - 2;
            [self addSubview:_pageControl];
            
        }
    
        

    }
    return self;

}
- (instancetype)initWithFrame:(CGRect)frame urlString:(NSArray <NSString *>*)urls
{
    if (self = [super initWithFrame:frame]) {
        
        _urls = [[NSMutableArray alloc] initWithArray:urls];
        _isAuto = YES;
        
        //1.对URL进行处理
        if(urls.count > 1){
            [_urls insertObject:[urls lastObject] atIndex:0];
            [_urls insertObject:[urls firstObject] atIndex:_urls.count];
            _currentPage = 1;
            
            NSTimer *tmpTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLL_TIME_INTERVAL target:self selector:@selector(pageScroll) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:tmpTimer forMode:NSRunLoopCommonModes];
            self.timer = tmpTimer;
        }
        
        
        //2.创建
        UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
        fl.itemSize = frame.size;
        fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        fl.minimumLineSpacing = 0.0;
        fl.minimumInteritemSpacing = 0.0;
        
        self.bannerCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:fl];
        [self addSubview:self.bannerCollectionView];
        self.bannerCollectionView.pagingEnabled = YES;
        self.bannerCollectionView.delegate = self;
        self.bannerCollectionView.dataSource = self;
        [self.bannerCollectionView  registerClass:[TLBannerCell class] forCellWithReuseIdentifier:XNBannerCellID];
        self.bannerCollectionView .showsHorizontalScrollIndicator = NO;
        [self.bannerCollectionView  setContentOffset:CGPointMake(self.frame.size.width, 0)];
    }
    
    
    if (_isAuto) {
        
    CGFloat pageControlHeight = 25.0;
    UIPageControl *tmpPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - pageControlHeight, self.frame.size.width, pageControlHeight)];
    [self addSubview:tmpPageControl];
    _pageControl = tmpPageControl;
    _pageControl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
//  _pageControl.pageIndicatorTintColor = [UIColor redColor];
    _pageControl.numberOfPages = self.urls.count - 2;
    [self addSubview:_pageControl];
    
    }
    
    return self;
    
}

- (void)setImgUrls:(NSArray *)imgUrls {

    _imgUrls = [imgUrls copy];
    //对图片进行处理
    
    //1.对URL进行处理
    if(imgUrls.count > 1){
        [_urls insertObject:[imgUrls lastObject] atIndex:0];
        [_urls insertObject:[imgUrls firstObject] atIndex:_urls.count];
        _currentPage = 1;
        
        NSTimer *tmpTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLL_TIME_INTERVAL target:self selector:@selector(pageScroll) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:tmpTimer forMode:NSRunLoopCommonModes];
        self.timer = tmpTimer;
        
        [self.bannerCollectionView reloadData];
        
    }
    

}

- (void)setIsAuto:(BOOL)isAuto
{
    _isAuto = isAuto;
    if (!_isAuto) {
        
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

- (void)pageScroll
{
    _currentPage ++;
    
    [self.bannerCollectionView  setContentOffset:CGPointMake(_currentPage * self.frame.size.width, 0) animated:YES];
    
    if (_currentPage == self.urls.count - 1) {
        _currentPage = 0;
    }
    
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.bannerCollectionView .contentOffset.x < self.bannerCollectionView .frame.size.width) {
        if (self.bannerCollectionView .contentOffset.x != 0) {
            return;
        }
    }

    
    NSInteger index = (self.bannerCollectionView .contentOffset.x )/self.frame.size.width;
    _currentPage = index - 1;
 
    //不循环
    if(_urls.count < 4) return;
    
    self.pageControl.currentPage = _currentPage;
    //最后一个
    if (index == self.urls.count - 1) {
        [self.bannerCollectionView  setContentOffset:CGPointMake(self.frame.size.width, 0) ];

        return;
    }

    //滑动到前面
    if (index == 0) {
        [self.bannerCollectionView  setContentOffset:CGPointMake(self.frame.size.width*(self.urls.count - 2), 0)];
        return;
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    XNLog(@"开始拖动");
    self.timer.fireDate = [NSDate distantFuture];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.timer.fireDate = [NSDate distantPast];
//    XNLog(@"结束拖动");
}

#pragma  mark - collectionView 点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma  mark - DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.urls.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TLBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XNBannerCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];

    cell.urlString = self.urls[indexPath.row];

    return cell;
}

@end
