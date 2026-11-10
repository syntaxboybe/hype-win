#define AppName "Hype"
#define AppVersion "0.6.0"
#define AppPublisher "Hype Windows"
#define SourceDir "..\build\release"


[Setup]
AppId={{A6E1C3A5-1D8E-4B68-9A57-7BD2A0C6C0D4}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/syntaxboybe/hype-win
AppSupportURL=https://github.com/syntaxboybe/hype-win/issues
VersionInfoVersion={#AppVersion}.0
VersionInfoProductVersion={#AppVersion}
VersionInfoProductName={#AppName}
VersionInfoDescription=Native Markdown presentation editor for Windows
VersionInfoCompany={#AppPublisher}
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
Name: "fileassoc"; Description: "Add Hype to the Windows ""Open with"" list for Markdown files"; GroupDescription: "Windows integration:"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion
[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\hype.exe"; ValueType: string; ValueName: ""; ValueData: "{app}\hype.exe"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\hype.exe"; ValueType: string; ValueName: "Path"; ValueData: "{app}"
Root: HKCU; Subkey: "Software\Classes\Hype.Markdown"; ValueType: string; ValueName: ""; ValueData: "Hype Markdown Presentation"; Flags: uninsdeletekey; Tasks: fileassoc
Root: HKCU; Subkey: "Software\Classes\Hype.Markdown\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\hype.exe"",0"; Tasks: fileassoc
Root: HKCU; Subkey: "Software\Classes\Hype.Markdown\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\hype.exe"" open ""%1"""; Tasks: fileassoc
Root: HKCU; Subkey: "Software\Classes\.md\OpenWithProgids"; ValueType: string; ValueName: "Hype.Markdown"; ValueData: ""; Flags: uninsdeletevalue; Tasks: fileassoc


[Icons]
Name: "{autoprograms}\Hype"; Filename: "{app}\hype.exe"; Parameters: "open"; WorkingDir: "{userdocs}"
Name: "{autodesktop}\Hype"; Filename: "{app}\hype.exe"; Parameters: "open"; WorkingDir: "{userdocs}"; Tasks: desktopicon

[Run]
Filename: "{app}\hype.exe"; Parameters: "open"; WorkingDir: "{userdocs}"; Description: "Launch Hype"; Flags: nowait postinstall skipifsilent
