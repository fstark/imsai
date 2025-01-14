import socket
from time import sleep

def send_byte( client_socket, byte, delay=1):
    print( f"Sending byte: {byte:#02x}" )
    client_socket.sendall( bytes([byte]) )
    sleep( delay )

def send_boot( client_socket ):
    send_byte( client_socket, 0x23, 1 )
    sleep( 2 ) # Size
    send_byte( client_socket, 0x03, 1 )
    send_byte( client_socket, 0x00, 1 )
    sleep( 2 ) # Adrs
    send_byte( client_socket, 0x00, 1 )
    send_byte( client_socket, 0x08, 1 )
    sleep( 2 ) # Data
    send_byte( client_socket, 0xc3, 1 )
    send_byte( client_socket, 0x00, 1 )
    send_byte( client_socket, 0xa0, 1 )

    sleep( 10 )
    while True:
        client_socket.sendall( bytes([0x00]) )

# Send data to the client, very slowly
def send_data( client_socket, data ):
    # Send data byte per byte
    for b in data:
        send_byte( client_socket, bytes([b]), 1 )

def start_server():
    host = '0.0.0.0'
    port = 8080

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server_socket.bind((host, port))
        server_socket.listen(1)
        print(f"Server listening on {host}:{port}")

        while True:
            client_socket, client_address = server_socket.accept()
            with client_socket:
                print(f"Connection from {client_address}")
                while True:
                    data = ""
                    while True:
                        packet = client_socket.recv(1024).decode('utf-8')
                        if not packet:
                            break
                        data += packet
                        if "\r" in data or "\n" in data:
                            break
                    if not data:
                        break
                    if data.strip() == "BOOT":
                        print( f"Received command: {data.strip()}" )
                        sleep( 1 )
                        print( f"Sendind BOOT file" )
                        # send_data( client_socket, b"#\x01\x00\xc3\x00\xa0")
                        send_boot( client_socket )
                        print( f"BOOT file sent" )
                        break
                    else:
                        client_socket.sendall(b"Invalid command\n\r")
                print( f"Connection from {client_address} closed" )


if __name__ == "__main__":
    start_server()
