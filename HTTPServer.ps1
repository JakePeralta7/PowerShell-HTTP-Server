Set-Location -Path ($MyInvocation.MyCommand.Path | Split-Path -Parent)
Import-Module -Name ".\HTTP.psm1" -Scope Local
Import-Module -Name ".\Variables.ps1"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    $continue=$true
    $Listener = [System.Net.HttpListener]::new()
    $Listener.Prefixes.Add($URL)
    $Listener.Start()

    while ($continue) {
      $context = $Listener.GetContext()
      $request = $context.Request
      $response = $context.Response

      Write-Verbose $request.RawUrl
      if ($request.HttpMethod -eq "POST") {
        $remoteHost = $request.RemoteEndPoint
        Write-Host "Got a POST request from $($remoteHost)"

        $command = $context.Request.Url.LocalPath

        if ($command -eq "/file") {
            if ($request.HasEntityBody) {
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $requestBody = $reader.ReadToEnd() | ConvertFrom-Json
                $reader.Close()

                if ($requestBody.Operation -eq "fetch") {
                    Send-ResponseFile -ResponseObject $response -StatusCode 200 -ContentType $ContentTypeFile -Path $requestBody.FilePath
                }
                elseif ($requestBody.Operation -eq "delete") {
                    # TODO
                }
                else {
                    Send-ResponseString -ResponseObject $response -StatusCode 200 -ContentType $ContentTypeText -String "ERROR - You need to provide the following values: FilePath, Operation (fetch, delete)"
                }
            }
            else {
                Send-ResponseString -ResponseObject $response -StatusCode 200 -ContentType $ContentTypeText -String "ERROR - You need to provide the following values: FilePath, Operation (fetch, delete)"
            }
        }

        $continue = $false
      }
    }
    $Listener.Stop()
}
else {
    Write-Host "ERROR: HTTP server needs to run as administrator" -ForegroundColor Red
    Read-Host
}