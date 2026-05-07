clear all
set more off
version 17

global root "/Users/zhongguoming/Desktop/数据清洗Round1"
global out2 "/Users/zhongguoming/Desktop/数据清洗Round1/analysis_output"
global out3 "/Users/zhongguoming/Desktop/数据清洗Round1/report_ready_output"

cap mkdir "$out3"

* ==================================
* 1) 通用程序：生成主口径与灰色池
* ==================================
capture program drop build_report_ready
program define build_report_ready
    syntax , INFILE(string) TYPE(string) OUTNAME(string)

    use "`infile'", clear

    * 标准化国家字段
    replace country = strtrim(itrim(country))
    gen country_missing = 0
    replace country_missing = 1 if missing(country) | country==""

    * 主报告口径
    gen keep_report = 1
    replace keep_report = 0 if keep_main!=1
    replace keep_report = 0 if country_missing==1
    replace keep_report = 0 if is_none_supplier==1

    * 品牌/链条未知项剥离
    if "`type'"=="devices" {
        replace keep_report = 0 if competitor_group=="Other/Unknown"
    }

    if "`type'"=="components" {
        replace keep_report = 0 if supplychain_group=="Other Telecom Chain"
    }

    * 灰色池
    gen grey_pool = 0
    replace grey_pool = 1 if keep_main==1 & keep_report==0

    * 保存主表
    save "$out3/`outname'_full.dta", replace
    export excel using "$out3/`outname'_full.xlsx", firstrow(variables) replace

    * 保存主口径
    preserve
    keep if keep_report==1
    save "$out3/`outname'_report_ready.dta", replace
    export excel using "$out3/`outname'_report_ready.xlsx", firstrow(variables) replace
    restore

    * 保存灰色池
    preserve
    keep if grey_pool==1
    save "$out3/`outname'_grey_pool.dta", replace
    export excel using "$out3/`outname'_grey_pool.xlsx", firstrow(variables) replace
    restore
end

* ==================================
* 2) 生成四个报告就绪表
* ==================================
build_report_ready, ///
    infile("$out2/851713_handset_round2.dta") ///
    type("devices") ///
    outname("851713_handset")

build_report_ready, ///
    infile("$out2/847130_tablet_round2.dta") ///
    type("devices") ///
    outname("847130_tablet")

build_report_ready, ///
    infile("$out2/851830_accessory_round2.dta") ///
    type("devices") ///
    outname("851830_accessory")

build_report_ready, ///
    infile("$out2/851779_component_round2.dta") ///
    type("components") ///
    outname("851779_component")

* ==================================
* 3) 合并整机主口径
* ==================================
use "$out3/851713_handset_report_ready.dta", clear
gen product_group = "smartphone"

append using "$out3/847130_tablet_report_ready.dta"
replace product_group = "tablet" if missing(product_group)

save "$out3/devices_report_ready_combined.dta", replace
export excel using "$out3/devices_report_ready_combined.xlsx", firstrow(variables) replace

* ==================================
* 4) 设备：品牌TOP / 国家TOP / 价格带
* ==================================
use "$out3/devices_report_ready_combined.dta", clear

preserve
collapse (sum) total_value qty shipments, by(competitor_group)
gsort -total_value
gen rank = _n
export excel using "$out3/devices_top_brand_report_ready.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(country)
gsort -total_value
gen rank = _n
export excel using "$out3/devices_top_country_report_ready.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(product_group price_band)
gsort product_group -total_value
export excel using "$out3/devices_priceband_summary.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(product_group competitor_group country)
gsort product_group -total_value
export excel using "$out3/devices_brand_country_matrix.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(supplier competitor_group)
gsort -total_value
gen rank = _n
keep if rank<=30
export excel using "$out3/devices_top30_supplier_report_ready.xlsx", firstrow(variables) replace
restore

* ==================================
* 5) 周边：品牌TOP / 国家TOP
* ==================================
use "$out3/851830_accessory_report_ready.dta", clear

preserve
collapse (sum) total_value qty shipments, by(competitor_group)
gsort -total_value
gen rank = _n
export excel using "$out3/accessory_top_brand_report_ready.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(country)
gsort -total_value
gen rank = _n
export excel using "$out3/accessory_top_country_report_ready.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(supplier competitor_group)
gsort -total_value
gen rank = _n
keep if rank<=30
export excel using "$out3/accessory_top30_supplier_report_ready.xlsx", firstrow(variables) replace
restore

* ==================================
* 6) 零部件：供应链/国家/供应商
* ==================================
use "$out3/851779_component_report_ready.dta", clear

preserve
collapse (sum) total_value qty shipments, by(supplychain_group)
gsort -total_value
gen rank = _n
export excel using "$out3/component_supplychain_top.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(country supplychain_group)
gsort -total_value
export excel using "$out3/component_supplychain_country_matrix.xlsx", firstrow(variables) replace
restore

preserve
collapse (sum) total_value qty shipments, by(supplier supplychain_group country)
gsort -total_value
gen rank = _n
keep if rank<=50
export excel using "$out3/component_top50_supplier_report_ready.xlsx", firstrow(variables) replace
restore

* ==================================
* 7) 灰色池占比
* ==================================
capture program drop grey_share
program define grey_share
    syntax , FULL(string) TITLE(string)

    use "`full'", clear
    gen total_all = total_value
    gen total_report = total_value if keep_report==1
    gen total_grey = total_value if grey_pool==1

    quietly summarize total_all
    scalar a = r(sum)

    quietly summarize total_report
    scalar b = r(sum)

    quietly summarize total_grey
    scalar c = r(sum)

    clear
    set obs 1
    gen dataset = "`title'"
    gen total_value_all = a
    gen total_value_report = b
    gen total_value_grey = c
    gen report_share = b/a
    gen grey_share = c/a

    export excel using "$out3/grey_share_`title'.xlsx", firstrow(variables) replace
end

grey_share, full("$out3/851713_handset_full.dta") title("851713_handset")
grey_share, full("$out3/847130_tablet_full.dta") title("847130_tablet")
grey_share, full("$out3/851830_accessory_full.dta") title("851830_accessory")
grey_share, full("$out3/851779_component_full.dta") title("851779_component")

di "======================================"
di "Round 3 completed."
di "Output folder: $out3"
di "======================================"
