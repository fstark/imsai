import serial
import os
import sys
import time

def print_serial_available(ser):
    """Read and print all available data from the serial port."""
    while ser.in_waiting:
        data = ser.read(ser.in_waiting)
        if data:
            print(data.decode(errors="replace"), end="", flush=True)
        time.sleep(0.01)

def sendhexfile(ser, filename):
    if not os.path.isfile(filename):
        print(f"File not found: {filename}")
        return
    print(f"Sending file: {filename}")
    with open(filename, 'rb') as f:
        while True:
            byte = f.read(1)
            if not byte:
                break
            ser.write(byte)
            time.sleep(0.01)
            print_serial_available(ser)

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <hexfile>")
        return
    filename = sys.argv[1]
    ser = serial.Serial('/dev/ttyUSB0', baudrate=9600, bytesize=8, parity='N', stopbits=1, timeout=1)
    print("Listening on /dev/ttyUSB0 at 9600 8N1... (Ctrl+C to quit)")
    try:
        print_serial_available(ser)
        sendhexfile(ser, filename)
        print("Reading serial port (Ctrl+C to stop)...")
        while True:
            print_serial_available(ser)
            time.sleep(0.1)
    except Exception as e:
        print(f"Error ({e})")
    except KeyboardInterrupt:
        print("\nExiting.")
    finally:
        ser.close()

if __name__ == "__main__":
    main()
