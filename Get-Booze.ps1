﻿Function Get-Booze {
    [CmdletBinding()]
    Param (
        [ValidateSet('Vinmonopolet', 'Systembolaget')][string[]]$Source = ('Vinmonopolet', 'Systembolaget')
    )

    Begin {
        $AllProtocols = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
        [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

        class Product {
            [string]$Source
            [long]$ProductNumber
            [string]$Name
            [string]$NameWithoutYear
            [int]$Year
            [float]$Price
            [float]$Volume
            [float]$PricePerLiter
            [string]$Category
            [string]$Container
            [float]$AlcoholPercentage
            [float]$PricePerAlcohol
        }
    }
    Process {
        $Products = @()
        if ($Source -contains 'Vinmonopolet') {
            $ProductsRawVinmonopoletUrl = 'https://www.vinmonopolet.no/medias/sys_master/products/products/hbc/hb0/8834253127710/produkter.csv'
            $VinmonopoletRequest = Invoke-WebRequest -Uri $ProductsRawVinmonopoletUrl
            $VinmonopoletProducts = $VinmonopoletRequest.Content | ConvertFrom-Csv -Delimiter ';'
            Foreach ($Entry in $VinmonopoletProducts) {
                $Product = New-Object Product
                $Product.Source = 'Vinmonopolet'
                $Product.ProductNumber = $Entry.Varenummer
                $Product.Name = $Entry.Varenavn
                $Product.NameWithoutYear = ($Entry.Varenavn -replace '\d{4}','').Trim()
                $Product.Year = $Entry.Argang
                $Product.Price = $Entry.Pris.Replace(',', '.')
                $Product.Volume = $Entry.Volum.Replace(',', '.')
                $Product.PricePerLiter = $Entry.LiterPris.Replace(',', '.')
                $Product.Category = $Entry.Varetype
                $Product.Container = $Entry.Emballasjetype
                $Product.AlcoholPercentage = $Entry.Alkohol.Replace(',', '.')
                $Product.PricePerAlcohol = $Product.Price/($Product.Volume*1000*($Product.AlcoholPercentage/100))
                $products += $Product
            }
        }
        if ($Source -contains 'Systembolaget') {
            $ProductsRawSystembolagetUrl = 'https://www.systembolaget.se/api/assortment/products/xml'
            $SystembolagetRequest = Invoke-WebRequest -Uri $ProductsRawSystembolagetUrl
            [xml]$SystembolagetProducts = $SystembolagetRequest.Content
            [System.Array]$SystembolagetProducts = $SystembolagetProducts.artiklar.artikel
            Foreach ($Entry in $SystembolagetProducts) {
                $Product = New-Object Product
                $Product.Source = 'Systembolaget'
                $Product.Productnumber = $Entry.nr
                $Product.Name = ("$($Entry.Namn) $($Entry.Namn2)").Trim()
                $Product.NameWithoutYear = ("$($Entry.Namn) $($Entry.Namn2)").Trim()
                $Product.Year = $Entry.Argang
                $Product.Price = $Entry.Prisinklmoms
                $Product.Volume = ($Entry.Volymiml / 1000)
                $Product.PricePerLiter = $Entry.PrisPerLiter
                $Product.Category = $Entry.Varugrupp
                $Product.Container = $Entry.Forpackning
                $Product.AlcoholPercentage = $Entry.Alkoholhalt.TrimEnd('%')
                $Product.PricePerAlcohol = $Product.Price/($Product.Volume*1000*($Product.AlcoholPercentage/100))
                $Products += $Product
            }
        }
        try {
            $Translations = Import-Csv $PSScriptRoot/translations.csv -Delimiter ';'
            foreach ($Product in $Products) {
                $TranslatedCategory = $Translations | Where-Object Original -EQ $Product.Category | Select-Object -ExpandProperty english
                if($TranslatedCategory) {
                    $Product.Category = $TranslatedCategory
                }
            }
        }
        catch {
            Write-Warning "Translations failed, the Translations.csv might be missing or translated categories might be incomplete."
        }
    }
    End {
        Write-Output $Products
    }
}
