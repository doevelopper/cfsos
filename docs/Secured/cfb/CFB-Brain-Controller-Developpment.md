### Call for Bid: Project 1 - Brain Controller Development

#### 1. Project Overview
- **Title**: Brain Controller Development for Unmanned Systems
- **Objective**: Design a compact, rugged Brain Controller to manage sensors, autonomy, and communication for a rover.
- **Background**: Core of a multi-platform ecosystem, starting with a cost-effective rover prototype.

#### 2. Scope of Work
- Develop a Raspberry Pi-based Brain Controller running ROS 2.
- Integrate specified sensors (GPS, IMU, ultrasonic) for position, orientation, and obstacle detection.
- Implement autonomy (waypoint navigation, obstacle avoidance) using EKF and A* algorithm.
- Enable MAVLink communication over Wi-Fi with telemetry output.
- Test on a rover in outdoor conditions.

#### 3. Requirements
- **Hardware**:
  - **Raspberry Pi 4B (4GB RAM)** - Part: Raspberry Pi 4 Model B 4GB (cost-effective choice).
  - **GPS**: Ublox NEO-6M-V2 (1 Hz, UART interface, external antenna SMA connector).
  - **IMU**: MPU-9250 (9-axis, I2C interface, 3.3V compatible).
  - **Ultrasonic**: HC-SR04 (4-pin, 5V, 2-400 cm range).
  - **Enclosure**: IP65-rated, 100x80x40mm ABS box (e.g., Hammond 1591XXTBK) with heat sink fins.
  - **Power**: 11.1V 3S LiPo (2200mAh), 5V/3A UBEC (e.g., Hobbywing 3A UBEC), JST-XH connectors.
  - **Connectors**: Molex Mini-Fit Jr. for power, Dupont 2.54mm for sensors.
- **Software**:
  - ROS 2 Humble, EKF for GPS/IMU fusion, A* for path planning.
  - MAVLink v2 over Wi-Fi (2.4 GHz, TP-Link TL-WN725N dongle).
- **Performance**:
  - Position accuracy: < 0.8m error with GPS lock.
  - Update rate: 20 Hz IMU, 5 Hz fused state.
  - Autonomy: Navigate 8 waypoints, 95% success rate.
- **Safety**: Emergency stop on signal loss (< 1.5s detection) or IMU tilt > 40°.
- **Durability**: -5°C to 45°C, 85% humidity, 3G vibration tolerance.

#### 4. Deliverables
- Assembled Brain Controller prototype.
- Source code (ROS nodes, configs) with README.
- Test report: Unit tests (sensor outputs, EKF) and field test (rover navigates 40m course).
- User guide: Setup, operation, troubleshooting (PDF).

#### 5. Timeline
- **Duration**: 3 months (tightened for efficiency).
  - Week 1-4: Hardware procurement, assembly, ROS setup.
  - Week 5-8: Sensor integration, autonomy coding.
  - Week 9-12: Outdoor testing, documentation.
- **Milestones**:
  - Month 1: Hardware assembled, ROS running.
  - Month 2: Autonomy functional in sim.
  - Month 3: Field-tested on rover.

#### 6. Budget
- **Estimated Cost**: $120-$200 (Pi 4B 4GB ~$55, NEO-6M ~$15, MPU-9250 ~$10, UBEC ~$10).
- **Bid Range**: $1,200-$2,800 (tightened labor: ~40-60 hours @ $30-$50/hr, plus materials).
- Funding covers materials, development, and testing.

#### 7. Submission Guidelines
- **Deadline**: April 1, 2025.
- **Format**: PDF, max 10 pages.
- **Content**:
  - Team profile, ROS/embedded experience.
  - Technical approach (fusion, autonomy).
  - Cost breakdown (labor, materials).
  - Timeline with milestones.
  - References.
- **Submit to**: bids@yourdomain.com.

#### 8. Evaluation Criteria
- ROS/autonomy expertise (40%).
- Cost efficiency and hardware fit (30%).
- Timeline and testing plan (20%).
- Durability/safety features (10%).

#### 9. Contact Information
- [Your name], Project Lead.
- Email: [Your email].
- Questions due by: March 15, 2025.
