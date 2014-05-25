//
//  WXController.m
//  SimpleWeather
//
//  Created by 杨萧玉 on 14-5-24.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//
#import "WXManager.h"
#import "WXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
@interface WXController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;
@end

@implementation WXController

- (id)init {
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 1 获取并存储屏幕的高度。稍后当用分页的方式展示所有天气数据的时候你将会用到这个。
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"bg"];
    // 2 创建一个静态图片的背景，并将它添加到视图。
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    // 3 用LBBlurredImage创建一个模糊的背景图片, 并将aphla的初始值设为0，这样刚开始backgroundImageView是可见的。
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    // 4 创建一个tableview 负责所有的数据呈现。 WXController 将是代理和数据源，同时也是滚动视图的代理。注意将 pagingEnabled 设为 YES。
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    // 1 将表头设置成与屏幕一样的大小。你将会利用UITableView的分页功能，它会将表头，每日和每小时预报的Section进行分页。
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // 2 创建一个inset(或者padding)变量，这样你的所有Label都能够均匀的间隔和居中。
    CGFloat inset = 20;
    // 3 为不同的视图创建并初始化高度变量， 将这些值设为常量，这样便于你在需要的时候配置与更改视图的设置。
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    // 4 根据常量和inset变量，为你的label和icon视图创建边框。
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    // 5 拷贝icon边框，对它进行调整以便文本有一些空间来伸展，并把它移到icon的右边 。当我们把label添加到视图的下边后你将会看到布局的数学运算是如何工作的。
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    // 1 将当前状况视图设置为表头。
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    // 2 创建每个需要的标签来现实天气数据。
    // bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    // 3 为天气图标添加一个图像视图。
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    // 1 观察WXManager单例的currentCondition。
    [[RACObserve([WXManager sharedManager], currentCondition)
      // 2 传递在主线程上的任何变化，因为你正在更新UI。
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         // 3 使用气象数据更新文本标签；你为文本标签使用newCondition的数据，而不是单例。订阅者的参数保证是最新值。
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         
         // 4 使用映射的图像文件名来创建一个图像，并将其设置为视图的图标。
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    // 1 RAC（…）宏有助于保持语法整洁。从该信号的返回值将被分配给hiloLabel对象的text。
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       // 2观察currentCondition的高温和低温。合并信号，并使用两者最新的值。当任一数据变化时，信号就会触发。
                                                       RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                             // 3 从合并的信号中，减少数值，转换成一个单一的数据，注意参数的顺序与信号的顺序相匹配。
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
                                              }] 
                            // 4 同样，因为你正在处理UI界面，所以把所有东西都传递到主线程。
                            deliverOn:RACScheduler.mainThreadScheduler];
    [[RACObserve([WXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    [[WXManager sharedManager] findCurrentLocation]; 
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
// 1 Pragma 标记符是帮助你组织代码的很好的方式。
#pragma mark - UITableViewDataSource
// 2 你的表视图有两个部分(Section)，一个是每小时的预报，一个是每天的 。你将始终为表视图Section数返回2。
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 1 第一部分是对的逐时预报。使用最近6小时的预预报，并添加了一个作为页眉的单元格。
    if (section == 0) {
        return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    // 2 接下来的部分是每日预报。使用最近6天的每日预报，并添加了一个作为页眉的单元格。
    return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    // 3 预报的表格单元应该是不可选的。将他们背景设置为半透明的黑色，文字为白色。
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    // TODO: Setup the cell
    if (indexPath.section == 0) {
        // 1 每个部分的第一行是标题单元格。
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            // 2 获取每小时的天气和使用自定义配置方法配置cell。
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    else if (indexPath.section == 1) {
        // 1 每个部分的第一行是标题单元格。
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            // 3 获取每天的天气，并使用另一个自定义配置方法配置cell。
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather]; 
        } 
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Determine cell height based on screen
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}


#pragma mark - help methods
// 1 配置和添加文本到作为section页眉单元格。你会重用此为每日每时的预测部分。
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

// 2 格式化逐时预报的单元格。
- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

// 3 格式化每日预报的单元格。
- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                 weather.tempHigh.floatValue,
                                 weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1 获取滚动视图的高度和内容偏移量。与0偏移量做比较，因此试图滚动table低于初始位置将不会影响模糊效果。
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 2 偏移量除以高度，并且最大值为1，所以alpha上限为1。
    CGFloat percent = MIN(position / height, 1.0);
    // 3 当你滚动的时候，把结果值赋给模糊图像的alpha属性，来更改模糊图像。
    self.blurredImageView.alpha = percent;
}

@end


