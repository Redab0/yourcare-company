"""Build an isolated historical-parser fixture; never modify the application.

Run Flutter only in the returned private package. Its lib/ files are byte-exact
Git blobs from the recorded historical revision, without app startup, native
configuration, assets, credentials or Firebase dependencies.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import posixpath
import re
import stat
import subprocess

REVISION = 'a931a4f8ee2f8a39c61537c6c77ff1f4f173a3f0'
PACKAGE = 'cleaning_service_driver'
HERE = Path(__file__).resolve().parent
REPOSITORY = HERE.parents[2]
SEEDS = [
    'lib/data/models/requests/cleaning_request.dart',
    'lib/data/models/auth/login_response.dart',
    'lib/data/services/jobs/jobs_service.dart',
]
DIRECTIVE = re.compile(r'(?:^|\n)\s*(?:import|export|part)\s+[\'\"]([^\'\"]+)[\'\"]')


def git_blob(path):
    result = subprocess.run(
        ['git', 'show', REVISION + ':' + path], cwd=REPOSITORY,
        check=True, capture_output=True, timeout=10,
    )
    if len(result.stdout) > 1024 * 1024:
        raise ValueError('historical_source_bound')
    return result.stdout


def source_graph():
    sources, dependencies, pending = {}, set(), list(SEEDS)
    while pending:
        path = pending.pop()
        if path in sources:
            continue
        if not path.startswith('lib/') or not path.endswith('.dart'):
            raise ValueError('historical_source_not_allowlisted')
        sources[path] = git_blob(path)
        if len(sources) > 96:
            raise ValueError('historical_graph_bound')
        for uri in DIRECTIVE.findall(sources[path].decode()):
            if uri.startswith('dart:'):
                continue
            if uri.startswith('package:' + PACKAGE + '/'):
                child = 'lib/' + uri.split('/', 1)[1]
            elif uri.startswith('package:'):
                dependencies.add(uri.split('/')[0][8:])
                continue
            else:
                child = posixpath.normpath(posixpath.join(posixpath.dirname(path), uri))
            pending.append(child)
    allowed = {'dio', 'equatable', 'flutter', 'flutter_localizations', 'intl', 'json_annotation', 'retrofit'}
    if dependencies != allowed:
        raise ValueError('historical_dependency_graph_changed')
    return sources, dependencies


def package_spec(dependencies):
    lock = git_blob('pubspec.lock').decode()
    versions = {}
    for name in dependencies - {'flutter', 'flutter_localizations'}:
        block = re.search(r'(?ms)^  ' + name + r':\n.*?(?=^  [a-zA-Z_]+:\n|\Z)', lock)
        version = re.search(r'^    version: "([^"\n]+)"$', block.group(), re.M) if block else None
        if not version:
            raise ValueError('historical_dependency_version_missing')
        versions[name] = version[1]
    versions.update({name: {'sdk': 'flutter'} for name in ['flutter', 'flutter_localizations']})
    return {
        'name': PACKAGE, 'description': 'Synthetic historical provider contract fixture only.',
        'publish_to': 'none', 'version': '1.0.0+1',
        'environment': {'sdk': '>=3.9.0 <4.0.0'},
        'dependencies': versions,
        'dev_dependencies': {name: {'sdk': 'flutter'} for name in ['flutter_test', 'integration_test']},
        'flutter': {'uses-material-design': True, 'assets': ['assets/backend-fixtures.json']},
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fixtures', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    output = args.output
    if not output.is_absolute() or output.exists() or output.is_symlink():
        raise ValueError('new_absolute_private_output_required')
    parent = output.parent.lstat()
    if not stat.S_ISDIR(parent.st_mode) or output.parent.is_symlink() or parent.st_uid != os.getuid() or parent.st_mode & 0o077:
        raise ValueError('private_owned_parent_required')
    if output.is_relative_to(REPOSITORY):
        raise ValueError('output_must_be_outside_repository')
    fixture = args.fixtures.read_bytes()
    decoded = json.loads(fixture)
    if len(fixture) > 2 * 1024 * 1024 or decoded.get('syntheticOnly') is not True or not isinstance(decoded.get('cases'), list):
        raise ValueError('bounded_synthetic_fixture_required')
    sources, dependencies = source_graph()
    os.umask(0o077)
    output.mkdir(mode=0o700)

    def save(path, data):
        dest = output / path
        dest.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        with dest.open('xb') as stream:
            stream.write(data)
        dest.chmod(0o600)

    for path, data in sources.items():
        save(path, data)
    save('pubspec.yaml', (json.dumps(package_spec(dependencies), indent=2) + '\n').encode())
    save('assets/backend-fixtures.json', fixture)
    for source, destination in [
        ('contract_suite.dart', 'test/contract_suite.dart'),
        ('host_entry.dart.fixture', 'test/legacy_provider_contract_test.dart'),
        ('device_entry.dart.fixture', 'integration_test/legacy_provider_contract_test.dart'),
    ]:
        save(destination, (HERE / source).read_bytes())
    manifest = {
        'schemaVersion': 1, 'historicalRevision': REVISION, 'historicalPackage': PACKAGE,
        'historicalSourceCount': len(sources), 'historicalSourceBytes': sum(map(len, sources.values())),
        'sources': {p: hashlib.sha256(b).hexdigest() for p, b in sorted(sources.items())},
        'fixtureSha256': hashlib.sha256(fixture).hexdigest(),
        'harness': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE / 'contract_suite.dart', HERE / 'host_entry.dart.fixture', HERE / 'device_entry.dart.fixture']},
        'applicationSourceChanged': False, 'historicalSourcesRewritten': False,
        'appMainNativeConfigurationOrCredentialsCopied': False,
        'transport': 'synthetic rejecting Dio adapter; native HttpClient creation denied',
    }
    save('provenance.json', (json.dumps(manifest, indent=2) + '\n').encode())
    print(json.dumps({k: manifest[k] for k in ['historicalRevision', 'historicalSourceCount', 'historicalSourceBytes', 'fixtureSha256', 'applicationSourceChanged', 'historicalSourcesRewritten']}))
    print('Prepared private historical parser package: ' + str(output))


if __name__ == '__main__':
    main()
