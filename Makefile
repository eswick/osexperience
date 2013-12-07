THEOS_BUILD_DIR = debs
THEOS_DEVICE_IP=127.0.0.1
THEOS_DEVICE_PORT=2222

include theos/makefiles/common.mk

TWEAK_NAME = OSExperience
OSExperience_FILES = Hooks.xm OSWallpaperView.m OSViewController.m OSPane.m OSDesktopPane.m OSSlider.m explorer/OSFile.m explorer/OSFileView.m explorer/OSFileGridView.m UIView+FrameExtensions.m OSAppPane.m launchpad/OSIconContentView.m launchpad/UIImage+StackBlur.m missioncontrol/OSThumbnailView.m missioncontrol/OSThumbnailWrapper.m missioncontrol/OSPaneThumbnail.m OSPaneModel.m missioncontrol/OSThumbnailPlaceholder.m OSPinchGestureRecognizer.m explorer/CGPointExtension.c OSWindow.m OSAppWindow.m UIImage+Extensions.m missioncontrol/OSAddDesktopButton.m OSSwitcherBackgroundView.m OSSwipeGestureRecognizer.m missioncontrol/OSMCWindowLayoutManager.m OSRemoteRenderLayer.m
OSExperience_FRAMEWORKS = UIKit QuartzCore CoreGraphics IOKit Security
OSExperience_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices BackBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
