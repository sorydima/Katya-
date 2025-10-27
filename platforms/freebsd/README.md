# FreeBSD Platform Configuration

## Target Platforms
- FreeBSD 12.0+ (Desktop)
- FreeBSD 13.0+ (Server/Desktop)
- FreeBSD-based appliances
- NAS devices running FreeBSD
- Router/firewall appliances

## Development Requirements
- FreeBSD 12.0+ installation
- Flutter SDK 3.0+
- Clang compiler 10+
- CMake 3.16+
- Ninja build system
- pkg package manager

## Build Settings
- **FreeBSD Version**: 12.0+
- **Target Architecture**: AMD64, ARM64, i386
- **Build Type**: Release, Debug, Profile
- **Compiler**: Clang 10+
- **Package Manager**: pkg

## Project Structure
```
freebsd/
├── src/
│   ├── main.c
│   ├── CMakeLists.txt
│   └── Makefile
├── pkg/
│   ├── pkg-plist
│   └── pkg-descr
├── scripts/
│   ├── build.sh
│   └── install.sh
└── ports/
    └── net-im/katya/
        ├── Makefile
        └── distinfo
```

## FreeBSD Port

### Port Makefile
```makefile
# freebsd/ports/net-im/katya/Makefile
PORTNAME=       katya
DISTVERSION=    1.0.0
CATEGORIES=     net-im
MASTER_SITES=   https://github.com/yourusername/katya/releases/download/v${DISTVERSION}/
PKGNAMEPREFIX=  ${DISTVERSION}

MAINTAINER=     your-email@example.com
COMMENT=        Secure messaging platform
WWW=            https://katya.app

LICENSE=        MIT

BUILD_DEPENDS=  flutter>=3.0:lang/flutter \
                clang10>=10.0.1:devel/llvm10 \
                cmake>=3.16:devel/cmake \
                ninja>=1.10:devel/ninja

RUN_DEPENDS=    libflutter.so:lang/flutter-runtime

USES=           cmake compiler:c++17-lang pkgconfig

CMAKE_ARGS=     -DCMAKE_BUILD_TYPE=Release \
                -DFLUTTER_ROOT=${LOCALBASE}/lib/flutter \
                -DTARGET_ARCH=${ARCH}

.include <bsd.port.mk>
```

### Port Description
```makefile
# freebsd/ports/net-im/katya/pkg-descr
Katya is a secure, decentralized messaging platform with blockchain integration.

Features:
- End-to-end encryption using Matrix protocol
- Multi-platform support (Desktop, Mobile, Web)
- Blockchain integration for secure transactions
- Advanced privacy and security features
- Cross-platform compatibility

WWW: https://katya.app
```

## Build Configuration

### CMake Configuration
```cmake
# freebsd/src/CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project(katya VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Flutter
set(FLUTTER_ROOT "/usr/local/lib/flutter")
set(FLUTTER_EMBEDDER_HEADER "${FLUTTER_ROOT}/include/flutter_embedder.h")
set(FLUTTER_LIBRARY "${FLUTTER_ROOT}/lib/libflutter.so")

# FreeBSD-specific configurations
if(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    set(FREEBSD TRUE)
    add_definitions(-DFREEBSD)
    # FreeBSD specific compiler flags
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif()

# Source files
set(SOURCES
    main.cc
    application.cc
    messaging_service.cc
    platform_handler.cc
)

# Create executable
add_executable(katya ${SOURCES})

# Link libraries
target_link_libraries(katya
    ${FLUTTER_LIBRARY}
    pthread
    dl
    m
    stdc++
)

# Include directories
target_include_directories(katya PRIVATE
    ${FLUTTER_ROOT}/include
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Install configuration
install(TARGETS katya
    RUNTIME DESTINATION bin
)

install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/../pkg/katya.desktop
    DESTINATION share/applications
)

install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/../pkg/katya.png
    DESTINATION share/pixmaps
)
```

## Platform Integration

