# ================= metrics-summary.ps1 =================
# Resumo de métricas do CK (Java)
# - Detecta a coluna correta de CC em method.csv: ciclomaticComplexity | cc | wmc
# - Converte valores de forma segura e gera um resumo no console e opcionalmente em arquivo

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-File($path) {
  if (-not (Test-Path $path)) {
    throw "Arquivo não encontrado: $path"
  }
}

function To-Int($v) {
  if ($null -eq $v -or "$v" -eq "") { return 0 }
  try { return [int]$v } catch { return [int][double]::Parse("$v",[System.Globalization.CultureInfo]::InvariantCulture) }
}

function To-Double($v) {
  if ($null -eq $v -or "$v" -eq "") { return 0.0 }
  try { return [double]$v } catch { return [double]::Parse("$v",[System.Globalization.CultureInfo]::InvariantCulture) }
}

# --- Entradas (ajuste se os CSVs estiverem em outro caminho) ---
$classCsvPath  = ".\class.csv"
$methodCsvPath = ".\method.csv"
$outFile       = $null         # ex: ".\ck-summary.txt" para salvar a saída

Require-File $classCsvPath
Require-File $methodCsvPath

$classCsv  = Import-Csv $classCsvPath
$methodCsv = Import-Csv $methodCsvPath

if ($classCsv.Count -eq 0 -or $methodCsv.Count -eq 0) {
  throw "CSV(s) vazio(s). Confirme se o CK gerou dados."
}

# --- Nº de classes e métodos ---
$classes = $classCsv.Count
$methods = $methodCsv.Count

# --- LOC total (coluna 'loc' em class.csv) ---
if (-not ($classCsv[0].PSObject.Properties.Name -contains "loc")) {
  throw "Coluna 'loc' não encontrada em class.csv."
}
$locTotal = ($classCsv | ForEach-Object { To-Int $_.loc } | Measure-Object -Sum).Sum

# --- Coluna de CC em method.csv: ciclomaticComplexity | cc | wmc ---
$methodCols = $methodCsv[0].PSObject.Properties.Name
$ccCol = if ($methodCols -contains "ciclomaticComplexity") {
  "ciclomaticComplexity"
} elseif ($methodCols -contains "cc") {
  "cc"
} elseif ($methodCols -contains "wmc") {
  # Em algumas versões, wmc no nível de método = CC do método
  "wmc"
} else {
  throw "Nenhuma coluna de complexidade encontrada em method.csv (procure por 'ciclomaticComplexity', 'cc' ou 'wmc')."
}

# --- CC por método ---
$ccVals = $methodCsv | ForEach-Object { To-Int $_.$ccCol }
$ccSum  = ($ccVals | Measure-Object -Sum).Sum
$ccMax  = ($ccVals | Measure-Object -Maximum).Maximum
$ccAvg  = if ($ccVals.Count -gt 0) { [math]::Round($ccSum / $ccVals.Count, 2) } else { 0 }

# --- WMC por classe (class.csv) ---
if (-not ($classCsv[0].PSObject.Properties.Name -contains "wmc")) {
  throw "Coluna 'wmc' não encontrada em class.csv."
}
$wmcVals = $classCsv | ForEach-Object { To-Int $_.wmc }
$wmcSum  = ($wmcVals | Measure-Object -Sum).Sum
$wmcMax  = ($wmcVals | Measure-Object -Maximum).Maximum
$wmcAvg  = if ($wmcVals.Count -gt 0) { [math]::Round($wmcSum / $wmcVals.Count, 2) } else { 0 }

# --- Saída ---
$lines = @()
$lines += "===== MÉTRICAS CK ====="
$lines += "Classes: $classes"
$lines += "Métodos: $methods"
$lines += "LOC total: $locTotal"
$lines += "Complexidade ciclomática média (método): $ccAvg"
$lines += "Complexidade ciclomática máxima (método): $ccMax"
$lines += "Complexidade ciclomática soma (métodos): $ccSum"
$lines += "WMC médio (classe): $wmcAvg"
$lines += "WMC máximo (classe): $wmcMax"
$lines += "WMC soma (classes): $wmcSum"
$lines += "========================"

$lines | ForEach-Object { Write-Host $_ }

if ($outFile) {
  $lines -join "`r`n" | Out-File -FilePath $outFile -Encoding UTF8
  Write-Host "Resumo salvo em: $outFile"
}
# ================= /metrics-summary.ps1 =================
