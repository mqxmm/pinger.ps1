param (
    [string]$ip,
    [int]$start,
    [int]$end
)

if ($ip -and $start -and $end) {
    $n = 0
    $jobs = @()

    for ($i = $start; $i -le $end; $i++) {
        $address = "$ip.$i"
        $pingResult = Test-Connection -ComputerName $address -Count 1 -ErrorAction SilentlyContinue -AsJob
        $jobs += $pingResult
    }

    # Wait for all ping jobs to complete
    $jobs | Wait-Job

    # Check the results of each job
    $jobs | ForEach-Object {
        $pingResult = Receive-Job -Job $_
        Remove-Job -Job $_
        
        if ($pingResult.StatusCode -eq 0) {
            Write-Host "$($pingResult.Address) is up."
            $n++
        }
    }

    Write-Host ""
    Write-Host "$n hosts are up."
} else {
    Write-Host "Usage: $PSCommandPath <ip> <start> <end>"
    Write-Host "Error: Insufficient arguments!"
}