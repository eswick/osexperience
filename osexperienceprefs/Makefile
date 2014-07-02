ARCHS = arm64 armv7

VERSION=1.0.6

include theos/makefiles/common.mk

BUNDLE_NAME = OSExperiencePrefs
OSExperiencePrefs_CFLAGS += -DVERSION=\"$(VERSION)\"
OSExperiencePrefs_FILES = OSExperience.m ../OSPreferences.m ../Installer.xm
OSExperiencePrefs_INSTALL_PATH = /Library/PreferenceBundles
OSExperiencePrefs_FRAMEWORKS = UIKit
OSExperiencePrefs_PRIVATE_FRAMEWORKS = Preferences
OSExperiencePrefs_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/OSExperience.plist$(ECHO_END)
