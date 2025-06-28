//currently script is not using socket

import java.net.*;

//can be used to receive incoming position data from any type of external sensor
class UDPSocketReceiver extends Thread {
  DatagramSocket socket;
  byte[] buffer = new byte[256];
  String latestMessage = "";

  void run() {
    try {
      socket = new DatagramSocket(5053); // make sure to match port 
      println("UDP listening on port 5053...");
      while (true) {
        DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
        socket.receive(packet);
        latestMessage = new String(packet.getData(), 0, packet.getLength());
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  String getLatestMessage() {
    return latestMessage;
  }
}
