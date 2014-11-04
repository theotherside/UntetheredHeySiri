//
//  AssistantControllerHooks.m
//  UntetheredHeySiri
//
//  Created by Hamza Sood on 24/10/2014.
//  Copyright (c) 2014 Hamza Sood. All rights reserved.
//

@import Preferences;
@import CydiaSubstrate;
@import FlipSwitch;
@import VoiceTrigger.VTPreferences;

#import "AssistantController.h"
#import "NoFooterGroupSpecifier.h"
#import <notify.h>

#define kSwitchBundleIdentifier @"com.hamzasood.UntetheredHeySiriSwitch"




//Class to store origonal implementations
@interface _AssistantControllerHooks : PSListController
@end
@implementation _AssistantControllerHooks
@end

@interface AssistantControllerHooks : _AssistantControllerHooks
@end




@implementation AssistantControllerHooks

PSSpecifier *_allowedWhenDisconnectedSpecifier;

- (id)init {
    if ((self = [super init])) {
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(flipSwitchDidChangeNotification:)
                                                   name:FSSwitchPanelSwitchStateChangedNotification
                                                 object:nil];
    }
    return self;
}

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        NSArray *updatedSpecifiers = [super.specifiers arrayByPerformingSpecifierUpdatesUsingBlock:^(PSSpecifierUpdates *updates) {
            PSSpecifier *voiceActivationGroupSpecifier = [updates specifierForID:@"VOICE_ACTIVATION_GROUP"];
            object_setClass(voiceActivationGroupSpecifier, [NoFooterGroupSpecifier class]);
            [voiceActivationGroupSpecifier removePropertyForKey:PSFooterTextGroupKey];
            
            _allowedWhenDisconnectedSpecifier = [[PSSpecifier preferenceSpecifierNamed:@"AllowedWhenDisconnected"
                                                                                 target:self
                                                                                    set:@selector(setVoiceTriggerAllowedWhenDisconnected:specifier:)
                                                                                    get:@selector(voiceTriggerAllowedWhenDisconnected:)
                                                                                 detail:Nil
                                                                                   cell:[PSTableCell cellTypeFromString:@"PSSegmentCell"]
                                                                                   edit:Nil]retain];
            [_allowedWhenDisconnectedSpecifier setValues:@[@NO, @YES] titles:@[@"While Charging", @"Always"]];
            if (VTPreferences.sharedPreferences.voiceTriggerEnabled)
                [updates appendSpecifier:_allowedWhenDisconnectedSpecifier toGroupWithID:@"VOICE_ACTIVATION_GROUP"];
        }];
        [_specifiers release];
        _specifiers = [updatedSpecifiers retain];
    }
    return _specifiers;
}

#pragma mark -
#pragma mark Added Methods

NSNumber *VoiceTriggerAllowedWhenDisconnected(AssistantControllerHooks *self, SEL _cmd, PSSpecifier *specifier) {
    return @([FSSwitchPanel.sharedPanel stateForSwitchIdentifier:kSwitchBundleIdentifier] == FSSwitchStateOn ? YES : NO);
}

void SetVoiceTriggerAllowedWhenDisconnected(AssistantControllerHooks *self, SEL _cmd, NSNumber *allowedWhenDisconnected, PSSpecifier *specifier) {
    [FSSwitchPanel.sharedPanel setState:(allowedWhenDisconnected.boolValue ? FSSwitchStateOn : FSSwitchStateOff) forSwitchIdentifier:kSwitchBundleIdentifier];
}

void FlipSwitchDidChangeNotification(AssistantControllerHooks *self, SEL _cmd, NSNotification* notification) {
    if ([[notification.userInfo objectForKey:FSSwitchPanelSwitchIdentifierKey]isEqualToString:kSwitchBundleIdentifier]) {
        [self reloadSpecifier:_allowedWhenDisconnectedSpecifier animated:YES];
    }
}

#pragma mark -

- (void)setVoiceTrigger:(NSNumber *)voiceTrigger forSpecifier:(PSSpecifier *)specifier {
    [super setVoiceTrigger:voiceTrigger forSpecifier:specifier];
    if (voiceTrigger.boolValue)
        [self insertSpecifier:_allowedWhenDisconnectedSpecifier afterSpecifierID:@"VOICE_ACTIVATION" animated:YES];
    else
        [self removeSpecifier:_allowedWhenDisconnectedSpecifier animated:YES];
}

- (void)dealloc {
    [_allowedWhenDisconnectedSpecifier release];
    [super dealloc];
}

@end




char *bundleLoadedObserver = "Where's AssistantController?!";

void AssistantBundleLoadedNotificationFired(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (objc_getClass("AssistantController") == Nil)
        return;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class $AssistantController = objc_getClass("AssistantController");
        MSHookClassPair($AssistantController, [AssistantControllerHooks class], [_AssistantControllerHooks class]);
        class_addMethod($AssistantController, @selector(voiceTriggerAllowedWhenDisconnected:), (IMP)VoiceTriggerAllowedWhenDisconnected, "@@:@");
        class_addMethod($AssistantController, @selector(setVoiceTriggerAllowedWhenDisconnected:specifier:), (IMP)SetVoiceTriggerAllowedWhenDisconnected, "v@:@@");
        class_addMethod($AssistantController, @selector(flipSwitchDidChangeNotification:), (IMP)FlipSwitchDidChangeNotification, "v@:@");
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(),
                                           bundleLoadedObserver,
                                           (CFStringRef)NSBundleDidLoadNotification,
                                           NULL);
    });
}

__attribute__((constructor)) static void AssistantControllerHooksInit() {
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                        bundleLoadedObserver,
                                        AssistantBundleLoadedNotificationFired,
                                        (CFStringRef)NSBundleDidLoadNotification,
                                        [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/Assistant.bundle"],
                                        CFNotificationSuspensionBehaviorCoalesce);
    }
}