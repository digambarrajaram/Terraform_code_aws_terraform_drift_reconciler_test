$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$registryPath = Join-Path $PSScriptRoot "scope-registry.json"
$registry = Get-Content -Raw -LiteralPath $registryPath | ConvertFrom-Json
$scopes = @($registry.scopes)
$newScope = $scopes | Where-Object { $_.slug -eq "multi-f" }

if ($scopes.slug -contains "ec2") {
    throw "The retired EC2 test scope must not be present in scope-registry.json."
}

if (@($newScope).Count -ne 1) {
    throw "Expected exactly one multi-f scope row in scope-registry.json."
}

foreach ($property in @("slug", "tf_dir", "backend_key")) {
    $duplicates = $scopes | Group-Object -Property $property | Where-Object Count -gt 1
    if ($duplicates) {
        throw "Duplicate scope $property value(s): $($duplicates.Name -join ', ')"
    }
}

foreach ($scope in $scopes) {
    $scopeDir = Join-Path $repoRoot $scope.tf_dir
    if (-not (Test-Path -LiteralPath $scopeDir -PathType Container)) {
        throw "Scope '$($scope.slug)' points to missing tf_dir '$($scope.tf_dir)'."
    }

    $backendFile = Join-Path $scopeDir "backend.tf"
    if (-not (Test-Path -LiteralPath $backendFile -PathType Leaf)) {
        $backendFile = Join-Path $scopeDir "main.tf"
    }
    if (-not (Test-Path -LiteralPath $backendFile -PathType Leaf)) {
        throw "Scope '$($scope.slug)' is missing a Terraform file with backend configuration."
    }

    $backendText = Get-Content -Raw -LiteralPath $backendFile
    if ($backendText -notmatch ('(?m)^\s*key\s*=\s*"' + [regex]::Escape($scope.backend_key) + '"')) {
        throw "Scope '$($scope.slug)' backend key does not match scope-registry.json."
    }
    if ($backendText -notmatch ('(?m)^\s*bucket\s*=\s*"' + [regex]::Escape($scope.backend_bucket) + '"')) {
        throw "Scope '$($scope.slug)' backend bucket does not match scope-registry.json."
    }
    if ($backendText -notmatch ('(?m)^\s*region\s*=\s*"' + [regex]::Escape($scope.region) + '"')) {
        throw "Scope '$($scope.slug)' backend region does not match scope-registry.json."
    }
}

$existingScopes = $scopes | Where-Object { $_.slug -ne "multi-f" }
if ($existingScopes.role_arn -contains $newScope.role_arn) {
    throw "multi-f must use a dedicated role ARN, not an existing scope role."
}
if ($newScope.backend_key -eq "ec2_scope_a/terraform.tfstate" -or
    $newScope.backend_key -eq "lambda_scope_a/terraform.tfstate") {
    throw "multi-f backend key collides with an existing scope."
}

Write-Host "Scope preflight passed: multi-f has unique routing, role, and backend configuration."