import plistlib
from pathlib import Path
p = Path('Payload/Tasbeeh.app')
info = {
    'CFBundleExecutable': 'Tasbeeh', 'CFBundleIdentifier': 'com.khizsnow.tasbeeh',
    'CFBundleName': 'Tasbeeh', 'CFBundleDisplayName': 'Tasbeeh',
    'CFBundlePackageType': 'APPL', 'CFBundleVersion': '1',
    'CFBundleShortVersionString': '1.0', 'MinimumOSVersion': '15.0',
    'LSRequiresIPhoneOS': True, 'UIDeviceFamily': [1],
    'UISupportedInterfaceOrientations': ['UIInterfaceOrientationPortrait'],
    'UILaunchScreen': {}, 'UIUserInterfaceStyle': 'Dark',
    'CFBundleSupportedPlatforms': ['iPhoneOS'],
}
(p / 'Info.plist').write_bytes(plistlib.dumps(info))
