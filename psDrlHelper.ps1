Function Get-Rules {
    Param(
        [parameter(ValueFromPipeline)] [System.IO.FileInfo[]]$File,
        [parameter()] [String[]]$FilePath
    )
    Begin {
    }
    Process {
        if ($File) {
            $p = $File.FullName
        } else {
            $p = $FilePath
        }
        $result = select-string "^\s*rule\s" -path $p | select -prop @{Name='ruleName';Expr={$_.line}},lineNumber,filename,path
        $ends   = select-string "^\s*end" -path $p | select -prop lineNumber
        $result | %{$b = $_; $e = ($ends | ?{$_.lineNumber -gt $b.lineNumber} | select -f 1); $b | Add-Member -MemberType NoteProperty -Name end -Value $e.lineNumber}
        $result | %{$b = $_; $ruleCode = (Get-Content $p | select -skip ($b.lineNumber-1) -f ($b.end-$b.lineNumber+1)) | Out-String ; $b | Add-Member -MemberType NoteProperty -Name ruleCode -Value $ruleCode} 
        return $result
    }
}

Function Select-Rules {
    Param(
        [parameter(ValueFromPipeline)] [PSCustomObject[]]$rules,
        [parameter()] [String]$Pattern
    )
    Begin {
    }
    Process {
        $rules | ?{$_.ruleCode -like "*$Pattern*"}
    }
}

Function Convert-Rules-To-String {
    Param(
        [parameter(ValueFromPipeline)] [PSCustomObject[]]$rules
    )
    Begin {
    }
    Process {
        $rules | %{"// " + $_.filename ; $_.ruleCode}
    }
}

