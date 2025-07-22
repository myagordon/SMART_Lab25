# Author: Lauro Ojeda, 2021
# Navigation Solutions LLC
# Requires Python >= 3 and bleak library
# Tested on MacOS by Mya Gordon on 7/07

from bleak import BleakClient
import asyncio
import struct
import signal
import sys
import numpy as np
import math
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

# Globals
g_quit = False
g_reset_requested = False
g_calibration_rotation_matrix = None
g_collecting_calibration = True
g_calibration_samples = []
g_calibration_count = 0
CALIBRATION_SAMPLE_COUNT = 15
#graphing variables
g_raw_x, g_raw_y = [], []
g_corrected_x, g_corrected_y = [], []
g_sample_count = 0
GRAPH_SAMPLE_COUNT = 50

osc_client = udp_client.SimpleUDPClient("127.0.0.1", 6800)

def signal_handler(sig, frame):
    global g_quit
    print('Quitting program!')
    g_quit = True

def osc_reset_handler(unused_addr, *args):
    global g_reset_requested
    print('reset command received')
    g_reset_requested = True

def rotation_matrix_z_radians(radians): # positive yaw results in cc rotation 
    c, s = math.cos(radians), math.sin(radians)
    return np.array([
        [c, -s, 0],
        [s,  c, 0],
        [0,  0, 1]
    ])

def plot_comparison():
    plt.figure(figsize=(8, 6))
    plt.scatter(g_raw_x, g_raw_y, c='blue', label='Raw')
    plt.scatter(g_corrected_x, g_corrected_y, c='red', label='Corrected')
    plt.xlabel('X (mm)')
    plt.ylabel('Y (mm)')
    plt.title('Raw vs Corrected XY')
    plt.legend()
    plt.axis('equal')
    plt.grid(True)
    plt.show()

#direct user to take one step forwards (~50cm) and then back
def calculate_forward_angle():
    global g_calibration_samples
    # find point w max distance from origin
    max_distance = 0
    max_point = None
    
    for x, y in g_calibration_samples:
        distance = math.sqrt(x*x + y*y)
        if distance > max_distance:
            max_distance = distance
            max_point = (x, y)
    
    # calc forward angle using inv. tan
    forward_angle = math.atan2(max_point[1], max_point[0])
    print(f"Forward angle: {math.degrees(forward_angle):.2f}°")
    return forward_angle

def notification_handler(sender, data):
    global g_calibration_rotation_matrix, g_collecting_calibration
    global g_raw_x, g_raw_y, g_corrected_x, g_corrected_y, g_sample_count
    global g_calibration_samples, g_calibration_count

    sample = struct.unpack('<H', data[0:2])[0]
    status = struct.unpack('B', data[2:3])[0]
    x = struct.unpack('<i', data[2:6])[0] / 256
    y = struct.unpack('<i', data[5:9])[0] / 256
    z = struct.unpack('<i', data[8:12])[0] / 256
    q0 = struct.unpack('<h', data[12:14])[0] / 32768
    q1 = struct.unpack('<h', data[14:16])[0] / 32768
    q2 = struct.unpack('<h', data[16:18])[0] / 32768
    q3 = struct.unpack('<h', data[18:20])[0] / 32768

    print(f"Sample: {sample} Status: {status} Pos: ({x:.1f},{y:.1f},{z:.1f}) Qua: ({q0:.3f},{q1:.3f},{q2:.3f},{q3:.3f})")

    if g_collecting_calibration:
        # Compute yaw, rotation about z axis, from calibration period
        g_calibration_samples.append((x,y))
        g_calibration_count+=1
        print(f"calibration sample {g_calibration_count}/{CALIBRATION_SAMPLE_COUNT}")
        
        if g_calibration_count>= CALIBRATION_SAMPLE_COUNT:
           forward_angle = calculate_forward_angle()
           #build rotation matrix using forward angle as yaw
           g_calibration_rotation_matrix = rotation_matrix_z_radians(-forward_angle)
           g_collecting_calibration = False
           print(f"calibration done")
        return

    g_raw_x.append(x)
    g_raw_y.append(y)

    pos_vec = np.array([x, y, z])
    corrected = g_calibration_rotation_matrix @ pos_vec #do matrix multiplication
    x_corr, y_corr, z_corr = corrected
    g_corrected_x.append(x_corr)
    g_corrected_y.append(y_corr)

    print(f"Corrected Pos: ({x_corr:.1f},{y_corr:.1f},{z_corr:.1f})")

    g_sample_count += 1
    if g_sample_count == GRAPH_SAMPLE_COUNT:
        print(f"plotting now...")
        plot_comparison()

    osc_client.send_message("/position", [x_corr, y_corr])

async def run(argv):
    global g_reset_requested
    global g_calibration_rotation_matrix, g_collecting_calibration
    global g_raw_x, g_raw_y, g_corrected_x, g_corrected_y, g_sample_count
    global g_calibration_samples, g_calibration_count

    if len(argv) < 2:
        print("Error: specify MAC address")
        sys.exit(1)
	#declare socket for reset command
    dispatcher = Dispatcher()
    dispatcher.map("/reset", osc_reset_handler)
    server = AsyncIOOSCUDPServer(("127.0.0.1", 6801), dispatcher, asyncio.get_event_loop())
    transport, protocol = await server.create_serve_endpoint()
    print("OSC server listening on port 6801")

    async with BleakClient(argv[1], timeout=4.0) as client:
        if client.is_connected:
            print("Sensor Connected")

        await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID, bytearray([CRTL_FOOTFALL_MODE]))
        print("Footfall mode")

        if ((len(argv) >= 3 and argv[2][0] == 'r') or (len(argv) == 4 and argv[3][0] == 'r')):
            await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID, bytearray([CRTL_RESET]))
            print("System reset")
            #reset calibration variables
            g_calibration_rotation_matrix = None
            g_collecting_calibration = True
            g_calibration_samples = []
            g_calibration_count=0
            g_raw_x, g_raw_y, g_corrected_x, g_corrected_y = [],[],[],[]
            g_sample_count = 0
        else:
            print("Did not reset")
            
		#wait for user to be ready for calibration
        input("Press Enter when ready to start calibration")

        await client.start_notify(DATA_CHARACTERISTIC_UUID, notification_handler) #start notifs after resetting 
        
        while not g_quit:
            if g_reset_requested: #complete remote reset request
                await client.write_gatt_char(CRTL_CHARACTERISTIC_UUID, bytearray([CRTL_RESET]))
                print("Reset via OSC")
                g_reset_requested = False
                g_calibration_rotation_matrix = None
                g_collecting_calibration = True
                g_calibration_samples = []
                g_calibration_count = 0
                g_raw_x, g_raw_y, g_corrected_x, g_corrected_y = [], [], [], []
                g_sample_count = 0
            await asyncio.sleep(0.1)

    transport.close()

print('Requires Python > 3')
print('Usage:\n\tpython3 getdata_rtfoot.py MAC_ADDRESS [r] [cFREQ]')
print('\tMAC_ADDRESS = Bluetooth address formated as XX:XX:XX:XX:XX:XX');
print('\tr = reset [optional]');
print('\tcFREQ = continious mode and frequency (FREQ: 25, 50, 100) [optional]');
print('\teg: python3 getdata_rtfoot.py 12:34:56:78:90:AB r c55');
signal.signal(signal.SIGINT, signal_handler)
asyncio.run(run(sys.argv))
