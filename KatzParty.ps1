$katTime = $args[0]

$domains = Get-ChildItem -Path $katTime | Select-String -Pattern '([""''])(?:(?=(\\?))\2.)*?\1 will be the domain' | % { $_.Matches } | % { $_.Value } | Select-String -Pattern '([""''])(?:(?=(\\?))\2.)*?\1' | % { $_.Matches } | % { $_.Value }
$usernames = Get-ChildItem -Path $katTime | Select-String -Pattern '(?i)(?i)\s+Username.* ((?!\(null\)).*)(?!\$)' | % { $_.Matches } | % { $_.Value }
$passwords = Get-ChildItem -Path $katTime | Select-String -Pattern '\s*\*\s+Password\s+:\s+((?!\(null\)).+)\s*(?!\$)' | % { $_.Matches } | % { $_.Value }
$ntlms = Get-ChildItem -Path $katTime | Select-String -Pattern '\s*\s+nt.*:\s+((?!\(null\)).+)(?!\$)' | % { $_.Matches } | % { $_.Value }
$lms = Get-ChildItem -Path $katTime | Select-String -Pattern '\s*\s+lm.*:\s+((?!\(null\)).+)(?!\$)' | % { $_.Matches } | % { $_.Value }
$ntlms = $ntlms -replace '\s',''
$lms = $lms -replace '\s',''
$ntlms = $ntlms -replace '-','_'
$lms = $lms -replace '-','_'
$usersWithDomain = Get-ChildItem -Path $katTime | Select-String -Pattern '([""''])(?:(?=(\\?))\2.)*?\1 will be the user account' | % { $_.Matches } | % { $_.Value } | Select-String -Pattern '([""''])(?:(?=(\\?))\2.)*?\1' | % { $_.Matches } | % { $_.Value }
$usersWithDomain = $usersWithDomain  -replace ‘['']’
$domains = $domains -replace ‘['']’
$DomainPrinted = @()
$UserPrinted = @()
$b = @()
$usernames2 = @()
$holder = ''
#clean usernames
for (($p = 0); $p -lt $usernames.Length; $p++)
{
 $usernames2 += Select-String -Pattern '(?<=\:\s).*' -inputObject $usernames[$p] | % { $_.Matches } | % { $_.Value }
}

#duplicate check
$b += $domains | select –unique
#Compare-object –referenceobject $b –differenceobject $domains 

for (($i = 0); $i -lt $b.Length; $i++)
{
  if ($DomainPrinted[0] -ne ($b[$i] + "\")){
    $DomainPrinted += $b[$i] + "\"
  }
  $counter = 0
  Foreach ($User in $usersWithDomain)
  {
    $UserDomain = Select-String -Pattern '^[^\\]*' -inputObject $User | % { $_.Matches } | % { $_.Value }
    if ((($DomainPrinted[$i]).subString(0, $UserDomain.Length)) -eq $UserDomain){
        $UserPrinted += $DomainPrinted[$i] + $usernames2[$counter]
    }
    $counter = $counter + 1
  }
  #$printed = $printed + "`r`n"
}
$notes = 0
$notes2 = 0
for (($v = 0); $v -lt $usernames.Length; $v++)
{
    
  if ($notes -eq 0)
  {
      for (($c = 1); $c -lt $ntlms.Length; $c++)
      {
    
        if(!($ntlms[$c].contains("NTLM:"))){
            echo ($UserPrinted[$v] + "_" + $ntlms[$c])
        }
        else{
            $notes = $c
            break
        }
      }
  }
  else{
    for (($c = 1); ($c + $notes) -lt $ntlms.Length; $c++)
      {
    
        if(!($ntlms[$c + $notes].contains("NTLM:"))){
            echo ($UserPrinted[$v] + "_" + $ntlms[$c + $notes])
        }
        else{
            $notes = $c
            break
        }
      }
  }
  if ($notes2 -eq 0)
  {
      echo ($UserPrinted[$v] + "_" + $lms[0])
      for (($c = 1); $c -lt $lms.Length; $c++)
      {
        if(!($lms[$c].contains("0:"))){
            echo ($UserPrinted[$v] + "_" + $lms[$c])
        }
        else{
            $notes2 = $c
            break
        }
      }
  }
  else{
    echo ($UserPrinted[$v] + "_" + $lms[$notes2])
    for (($c = 1); ($c + $notes) -lt $lms.Length + 1; $c++)
      {
        if(!($lms[$c + $notes2].contains("0:"))){
            echo ($UserPrinted[$v] + "_" + $lms[$c + $notes2])
        }
        else{
            $notes2 = $c
            break
        }
      }
  }

}
#echo $printed
$printed = ''