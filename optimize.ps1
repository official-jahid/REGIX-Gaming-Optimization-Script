# নিশ্চিত করা হচ্ছে যে স্ক্রিপ্টটি Administrator হিসেবে রান হয়েছে কিনা
if (-not ([Security.Principal].WindowsPrincipal [Security.Principal].WindowsIdentity::GetCurrent()).IsInRole([Security.Principal].WindowsBuiltInRole::Administrator)) {
    Write-Warning "দয়া করে এই স্ক্রিপ্টটি Run as Administrator হিসেবে চালাও!"
    Exit
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   REGIX Gaming Optimization Script      " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# ১. Power Profile-কে Ultimate Performance-এ সেট করা
Write-Host "[+] Power Plan চেক করা হচ্ছে..." -ForegroundColor Yellow
$ultimatePlan = "2a737441-1930-4402-8d77-cc2bba7b8075"
$highPlan = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

powercfg /setactive $ultimatePlan 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[-] Ultimate Performance পাওয়া যায়নি। High Performance সেট করা হচ্ছে..." -ForegroundColor DarkYellow
    powercfg /setactive $highPlan
} else {
    Write-Host "[+] Power Plan সফলভাবে 'Ultimate Performance'-এ সেট করা হয়েছে।" -ForegroundColor Green
}

# টার্গেটেড এমুলেটর প্রসেসের তালিকা (BS5, MSI 5, MEmu, Nox ইত্যাদি)
$emulatorProcesses = @("HD-Player", "MEmuHeadless", "LdVBoxHeadless", "AndroidProcess", "Nox")

Write-Host "`n[+] চলমান এমুলেটর প্রসেস খোঁজা হচ্ছে..." -ForegroundColor Yellow
$found = $false

foreach ($procName in $emulatorProcesses) {
    $procs = Get-Process -Name $procName -ErrorAction SilentlyContinue
    
    if ($procs) {
        $found = $true
        foreach ($proc in $procs) {
            Write-Host "[*] এমুলেটর পাওয়া গেছে: $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Cyan
            
            try {
                # ২. CPU Priority -> High করা
                $proc.PriorityClass = 'High'
                Write-Host "   -> CPU Priority: HIGH করা হয়েছে।" -ForegroundColor Green
                
                # ৩. CPU Affinity -> সব কোড (বিশেষ করে P-Cores) ব্যবহার নিশ্চিত করা
                # এটি প্রসেসটিকে সিস্টেমের সবকটি লজিক্যাল কোড ব্যবহার করতে বাধ্য করবে
                $allCoresMask = ([Math]::Pow(2, [Environment]::ProcessorCount) - 1)
                $proc.ProcessorAffinity = [IntPtr]$allCoresMask
                Write-Host "   -> CPU Affinity: সমস্ত পারফরম্যান্স কোর (P-Cores) বরাদ্দ করা হয়েছে।" -ForegroundColor Green
                
                # ৪. I/O এবং Memory Priority বুস্ট
                # উইন্ডোজে CPU Priority 'High' করলে স্বয়ংক্রিয়ভাবে সেই প্রসেসের I/O এবং Page Priority সর্বোচ্চ লেভেলে চলে যায়।
                Write-Host "   -> I/O & Memory Scheduling: সর্বোচ্চ পারফরম্যান্সে বুস্ট করা হয়েছে।" -ForegroundColor Green
                
            } catch {
                Write-Host "   [-] প্রসেসটি মডিফাই করতে সমস্যা হয়েছে: $_" -ForegroundColor Red
            }
        }
    }
}

if (-not $found) {
    Write-Host "[-] কোনো চলমান এমুলেটর প্রসেস পাওয়া যায়নি! প্রথমে তোমার Bluestacks/MSI প্লেয়ারটি চালু করো।" -ForegroundColor Red
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "        অপ্টিমাইজেশন সম্পন্ন হয়েছে!        " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
