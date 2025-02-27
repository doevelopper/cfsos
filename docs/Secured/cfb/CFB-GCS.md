### Call for Bid: Project 3 - Ground Control Station (GCS) Application

#### 1. Project Overview
- **Title**: Ground Control Station Application for Unmanned Systems
- **Objective**: Develop a secure GCS app to monitor and control a rover, integrating with Projects 1 and 2, with future UAV scalability.
- **Background**: Unifies the ecosystem with an efficient, user-focused interface.

#### 2. Scope of Work
- Build a Qt-based GUI for Ubuntu 22.04 and Windows 11, using MAVLink over Wi-Fi.
- Implement telemetry, manual control, and mission planning with OpenStreetMap.
- Integrate with Brain Controller and ESC on a rover.
- Add security and outdoor usability features.
- Test over 150m range in field conditions.

#### 3. Requirements
- **Software**:
  - **Qt 6.5** (C++), targets Ubuntu 22.04 LTS and Windows 11 (64-bit).
  - MAVLink v2 parsing, OpenStreetMap via Qt Location API.
  - Features:
    - Telemetry: Speed, position, battery (dashboard + line graph).
    - Control: Keyboard input (WASD), arm/disarm button.
    - Mission: Waypoint editor (min 10 points), geofence toggle.
- **Hardware**:
  - **Radio**: TP-Link TL-WN722N Wi-Fi dongle (150 Mbps, USB-A, 2.4 GHz).
  - Runs on PC/laptop: 8GB RAM, Intel i3-10100 or AMD Ryzen 3 3100, 1080p display.
- **Performance**:
  - Latency: < 90ms for commands.
  - Refresh: 12 Hz for telemetry.
  - UI: < 40ms response.
- **Security**:
  - AES-128 encryption for MAVLink (lighter than AES-256 for speed).
  - Login with SHA-256 hashed passwords.
- **Usability**: Dark mode, 800x600 min resolution, keyboard shortcuts.

#### 4. Deliverables
- GCS app (executables + source code).
- User manual: Installation, operation, troubleshooting (PDF).
- Test report: Unit tests (UI, comms) and field test (150m rover control).
- Installers (.deb for Ubuntu, .exe for Windows).

#### 5. Timeline
- **Duration**: 3-4 months (tightened for focused dev).
  - Week 1-4: UI design, telemetry/control.
  - Week 5-8: Mission planning, security.
  - Week 9-12: Integration, field testing (optional Month 4 for polish).
- **Milestones**:
  - Month 1: GUI with telemetry.
  - Month 2: Control and planning done.
  - Month 3-4: Security, field-tested.

#### 6. Budget
- **Estimated Cost**: $20-$80 (Wi-Fi dongle ~$15, optional testing hardware).
- **Bid Range**: $2,000-$3,500 (tightened labor: ~60-80 hours @ $30-$45/hr, plus tools).
- Funding covers development and testing.

#### 7. Submission Guidelines
- **Deadline**: October 15, 2025.
- **Format**: PDF, max 10 pages.
- **Content**:
  - Team profile, Qt/MAVLink experience.
  - Technical approach (UI, security).
  - Cost breakdown (labor, tools).
  - Timeline with milestones.
  - References.
- **Submit to**: bids@yourdomain.com.

#### 8. Evaluation Criteria
- Qt/MAVLink expertise (40%).
- Cost efficiency and feature fit (30%).
- Timeline and testing plan (20%).
- Security/usability enhancements (10%).

#### 9. Contact Information
- [Your name], Project Lead.
- Email: [Your email].
- Questions due by: October 1, 2025.