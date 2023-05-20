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