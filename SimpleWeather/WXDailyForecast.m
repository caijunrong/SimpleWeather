//
//  WXDailyForecast.m
//  SimpleWeather
//
//  Created by 杨萧玉 on 14-5-24.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1 获取 WXCondition的映射并创建一份可变的拷贝 。
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2 将最高气温和最低气温的映射改为每日预报中你所需要的。
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3 返回新的映射。
    return paths;
}
@end
