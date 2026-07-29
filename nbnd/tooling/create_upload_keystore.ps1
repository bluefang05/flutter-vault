param(
    [string]$ProjectRoot = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$keyPath = Join-Path $ProjectRoot 'android\app\upload-keystore.jks'
$propsPath = Join-Path $ProjectRoot 'android\key.properties'

Remove-Item -LiteralPath $keyPath, $propsPath -Force -ErrorAction SilentlyContinue

$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-+='.ToCharArray()
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

function New-Secret([int]$Length) {
    $bytes = New-Object byte[] $Length
    $rng.GetBytes($bytes)
    $output = New-Object char[] $Length
    for ($index = 0; $index -lt $Length; $index++) {
        $output[$index] = $chars[$bytes[$index] % $chars.Length]
    }
    -join $output
}

$storePass = New-Secret 32
$keyPass = $storePass
$keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'

& $keytool `
    -genkeypair `
    -v `
    -keystore $keyPath `
    -storetype PKCS12 `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias upload `
    -storepass $storePass `
    -keypass $keyPass `
    -dname 'CN=NBND, OU=Mobile, O=Enmanuel Apps, L=Santo Domingo, ST=Santo Domingo, C=DO' | Out-Null

$lines = [string[]]@(
    "storePassword=$storePass",
    "keyPassword=$keyPass",
    'keyAlias=upload',
    'storeFile=app/upload-keystore.jks'
)
[System.IO.File]::WriteAllLines($propsPath, $lines, [System.Text.UTF8Encoding]::new($false))

Get-Item -LiteralPath $keyPath, $propsPath |
    Select-Object FullName, Length, LastWriteTime |
    Format-Table -AutoSize

(Get-Content -LiteralPath $propsPath) -replace '=.*', '=***'
