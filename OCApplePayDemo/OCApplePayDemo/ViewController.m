//
//  ViewController.m
//  OCApplePayDemo
//
//  Created by Will Wang on 16/2/18.
//  Copyright © 2016年 WEL. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //是否支持 ApplePay系统版本，硬件 ParentControl  或者是否因为家长控制而不能支付
    BOOL isSupportPay = [PKPaymentAuthorizationViewController canMakePayments];
    
    if (!isSupportPay) {
        return;
    }else {
        // do something
    }
    
    //是否支持这些支持方式（可能没有绑定卡）判断用户是否能够使用你提供的支付网络进行支付
    NSArray *netwotks = @[PKPaymentNetworkPrivateLabel,PKPaymentNetworkVisa,PKPaymentNetworkMasterCard];
    
    BOOL canPay = [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:netwotks];
    if (!canPay) {
        
        //setup
        PKPaymentButton *setupButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleBlack];
        [setupButton addTarget:self action:@selector(applePaySetupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:setupButton];
        setupButton.center = CGPointMake(self.view.frame.size.width/2, 100);
        
    }else{
        //发起支付请求
        //PKPaymentRequest
        PKPaymentRequest *paymentRequest = [PKPaymentRequest new];
        paymentRequest.currencyCode = @"CNY";
        paymentRequest.countryCode = @"CN";
        paymentRequest.merchantIdentifier = @"merchant.com.hunk.assistants";
        
        // 构造金额
        
        // 2.01 subtotal 标签文本是一个用户可阅读的摘要项目描述信息，数额是相对应的支付数额
        NSDecimalNumber *subtotalAmount = [NSDecimalNumber decimalNumberWithMantissa:201 exponent:-2 isNegative:NO];
        PKPaymentSummaryItem *subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subtotalAmount];
        
        // 2.00 discount 对于折扣或优惠券，则需要把数额设成负数。
        NSDecimalNumber *discountAmount = [NSDecimalNumber decimalNumberWithMantissa:200 exponent:-2 isNegative:YES];
        PKPaymentSummaryItem *discount = [PKPaymentSummaryItem summaryItemWithLabel:@"Discount" amount:discountAmount];
        
        // 0.01 grand total 总计金额 应该使用公司的名称做为其标签，使用所有其它项目的金额总和做为金额
        NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
        totalAmount = [totalAmount decimalNumberByAdding:subtotalAmount];
        totalAmount = [totalAmount decimalNumberByAdding:discountAmount];
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Gou Min Company" amount:totalAmount];
        
        NSArray *summaryItems = @[subtotal, discount, total];
        paymentRequest.paymentSummaryItems = summaryItems;
        
        
        // Shipping Method (skip now)
        // 支付标准
        
        paymentRequest.supportedNetworks = @[PKPaymentNetworkPrivateLabel, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
        // Supports 3DS only 还可以设置支持其他的
        paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
        
        // 配送信息以及mail地址
        
        paymentRequest.requiredBillingAddressFields = PKAddressFieldEmail;
        paymentRequest.requiredBillingAddressFields = PKAddressFieldEmail | PKAddressFieldPostalAddress;
        
        PKContact *contact = [[PKContact alloc] init];
        
        NSPersonNameComponents *name = [[NSPersonNameComponents alloc] init];
        name.givenName = @"Wang";
        name.familyName = @"WEL";
        
        contact.name = name;
        
        CNMutablePostalAddress *address = [[CNMutablePostalAddress alloc] init];
        address.street = @"1234 Guangshun Street";
        address.city = @"Atlanta";
        address.state = @"GA";
        address.postalCode = @"30303";
        
        contact.postalAddress = address;
        paymentRequest.shippingContact = contact;
        
        
        // Storing Additional Information
        
        // request.applicationData =
        
        
        // Authorizing Payment show
        
        PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        if (!viewController) {
            /* ... Handle error ... */
        } else {
            viewController.delegate = self;
            [self presentViewController:viewController animated:YES completion:nil];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)applePaySetupButtonPressed:(PKPaymentButton *)sender {
    [[PKPassLibrary new] openPaymentSetup];
}


#pragma mark PKPaymentAuthorizationViewControllerDelegate Methods

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{

    PKPaymentAuthorizationStatus status;
    
    completion(status);
    
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
