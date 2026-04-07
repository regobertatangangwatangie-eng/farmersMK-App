$ErrorActionPreference = "SilentlyContinue"

# ─── Load HTTP assembly (required in fresh PS5 sessions) ─────────────────────
Add-Type -AssemblyName System.Net.Http -ErrorAction Stop

# ─── HTTP client ──────────────────────────────────────────────────────────────
$httpHandler          = New-Object System.Net.Http.HttpClientHandler
$httpClient           = New-Object System.Net.Http.HttpClient($httpHandler)
$httpClient.Timeout   = [TimeSpan]::FromSeconds(8)

# ─── Single HTTP probe (returns int status code, 0 = no response) ─────────────
function Invoke-Probe {
    param(
        [string]$Url,
        [string]$Method      = "GET",
        [string]$Body        = $null,
        [string]$ContentType = "application/json"
    )
    try {
        $reqMethod = New-Object System.Net.Http.HttpMethod($Method)
        $request   = New-Object System.Net.Http.HttpRequestMessage($reqMethod, $Url)
        if ($Body) {
            $request.Content = New-Object System.Net.Http.StringContent(
                $Body, [System.Text.Encoding]::UTF8, $ContentType)
        }
        $response = $httpClient.SendAsync($request).GetAwaiter().GetResult()
        return [int]$response.StatusCode
    } catch {
        return 0
    }
}

# ─── Classify an HTTP status code into a functional health label ──────────────
function Get-FunctionalStatus {
    param([int]$Code, [bool]$TcpOpen)
    if (-not $TcpOpen) { return "DOWN" }
    switch ($Code) {
        0                    { return "DOWN"      }   # no TCP/HTTP connection
        { $_ -in 200..299 }  { return "HEALTHY"   }   # endpoint responded correctly
        { $_ -in 301..302 }  { return "HEALTHY"   }   # redirect = service alive
        { $_ -in 401..403 }  { return "SECURED"   }   # auth-gated – expected in prod
        { $_ -ge 500 }       { return "DEGRADED"  }   # app up but internal error
        default              { return "REACHABLE" }   # 404/405/4xx – app alive, no 2xx
    }
}

# ─── Rank map used to keep the best probe result across multiple paths ─────────
$rank = @{ HEALTHY = 5; SECURED = 4; REACHABLE = 3; DEGRADED = 2; DOWN = 1 }

# ─── Try every probe entry for a service, return the best result ──────────────
function Test-Service {
    param([hashtable]$Svc, [bool]$TcpOpen)
    $best = @{ Code = 0; Url = "$($Svc.Url)/"; Status = "DOWN" }
    if (-not $TcpOpen) { return $best }

    foreach ($p in $Svc.Probes) {
        $url    = "$($Svc.Url)$($p.Path)"
        $method = if ($p.Method) { $p.Method } else { "GET" }
        $code   = Invoke-Probe -Url $url -Method $method -Body $p.Body
        $status = Get-FunctionalStatus -Code $code -TcpOpen $TcpOpen
        if ($rank[$status] -gt $rank[$best.Status]) {
            $best = @{ Code = $code; Url = $url; Status = $status }
        }
        if ($status -eq "HEALTHY") { break }   # perfect match – stop probing
    }
    return $best
}

