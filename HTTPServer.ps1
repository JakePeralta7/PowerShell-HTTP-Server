Import-Module -Name ".\HTTP.psm1"
Import-Module -Name ".\Variables.ps1"

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
                Send-ResponseFile -ResponseObject $response -StatusCode 200 -ContentType 'application/octet-stream' -Path $requestBody.FilePath
            }
            if ($requestBody.Operation -eq "fetch") {
                Send-ResponseFile -ResponseObject $response -StatusCode 200 -ContentType 'application/octet-stream' -Path $requestBody.FilePath
            }
            else {
                Send-ResponseString -ResponseObject $response -StatusCode 200 -ContentType 'text\plain' -String "ERROR - You need to provide the following values: FilePath, Operation (fetch, delete)"
            }
        }
        else {
            Send-ResponseString -ResponseObject $response -StatusCode 200 -ContentType 'text\plain' -String "ERROR - You need to provide the following values: FilePath, Operation (fetch, delete)"
        }
    }

    $continue = $false
  }
}
$Listener.Stop()