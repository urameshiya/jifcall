ARCHS = arm64
TARGET = iphone:clang:12.1.1:12.1.1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = jifcallprefs
jifcallprefs_FILES = JIFRootListController.m JIFVideoEditViewController.m JIFSaver.m JIFPreferences.m JIFModel.m
jifcallprefs_INSTALL_PATH = /Library/PreferenceBundles
jifcallprefs_FRAMEWORKS = UIKit
jifcallprefs_PRIVATE_FRAMEWORKS = Preferences
jifcallprefs_EXTRA_FRAMEWORKS += Cephei
ADDITIONAL_OBJCFLAGS = -fobjc-arc


include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/jifcallprefs.plist$(ECHO_END)
