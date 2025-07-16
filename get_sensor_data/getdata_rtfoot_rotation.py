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
#import time
import numpy as np
from pythonosc import udp_client 
from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
import matplotlib.pyplot as plt

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
g_reset_requested = False  # Flag for OSC reset requests

# Tilt correction variables
g_calibration_rotation_matrix = None
g_collecting_calibration = True

# Graphing variables
g_raw_x = []
g_raw_y = []
g_corrected_x = []
g_corrected_y = []
g_sample_count = 0
GRAPH_SAMPLE_COUNT = 50

# OSC client setup (NEW)
osc_client = udp_client.SimpleUDPClient("127.0.0.1", 6800)

def signal_handler(sig, frame): # CTRL-C, quits (gracefully) closing BLE comms
	global g_quit
	print('Quitting program!')
	g_quit = True

# OSC handler for reset commands
def osc_reset_handler(unused_addr, *args):
	global g_reset_requested
	print('OSC reset command received')
	g_reset_requested = True

def quaternion_to_rotation_matrix(q0, q1, q2, q3):
	"""Convert quaternion to rotation matrix"""
	# Normalize quaternion
	norm = np.sqrt(q0*q0 + q1*q1 + q2*q2 + q3*q3)
	if norm > 0:
		q0, q1, q2, q3 = q0/norm, q1/norm, q2/norm, q3/norm
	
	# Create rotation matrix
	R = np.array([
		[1 - 2*(q2*q2 + q3*q3), 2*(q1*q2 - q0*q3), 2*(q1*q3 + q0*q2)],
		[2*(q1*q2 + q0*q3), 1 - 2*(q1*q1 + q3*q3), 2*(q2*q3 - q0*q1)],
		[2*(q1*q3 - q0*q2), 2*(q2*q3 + q0*q1), 1 - 2*(q1*q1 + q2*q2)]
	])
	return R

#included this for testing, we should take this out if we decide to use this
def plot_comparison():
	#Plot raw vs corrected positions
	plt.figure(figsize=(15, 6))
	
	# Scatter plot 
	plt.subplot(1, 3, 3)
	plt.scatter(g_raw_x, g_raw_y, c='blue', alpha=0.6, s=20, label='Raw Path')
	plt.scatter(g_corrected_x, g_corrected_y, c='red', alpha=0.6, s=20, label='Corrected Path')
	plt.xlabel('X Position (mm)')
	plt.ylabel('Y Position (mm)')
	plt.title('Movement Path (X vs Y)')
	plt.legend()
	plt.grid(True, alpha=0.3)
	plt.axis('equal')  # Equal aspect ratio to show true path shape
	
	plt.tight_layout()
	plt.show()
	
    
def rotation_matrix_z(degrees):
    """Create a 3x3 rotation matrix for rotation around Z-axis by degrees."""
    radians = np.radians(degrees)
    cos = np.cos(radians)
    sin = np.sin(radians)
    return np.array([
        [cos, -sin, 0],
        [sin,  cos, 0],
        [0,    0,   1]
    ])

def notification_handler(sender, data): # parse data packet
    global g_calibration_rotation_matrix, g_collecting_calibration
    global g_raw_x, g_raw_y, g_corrected_x, g_corrected_y, g_sample_count

    # Packet structure
    sample = struct.unpack('<H', data[0:2])[0]
    status = struct.unpack('B', data[2:3])[0]

    x = struct.unpack('<i',data[2:6])[0] / 256
    y = struct.unpack('<i',data[5:9])[0] / 256
    z = struct.unpack('<i',data[8:12])[0] / 256

    q0 = float(struct.unpack('<h', data[12:14])[0]) / 32768
    q1 = float(struct.unpack('<h', data[14:16])[0]) / 32768
    q2 = float(struct.unpack('<h', data[16:18])[0]) / 32768
    q3 = float(struct.unpack('<h', data[18:20])[0]) / 32768

    print(f"Sample: {sample} Status: {status} Pos: ({x:.2f}, {y:.2f}, {z:.2f}) Qua: ({q0:.3f}, {q1:.3f}, {q2:.3f}, {q3:.3f})")

    if g_collecting_calibration:
        R_calib = quaternion_to_rotation_matrix(q0, q1, q2, q3)
        R_inv = R_calib.T  # inverse of calibration quaternion

        # apply fixed additional correction: 10 degrees about Z
        R_fixed = rotation_matrix_z(10)

        # combine: first undo calibration rotation, then apply fixed correction
        g_calibration_rotation_matrix = R_fixed @ R_inv

        g_collecting_calibration = False
        print("Calibration complete. Applied fixed -10° Z rotation.")
        return  # skip sending first sample

    # store raw for graph
    g_raw_x.append(x)
    g_raw_y.append(y)

    # correct
    pos_vec = np.array([x, y, z])
    corrected = g_calibration_rotation_matrix @ pos_vec
    x_corr, y_corr, z_corr = corrected

    g_corrected_x.append(x_corr)
    g_corrected_y.append(y_corr)

    print(f"Corrected Pos: ({x_corr:.2f}, {y_corr:.2f}, {z_corr:.2f})")

    # plot if enough samples
    g_sample_count += 1
    if g_sample_count == GRAPH_SAMPLE_COUNT:
        print(f"Reached {GRAPH_SAMPLE_COUNT} samples - generating comparison plot...")
        plot_comparison()

    osc_client.send_message("/position", [x_corr, y_corr])

async def run(argv): # BLE comms
	global g_reset_requested  # Access global variable
	global g_calibration_rotation_matrix, g_collecting_calibration
	global g_raw_x, g_raw_y, g_corrected_x, g_corrected_y, g_sample_count
	
	if(len(argv) == 1):
		print("Error: insufficient arguments")
		raise SystemExit
	
	# Setup OSC server before BLE connection to listen for reset command
	dispatcher = Dispatcher()
	dispatcher.map("/reset", osc_reset_handler)
	server = AsyncIOOSCUDPServer(("127.0.0.1", 6801), dispatcher, asyncio.get_event_loop())
	transport, protocol = await server.create_serve_endpoint()
	print("OSC server listening on port 6801 for /reset commands")

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
			# Check for OSC reset requests
			if g_reset_requested:
				await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID,  bytearray([CRTL_RESET]))
				print('System was reset via OSC')
				g_reset_requested = False
				
				# Reset calibration after OSC reset
				g_calibration_rotation_matrix = None
				g_collecting_calibration = True
				print("Restarting calibration after reset...")
				
				# Reset graphing data
				g_raw_x = []
				g_raw_y = []
				g_corrected_x = []
				g_corrected_y = []
				g_sample_count = 0
				
			await asyncio.sleep(0.1)  # Shorter sleep for more responsive reset
		
		# Close OSC server
		transport.close()

# Main program
print('Requires Python > 3');
print('Usage:\n\tpython3 getdata_rtfoot.py MAC_ADDRESS [r] [cFREQ]')
print('\tMAC_ADDRESS = Bluetooth address formated as XX:XX:XX:XX:XX:XX');
print('\tr = reset [optional]');
print('\tcFREQ = continious mode and frequency (FREQ: 25, 50, 100) [optional]');
print('\teg: python3 getdata_rtfoot.py 12:34:56:78:90:AB r c55');
print('\tSend OSC message to /reset on port 6801 to reset sensor remotely');
print(f'\tGraphing: will display raw vs corrected X,Y positions after {GRAPH_SAMPLE_COUNT} samples');
signal.signal(signal.SIGINT, signal_handler)
asyncio.run(run(sys.argv))
