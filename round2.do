clear all
set more off
version 17

global root "/Users/zhongguoming/Desktop/数据清洗Round1"
global out  "/Users/zhongguoming/Desktop/数据清洗Round1/clean_output"
global out2 "/Users/zhongguoming/Desktop/数据清洗Round1/analysis_output"

cap mkdir "$out2"

* =========================
* 1) 通用：价格带划分
* =========================
capture program drop add_price_band
program define add_price_band
    capture drop price_band
    gen price_band = ""

    replace price_band = "low"    if avg_price_calc < 100 & !missing(avg_price_calc)
    replace price_band = "mid"    if avg_price_calc >=100 & avg_price_calc < 400
    replace price_band = "upper"  if avg_price_calc >=400 & avg_price_calc < 800
    replace price_band = "high"   if avg_price_calc >=800 & avg_price_calc < 1500
    replace price_band = "premium" if avg_price_calc >=1500 & !missing(avg_price_calc)
end

* =========================
* 2) 手机整机 851713
* =========================
use "$out/round1_851713_handset.dta", clear

gen keep_main = 1
replace keep_main = 0 if keep_flag==0
replace keep_main = 0 if is_none_supplier==1

* 剔除明显非手机消费市场主体（保守）
replace keep_main = 0 if regexm(supplier_upper,"CLINICAL|HOSPITAL|MEDICAL|AVIATION|AIRLINES|DRILLING|OFFSHORE|OIL|MINING|AEROSPACE") ///
    & brand_guess=="Unknown"

* 品牌竞品标签
gen competitor_group = ""
replace competitor_group = "Apple" if brand_guess=="Apple"
replace competitor_group = "Samsung" if brand_guess=="Samsung"
replace competitor_group = "Xiaomi" if brand_guess=="Xiaomi"
replace competitor_group = "Motorola" if brand_guess=="Motorola"
replace competitor_group = "Huawei" if brand_guess=="Huawei"
replace competitor_group = "Realme" if brand_guess=="Realme"
replace competitor_group = "Vivo" if brand_guess=="Vivo"
replace competitor_group = "HMD/Nokia" if brand_guess=="HMD/Nokia"
replace competitor_group = "Transsion/Infinix" if brand_guess=="Transsion/Infinix"
replace competitor_group = "OPPO/OnePlus/HeyTap" if brand_guess=="OPPO/OnePlus/HeyTap"
replace competitor_group = "Other/Unknown" if competitor_group==""

add_price_band

save "$out2/851713_handset_round2.dta", replace
export excel using "$out2/851713_handset_round2.xlsx", firstrow(variables) replace

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(competitor_group country)
gsort -total_value
export excel using "$out2/851713_brand_country_summary.xlsx", firstrow(variables) replace
restore

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(supplier brand_guess)
gsort -total_value
export excel using "$out2/851713_supplier_summary.xlsx", firstrow(variables) replace
restore

* =========================
* 3) 平板 847130
* =========================
use "$out/round1_847130_tablet.dta", clear

gen keep_main = 1
replace keep_main = 0 if keep_flag==0
replace keep_main = 0 if is_none_supplier==1

* 更严格保留消费电子/平板相关品牌
replace keep_main = 0 if brand_guess=="Unknown" ///
    & !regexm(supplier_upper,"TABLET|LENOVO|APPLE|DELL|HP|XIAOMI|SAMSUNG|ASUS|ACER|HUAWEI|MICROSOFT|GETAC|ZEBRA")

replace keep_main = 0 if regexm(supplier_upper,"DRILLING|OFFSHORE|MEDICAL|AEROSPACE|NAVAL|AIRLINES") ///
    & !regexm(supplier_upper,"APPLE|LENOVO|DELL|HP|XIAOMI|SAMSUNG|ASUS|ACER|MICROSOFT")

gen competitor_group = ""
replace competitor_group = "Apple" if brand_guess=="Apple"
replace competitor_group = "Samsung" if brand_guess=="Samsung"
replace competitor_group = "Xiaomi" if brand_guess=="Xiaomi"
replace competitor_group = "Lenovo" if brand_guess=="Lenovo"
replace competitor_group = "Dell" if brand_guess=="Dell"
replace competitor_group = "HP" if brand_guess=="HP"
replace competitor_group = "Zebra" if brand_guess=="Zebra"
replace competitor_group = "Other/Unknown" if competitor_group==""

add_price_band

save "$out2/847130_tablet_round2.dta", replace
export excel using "$out2/847130_tablet_round2.xlsx", firstrow(variables) replace

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(competitor_group country)
gsort -total_value
export excel using "$out2/847130_brand_country_summary.xlsx", firstrow(variables) replace
restore

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(supplier brand_guess)
gsort -total_value
export excel using "$out2/847130_supplier_summary.xlsx", firstrow(variables) replace
restore

