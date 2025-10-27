# Windows UWP Platform Configuration

## Target Platforms
- Windows 10 (version 1903+)
- Windows 11
- Xbox One
- Xbox Series X/S
- HoloLens 2

## Development Requirements
- Visual Studio 2022 (17.0+)
- Windows 10 SDK (10.0.19041.0+)
- Windows App SDK 1.0+
- .NET 6.0+ Runtime
- WinUI 3.0+

## Build Settings
- **Target Platform**: x64, ARM64, x86
- **Minimum Windows Version**: 10.0.19041.0
- **Target Framework**: net6.0-windows10.0.19041.0
- **App SDK Version**: 1.0.0

## Package Manifest
```xml
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:mp="http://schemas.microsoft.com/appx/2014/phone/manifest"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities">

  <Identity
    Name="12345YourCompany.Katya"
    Publisher="CN=Your Company"
    Version="1.0.0.0" />

  <mp:PhoneIdentity PhoneProductId="12345678-1234-1234-1234-123456789012"
                    PhonePublisherId="00000000-0000-0000-0000-000000000000"/>

  <Properties>
    <DisplayName>Katya</DisplayName>
    <PublisherDisplayName>Your Company</PublisherDisplayName>
    <Logo>Assets\StoreLogo.png</Logo>
    <Description>Secure messaging platform</Description>
  </Properties>

  <Dependencies>
    <TargetDeviceFamily Name="Windows.Universal" MinVersion="10.0.19041.0" MaxVersionTested="10.0.19041.0" />
    <TargetDeviceFamily Name="Windows.Desktop" MinVersion="10.0.19041.0" MaxVersionTested="10.0.19041.0" />
  </Dependencies>

  <Resources>
    <Resource Language="x-generate"/>
  </Resources>

  <Applications>
    <Application Id="App"
      Executable="$targetnametoken$.exe"
      EntryPoint="$targetentrypoint$">
      <uap:VisualElements
        DisplayName="Katya"
        Description="Secure messaging platform"
        BackgroundColor="transparent"
        Square150x150Logo="Assets\Square150x150Logo.png"
        Square44x44Logo="Assets\Square44x44Logo.png">
        <uap:DefaultTile Wide310x150Logo="Assets\Wide310x150Logo.png"  Square71x71Logo="Assets\SmallTile.png" Square310x310Logo="Assets\LargeTile.png"/>
        <uap:SplashScreen Image="Assets\SplashScreen.png" />
      </uap:VisualElements>
      <Extensions>
        <uap:Extension Category="windows.fileTypeAssociation">
          <uap:FileTypeAssociation Name="katyachat">
            <uap:SupportedFileTypes>
              <uap:FileType>.katya</uap:FileType>
            </uap:SupportedFileTypes>
          </uap:FileTypeAssociation>
        </uap:Extension>
        <uap:Extension Category="windows.protocol">
          <uap:Protocol Name="katya">
            <uap:DisplayName>Katya Chat</uap:DisplayName>
          </uap:Protocol>
        </uap:Extension>
      </Extensions>
    </Application>
  </Applications>

  <Capabilities>
    <rescap:Capability Name="runFullTrust" />
    <Capability Name="internetClient" />
    <Capability Name="internetClientServer" />
    <Capability Name="privateNetworkClientServer" />
    <uap:Capability Name="picturesLibrary" />
    <uap:Capability Name="videosLibrary" />
    <uap:Capability Name="musicLibrary" />
    <uap:Capability Name="documentsLibrary" />
    <uap:Capability Name="microphone" />
    <uap:Capability Name="webcam" />
    <Capability Name="location" />
    <uap:Capability Name="backgroundMediaPlayback" />
    <uap:Capability Name="voipCall" />
  </Capabilities>
</Package>
```

## Platform-Specific Features
- **Live Tiles**: Dynamic content on Start Menu
- **Toast Notifications**: Rich notifications with actions
- **App Services**: Background task integration
- **Cortana Integration**: Voice commands
- **Windows Hello**: Biometric authentication
- **App Protocols**: Custom URI scheme handling
- **File Associations**: Open .katya files
- **Share Contract**: Share content with other apps
- **Settings Integration**: App settings in Windows Settings
- **Taskbar Integration**: Jump lists and progress indication

## Build Commands
```bash
# Debug build
flutter build windows --debug

# Release build
flutter build windows --release

# UWP package
flutter build windows --uwp

# MSIX package
flutter build windows --msix
```

## Deployment
- **Microsoft Store**: MSIX package submission
- **Enterprise**: Sideloading with certificate
- **Developer**: Package signing required

## Testing
- **Windows App Certification Kit**: Store compliance
- **Visual Studio Test Platform**: Unit and UI testing
- **WinAppDriver**: UI automation testing
