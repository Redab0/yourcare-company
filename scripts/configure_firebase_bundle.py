#!/usr/bin/env python3
"""Keep production Firebase credentials out of the generated development iOS app."""
import base64
import os
from pathlib import Path
import shutil


def configure(environment, source, destination):
    if environment not in ('production', 'development'):
        raise ValueError('API_ENV must be production or development')
    if environment == 'development':
        destination.unlink(missing_ok=True)
    elif source.exists():
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)


if __name__ == '__main__':
    values = {}
    for encoded in os.environ.get('DART_DEFINES', '').split(','):
        if encoded:
            key, separator, value = base64.b64decode(encoded).decode().partition('=')
            if separator:
                values[key] = value
    source = Path(os.environ['SRCROOT']) / 'Runner/GoogleService-Info.plist'
    destination = Path(os.environ['TARGET_BUILD_DIR']) / os.environ['UNLOCALIZED_RESOURCES_FOLDER_PATH'] / 'GoogleService-Info.plist'
    configure(values.get('API_ENV', 'production'), source, destination)
