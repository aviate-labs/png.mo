import Array "mo:base/Array";
import Array_ "mo:array/Array";
import Binary "mo:encoding/Binary";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";

import Debug "mo:base/Debug";

module {
    // Largest prime that is less than 65536.
    private let mod : Nat32 = 65521;
    // Largest n such that: 255 * n * (n+1) / 2 + (n+1) * (mod-1) <= 2^32-1.
    private let nmax : Nat32 = 5552;

    private let magic : [Nat8] = [0x61, 0x64, 0x6c, 0x01];

    public func checksum(bs : [Nat8]) : Nat32 {
        let h = New();
        h.write(bs);
        h.sum32();       
    };

    func checksumSlow(bs : [Nat8]) : Nat32 {
        // RFC 1950: Section 9
        var s1 : Nat32 = 1;
        var s2 : Nat32 = 0;
        for (x in bs.vals()) {
            s1 := (s1 + nat8to32(x)) % mod;
            s2 := (s2 + s1) % mod;
        };
        s2 << 16 | s1;
    };

    public class New() {
        var hash : Nat32 = 1;
        
        public func size() : Nat { 4 };

        public func blockSize() : Nat { 4 };

        public func reset() { hash := 1 };

        public func write(bs : [Nat8]) {
            var s1 = hash & 0xFFFF;
            var s2 = hash >> 16;
            
            var p = bs;
            while (0 < p.size()) {
                var q : [Nat8] = [];

                let n = Nat32.toNat(nmax);
                if (n < p.size()) {
                    let (p_, q_) = Array_.split<Nat8>(p, n);
                    p := p_;
                    q := q_;
                };
                while (4 <= p.size()) {
                    var i = 0;
                    while (i < 4) {
                        s1 +%= nat8to32(p[i]);
                        s2 +%= s1;
                        i += 1
                    };
                    p := Array_.drop(p, 4);
                };
                for (x in p.vals()) {
                    s1 +%= nat8to32(x);
                    s2 +%= s1;
                };
                s1 %= mod;
                s2 %= mod;
                p := q;
            };
            hash := s2 << 16 | s1;
        };

        public func sum32() : Nat32 { hash };

        public func sum(bs : [Nat8]) : [Nat8] {
            Array.append<Nat8>(bs, Binary.BigEndian.fromNat32(hash));
        };
    };

    private func nat8to32(n : Nat8) : Nat32 {
        Nat32.fromNat(Nat8.toNat(n));
    };
};
