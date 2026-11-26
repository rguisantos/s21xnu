import struct
import unittest

from mkpayload import brcmf_nvram


class NvramLayout(unittest.TestCase):
    def test_all_four_lengths(self):
        for count in range(4):
            with self.subTest(count=count):
                value = b'x' * count
                nvram = brcmf_nvram(b'# ignored\nboardrev=1\nkey=' + value + b'\n')
                entries = b'boardrev=1\0key=' + value + b'\0'
                body, trailer = nvram[:-4], nvram[-4:]
                self.assertTrue(body.startswith(entries))
                self.assertIn(body[len(entries):], [bytes(n) for n in range(1, 5)])
                self.assertEqual(len(body) % 4, 0)
                words, inverse = struct.unpack('<HH', trailer)
                self.assertEqual(words * 4, len(body))
                self.assertEqual(words ^ inverse, 0xffff)

    def test_word_count_overflow(self):
        with self.assertRaisesRegex(ValueError, 'length token'):
            brcmf_nvram(b'key=' + b'x' * (4 * 65535))


if __name__ == '__main__':
    unittest.main()
