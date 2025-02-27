### Project 3: Ground Control Station (GCS) Application
**Focus**: Develop a user-friendly GCS app to monitor and control unmanned systems, integrating with the Brain Controller and ESC.

#### SDD Outline
1. **Introduction**
   - Purpose: Create a GCS app for remote operation and telemetry of unmanned systems.
   - Scope: Initial focus on rover control, expandable to UAVs/VTOLs.
   - Objectives: Real-time monitoring, mission planning, and system configuration.

2. **System Overview**
   - Description: A Qt-based GUI running on Linux/Windows, communicating with the Brain Controller.
   - Use Case: Operator controls rover, plans missions, and views telemetry.

3. **System Architecture**
   - Components: GCS app, Wi-Fi/LoRa link, Brain Controller interface.
   - Interactions: GCS → Brain Controller (commands) → ESC; Brain Controller → GCS (telemetry).
   - Diagram: GCS-to-system communication flow.

4. **Functional Requirements**
   - Display telemetry (speed, position, battery).
   - Enable manual control and waypoint setting.
   - Configure Brain Controller/ESC settings.

5. **Technical Specifications**
   - Software: Qt framework, MAVLink parsing.
   - Hardware: Laptop/PC (Linux/Windows).
   - Performance: < 100ms command latency, 10 Hz telemetry refresh.

6. **Design Considerations**
   - Communication: MAVLink over Wi-Fi, AES-256 encryption.
   - UI: Modular layout (telemetry, map, controls).
   - Safety: Alerts for low battery, signal loss.
   - Scalability: Plugin system for new features.

7. **Implementation Plan**
   - Phase 1 (1-2 months): Basic GUI with telemetry and manual control.
   - Phase 2 (1-2 months): Add mission planning, configuration tools.

8. **Testing and Validation**
   - Unit tests: UI responsiveness, MAVLink parsing.
   - Field test: Operator controls rover over 100m range.

9. **Constraints and Risks**
   - Cost: ~$0-$50 (assuming existing PC, optional radio hardware).
   - Risk: Latency over long range; mitigated with LoRa fallback.

**Deliverable**: A GCS app controlling the rover via the Brain Controller, with telemetry and mission planning.

**Why Third?**: Requires a functional Brain Controller and ESC to interact with, making it the capstone integrating the full system.