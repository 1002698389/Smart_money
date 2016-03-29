//
//  ZMAdminUserBaseInfo.m
//  ZiMaCaiHang
//
//  Created by zhangxh on 15-4-29.
//  Copyright (c) 2015年 zimacaihang. All rights reserved.
//

#import "ZMAdminUserBaseInfo.h"

@implementation ZMAdminUserBaseInfo
-(id)init
{
    self = [super init];
    if (self) {
        self.userId = -1;
        self.userSubId = -1;
        
        self.avartar = @"";
        
        self.birthday = @"";
        self.gender = @"";               //性别
        self.genderValue = @"";
        self.idCard = @"";               //实名身份证号码
        self.realname = @"";             //实名
        self.firstInAmount = @"";        //是否首次充值
        
        self.isFinancialPlanner = 0;    //是否为理财师(默认为NO)
        self.mobile = @"";               //手机
        self.email = @"";                //邮箱
        
        self.companyIndustry = @"";
        self.companyIndustryValue = @"";
        self.companyScale = @"";
        self.companyScaleValue = @"";
        self.educationalType = @"";
        self.educationalTypeValue = @"";
        self.graduateInstitutions = @""; //毕业院校
        self.incomeMonthly = @"";
        self.incomeMonthlyValue = @"";
        self.marriageStatusValue = @"";
        self.position = @"";             //职位
        self.residentialAddress = @"";   //居住地址
    }
    return self;
}
@end
