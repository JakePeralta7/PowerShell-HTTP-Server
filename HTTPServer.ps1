function Send-ResponseString ($ResponseObject, $StatusCode, $ContentType, $String) {

    # Set the response status code and content type
    $ResponseObject.StatusCode = 200
    $ResponseObject.ContentType = "text/plain"

    # Write the response body
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($String)
    $ResponseObject.ContentLength64 = $buffer.Length
    $ResponseObject.OutputStream.Write($buffer, 0, $buffer.Length)

    # Close the response to send it to the client
    $ResponseObject.Close()
}

function Send-ResponseFile ($ResponseObject, $StatusCode, $ContentType, $Path) {

    # Set the response status code and content type
    $response.StatusCode = 200
    $response.ContentType = "application/octet-stream"

    # Read the file and write it to the response body
    $buffer = [System.IO.File]::ReadAllBytes($Path)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)

    # Close the response to send it to the client
    $response.Close()
}

$VerbosePreference="Continue"
Clear-Host
$Continue=$true
$Listener=[System.Net.HttpListener]::new()
$Listener.Prefixes.Add("http://+:8080/")
$Listener.Start()
while ($Continue) {
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

    $Continue = $false
  }
}
$Listener.Stop()