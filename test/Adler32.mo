import Blob "mo:base/Blob";
import Text "mo:base/Text";

import Adler32 "../src/Adler32";

import Debug "mo:base/Debug";

type Test = {
    bs   : Text;
    hash : Nat32;
};

let tests : [Test] = [
    { bs = ""; hash = 0x00000001 },
    { bs = "a"; hash = 0x00620062 },
    { bs = "ab"; hash = 0x012600c4 },
    { bs = "abc"; hash = 0x024d0127 },
    { bs = "abcd"; hash = 0x03d8018b },
    { bs = "abcde"; hash = 0x05c801f0 },
    { bs = "abcdef"; hash = 0x081e0256 },
    { bs = "abcdefg"; hash = 0x0adb02bd },
    { bs = "abcdefgh"; hash = 0x0e000325 },
    { bs = "abcdefghi"; hash = 0x118e038e },
    { bs = "abcdefghij"; hash = 0x158603f8 },
];

for (t in tests.vals()) {
    let p = Text.encodeUtf8(t.bs);
    let cs = Adler32.checksum(Blob.toArray(p));
    if (cs != t.hash) assert(false);
};