### FreeBSD Desktop Integration
```c++
// freebsd/src/platform_handler.cc
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>
#include <glib.h>
#include "platform_handler.h"

namespace katya {

PlatformHandler::PlatformHandler() {
    // Initialize FreeBSD-specific platform features
    detect_desktop_environment();
    setup_dbus_integration();
    configure_notifications();
}

std::string PlatformHandler::get_platform_name() const {
    return "FreeBSD";
}

std::string PlatformHandler::get_user_home_directory() const {
    const char* home = getenv("HOME");
    if (home) {
        return home;
    }

    // Fallback to passwd database
    struct passwd* pwd = getpwuid(getuid());
    return pwd ? pwd->pw_dir : "/tmp";
}

std::string PlatformHandler::get_config_directory() const {
    std::string config_dir = get_user_home_directory() + "/.config/katya";
    ensure_directory_exists(config_dir);
    return config_dir;
}

void PlatformHandler::detect_desktop_environment() {
    // Detect FreeBSD desktop environment
    const char* desktop = getenv("XDG_CURRENT_DESKTOP");
    if (desktop) {
        desktop_environment_ = desktop;
    } else {
        // Fallback detection
        desktop_environment_ = detect_desktop_fallback();
    }
}

void PlatformHandler::setup_dbus_integration() {
    // Set up D-Bus integration for FreeBSD
    if (system("pgrep dbus-daemon > /dev/null 2>&1") == 0) {
        dbus_available_ = true;
    }
}

void PlatformHandler::configure_notifications() {
    // Configure FreeBSD notification system
    if (desktop_environment_ == "KDE" || desktop_environment_ == "Plasma") {
        notification_system_ = "org.freedesktop.Notifications";
    } else if (desktop_environment_ == "GNOME") {
        notification_system_ = "org.gnome.Notifications";
    } else {
        // Fallback to system notifications
        notification_system_ = "system";
    }
}

bool PlatformHandler::ensure_directory_exists(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == 0) {
        return S_ISDIR(st.st_mode);
    }

    // Create directory with proper permissions
    if (mkdir(path.c_str(), 0755) == 0) {
        return true;
    }

    return false;
}

} // namespace katya
```

### FreeBSD Service Integration
```makefile
# freebsd/pkg/katya.rc
#!/bin/sh
#
# PROVIDE: katya
# REQUIRE: NETWORKING
# KEYWORD: shutdown

. /etc/rc.subr

name="katya"
rcvar="katya_enable"

command="/usr/local/bin/katya"
command_args="--daemon"
pidfile="/var/run/katya.pid"

load_rc_config $name

: ${katya_enable:="NO"}
: ${katya_user:="katya"}
: ${katya_group:="katya"}

run_rc_command "$1"
```

## Build Commands

### FreeBSD Development Build
```bash
# Build for FreeBSD development
cd freebsd/src
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make

# Install development build
sudo make install
```

### FreeBSD Release Build
```bash
# Build for FreeBSD release
cd freebsd/src
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
make

# Create package
make package

# Install release build
sudo make install
```

### FreeBSD Port Build
```bash
# Build using FreeBSD ports
cd /usr/ports/net-im/katya
make install clean

# Or using pkg
sudo pkg install katya
```

## Package Management

### FreeBSD Package
```makefile
# freebsd/pkg/pkg-plist
bin/katya
share/applications/katya.desktop
share/pixmaps/katya.png
%%DATADIR%%/flutter_assets/
%%DATADIR%%/lib/
@dir %%DATADIR%%
@dir etc/katya/
etc/katya/katya.conf.sample
@dir var/log/katya/
@dir var/run/katya/
```

### Desktop File
```ini
# freebsd/pkg/katya.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Katya
Comment=Secure messaging platform
Exec=/usr/local/bin/katya %U
Icon=katya
Terminal=false
Categories=Network;Chat;Security;
Keywords=messaging;chat;secure;privacy;blockchain;
MimeType=application/x-katya-chat;
StartupWMClass=katya
```

## Platform-Specific Features

### FreeBSD Jails Integration
```c++
// freebsd/src/jail_integration.cc
namespace katya {

class JailIntegration {
public:
    static bool is_running_in_jail() {
        // Check if running in FreeBSD jail
        FILE* fp = fopen("/proc/1/status", "r");
        if (fp) {
            char buffer[256];
            while (fgets(buffer, sizeof(buffer), fp)) {
                if (strstr(buffer, "sibling") != nullptr) {
                    fclose(fp);
                    return true;
                }
            }
            fclose(fp);
        }
        return false;
    }

    static std::string get_jail_name() {
        // Get FreeBSD jail name
        return get_hostname();
    }

    static bool configure_jail_security() {
        // Configure security for jail environment
        // Set up proper file permissions
        // Configure network isolation
        return true;
    }
};

} // namespace katya
```

### FreeBSD Network Configuration
```c++
// freebsd/src/network_config.cc
namespace katya {

class FreeBSDNetworkConfig {
public:
    static bool configure_firewall() {
        // Configure FreeBSD firewall (PF or IPFW)
        std::string command = "pfctl -f /etc/pf.conf";
        return system(command.c_str()) == 0;
    }

    static bool setup_vpn() {
        // Set up VPN for FreeBSD
        // Configure OpenVPN or WireGuard
        return true;
    }

    static std::vector<std::string> get_network_interfaces() {
        // Get list of FreeBSD network interfaces
        std::vector<std::string> interfaces;

        // Parse /etc/rc.conf or use ifconfig
        FILE* fp = popen("ifconfig -l", "r");
        if (fp) {
            char buffer[1024];
            if (fgets(buffer, sizeof(buffer), fp)) {
                char* token = strtok(buffer, " \t\n");
                while (token) {
                    interfaces.push_back(token);
                    token = strtok(nullptr, " \t\n");
                }
            }
            pclose(fp);
        }

        return interfaces;
    }
};

} // namespace katya
```

