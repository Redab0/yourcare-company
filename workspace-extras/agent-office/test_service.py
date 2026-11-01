import unittest
from pathlib import Path
from service import HERE, belongs_to_office, configuration


class ServiceTests(unittest.TestCase):
    def test_launchd_owns_process_and_restarts_it(self):
        config = configuration(Path('/tmp/robot-office-test'))
        self.assertTrue(config['KeepAlive'])
        self.assertTrue(config['RunAtLoad'])
        self.assertEqual(config['WorkingDirectory'], str(HERE))
        self.assertEqual(config['ProgramArguments'][1], str(HERE / 'server.py'))
        self.assertTrue(Path(config['ProgramArguments'][0]).is_absolute())
        self.assertTrue(belongs_to_office(config))

    def test_unrelated_service_cannot_be_replaced(self):
        self.assertFalse(belongs_to_office({'Label': 'local.robot-office', 'ProgramArguments': ['/bin/something-else']}))
        self.assertFalse(belongs_to_office({'Label': 'other-service', 'ProgramArguments': [str(HERE / 'server.py')]}))


if __name__ == '__main__':
    unittest.main()
