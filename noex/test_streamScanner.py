import unittest
from unittest import TestCase
from noex import StreamScanner

class TestStreamScanner(TestCase):
    def test_construction(self):
        scanner = StreamScanner("foo")
        self.assertEqual("foo", scanner.target_string)
        self.assertEqual(3, scanner.target_len)
        self.assertFalse(scanner.found_target)

    def test_single_char(self):
        scanner = StreamScanner("a")
        scanner.injest("a")
        self.assertTrue(scanner.found_target)

    def test_multi_char(self):
        scanner = StreamScanner("hello world")
        scanner.injest("hello")
        scanner.injest(" ")
        self.assertFalse(scanner.found_target)
        scanner.injest("worl")
        self.assertFalse(scanner.found_target)
        scanner.injest("d")
        self.assertTrue(scanner.found_target)

    def test_extra_stuff(self):
        scanner = StreamScanner("hello world")
        self.assertFalse(scanner.found_target)
        scanner.injest("abchello world")
        self.assertTrue(scanner.found_target)
        scanner.injest("extra stuff")
        self.assertTrue(scanner.found_target)

if __name__ == '__main__':
    unittest.main()