* =========================
* 4) 周边 851830
* =========================
use "$out/round1_851830_accessory.dta", clear

gen keep_main = 1
replace keep_main = 0 if keep_flag==0
replace keep_main = 0 if is_none_supplier==1

* 剔除明显航空/工业专用耳机主体（先保守）
replace keep_main = 0 if regexm(supplier_upper,"AVIATION|AIRLINES|OFFSHORE|DRILLING|AEROSPACE") ///
    & brand_guess=="Unknown"

gen competitor_group = ""
replace competitor_group = "Apple" if brand_guess=="Apple"
replace competitor_group = "Samsung" if brand_guess=="Samsung"
replace competitor_group = "Motorola" if brand_guess=="Motorola"
replace competitor_group = "Huawei" if brand_guess=="Huawei"
replace competitor_group = "Lenovo" if brand_guess=="Lenovo"
replace competitor_group = "Dell" if brand_guess=="Dell"
replace competitor_group = "HP" if brand_guess=="HP"
replace competitor_group = "Other/Unknown" if competitor_group==""

add_price_band

save "$out2/851830_accessory_round2.dta", replace
export excel using "$out2/851830_accessory_round2.xlsx", firstrow(variables) replace

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(competitor_group country)
gsort -total_value
export excel using "$out2/851830_brand_country_summary.xlsx", firstrow(variables) replace
restore

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(supplier brand_guess)
gsort -total_value
export excel using "$out2/851830_supplier_summary.xlsx", firstrow(variables) replace
restore

* =========================
* 5) 零部件 851779
* =========================
use "$out/round1_851779_component.dta", clear

gen keep_main = 1
replace keep_main = 0 if keep_flag==0
replace keep_main = 0 if is_none_supplier==1

* 零部件保留更广，但先优先手机链条
gen supplychain_group = ""
replace supplychain_group = "Samsung Chain" if regexm(supplier_upper,"SAMSUNG|PARTRON|MCNEX|CAMMSYS|POWER LOGICS|NAMUGA|ACE ANTENNA")
replace supplychain_group = "Apple/Foxconn Chain" if regexm(supplier_upper,"APPLE|FOXCONN|HON HAI|HONGFUJIN|FUTAIHUA|LUXSHARE|GOERTEK|BIEL")
replace supplychain_group = "Motorola/ODM Chain" if regexm(supplier_upper,"MOTOROLA|HUAQIN|LONGCHEER|WINGTECH")
replace supplychain_group = "Huawei/ZTE Chain" if regexm(supplier_upper,"HUAWEI|ZTE")
replace supplychain_group = "Other Telecom Chain" if supplychain_group==""

* 剔除明显非电子通信类的异常主体
replace keep_main = 0 if regexm(supplier_upper,"TEXTILE|TOY|CHEMICAL|PIGMENT") ///
    & supplychain_group=="Other Telecom Chain"

add_price_band

save "$out2/851779_component_round2.dta", replace
export excel using "$out2/851779_component_round2.xlsx", firstrow(variables) replace

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(supplychain_group country)
gsort -total_value
export excel using "$out2/851779_supplychain_country_summary.xlsx", firstrow(variables) replace
restore

preserve
keep if keep_main==1
collapse (sum) total_value qty shipments, by(supplier brand_guess supplychain_group)
gsort -total_value
export excel using "$out2/851779_supplier_summary.xlsx", firstrow(variables) replace
restore

* =========================
* 6) 整机合并分析表
* =========================
use "$out2/851713_handset_round2.dta", clear
gen product_group = "smartphone"

append using "$out2/847130_tablet_round2.dta"
replace product_group = "tablet" if missing(product_group)

gen keep_total = keep_main

save "$out2/combined_devices_round2.dta", replace
export excel using "$out2/combined_devices_round2.xlsx", firstrow(variables) replace

preserve
keep if keep_total==1
collapse (sum) total_value qty shipments, by(product_group competitor_group country price_band)
gsort product_group -total_value
export excel using "$out2/combined_devices_summary.xlsx", firstrow(variables) replace
restore

* =========================
* 7) 生成TOP表
* =========================
use "$out2/combined_devices_round2.dta", clear
keep if keep_total==1

preserve
collapse (sum) total_value qty shipments, by(country)
gsort -total_value
gen rank = _n
keep if rank<=15
export excel using "$out2/top15_origin_country_devices.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(competitor_group)
gsort -total_value
gen rank = _n
export excel using "$out2/top_brand_devices.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(supplier)
gsort -total_value
gen rank = _n
keep if rank<=30
export excel using "$out2/top30_supplier_devices.xlsx", firstrow(variables) replace
restore

di "======================================"
di "Round 2 completed."
di "Output folder: $out2"
di "======================================"
