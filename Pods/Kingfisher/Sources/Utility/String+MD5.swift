//
//  String+MD5.swift
//  Kingfisher
//
//  Created by Wei Wang on 18/09/25.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import CommonCrypto
import Foundation

extension String: KingfisherCompatibleValue {}
extension KingfisherWrapper where Base == String {
    var md5: String {
        guard let data = base.data(using: .utf8) else {
            return base
        }

        let message = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            [UInt8](bytes)
        }

        let MD5Calculator = MD5(message)
        let MD5Data = MD5Calculator.calculate()

        var MD5String = String()
        for c in MD5Data {
            MD5String += String(format: "%02x", c)
        }
        return MD5String
    }

    var ext: String? {
        guard let firstSeg = base.split(separator: "@").first else {
            return nil
        }

        var ext = ""
        if let index = firstSeg.lastIndex(of: ".") {
            let extRange = firstSeg.index(index, offsetBy: 1) ..< firstSeg.endIndex
            ext = String(firstSeg[extRange])
        }
        return ext.count > 0 ? ext : nil
    }
}

// array of bytes, little-endian representation
func arrayOfBytes<T>(_ value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)

    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value

    let bytes = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) { bytesPointer -> [UInt8] in
        var bytes = [UInt8](repeating: 0, count: totalBytes)
        for j in 0 ..< min(MemoryLayout<T>.size, totalBytes) {
            bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
        }
        return bytes
    }

    valuePointer.deinitialize(count: 1)
    valuePointer.deallocate()

    return bytes
}

extension Int {
    // Array of bytes with optional padding (little-endian)
    func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
}

protocol HashProtocol {
    var message: [UInt8] { get }
    // Common part for hash calculation. Prepare header data.
    func prepare(_ len: Int) -> [UInt8]
}

extension HashProtocol {
    func prepare(_ len: Int) -> [UInt8] {
        var tmpMessage = message

        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (UInt8 with one bit) to message

        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0

        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }

        tmpMessage += [UInt8](repeating: 0, count: counter)
        return tmpMessage
    }
}

func toUInt32Array(_ slice: ArraySlice<UInt8>) -> [UInt32] {
    var result = [UInt32]()
    result.reserveCapacity(16)

    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
        let d0 = UInt32(slice[idx.advanced(by: 3)]) << 24
        let d1 = UInt32(slice[idx.advanced(by: 2)]) << 16
        let d2 = UInt32(slice[idx.advanced(by: 1)]) << 8
        let d3 = UInt32(slice[idx])
        let val: UInt32 = d0 | d1 | d2 | d3

        result.append(val)
    }
    return result
}

struct BytesIterator: IteratorProtocol {
    let chunkSize: Int
    let data: [UInt8]

    init(chunkSize: Int, data: [UInt8]) {
        self.chunkSize = chunkSize
        self.data = data
    }

    var offset = 0

    mutating func next() -> ArraySlice<UInt8>? {
        let end = min(chunkSize, data.count - offset)
        let result = data[offset ..< offset + end]
        offset += result.count
        return result.count > 0 ? result : nil
    }
}

struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]

    func makeIterator() -> BytesIterator {
        return BytesIterator(chunkSize: chunkSize, data: data)
    }
}

func rotateLeft(_ value: UInt32, bits: UInt32) -> UInt32 {
    return ((value << bits) & 0xFFFF_FFFF) | (value >> (32 - bits))
}

class MD5: HashProtocol {
    let message: [UInt8]

    init(_ message: [UInt8]) {
        self.message = message
    }

    // specifies the per-round shift amounts
    private let shifts: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]

    // binary integer part of the sines of integers (Radians)
    private let sines: [UInt32] = [0xD76A_A478, 0xE8C7_B756, 0x2420_70DB, 0xC1BD_CEEE,
                                   0xF57C_0FAF, 0x4787_C62A, 0xA830_4613, 0xFD46_9501,
                                   0x6980_98D8, 0x8B44_F7AF, 0xFFFF_5BB1, 0x895C_D7BE,
                                   0x6B90_1122, 0xFD98_7193, 0xA679_438E, 0x49B4_0821,
                                   0xF61E_2562, 0xC040_B340, 0x265E_5A51, 0xE9B6_C7AA,
                                   0xD62F_105D, 0x0244_1453, 0xD8A1_E681, 0xE7D3_FBC8,
                                   0x21E1_CDE6, 0xC337_07D6, 0xF4D5_0D87, 0x455A_14ED,
                                   0xA9E3_E905, 0xFCEF_A3F8, 0x676F_02D9, 0x8D2A_4C8A,
                                   0xFFFA_3942, 0x8771_F681, 0x6D9D_6122, 0xFDE5_380C,
                                   0xA4BE_EA44, 0x4BDE_CFA9, 0xF6BB_4B60, 0xBEBF_BC70,
                                   0x289B_7EC6, 0xEAA1_27FA, 0xD4EF_3085, 0x4881D05,
                                   0xD9D4_D039, 0xE6DB_99E5, 0x1FA2_7CF8, 0xC4AC_5665,
                                   0xF429_2244, 0x432A_FF97, 0xAB94_23A7, 0xFC93_A039,
                                   0x655B_59C3, 0x8F0C_CC92, 0xFFEF_F47D, 0x8584_5DD1,
                                   0x6FA8_7E4F, 0xFE2C_E6E0, 0xA301_4314, 0x4E08_11A1,
                                   0xF753_7E82, 0xBD3A_F235, 0x2AD7_D2BB, 0xEB86_D391]

    private let hashes: [UInt32] = [0x6745_2301, 0xEFCD_AB89, 0x98BA_DCFE, 0x1032_5476]

    func calculate() -> [UInt8] {
        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)

        // hash values
        var hh = hashes

        // Step 2. Append Length a 64-bit representation of lengthInBits
        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reversed()

        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64

        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            let M = toUInt32Array(chunk)
            assert(M.count == 16, "Invalid array")

            // Initialize hash value for this chunk:
            var A: UInt32 = hh[0]
            var B: UInt32 = hh[1]
            var C: UInt32 = hh[2]
            var D: UInt32 = hh[3]

            var dTemp: UInt32 = 0

            // Main loop
            for j in 0 ..< sines.count {
                var g = 0
                var F: UInt32 = 0

                switch j {
                case 0 ... 15:
                    F = (B & C) | ((~B) & D)
                    g = j
                case 16 ... 31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                case 32 ... 47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                case 48 ... 63:
                    F = C ^ (B | ~D)
                    g = (7 * j) % 16
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft(A &+ F &+ sines[j] &+ M[g], bits: shifts[j])
                A = dTemp
            }

            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)

        for item in hh {
            let itemLE = item.littleEndian
            let r1 = UInt8(itemLE & 0xFF)
            let r2 = UInt8((itemLE >> 8) & 0xFF)
            let r3 = UInt8((itemLE >> 16) & 0xFF)
            let r4 = UInt8((itemLE >> 24) & 0xFF)
            result += [r1, r2, r3, r4]
        }
        return result
    }
}
