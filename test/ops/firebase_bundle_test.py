import base64
import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/configure_firebase_bundle.py'
spec = importlib.util.spec_from_file_location('firebase_bundle', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class FirebaseBundleTests(unittest.TestCase):
    def test_development_omits_config_and_production_restores_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'source.plist'
            output = root / 'app/GoogleService-Info.plist'
            source.write_text('fixture-configuration')
            module.configure('production', source, output)
            self.assertEqual(output.read_text(), source.read_text())
            module.configure('development', source, output)
            self.assertFalse(output.exists())
            self.assertTrue(source.exists())
            module.configure('production', source, output)
            self.assertEqual(output.read_text(), source.read_text())
            with self.assertRaises(ValueError):
                module.configure('developmnt', source, output)

    def test_development_requires_exact_debug_and_opt_in_strings(self):
        flags = ('true', 'false', '', 'TRUE', '1', True, None)
        configurations = ('Debug', 'Release', 'Profile', '', 'debug', 'Debug-dev')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'source.plist'
            output = root / 'app/GoogleService-Info.plist'
            source.write_bytes(b'private synthetic configuration')
            output.parent.mkdir()
            for flag in flags:
                for configuration in configurations:
                    with self.subTest(flag=flag, configuration=configuration):
                        output.write_bytes(b'stale output')
                        module.configure('development', source, output, flag, configuration)
                        if flag == 'true' and configuration == 'Debug':
                            self.assertEqual(output.read_bytes(), source.read_bytes())
                        else:
                            self.assertFalse(output.exists())
                        self.assertEqual(source.read_bytes(), b'private synthetic configuration')

    def test_opted_in_debug_copies_to_new_resources_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'source.plist'
            output = root / 'new app/Resources/GoogleService-Info.plist'
            source.write_bytes(b'\x00synthetic plist\xff')
            module.configure('development', source, output, 'true', 'Debug')
            self.assertEqual(output.read_bytes(), source.read_bytes())

    def test_missing_opted_in_source_fails_and_removes_stale_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'missing.plist'
            output = root / 'stale.plist'
            output.write_text('stale output')
            with self.assertRaisesRegex(FileNotFoundError, 'requires a private Firebase plist'):
                module.configure('development', source, output, 'true', 'Debug')
            self.assertFalse(output.exists())
            self.assertFalse(source.exists())

    def test_ordinary_development_needs_no_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'missing.plist'
            output = root / 'stale.plist'
            output.write_text('stale output')
            module.configure('development', source, output)
            self.assertFalse(output.exists())

    def test_production_ignores_development_switches(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'source.plist'
            output = root / 'app/GoogleService-Info.plist'
            source.write_text('production fixture')
            for flag in ('true', 'false', ''):
                for configuration in ('Debug', 'Release', 'Profile', ''):
                    with self.subTest(flag=flag, configuration=configuration):
                        module.configure('production', source, output, flag, configuration)
                        self.assertEqual(output.read_text(), 'production fixture')

    def test_production_missing_source_keeps_existing_behavior(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'missing.plist'
            output = root / 'existing.plist'
            module.configure('production', source, output, 'true', 'Debug')
            self.assertFalse(output.exists())
            output.write_text('existing output')
            module.configure('production', source, output, 'true', 'Debug')
            self.assertEqual(output.read_text(), 'existing output')

    def test_invalid_environment_does_not_mutate_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'source.plist'
            output = root / 'existing.plist'
            source.write_text('source fixture')
            output.write_text('existing output')
            with self.assertRaises(ValueError):
                module.configure('Development', source, output, 'true', 'Debug')
            self.assertEqual(source.read_text(), 'source fixture')
            self.assertEqual(output.read_text(), 'existing output')

    def _run_entrypoint(self, root, definitions, configuration=None, extra_environment=None):
        environment = {
            'SRCROOT': str(root / 'ios source'),
            'TARGET_BUILD_DIR': str(root / 'build output'),
            'UNLOCALIZED_RESOURCES_FOLDER_PATH': 'Runner.app',
            'DART_DEFINES': ','.join(
                base64.b64encode(value.encode()).decode() for value in definitions
            ),
            'PYTHONDONTWRITEBYTECODE': '1',
        }
        if configuration is not None:
            environment['CONFIGURATION'] = configuration
        environment.update(extra_environment or {})
        return subprocess.run(
            [sys.executable, '-B', str(SCRIPT)],
            env=environment,
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def test_main_decodes_dart_defines_and_applies_xcode_policy(self):
        cases = (
            (('API_ENV=development', 'DEV_PUSH_TEST=true'), 'Debug', True),
            (('API_ENV=development', 'DEV_PUSH_TEST=true'), 'Release', False),
            (('API_ENV=development', 'DEV_PUSH_TEST=true'), 'Profile', False),
            (('API_ENV=development', 'DEV_PUSH_TEST=true'), None, False),
            (('API_ENV=development', 'DEV_PUSH_TEST=true'), 'Debug-dev', False),
            (('API_ENV=development', 'DEV_PUSH_TEST=false'), 'Debug', False),
            (('API_ENV=development', 'DEV_PUSH_TEST=TRUE'), 'Debug', False),
            (('API_ENV=development',), 'Debug', False),
            (('API_ENV=production', 'DEV_PUSH_TEST=false'), 'Release', True),
            ((), 'Debug', True),
        )
        for definitions, configuration, included in cases:
            with self.subTest(definitions=definitions, configuration=configuration):
                with tempfile.TemporaryDirectory() as directory:
                    root = Path(directory)
                    source = root / 'ios source/Runner/GoogleService-Info.plist'
                    output = root / 'build output/Runner.app/GoogleService-Info.plist'
                    source.parent.mkdir(parents=True)
                    source.write_text('entrypoint synthetic fixture')
                    output.parent.mkdir(parents=True)
                    output.write_text('stale output')
                    result = self._run_entrypoint(root, definitions, configuration)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stdout, '')
                    if included:
                        self.assertEqual(output.read_bytes(), source.read_bytes())
                    else:
                        self.assertFalse(output.exists())

    def test_main_requires_encoded_flag_not_plain_environment_variable(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'ios source/Runner/GoogleService-Info.plist'
            output = root / 'build output/Runner.app/GoogleService-Info.plist'
            source.parent.mkdir(parents=True)
            source.write_text('synthetic fixture')
            result = self._run_entrypoint(
                root, ('API_ENV=development',), 'Debug', {'DEV_PUSH_TEST': 'true'}
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(output.exists())

    def test_main_opted_in_missing_private_input_fails_clearly(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / 'build output/Runner.app/GoogleService-Info.plist'
            output.parent.mkdir(parents=True)
            output.write_text('stale output')
            result = self._run_entrypoint(
                root, ('API_ENV=development', 'DEV_PUSH_TEST=true'), 'Debug'
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('requires a private Firebase plist', result.stderr)
            self.assertEqual(result.stdout, '')
            self.assertFalse(output.exists())


if __name__ == '__main__':
    unittest.main()
