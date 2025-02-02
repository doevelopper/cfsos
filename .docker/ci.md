graph TD
    A[Start] --> B{Git Flow Branching}
    B -- Feature Branch --> C[Feature Branch Pipeline]
    C --> D[Unit Tests]
    D --> E{Code Quality Checks}
    E -- SonarQube --> F[Code Coverage Report]
    F --> G{Static Analysis}
    G --> H[Build Artifact]
    H --> I{Containerize (Docker/OCI)}
    I --> J[Container Scan]
    J --> K{Merge Request Pipeline}
    K -- Approved --> L[Merge to Develop]
    L --> M[Develop Branch Pipeline]
    M --> D
    M --> N{Integration Tests}
    N --> O{Performance Tests}
    O --> P[Deploy to Staging]
    P --> Q[Manual Testing/QA]
    Q -- Approved --> R[Deploy to Canary]
    R --> S[Canary Testing/Monitoring]
    S -- Successful --> T[Deploy to Production]
    T --> U[Release Tag Creation]
    U --> V[Release Notes Generation]
    V --> W[Schedule Releases]
    W --> X[End]

    subgraph Release
        U --> Y[Release Management (GitLab)]
    end

    subgraph Security
        I --> Z[Container Security Scan (e.g., Clair, Trivy)]
    end
