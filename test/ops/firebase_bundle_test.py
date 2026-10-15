import importlib.util
from pathlib import Path
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


if __name__ == '__main__':
    unittest.main()
