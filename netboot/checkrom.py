def check_bytes(filename):
    with open(filename, 'rb') as file:
        offset = 0
        while byte := file.read(1):
            byte_value = ord(byte)
            if offset & 0x40:  # Check if bit 6 is set in the offset
                if byte_value != 0x00:
                    print(f"Byte at offset {offset:#04x} is {byte_value:#04x}, expected 0x00")
                    return False
            offset += 1
    # print("All bytes at offsets with bit 6 set are 0x00")
    return True

if __name__ == "__main__":
    filename = "../ROMs/debug.bin"
    check_bytes(filename)
