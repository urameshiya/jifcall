include $(THEOS)/makefiles/common.mk

TWEAK_NAME = jifcall
jifcall_FILES = Tweak.xm jifcallprefs/JIFModel.m jifcallprefs/JIFPreferences.m
ADDITIONAL_OBJCFLAGS = -fobjc-arc
jifcall_EXTRA_FRAMEWORKS += Cephei



include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	# install.exec "killall -9 SpringBoard"
	install.exec "killall -9 Preferences || :"
	install.exec "killall -9 InCallService || :"

SUBPROJECTS += jifcallprefs
include $(THEOS_MAKE_PATH)/aggregate.mk