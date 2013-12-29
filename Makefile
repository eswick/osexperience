THEOS_BUILD_DIR = debs
DEBUG = 1
include theos/makefiles/common.mk

TWEAK_NAME = OSExperience
OSExperience_FILES = Hooks.xm OSWallpaperView.m OSViewController.m OSPane.m OSDesktopPane.m OSSlider.m UIView+FrameExtensions.m OSAppPane.m launchpad/OSIconContentView.m launchpad/UIImage+StackBlur.m missioncontrol/OSThumbnailView.m missioncontrol/OSThumbnailWrapper.m missioncontrol/OSPaneThumbnail.m OSPaneModel.m missioncontrol/OSThumbnailPlaceholder.m OSPinchGestureRecognizer.m explorer/CGPointExtension.c OSWindow.m OSAppWindow.m UIImage+Extensions.m missioncontrol/OSAddDesktopButton.m OSSwitcherBackgroundView.m OSSwipeGestureRecognizer.m missioncontrol/OSMCWindowLayoutManager.m OSRemoteRenderLayer.m OSExplorerWindow.m explorer/OSFileGridViewController.m explorer/OSFileViewController.m explorer/OSFileGridTile.m explorer/OSSelectionDragView.m explorer/OSFileGridTileLabel.m explorer/OSFileGridTileGhostView.m explorer/OSFileGridTileMap.m
OSExperience_LDFLAGS = -lfsmonitor
OSExperience_FRAMEWORKS = UIKit QuartzCore CoreGraphics IOKit Security CoreText
OSExperience_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices BackBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
