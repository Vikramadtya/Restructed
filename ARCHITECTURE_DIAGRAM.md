# Component-Based Architecture Diagram

Below is the high-level architecture diagram detailing the three main domains of the Restructed application (`/ui`, `/backend`, and `/daemon`) and how their internal components interact following our recent massive refactoring.

```mermaid
flowchart TB
    subgraph UI["UI Domain (/ui)"]
        direction TB
        UICore["Core (App Providers, Theme)"]
        UIDashboard["Dashboard Component"]
        UIRules["Rules Component"]
        UICategories["Categories Component"]
        UIAnalytics["Analytics Component"]
        UISettings["Settings Component"]
        
        UIDashboard --> UICore
        UIRules --> UICore
        UICategories --> UICore
        UIAnalytics --> UICore
        UISettings --> UICore
    end

    subgraph Backend["Backend Domain (/backend)"]
        direction TB
        BackCore["Core Component\n(Drift DB, DI)"]
        
        BackRules["Rules Component\n(Models, Repositories)"]
        BackCategories["Categories Component\n(Models, Repositories)"]
        BackAnalytics["Analytics Component\n(Models, Repositories)"]
        BackSettings["Settings Component\n(SharedPrefs Service)"]
        
        DaemonClient["Daemon Client Component\n(Launcher, API, Socket Services)"]

        BackRules --> BackCore
        BackCategories --> BackCore
        BackAnalytics --> BackCore
        
        DaemonClient <--> BackRules
        DaemonClient <--> BackCategories
        DaemonClient <--> BackAnalytics
        DaemonClient --> BackSettings
    end

    subgraph OS["OS Level"]
        Daemon["Root Proxy Daemon (/daemon)\n(Standalone Executable)"]
    end

    %% Interactions between domains
    UICore == "Riverpod Providers" ==> BackRules
    UICore == "Riverpod Providers" ==> BackCategories
    UICore == "Riverpod Providers" ==> BackAnalytics
    UICore == "Riverpod Providers" ==> BackSettings
    UICore == "Riverpod Providers" ==> DaemonClient

    DaemonClient == "TCP (8193) Control/Sync" ==> Daemon
    Daemon -. "UDP (8192) Analytics Stream" .-> DaemonClient

    %% Styling
    classDef ui fill:#4F46E5,color:#fff,stroke:#312E81,stroke-width:2px;
    classDef backend fill:#10B981,color:#fff,stroke:#065F46,stroke-width:2px;
    classDef daemon fill:#EF4444,color:#fff,stroke:#7F1D1D,stroke-width:2px;
    classDef default fill:#1E293B,color:#e2e8f0,stroke:#334155;

    class UI ui;
    class Backend backend;
    class OS daemon;
```

## How It Works

1. **Strict Layer Separation**: 
   The `UI` components never directly instantiate backend logic. They interact purely through the `Core` providers. This means your UI just "reacts" to state changes.

2. **Component Encapsulation**: 
   Inside the `/backend`, each feature (Rules, Categories, Analytics, Settings) is entirely self-contained. They possess their own Models, Repositories, and implementation logic. They only rely on the Backend `Core` component for shared database injection.

3. **The Event Hub (Daemon Client)**:
   The `Daemon Client` component is the beating heart of the system. It connects the Flutter frontend to the root executable.
   - It sends the user's latest blocklist to the Daemon via a **stateless TCP connection** on port `8193`.
   - It listens for incoming HTTP intercept attempts via a **stateless UDP broadcast** on port `8192`.
   - When a UDP hit is detected, the `Daemon Client` logs it using the `Analytics Component` and updates the UI in real-time.

4. **The Stateless OS Daemon**:
   The `/daemon` is a completely isolated executable running with root privileges. It holds absolutely no state or database of its own—it relies entirely on the `Daemon Client` to feed it the blocklist and takes action purely based on what it is told.
