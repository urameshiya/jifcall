include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e
TARGET = iphone:clang:12.1.1:12.1.1

TWEAK_NAME = jifcall
jifcall_FILES = Tweak.xm jifcallprefs/JIFModel.m jifcallprefs/JIFPreferences.m JIFWindow.m JIFBannerController.m
ADDITIONAL_OBJCFLAGS = -fobjc-arc
jifcall_EXTRA_FRAMEWORKS += Cephei
jifcall_PRIVATE_FRAMEWORKS += SpringBoardFoundation



include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
	install.exec "killall -9 Preferences || :"
	install.exec "killall -9 InCallService || :"

SUBPROJECTS += jifcallprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
