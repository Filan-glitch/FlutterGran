; The Windows installer: chalk-<version>-windows-x64-setup.exe.
;
; Built by .github/workflows/build.yml, after the app folder (with the Visual
; C++ runtime DLLs copied in) is packaged, so the installer and the portable
; zip ship the same files. Locally, from the repo root, after
; `flutter build windows --release` and that Package step:
;
;   ISCC /DAppVersion=1.4.0 /DSourceDir=%CD%\build\windows\x64\runner\Release windows\installer\chalk.iss
;
; Self-update runs this same file with /SILENT (lib/app/update/update_platform.dart),
; so nothing below may ask a question a silent install cannot answer.

#ifndef AppVersion
  #error Pass the version: ISCC /DAppVersion=1.2.3
#endif
#ifndef SourceDir
  #error Pass the app folder: ISCC /DSourceDir=<path to build\windows\x64\runner\Release>
#endif

[Setup]
; A contract, never to be changed: upgrades in place, the uninstall entry and
; the previous install folder are all found by this id. A new one would install
; a second Chalk beside the first. (The doubled brace is Inno's escape.)
AppId={{A2D5EDC0-3A85-4D63-ABC8-EDED16293004}
AppName=Chalk
AppVersion={#AppVersion}
AppVerName=Chalk {#AppVersion}
; Matches CompanyName in windows/runner/Runner.rc.
AppPublisher=de.bot.filan
AppPublisherURL=https://github.com/Filan-glitch/FlutterGran
AppSupportURL=https://github.com/Filan-glitch/FlutterGran/issues
AppUpdatesURL=https://github.com/Filan-glitch/FlutterGran/releases
VersionInfoVersion={#AppVersion}
VersionInfoProductName=Chalk

; Per user by default, so installing and every self-update need no admin
; rights and no UAC prompt: {autopf} is %LOCALAPPDATA%\Programs then. The
; wizard still offers an install for all users, into Program Files.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\Chalk
DisableProgramGroupPage=yes
DisableDirPage=auto

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0

WizardStyle=modern
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\fluttergran.exe
UninstallDisplayName=Chalk
Compression=lzma2/ultra64
SolidCompression=yes

; A running Chalk is closed before its files are replaced. Not restarted by
; the Restart Manager: the [Run] entry below starts it again, and doing both
; would open it twice.
CloseApplications=yes
RestartApplications=no

; Overridden by the workflow's /O and /F.
OutputDir=..\..\build\installer
OutputBaseFilename=chalk-{#AppVersion}-windows-x64-setup

[Languages]
; The app's two locales.
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Chalk"; Filename: "{app}\fluttergran.exe"
Name: "{autodesktop}\Chalk"; Filename: "{app}\fluttergran.exe"; Tasks: desktopicon

[Run]
; No skipifsilent, on purpose: in the wizard this is the "Launch Chalk"
; checkbox on the last page, and in a silent self-update it is what brings
; the app back once the new version is in place.
Filename: "{app}\fluttergran.exe"; Description: "{cm:LaunchProgram,Chalk}"; Flags: nowait postinstall

; Match history is not in {app}: the database lives in
; %APPDATA%\de.bot.filan\Chalk (Runner.rc's CompanyName and ProductName), so
; upgrading never touches it and uninstalling leaves it for a reinstall. There
; is deliberately no [UninstallDelete] for it.
