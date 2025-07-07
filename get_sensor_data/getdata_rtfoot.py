# Author: Lauro Ojeda, 2021
# Navigation Solutions LLC
# Requires Python >= 3 and blake library
# This program has been tested in Linux and Windows

#Tested on MacOS device by Mya Gordon on 7/07

from bleak import BleakClient
import asyncio
import struct
import signal
import sys
import time

# Constants
DATA_CHARACTERISTIC_UUID = "6d071524-e3b8-4428-b7b6-b3f59c38b7bb"
CRTL_CHARACTERISTIC_UUID = "6d071525-e3b8-4428-b7b6-b3f59c38b7bb"
CRTL_RESET = 0x64
CRTL_FOOTFALL_MODE = 0x65
CRTL_CONTINUOUS_MODE_25HZ = 0x66
CRTL_CONTINUOUS_MODE_50HZ = 0x67
CRTL_CONTINUOUS_MODE_100HZ = 0x68

# Global variables
g_quit = False

def signal_handler(sig, frame): # CTRL-C, quits (gracefully) closing BLE comms
	global g_quit
	print('Quitting program!')
	g_quit = True

def notification_handler(sender, data): # parse data packet
	# Packet size = 20
	# Packet structure
	# Sample(2), Status(1), X(3), Y(3), Z(3), Q0(2), Q1(2), Q2(2), Q3(2)

	# Sample number = data[0 ..1]
	sample = struct.unpack('<H', data[0:2])[0]
	print("Sample:", sample)

	# Status byte = data[2]
	status = struct.unpack('B', data[2:3])[0]
	print("Status:", status)

	# Position is provided using a 3-byte integer format in millimeters.
	# Use an auxiliary byte to simplify conversion,
	# because it is little endian (least significant first),
	# the extra byte must be included at the beginning.
	# To eliminate the effect of adding the additional byte,
	# the final solution is shifted to the right or dividing by 256
	# Positions: X=data[3..5], Y=data[6...8], Z=data[9...11]
	x = struct.unpack('<i',data[2:6])[0] / 256
	y = struct.unpack('<i',data[5:9])[0] / 256
	z = struct.unpack('<i',data[8:12])[0] / 256
	print ("Pos:", x, y, z)

	# Quaternions are provided using a short representation where 2^15 is equivalent to 1 (SF = 1/32768)
	# Quaternions:  Q0=data[12..13], Q1=data[14..15], Q2=data[16..17], Q3=data[18..19]
	q0 = float(struct.unpack('<h', data[12:14])[0]) / 32768
	q1 = float(struct.unpack('<h', data[14:16])[0]) / 32768
	q2 = float(struct.unpack('<h', data[16:18])[0]) / 32768
	q3 = float(struct.unpack('<h', data[18:20])[0]) / 32768
	print("Qua:", q0, q1, q2, q3)

async def run(argv): # BLE comms
	if(len(argv) == 1):
		print("Error: insufficient arguments")
		raise SystemExit
	async with BleakClient(argv[1], timeout = 4.0) as client:
		if client.is_connected:
			print("Sensor Connected")
		if((len(argv) >= 3 and argv[2][0] == 'c') or (len(argv) == 4 and argv[3][0] == 'c')):
			freq = argv[2][1:] if(argv[2][0] == 'c') else argv[3][1:]
			if(freq == '25'):
				await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID,  bytearray([CRTL_CONTINUOUS_MODE_25HZ]))
			elif(freq == '50'):
				await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID,  bytearray([CRTL_CONTINUOUS_MODE_50HZ]))
			elif(freq == '100'):
				await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID,  bytearray([CRTL_CONTINUOUS_MODE_100HZ]))
			else:
				print("Error: incorrect continious mode argument")
				raise SystemExit
			print('Continuous mode freq: ' + freq)
		else:
			await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID,  bytearray([CRTL_FOOTFALL_MODE]))
			print('Footfall mode')

		if((len(argv) >= 3 and argv[2][0] == 'r') or (len(argv) == 4 and argv[3][0] == 'r')):
			await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID,  bytearray([CRTL_RESET]))
			print('System was reset')
		else:
			print('Did not reset system')

		# Start streaming
		await client.start_notify(DATA_CHARACTERISTIC_UUID, notification_handler)
		while (not g_quit): # quit with CRTL-C
			await asyncio.sleep(1.0)

# Main program
print('Requires Python > 3');
print('Usage:\n\tpython3 getdata_rtfoot.py MAC_ADDRESS [r] [cFREQ]')
print('\tMAC_ADDRESS = Bluetooth address formated as XX:XX:XX:XX:XX:XX');
print('\tr = reset [optional]');
print('\tcFREQ = continious mode and frequency (FREQ: 25, 50, 100) [optional]');
print('\teg: python3 getdata_rtfoot.py 12:34:56:78:90:AB r c55');
signal.signal(signal.SIGINT, signal_handler)
asyncio.run(run(sys.argv))
