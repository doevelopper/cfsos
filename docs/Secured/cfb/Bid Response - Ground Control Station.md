### Bid Response: Project 3 - Ground Control Station (GCS) Application

#### 1. Company/Team Profile
- **Name**: TechForge Robotics
- **Overview**: 4-person team with expertise in DDS, UI, and secure systems.
- **Relevant Experience**:
  - Qt/DDS GCS for drone swarm (2022), secure MAVLink.
  - Cross-platform rover app (2024), < 100ms latency.
- **Key Personnel**: Alex Carter (Lead), Priya Sharma (UI), Liam Nguyen (Software).

#### 2. Technical Approach
We propose a secure, DDS-driven GCS with usability enhancements.

- **Software Development**:
  - **Qt 6.5**: Ubuntu 22.04/Windows 11, QML UI, C++ backend.
  - **DDS**: RTI Connext DDS Micro, topics: `telemetry_in`, `command_out`, `mission_plan`.
  - **Features**:
    - *Telemetry*: Qwt dashboard (speed, battery), graph (position).
    - *Control*: WASD, arm/disarm button.
    - *Mission*: Qt Location (OpenStreetMap), 10-point waypoint editor.
  - **Radio**: TP-Link TL-WN722N (AP mode, 192.168.1.1).
  - **Cybersecurity**:
    - TLS 1.3 for DDS (RTI Security Plugins).
    - SHA-256 hashed login (SQLite).
    - AES-128 encrypted commands.
  - **Proposal**: Add DDoS protection (rate limiting, ~3 hours).

- **Integration & Testing**:
  - Integrate with Projects 1 & 2 on rover.
  - Unit tests: UI (< 40ms), DDS (< 90ms), security (100% auth).
  - Field test: 150m control, 12 Hz refresh.

#### 3. Cost Breakdown
| **Item**                | **Description**                     | **Cost (USD)** |
|-------------------------|-------------------------------------|----------------|
| **Hardware**            |                                     |                |
| TP-Link TL-WN722N       | Wi-Fi dongle                        | $15            |
| Testing Misc            | Cables                              | $5             |
| **Subtotal**            |                                     | **$20**        |
| **Labor**               |                                     |                |
| UI Design               | 20 hours @ $40/hr                   | $800           |
| DDS Coding              | 35 hours @ $40/hr (DDS setup)       | $1,400         |
| Testing & Docs          | 15 hours @ $35/hr                   | $525           |
| **Subtotal**            | 70 hours total                      | **$2,725**     |
| **Total**               | Hardware + Labor                    | **$2,745**     |

- **Notes**: Labor upped to 70 hours for DDS/UI. Fits $2,000-$3,500.

#### 4. Timeline with Milestones
- **Duration**: 3 months (October 15, 2025 - January 15, 2026).
  - **Week 1-4**: Design UI, setup DDS.
    - *Milestone*: GUI with telemetry.
  - **Week 5-8**: Add control, mission, security.
    - *Milestone*: Waypoints secure.
  - **Week 9-12**: Integrate, field test (150m), document.
    - *Milestone*: Delivered, 12 Hz.

#### 5. References
- **Drone GCS (2022)**: Qt/DDS. Contact: Dr. Sarah Kim, [Lab Email].
- **Rover App (2024)**: Secure UI. Contact: [Client Email].

#### 6. Proposed Enhancements
- **DDoS Protection**: Rate limit DDS packets (no cost, ~3 hours).
- **Config Export**: JSON settings (no cost, ~4 hours).
- **Log Replay**: SQLite replay ($5 SD, ~6 hours).

#### 7. Conclusion
TechForge delivers a secure GCS at $2,745, in 3 months, with DDS and cybersecurity, completing your ecosystem.