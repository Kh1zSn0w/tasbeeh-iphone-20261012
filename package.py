import plistlib
from pathlib import Path
p = Path('Payload/Tasbeeh.app')
info = {
    'CFBundleExecutable': 'Tasbeeh', 'CFBundleIdentifier': 'com.khizsnow.tasbeeh',
    'CFBundleName': 'Tasbeeh', 'CFBundleDisplayName': 'Tasbeeh',
    'CFBundlePackageType': 'APPL', 'CFBundleVersion': '2',
    'CFBundleShortVersionString': '1.1', 'MinimumOSVersion': '15.0',
    'LSRequiresIPhoneOS': True, 'UIDeviceFamily': [1],
    'UISupportedInterfaceOrientations': ['UIInterfaceOrientationPortrait'],
    'UILaunchScreen': {}, 'UIUserInterfaceStyle': 'Dark',
    'CFBundleSupportedPlatforms': ['iPhoneOS'],
}
(p / 'Info.plist').write_bytes(plistlib.dumps(info))
