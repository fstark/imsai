import serial
import os

def readhex2(ser):
    buf = bytearray()
    while True:
        b = ser.read(1)
        if not b:
            continue  # Timeout, keep waiting
        buf += b
        if b == b'\r':
            break
    return buf

def sendhexfile(ser, number):
    filename = f"boot/{number:02x}.hex"
    if not os.path.isfile(filename):
        print(f"File not found: {filename}")
        return
    print(f"Sending file: {filename}")
    with open(filename, 'rb') as f:
        while True:
            chunk = f.read(64)
            if not chunk:
                break
            ser.write(chunk)
    print(f"Done sending {filename}")

def main():
    # Open serial port with 9600 baud, 8 data bits, no parity, 1 stop bit
    ser = serial.Serial('/dev/ttyUSB0', baudrate=9600, bytesize=8, parity='N', stopbits=1, timeout=1)
    print("Listening on /dev/ttyUSB0 at 9600 8N1... (Ctrl+C to quit)")
    try:
        while True:
            buf = readhex2(ser)
            # Try to parse as 2-digit hex
            try:
                s = buf.decode(errors='replace').strip('\r')
                if len(s) == 2:
                    value = int(s, 16)
                    print(f"Parsed hex value: 0x{value:02X} ({value})")
                    sendhexfile(ser, value)
                else:
                    print(f"Input is not 2 hex digits: {s!r}")
            except Exception as e:
                print(f"Error parsing input: {buf!r} ({e})")
    except KeyboardInterrupt:
        print("\nExiting.")
    finally:
        ser.close()

if __name__ == "__main__":
    main()
