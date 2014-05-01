ARCHS = arm64 armv7

include theos/makefiles/common.mk

BUNDLE_NAME = OSExperiencePrefs
OSExperiencePrefs_FILES = OSExperience.m ../OSPreferences.m
OSExperiencePrefs_INSTALL_PATH = /Library/PreferenceBundles
OSExperiencePrefs_FRAMEWORKS = UIKit
OSExperiencePrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/OSExperience.plist$(ECHO_END)
