TARGET=iphone:7.0:7.0
ARCHS = arm64 armv7
THEOS_BUILD_DIR = debs
#messages=yes
include theos/makefiles/common.mk

#ENCRYPT=1
#INSTALL_LOCAL=1
#MAKE_SOURCE_DYLIB=1

export VERSION=1.0.6



TWEAK_NAME = OSExperience

OSExperience_CFLAGS += -DVERSION=\"$(VERSION)\"

ifdef MAKE_SOURCE_DYLIB
OSExperience_FILES += $(wildcard tutorial/*.x) $(wildcard missioncontrol/*.xm) Hooks.xm $(wildcard *.m) $(wildcard missioncontrol/*.m) $(wildcard missioncontrol/*.mm) $(wildcard explorer/*.c) $(wildcard launchpad/*.m)
OSExperience_CFLAGS += -O0 -Wno-unused-function -mno-thumb -Wno-deprecated-declarations
OSExperience_FRAMEWORKS += UIKit QuartzCore CoreGraphics IOKit Security CoreText
OSExperience_PRIVATE_FRAMEWORKS += AppSupport GraphicsServices BackBoardServices SpringBoardFoundation
OSExperience_LIBRARIES += rocketbootstrap objcipc MobileGestalt
ifndef INSTALL_LOCAL
OSExperience_INSTALL_PATH = /var/mobile/Library/Application Support/OS Experience/
endif
else
OSExperience_FILES = Installer.xm
OSExperience_FRAMEWORKS += UIKit
OSExperience_LIBRARIES = MobileGestalt
endif

ifdef ENCRYPT
#OSExperience_FILES += Initializer.S Initializer.init
OSExperience_CFLAGS += -DMACH_ENCRYPT -DMACH_VERIFY_UDID
endif


include $(THEOS_MAKE_PATH)/tweak.mk

ifdef INSTALL_LOCAL
ifdef ENCRYPT
after-OSExperience-all::
	cp $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT) $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT).tmp
	rm $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
	/Users/eswick/Development/mach_pwn/mach_pwn $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT).tmp -u 9f1b481a4bcce5a47ef72374155289b9246f8a1f -o $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
	strip -u -r $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
endif
endif

ifndef INSTALL_LOCAL
ifdef MAKE_SOURCE_DYLIB
after-OSExperience-all::
	install_name_tool -id /var/mobile/Library/Preferences/com.eswick.osexperience.license $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
endif
endif

#ifdef INSTALL_LOCAL
#before-package::
#	rm $(THEOS_STAGING_DIR)/DEBIAN/extrainst_
#endif

after-install::
	install.exec "killall -9 backboardd"

SUBPROJECTS += osexperienceprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
