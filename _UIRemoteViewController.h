/*
* This header is generated by classdump-dyld 1.0
* on Friday, February 8, 2019 at 1:26:50 PM Eastern European Standard Time
* Operating System: Version 12.1 (Build 16B92)
* Image Source: /System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/

// #import <UIKitCore/UIKitCore-Structs.h>
// #import <UIKitCore/UIViewController.h>
// #import <UIKitCore/_UIRemoteViewController_ViewControllerOperatorInterface.h>

@class NSString, _UIViewServiceInterface, _UIRemoteViewService, NSArray, _UIAsyncInvocation, _UISizeTrackingView, _UIRemoteView, _UITextEffectsRemoteView, UIView, FBSDisplayIdentity, NSError, _UITextServiceSession, UIDimmingView, UIAlertView, BKSTouchDeliveryPolicyAssertion;

@interface _UIRemoteViewController : UIViewController
+(id)serviceViewControllerInterface;
+(id)exportedInterface;
+(id)requestViewControllerWithService:(id)arg1 connectionHandler:(/*^block*/id)arg2 ;
+(id)requestViewController:(id)arg1 fromServiceWithBundleIdentifier:(id)arg2 connectionHandler:(/*^block*/id)arg3 ;
+(id)requestViewController:(id)arg1 traitCollection:(id)arg2 fromServiceWithBundleIdentifier:(id)arg3 connectionHandler:(/*^block*/id)arg4 ;
+(id)requestViewControllerWithService:(id)arg1 traitCollection:(id)arg2 connectionHandler:(/*^block*/id)arg3 ;

@end