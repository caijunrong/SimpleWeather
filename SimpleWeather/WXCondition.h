//
//  WXCondition.h
//  SimpleWeather
//
//  Created by 杨萧玉 on 14-5-24.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

#import <Mantle.h>
//MTLJSONSerializing 协议告诉Mantle 序列化器 这个对象拥有如何将 JSON 映射成 Objective-C 属性的指令。
@interface WXCondition : MTLModel <MTLJSONSerializing>
//这些是你的天气数据的所有属性。你将会用到他们中的一部分，不过最好你能够访问到所有数据，说不定以后你会想要扩展你的应用。
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;
//这仅仅是一个将天气状况映射为图像文件的帮助方法。
- (NSString *)imageName;
@end
