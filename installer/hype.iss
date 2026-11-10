#define AppName "Hype"
#define AppVersion "0.6.0"
#define AppPublisher "Hype Windows"
#define SourceDir "..\build\release"

[Setup]
AppId={{A6E1C3A5-1D8E-4B68-9A57-7BD2A0C6C0D4}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={localappdata}\Programs\Hype
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\dist
OutputBaseFilename=hype-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\hype.exe

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{autoprograms}\Hype"; Filename: "{app}\hype.exe"; Parameters: "open"; WorkingDir: "{userdocs}"
Name: "{autodesktop}\Hype"; Filename: "{app}\hype.exe"; Parameters: "open"; WorkingDir: "{userdocs}"; Tasks: desktopicon

[Run]
Filename: "{app}\hype.exe"; Parameters: "open"; WorkingDir: "{userdocs}"; Description: "Launch Hype"; Flags: nowait postinstall skipifsilent
