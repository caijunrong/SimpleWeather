//
//  WXCondition.m
//  SimpleWeather
//
//  Created by 杨萧玉 on 14-5-24.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//
#define MPS_TO_MPH 2.23694f
#import "WXCondition.h"

@implementation WXCondition
+ (NSDictionary *)imageMap {
    // 1 创建一个静态NSDictionary，因为每个 WXCondition 的实例都将用到相同的数据映射器。
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        // 2 将天气状况代码映射为图像文件 (比如 “01d” 映射为 “weather-clear.png”)。
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}
// 3 声名公有消息来获取图像的文件名。
- (NSString *)imageName {
    return [WXCondition imageMap][self.icon];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    // 1 返回一个MTLValueTransformer，它通过块将值转换为Objective-C属性并从Objective-C属性转换为值。
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}
// 2 你只需要描述一次如何在Unix时间和NSDate之间进行转换，然后在日出和日落的转换器中重用-dateJSONTransformer就可以了。
+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}
+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}
+ (NSValueTransformer *)conditionJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}
+ (NSValueTransformer *)iconJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

@end
