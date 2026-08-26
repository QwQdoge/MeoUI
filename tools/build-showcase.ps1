param(
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$Config = "Release",
    [string]$OutputRoot = "",
    [string]$BuildDir = "",
    [string]$InstallDir = "",
    [string]$ValidationDir = "",
    [string]$RunId = "",
    [string]$QtPrefixPath = "",
    [string]$ScreenshotPath = "",
    [switch]$Install,
    [switch]$Run
)

$ErrorActionPreference = "Stop"

$SourceDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$RunIdWasExplicit = $RunId -ne ""
$ValidationDirWasExplicit = $ValidationDir -ne ""

function Resolve-MeoPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$BaseDirectory = $SourceDir
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $Path))
}

function Invoke-Logged {
    param(
        [Parameter(Mandatory = $true)][string]$LogPath,
        [Parameter(Mandatory = $true)][scriptblock]$Command
    )

    & $Command 2>&1 | Tee-Object -FilePath $LogPath
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE. See $LogPath"
    }
}

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    throw "cmake was not found on PATH. Install CMake and Qt, or run this from a Qt developer shell."
}

$PythonCommand = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $PythonCommand) {
    $PythonCommand = Get-Command python -ErrorAction SilentlyContinue
}
if (-not $PythonCommand) {
    throw "python3 or python was not found on PATH; it is required to verify Showcase coverage."
}

if ($OutputRoot -eq "") {
    $OutputRoot = if ($env:MEO_OUTPUT_ROOT) {
        $env:MEO_OUTPUT_ROOT
    } else {
        Join-Path (Split-Path -Parent $SourceDir) "outputs"
    }
}
$OutputRoot = Resolve-MeoPath $OutputRoot

if ($BuildDir -eq "") {
    $BuildDir = if ($env:MEO_UI_BUILD_DIR) {
        $env:MEO_UI_BUILD_DIR
    } else {
        Join-Path $OutputRoot "meo-ui/build/showcase"
    }
}
if ($InstallDir -eq "") {
    $InstallDir = if ($env:MEO_UI_INSTALL_DIR) {
        $env:MEO_UI_INSTALL_DIR
    } else {
        Join-Path $OutputRoot "meo-ui/install/showcase"
    }
}
if ($RunId -eq "") {
    $RunId = if ($env:MEOUI_RUN_ID) {
        $null = ($RunIdWasExplicit = $true)
        $env:MEOUI_RUN_ID
    } elseif ($Run) {
        "{0}-showcase-run" -f [DateTime]::UtcNow.ToString("yyyy-MM-ddTHHmmssZ")
    } else {
        "{0}-showcase-build" -f [DateTime]::UtcNow.ToString("yyyy-MM-ddTHHmmssZ")
    }
}
if ($RunId -notmatch '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}Z-[A-Za-z0-9][A-Za-z0-9._-]*$') {
    throw "Invalid -RunId '$RunId'. Expected YYYY-MM-DDTHHMMSSZ-short-label."
}
if ($ValidationDir -eq "") {
    $ValidationDir = if ($env:MEOUI_VALIDATION_DIR) {
        $null = ($ValidationDirWasExplicit = $true)
        $env:MEOUI_VALIDATION_DIR
    } else {
        Join-Path $OutputRoot "meo-ui/validation/$RunId"
    }
}

if (-not $RunIdWasExplicit -and -not $ValidationDirWasExplicit) {
    $InitialRunId = $RunId
    $Suffix = 2
    while (Test-Path -LiteralPath (Join-Path $OutputRoot "meo-ui/validation/$RunId")) {
        $RunId = "$InitialRunId-$Suffix"
        $Suffix += 1
    }
    $ValidationDir = Join-Path $OutputRoot "meo-ui/validation/$RunId"
}

$BuildPath = Resolve-MeoPath $BuildDir
$InstallPath = Resolve-MeoPath $InstallDir
$ValidationPath = Resolve-MeoPath $ValidationDir
if ($ScreenshotPath -ne "") {
    $ScreenshotPath = Resolve-MeoPath $ScreenshotPath $ValidationPath
}

