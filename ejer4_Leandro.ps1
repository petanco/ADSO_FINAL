[int]$num1 = Read-Host -Prompt 'Escriba un numero entre 1 y 5'
[int]$num2 = Read-Host -Prompt 'Escriba otro numero entre 1 y 5'
[int]$suma = $num1 + $num2

# Declaración de las variables a usar 

if(($num1 -gt 0) -and ($num1 -lt 6) -and ($num2 -gt 0) -and ($num2 -lt 6)) { # Chequeamos que los números que nos dan estan entre 1 y 5
                                                                             # en caso contrario nos echa del programa
    if($num1 -gt $num2){ # Esta condicional lo hacemos para ordenar los números dados de menor a mayor y poder trabajar con ellos así
        $n1 = $num2
        $n2 = $num1
    }else{
        $n1 = $num1
        $n2 = $num2
    }
          
    Write-Host "La sucesión aritmético geométrica para los siguientes 6 elementos es:" # Parte estática del texto a mostrar antes del loop
    Write-Host -NoNewline "$n1, $n2, "
           
    for ($i=1; $i-lt 6; $i++){        # Loop para sacarnos los 6 números.
        [int]$result = $n1*$n2        
        Write-Host -NoNewline $result  
        if($i -ne 5){                 # Esta condicional es para que la coma ',' no se nos ponga en el último número
            Write-Host -NoNewline ", "
        }  
        $n1 = $n2
        $n2 = $result  
        $suma = $suma + $result
    }
    Write-Host " y la suma de todos es $suma"
}else{
   Write-Host "Ha introducido algun numero incorrecto, por favor reinicie el programa" # En caso de que los números no estén en el rango nos echa del programa
   exit(1)
}
