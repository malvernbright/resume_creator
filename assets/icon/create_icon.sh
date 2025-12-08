#!/bin/bash
# Create a simple colored square as icon
python3 << 'PYTHON_EOF'
import struct
import zlib

def create_png(width, height, rgb):
    def chunk(header, data):
        return struct.pack(">I", len(data)) + header + data + struct.pack(">I", zlib.crc32(header + data) & 0xffffffff)
    
    # PNG signature
    png = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    png += chunk(b'IHDR', ihdr)
    
    # IDAT chunk - raw image data
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # filter type
        raw_data += (bytes(rgb) * width)
    
    png += chunk(b'IDAT', zlib.compress(raw_data, 9))
    
    # IEND chunk
    png += chunk(b'IEND', b'')
    
    return png

# Create purple icon (RGB: 156, 91, 175)
icon_data = create_png(1024, 1024, (156, 91, 175))

with open('icon.png', 'wb') as f:
    f.write(icon_data)

print("Icon created successfully!")
PYTHON_EOF
