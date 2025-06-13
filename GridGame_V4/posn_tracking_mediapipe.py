import cv2
import mediapipe as mp #must download mediapipe library to access llm
import math
import socket

# udp setup. socket is good bec it's highly modular so 
# opencv posn tracking can be replaced with sensor down the road
UDP_IP = "127.0.0.1"   # Localhost (change if sending to another machine)
UDP_PORT = 5053        # Port number to match Processing
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# init pose model
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(
    static_image_mode=False,
    model_complexity=1,
    enable_segmentation=False,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
)

# Video capture from webcam
cap = cv2.VideoCapture(0)

# Store init position
initial_x = None
initial_z = None

# Define physical movement to tile step ratio
lateral_step = 0.05  # 1 tile = 5% screen width (X movement)
depth_step = 0.05    # Z movement

def calc_distance(p1, p2):
    return math.sqrt(
        (p1.x - p2.x) ** 2 +
        (p1.y - p2.y) ** 2 +
        (p1.z - p2.z) ** 2
    )

while cap.isOpened():
    success, frame = cap.read()
    if not success:
        print("Camera read failed.")
        break

    frame = cv2.flip(frame, 1)  # Mirror for natural interaction
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = pose.process(rgb_frame)

    if results.pose_landmarks:
        landmarks = results.pose_landmarks.landmark
        left_hip = landmarks[mp_pose.PoseLandmark.LEFT_HIP]
        right_hip = landmarks[mp_pose.PoseLandmark.RIGHT_HIP]

        # Average hip center (x: lateral, z: depth)
        x = (left_hip.x + right_hip.x) / 2 # left/right movement 
        shoulder_width = calc_distance( landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER],
                                       landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER])  # forwards/backwards movement

        # init zero-point on first detection
        if initial_x is None or initial_z is None:
            initial_x = x
            initial_z = shoulder_width

        dx = x - initial_x
        dz = shoulder_width - initial_z

        # Convert to virtual grid steps, constrain to pos values w respect to starting point
        tile_x = max(0, int(dx / lateral_step))
        tile_y = max(0, int(dz / depth_step))

        print(f" Grid Position: ({tile_x}, {tile_y})")

        # send over udp
        message = f"{tile_x},{tile_y}"
        sock.sendto(message.encode(), (UDP_IP, UDP_PORT))

        # draw skeleton
        mp.solutions.drawing_utils.draw_landmarks(
            frame, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

    # Display feed
    cv2.imshow('Pose Grid Tracking', frame)

    # ESC to exit
    if 0xFF == 27:
        break

cap.release()
cv2.destroyAllWindows()
