clear all
set more off
version 17

* =========================
* 1) 路径设置
* =========================
global root "/Users/zhongguoming/Desktop/数据清洗Round1"
global out  "/Users/zhongguoming/Desktop/数据清洗Round1/clean_output"

cap mkdir "$out"

* =========================
* 2) 通用清洗程序
* =========================
capture program drop clean_trade_file
program define clean_trade_file
    syntax , FILE(string) SHEET(string) HS(string) CAT(string) OUTNAME(string)

    di "=============================="
    di "Importing: `file'"
    di "Sheet: `sheet'"
    di "HS: `hs' | Category: `cat'"
    di "=============================="

    import excel using "`file'", sheet("`sheet'") firstrow clear

    * 统一中文字段名
    capture rename 供应商 supplier
    capture rename 所在国 country
    capture rename 总额 total_value
    capture rename 千克重量 weight_kg
    capture rename 数量 qty
    capture rename 单价 unit_price
    capture rename 票数 shipments

    * 如果列名未成功识别，直接查看变量名
    describe

    * 强制字符串清理
    capture confirm string variable supplier
    if !_rc replace supplier = strtrim(itrim(supplier))

    capture confirm string variable country
    if !_rc replace country = strtrim(itrim(country))

    * 转数值
    capture destring total_value, replace force
    capture destring weight_kg, replace force
    capture destring qty, replace force
    capture destring unit_price, replace force
    capture destring shipments, replace force

    * 增加基础字段
    gen hs_code = "`hs'"
    gen category_main = "`cat'"

    * 供应商标准化
    gen supplier_upper = upper(supplier)

    * 有效性标记
    gen keep_flag = 1
    gen drop_reason = ""

    replace keep_flag = 0 if missing(total_value) | total_value<=0
    replace drop_reason = "invalid_total_value" if missing(total_value) | total_value<=0

    replace keep_flag = 0 if missing(qty) | qty<=0
    replace drop_reason = ///
        cond(drop_reason=="","invalid_qty", drop_reason + ";invalid_qty") ///
        if missing(qty) | qty<=0

    * 是否 NONE
    gen is_none_supplier = 0
    replace is_none_supplier = 1 if supplier_upper=="NONE"

    * 自算均价
    gen avg_price_calc = .
    replace avg_price_calc = total_value/qty if qty>0

    * 品牌初判
    gen brand_guess = ""

    replace brand_guess = "Apple" if regexm(supplier_upper,"APPLE")
    replace brand_guess = "Samsung" if regexm(supplier_upper,"SAMSUNG")
    replace brand_guess = "Xiaomi" if regexm(supplier_upper,"XIAOMI")
    replace brand_guess = "Motorola" if regexm(supplier_upper,"MOTOROLA")
    replace brand_guess = "Huawei" if regexm(supplier_upper,"HUAWEI")
    replace brand_guess = "Realme" if regexm(supplier_upper,"REALME")
    replace brand_guess = "Vivo" if regexm(supplier_upper,"VIVO")
    replace brand_guess = "ZTE" if regexm(supplier_upper,"ZTE")
    replace brand_guess = "HMD/Nokia" if regexm(supplier_upper,"HMD GLOBAL|NOKIA")
    replace brand_guess = "Transsion/Infinix" if regexm(supplier_upper,"INFINIX|TECNO|ITEL|TRANSSION")
    replace brand_guess = "OPPO/OnePlus/HeyTap" if regexm(supplier_upper,"OPPO|ONEPLUS|HEYTAP")
    replace brand_guess = "Lenovo" if regexm(supplier_upper,"LENOVO")
    replace brand_guess = "Dell" if regexm(supplier_upper,"DELL")
    replace brand_guess = "HP" if regexm(supplier_upper,"HP INC|HP USA|^HP ")
    replace brand_guess = "Zebra" if regexm(supplier_upper,"ZEBRA")
    replace brand_guess = "Foxconn/Hon Hai" if regexm(supplier_upper,"FOXCONN|HON HAI|HONGFUJIN|FUTAIHUA")
    replace brand_guess = "Huaqin" if regexm(supplier_upper,"HUAQIN")
    replace brand_guess = "Longcheer" if regexm(supplier_upper,"LONGCHEER")
    replace brand_guess = "Wingtech" if regexm(supplier_upper,"WINGTECH")
    replace brand_guess = "Luxshare" if regexm(supplier_upper,"LUXSHARE")
    replace brand_guess = "Goertek" if regexm(supplier_upper,"GOERTEK")
    replace brand_guess = "Partron" if regexm(supplier_upper,"PARTRON")
    replace brand_guess = "Unknown" if brand_guess==""

    * 价格异常标记（不删除，只标记）
    gen price_flag = ""
    replace price_flag = "very_low" if avg_price_calc<1 & !missing(avg_price_calc)
    replace price_flag = "very_high" if avg_price_calc>10000 & !missing(avg_price_calc)

    * 输出排序
    order supplier country total_value weight_kg qty unit_price avg_price_calc shipments hs_code category_main brand_guess is_none_supplier keep_flag drop_reason price_flag supplier_upper

    * 保存
    save "$out/`outname'.dta", replace
    export excel using "$out/`outname'.xlsx", firstrow(variables) replace

    * 简单汇总
    di "---- Summary: `outname' ----"
    count
    count if keep_flag==1
    count if is_none_supplier==1
    tab brand_guess if keep_flag==1, sort
    summarize total_value qty avg_price_calc if keep_flag==1
end

* =========================
* 3) 分文件执行
* =========================

clean_trade_file , ///
    file("$root/巴西手机_851713_24-26年手机品类的副本.xlsx") ///
    sheet("266539001-综合统计-20260428015652") ///
    hs("851713") ///
    cat("handset") ///
    outname("round1_851713_handset")

clean_trade_file , ///
    file("$root/巴西平板_847130_24-26 的副本.xlsx") ///
    sheet("266539001-综合统计-20260428020007") ///
    hs("847130") ///
    cat("tablet") ///
    outname("round1_847130_tablet")

clean_trade_file , ///
    file("$root/巴西蓝牙耳机_851830的副本.xlsx") ///
    sheet("266539001-综合统计-20260428020429") ///
    hs("851830") ///
    cat("accessory") ///
    outname("round1_851830_accessory")

clean_trade_file , ///
    file("$root/巴西 手机零件_851779的副本.xlsx") ///
    sheet("266539001-综合统计-20260428021123") ///
    hs("851779") ///
    cat("component") ///
    outname("round1_851779_component")

* =========================
* 4) 合并主表（可选）
* =========================
use "$out/round1_851713_handset.dta", clear
gen source_file = "851713"

append using "$out/round1_847130_tablet.dta"
replace source_file = "847130" if missing(source_file)

append using "$out/round1_851830_accessory.dta"
replace source_file = "851830" if missing(source_file)

append using "$out/round1_851779_component.dta"
replace source_file = "851779" if missing(source_file)

order source_file supplier country total_value weight_kg qty unit_price avg_price_calc shipments hs_code category_main brand_guess is_none_supplier keep_flag drop_reason price_flag

save "$out/round1_all_4files.dta", replace
export excel using "$out/round1_all_4files.xlsx", firstrow(variables) replace

di "======================================"
di "Round 1 cleaning completed."
di "Output folder: $out"
di "======================================"