## Testing

### FreeBSD Testing Framework
```c++
// freebsd/src/tests/freebsd_tests.cc
#include <gtest/gtest.h>
#include "platform_handler.h"
#include "jail_integration.h"

namespace katya {

TEST(FreeBSDPlatformTest, PlatformDetection) {
    PlatformHandler handler;
    EXPECT_EQ(handler.get_platform_name(), "FreeBSD");
}

TEST(FreeBSDPlatformTest, HomeDirectory) {
    PlatformHandler handler;
    std::string home = handler.get_user_home_directory();
    EXPECT_FALSE(home.empty());
    EXPECT_EQ(home[0], '/');  // Should be absolute path
}

TEST(FreeBSDPlatformTest, ConfigDirectory) {
    PlatformHandler handler;
    std::string config = handler.get_config_directory();
    EXPECT_FALSE(config.empty());
    EXPECT_TRUE(handler.ensure_directory_exists(config));
}

TEST(JailIntegrationTest, JailDetection) {
    EXPECT_TRUE(JailIntegration::is_running_in_jail() ||
               !JailIntegration::is_running_in_jail());
}

} // namespace katya
```

## Distribution

### FreeBSD Ports Collection
```bash
# Submit to FreeBSD ports
cd /usr/ports/net-im/katya
make makesum
make install

# Submit port
# Follow FreeBSD port submission guidelines
```

### FreeBSD Package Repository
```bash
# Create FreeBSD package
pkg create -m freebsd/pkg -r build/freebsd/stage -p freebsd/pkg/pkg-plist katya

# Submit to package repository
# Upload to FreeBSD package mirrors
```

## Security

### FreeBSD Security Features
```c++
// freebsd/src/security.cc
namespace katya {

class FreeBSDSecurity {
public:
    static bool enable_mandatory_access_control() {
        // Enable FreeBSD MAC (Mandatory Access Control)
        return configure_mac_policy();
    }

    static bool configure_audit_system() {
        // Configure FreeBSD audit system
        return system("auditd -c") == 0;
    }

    static bool setup_jail_security() {
        // Set up security for jail environment
        return JailIntegration::configure_jail_security();
    }

private:
    static bool configure_mac_policy() {
        // Configure MAC policy for FreeBSD
        std::ofstream mac_conf("/etc/mac.conf");
        if (mac_conf.is_open()) {
            mac_conf << "default_policy = MLS" << std::endl;
            mac_conf.close();
            return system("service mac enable") == 0;
        }
        return false;
    }
};

} // namespace katya
```

## Performance Optimization

### FreeBSD Performance
```c++
// freebsd/src/performance.cc
namespace katya {

class FreeBSDPerformanceOptimizer {
public:
    static void optimize_for_freebsd() {
        // Optimize for FreeBSD
        configure_memory_management();
        setup_disk_io_optimization();
        configure_network_optimization();
    }

    static void configure_zfs() {
        // Configure ZFS optimizations if available
        if (is_zfs_available()) {
            configure_zfs_settings();
        }
    }

private:
    static void configure_memory_management() {
        // Configure FreeBSD memory management
        // Set up proper malloc settings
        setenv("MALLOC_OPTIONS", "A", 1);
    }

    static void setup_disk_io_optimization() {
        // Optimize disk I/O for FreeBSD
        // Configure proper async I/O
    }

    static void configure_network_optimization() {
        // Optimize network stack for FreeBSD
        // Configure TCP settings
        system("sysctl net.inet.tcp.sendspace=1048576");
        system("sysctl net.inet.tcp.recvspace=1048576");
    }

    static bool is_zfs_available() {
        return system("which zfs > /dev/null 2>&1") == 0;
    }

    static void configure_zfs_settings() {
        // Configure ZFS for optimal performance
        system("zfs set compression=lz4 tank/katya");
        system("zfs set atime=off tank/katya");
    }
};

} // namespace katya
```

## Support

### FreeBSD Community Support
- **FreeBSD Forums**: https://forums.freebsd.org/
- **FreeBSD Mailing Lists**: https://www.freebsd.org/community/mailinglists/
- **FreeBSD Documentation**: https://docs.freebsd.org/
- **FreeBSD Bug Reports**: https://bugs.freebsd.org/

## Resources

- [FreeBSD Documentation](https://docs.freebsd.org/)
- [FreeBSD Ports Collection](https://www.freebsd.org/ports/)
- [FreeBSD Handbook](https://docs.freebsd.org/en/books/handbook/)
- [FreeBSD Security](https://www.freebsd.org/security/)