# ─── Service registry ─────────────────────────────────────────────────────────
# Each Probes entry: Path (required), Method (default GET), Body (default null)
# Entries are tried in order; first HEALTHY result wins.
# Payment/social services include POST probes with realistic but safe payloads.
$services = @(

    @{  Name = "Frontend (Docker)"
        Url  = "http://localhost:3000"
        Probes = @(
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "Frontend (Vite)"
        Url  = "http://localhost:5173"
        Probes = @(
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "Frontend (Vite Alt)"
        Url  = "http://localhost:5174"
        Probes = @(
            @{ Path = "/"; Method = "GET" }
        )
    },

    @{  Name = "API Gateway"
        Url  = "http://localhost:8080"
        Probes = @(
            @{ Path = "/actuator/health"; Method = "GET" },
            @{ Path = "/";                Method = "GET" }
        )
    },

    # ── Core services (GET endpoints) ────────────────────────────────────────
    @{  Name = "Admin"
        Url  = "http://localhost:8081"
        Probes = @(
            @{ Path = "/admin/stats"; Method = "GET" },
            @{ Path = "/admin/users"; Method = "GET" },
            @{ Path = "/";            Method = "GET" }
        )
    },
    @{  Name = "User"
        Url  = "http://localhost:8082"
        Probes = @(
            @{ Path = "/users"; Method = "GET" },
            @{ Path = "/";      Method = "GET" }
        )
    },
    @{  Name = "Marketplace"
        Url  = "http://localhost:8083"
        Probes = @(
            @{ Path = "/products"; Method = "GET" },
            @{ Path = "/";         Method = "GET" }
        )
    },
    @{  Name = "Notification"
        Url  = "http://localhost:8084"
        Probes = @(
            @{ Path = "/api/notifications"; Method = "GET" },
            @{ Path = "/api/notifications"; Method = "POST"
               Body = '{"recipient":"health@FarmersMK.local","message":"probe"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "Post"
        Url  = "http://localhost:8085"
        Probes = @(
            @{ Path = "/posts"; Method = "GET" },
            @{ Path = "/";      Method = "GET" }
        )
    },
    @{  Name = "Wallet"
        Url  = "http://localhost:8086"
        Probes = @(
            @{ Path = "/wallets"; Method = "GET" },
            @{ Path = "/";        Method = "GET" }
        )
    },
    @{  Name = "Realtime"
        Url  = "http://localhost:8087"
        Probes = @(
            @{ Path = "/actuator/health"; Method = "GET" },
            @{ Path = "/";                Method = "GET" }
        )
    },

    # ── Payment services (POST probes with valid payloads) ───────────────────
    @{  Name = "Mastercard"
        Url  = "http://localhost:8088"
        Probes = @(
            @{ Path = "/api/mastercard/pay"; Method = "POST"
               Body = '{"cardNumber":"5500000000000004","amount":1.00,"currency":"XAF","description":"health-probe"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "VISA"
        Url  = "http://localhost:8089"
        Probes = @(
            @{ Path = "/api/visacard/pay"; Method = "POST"
               Body = '{"cardNumber":"4111111111111111","amount":1.00,"currency":"XAF","description":"health-probe"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "MTN Mobile Money"
        Url  = "http://localhost:8090"
        Probes = @(
            @{ Path = "/mtn"; Method = "GET" },
            @{ Path = "/mtn"; Method = "POST"
               Body = '{"phoneNumber":"237600000001","amount":100,"description":"health-probe"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "Orange Money"
        Url  = "http://localhost:8091"
        Probes = @(
            @{ Path = "/orangemoney/send"; Method = "POST"
               Body = '{"phoneNumber":"237620000001","amount":100,"description":"health-probe"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "Crypto Wallet"
        Url  = "http://localhost:8092"
        Probes = @(
            @{ Path = "/api/crypto/transfer"; Method = "POST"
               Body = '{"walletAddress":"0xProbe0000000000000000000000000000000001","amount":0.001,"cryptoType":"ETH","description":"health-probe"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },

    # ── Social media services (POST probes with valid payloads) ──────────────
    @{  Name = "Facebook"
        Url  = "http://localhost:8093"
        Probes = @(
            @{ Path = "/facebook/post"; Method = "POST"
               Body = '{"title":"farmersmk Health Check","content":"probe"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "Instagram"
        Url  = "http://localhost:8094"
        Probes = @(
            @{ Path = "/api/instagram/redirect?url=https://FarmersMK.local"; Method = "GET" },
            @{ Path = "/api/instagram/ads"; Method = "POST"
               Body = '{"title":"farmersmk Ad","content":"probe","redirectUrl":"https://FarmersMK.local"}' },
            @{ Path = "/"; Method = "GET" }
        )
    },
    @{  Name = "Twitter/X"
        Url  = "http://localhost:8095"
        Probes = @(
            @{ Path = "/twitter/posts"; Method = "GET" },
            @{ Path = "/twitter/posts"; Method = "POST"
               Body = '{"title":"farmersmk Health Check","content":"probe","link":"https://FarmersMK.local"}' },
            @{ Path = "/"; Method = "GET" }
        )
    }
)

# ─── Status colour map ────────────────────────────────────────────────────────
$statusColor = @{
    HEALTHY   = "Green"
    SECURED   = "Cyan"
    REACHABLE = "Yellow"
    DEGRADED  = "Magenta"
    DOWN      = "Red"
}

# ─── Header ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== farmersmk SERVICE HEALTH DASHBOARD ===" -ForegroundColor Cyan
Write-Host "    Functional endpoint probes | POST payloads for payment & social services" -ForegroundColor DarkGray
Write-Host ""
Write-Host ("{0,-24} {1,-7} {2,-10}  {3,-11}  {4}" -f `
    "Service", "TCP", "HTTP", "Status", "Probed URL") -ForegroundColor White
Write-Host ("-" * 95)

$summary = @{ HEALTHY = 0; SECURED = 0; REACHABLE = 0; DEGRADED = 0; DOWN = 0 }

# ─── Probe loop ───────────────────────────────────────────────────────────────
foreach ($svc in $services) {
    $port     = ([System.Uri]$svc.Url).Port
    $tcp      = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
    $tcpOpen  = $tcp.TcpTestSucceeded
    $tcpLabel = if ($tcpOpen) { "OPEN  " } else { "CLOSED" }

    $result   = Test-Service -Svc $svc -TcpOpen $tcpOpen
    $httpCode = if ($result.Code -gt 0) { "HTTP_$($result.Code)" } else { "NO_HTTP" }
    $status   = $result.Status
    $summary[$status]++

    Write-Host ("{0,-24} {1,-7} {2,-10}  " -f $svc.Name, $tcpLabel, $httpCode) -NoNewline
    Write-Host ("{0,-11}" -f "[$status]") -ForegroundColor $statusColor[$status] -NoNewline
    Write-Host "  $($result.Url)"
}

# ─── Summary ─────────────────────────────────────────────────────────────────
Write-Host ("-" * 95)
Write-Host ""
Write-Host "Summary:" -ForegroundColor White
Write-Host ("  HEALTHY   : {0,2}   2xx at functional endpoint - fully operational"  -f $summary.HEALTHY)   -ForegroundColor Green
Write-Host ("  SECURED   : {0,2}   401/403 - auth-gated, application is running"    -f $summary.SECURED)   -ForegroundColor Cyan
Write-Host ("  REACHABLE : {0,2}   HTTP response but no 2xx - check routes/config"  -f $summary.REACHABLE) -ForegroundColor Yellow
Write-Host ("  DEGRADED  : {0,2}   5xx - application running but internal errors"   -f $summary.DEGRADED)  -ForegroundColor Magenta
Write-Host ("  DOWN      : {0,2}   TCP closed or no HTTP response"                  -f $summary.DOWN)      -ForegroundColor Red
Write-Host ""
Write-Host "Frontend entry points:" -ForegroundColor White
Write-Host "  Service hub  : http://localhost          (nginx)"
Write-Host "  Docker build : http://localhost:3000"
Write-Host "  Vite dev     : http://localhost:5173"

$httpClient.Dispose()