New-Item -ItemType Directory -Force -Path $ValidationPath | Out-Null
$ReadmePath = Join-Path $ValidationPath "README.md"
if (-not (Test-Path -LiteralPath $ReadmePath)) {
    @(
        "# MeoUI Showcase validation run",
        "",
        "- Run ID: ``$RunId``",
        "- Build directory: ``$BuildPath``",
        "- Install directory: ``$InstallPath``",
        "- Run requested: ``$($Run.IsPresent)``",
        "",
        "Files in this directory are the evidence for one Showcase invocation. The build launcher writes coverage, configure, build, install, and runtime logs here as applicable."
    ) | Set-Content -LiteralPath $ReadmePath -Encoding UTF8
}
$ChecklistPath = Join-Path $ValidationPath "delivery-checklist.md"
if (-not (Test-Path -LiteralPath $ChecklistPath)) {
    @(
        "# MeoUI Showcase delivery checklist",
        "",
        "Status: complete this checklist before claiming delivery acceptance.",
        "",
        "- Public QML exports: see ``coverage.log`` for the automated qmldir-to-sample gate.",
        "- Changed tokens and theme behavior:",
        "- Changed C++ runtime/API surface:",
        "- Changed assets or packaging:",
        "- Changed visible behavior and its Showcase sample:",
        "- Visual/manual review scope and result:",
        "- Intentional non-visual items and rationale:"
    ) | Set-Content -LiteralPath $ChecklistPath -Encoding UTF8
}

$CoverageVerifier = Join-Path $SourceDir "tools/verify-showcase-coverage.py"
Invoke-Logged (Join-Path $ValidationPath "coverage.log") {
    & $PythonCommand.Source $CoverageVerifier
}

$ConfigureArgs = @("-S", $SourceDir, "-B", $BuildPath, "-DCMAKE_BUILD_TYPE=$Config")
if ($QtPrefixPath -ne "") {
    $ConfigureArgs += "-DCMAKE_PREFIX_PATH=$QtPrefixPath"
}
Invoke-Logged (Join-Path $ValidationPath "configure.log") {
    & cmake @ConfigureArgs
}
Invoke-Logged (Join-Path $ValidationPath "build.log") {
    & cmake --build $BuildPath --config $Config --target MeoShowcaseDemo
}

if ($Install) {
    Invoke-Logged (Join-Path $ValidationPath "install.log") {
        & cmake --install $BuildPath --config $Config --prefix $InstallPath
    }
}

if ($Run) {
    $candidates = @(
        (Join-Path $BuildPath $Config "MeoShowcaseDemo.exe"),
        (Join-Path $BuildPath "MeoShowcaseDemo.exe")
    )
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) {
        throw "Could not find MeoShowcaseDemo.exe in $BuildPath"
    }

    if ($ScreenshotPath -ne "") {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ScreenshotPath) | Out-Null
    }
    $LaunchArgs = @("--validation-dir=$ValidationPath", "--run-id=$RunId")
    if ($ScreenshotPath -ne "") {
        $LaunchArgs += "--screenshot=$ScreenshotPath"
    }

    $HadValidationDir = Test-Path Env:MEOUI_VALIDATION_DIR
    $HadRunId = Test-Path Env:MEOUI_RUN_ID
    $PreviousValidationDir = $env:MEOUI_VALIDATION_DIR
    $PreviousRunId = $env:MEOUI_RUN_ID
    try {
        $env:MEOUI_VALIDATION_DIR = $ValidationPath
        $env:MEOUI_RUN_ID = $RunId
        Invoke-Logged (Join-Path $ValidationPath "run.stdout.log") {
            & $exe @LaunchArgs
        }
    } finally {
        if ($HadValidationDir) {
            $env:MEOUI_VALIDATION_DIR = $PreviousValidationDir
        } else {
            Remove-Item Env:MEOUI_VALIDATION_DIR -ErrorAction SilentlyContinue
        }
        if ($HadRunId) {
            $env:MEOUI_RUN_ID = $PreviousRunId
        } else {
            Remove-Item Env:MEOUI_RUN_ID -ErrorAction SilentlyContinue
        }
    }
}
