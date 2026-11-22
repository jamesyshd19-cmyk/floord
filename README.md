# Floor daemon
**Floord** is a lightweight background daemon written in Rust that automatically manages and organizes incoming files.

## Daemon and configuration

Floord can run the inbox organizer and cleanup independently or together. Use
`--daemon` on the command line or `daemon = true` in the TOML configuration to
run the enabled services repeatedly. Without daemon mode, each enabled service
makes one pass. Run `floord --help` to see all command-line options.

Both installers create a configuration with daemon mode, the organizer, cleanup,
and notifications enabled. They keep an existing configuration file. Edit the
installed `config.toml` and restart Floord to apply changes. See the
[configuration template](config_template.toml) for the available settings.

## File Organization

**Floord** automatically organizes incoming files based on their file extensions, sorting them into the appropriate system directories according to their file type.

It uses the operating system's standard directories whenever available:

- **Documents**: .pdf, .docx, .txt, .odt, etc.
- **Music**: .mp3, .wav, .flac, .ogg, etc.
- **Videos**: .mp4, .mkv, .avi, .mov, etc.
- **Pictures**: .jpg, .jpeg, .png, .gif, .webp, etc.

**Unknown files**: If a file has an unsupported or unrecognized extension, Floord automatically creates an Unknown folder inside the designated organization directory (if it doesn't already exist) and moves the file there.

Set `organizer` to enable the inbox organizer. If you leave `inbox` unset,
Floord uses your Downloads folder when available. The `delay` setting is the
minimum age in seconds since the last modification before an item can be moved.
The installers set it to 300 seconds.

## File Cleaning

Set `cleanup` to enable cleanup. Set `paths` to the folders you want Floord
to scan. An empty list uses the available Documents, Music, Videos, and Pictures
folders. Inside each scanned folder, Floord skips the `Secure` subfolder.
Floord checks the access and modification timestamps of each immediate entry
and moves eligible entries to `SoonDeleted` once they reach `span` days of age.

New installer-created configurations set `allow_deletion = false`. Reinstalling
preserves an existing `config.toml`, including any setting that enables deletion.
With `allow_deletion = true`, entries directly inside `SoonDeleted` become
eligible for permanent deletion at a total age of `span + grace` days, measured
from their access and modification timestamps. Floord uses a directory's own
timestamps for both checks. It can move the whole directory and later delete it
and all its contents, even if a file inside was recently edited.

New installer-created configurations set `span` to 30 days and `grace` to 7
days. Set `notify` to control notifications for organizer and cleanup moves.

# Installation

### Linux

The [Linux installer](installers/install.sh) uses `sudo` to put the executable
at `/usr/local/bin/floord`. It stores the configuration at
`~/.config/floord/config.toml` and the systemd user unit at
`~/.config/systemd/user/floor-daemon.service`. The installer starts the service
immediately and enables it to start at login. systemd restarts it on failure
after 10 seconds.

Execute:
```bash
curl -fsSL https://raw.githubusercontent.com/polete-bermejo/floord/main/installers/install.sh | sh
```

Use these commands to check status, stop Floord, or restart it after changing
the configuration. Stopping the service keeps its automatic startup setting.

```bash
systemctl --user status floor-daemon.service
systemctl --user stop floor-daemon.service
systemctl --user restart floor-daemon.service
```

To stop it and turn off automatic startup, run
`systemctl --user disable --now floor-daemon.service`. To turn automatic
startup back on and start it immediately, run
`systemctl --user enable --now floor-daemon.service`.

### Windows

The [Windows installer](installers/install.ps1) places the executable at
`%LOCALAPPDATA%\Floord\floord.exe` and the configuration at
`%APPDATA%\floord\config.toml`. It registers a Task Scheduler task named
`Floord` for the current user and starts it immediately. The task runs at
user logon and launches Floord hidden.

Execute:
```powershell
irm https://raw.githubusercontent.com/polete-bermejo/floord/main/installers/install.ps1 | iex
```

Inspect the task and the running process in PowerShell:

```powershell
Get-ScheduledTask -TaskName Floord
Get-Process -Name floord -ErrorAction SilentlyContinue
```

The task launches a separate process. To stop Floord, stop the task and end
the process if it is still running:

```powershell
Stop-ScheduledTask -TaskName Floord -ErrorAction SilentlyContinue
Get-Process -Name floord -ErrorAction SilentlyContinue | Stop-Process
```

After editing the configuration, stop Floord and run
`Start-ScheduledTask -TaskName Floord` to start it again. To prevent startup at
the next logon, also run `Disable-ScheduledTask -TaskName Floord`. Run
`Enable-ScheduledTask -TaskName Floord` to restore automatic startup.

To view the CLI options from PowerShell, run
`& "$env:LOCALAPPDATA\Floord\floord.exe" --help`.

# Uninstall

Both uninstallers remove the configuration directory. Back up `config.toml`
first if you want to keep your settings.

## Linux

The [Linux uninstaller](uninstallers/uninstall.sh) stops the user service if
active, removes the unit file, reloads the user systemd manager, removes the
executable with `sudo`, and removes `~/.config/floord`. If automatic startup
is enabled, disable it with `systemctl --user disable --now floor-daemon.service`
before removing the unit.

Execute:
```bash
curl -fsSL https://raw.githubusercontent.com/polete-bermejo/floord/main/uninstallers/uninstall.sh | sh
```

## Windows

The [Windows uninstaller](uninstallers/uninstall.ps1) stops and unregisters
the `Floord` task if present, stops any running `floord` processes it can
access, and removes `%LOCALAPPDATA%\Floord` and `%APPDATA%\floord`.

Execute:
```powershell
irm https://raw.githubusercontent.com/polete-bermejo/floord/main/uninstallers/uninstall.ps1 | iex
```

> [!NOTE]
> A graphical interface for Floord is currently under development!
> Check out floord-gui and feel free to contribute if you'd like to help with the project.
