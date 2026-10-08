* ---------------------------------------------------------------------------
* Benefit_Variation_Counts.do  ->  output/factor_results/Benefit_Variation_Counts.csv
*
* The in-text benefit-duration-variation facts (Section 3, data description):
* "Among 1,172 border county pairs used in our analysis, 1,142 have different
* benefits for at least one quarter. The median county pair has different benefit
* durations for 14 quarters during 2008-2012. The difference in available benefit
* duration within a county-pair ranges from 0 to 18 quarters."
*
* diff_logmeanwks = log(meanwks) of county 1 minus log(meanwks) of county 2 for each
* pair-quarter (built in MakeDataSetsMainPaper; carried in the controls dataset, one
* row per pair-quarter). A pair-quarter has "different benefits" when it is non-zero.
* ---------------------------------------------------------------------------

do "config.do"
set more off

use "${processed}/UIMacro_DataControls.dta", clear
keep if year>=2008 & year<=2012
gen byte diffben = abs(diff_logmeanwks) > 1e-9 & !missing(diff_logmeanwks)
collapse (sum) n_quarters_diff = diffben, by(pair_id_numeric)

count
scalar n_pairs = r(N)
count if n_quarters_diff>0
scalar n_pairs_diff = r(N)
qui sum n_quarters_diff, detail
scalar med_q = r(p50)
scalar min_q = r(min)
scalar max_q = r(max)

di as txt "==== Benefit-duration variation across border pairs, 2008-2012 ===="
di as txt "  pairs=" as res n_pairs as txt " (paper 1,172); with different benefits in >=1 quarter=" as res n_pairs_diff as txt " (paper 1,142)"
di as txt "  quarters with different durations: median=" as res med_q as txt " (paper 14), range=" as res min_q as txt "-" as res max_q as txt " (paper 0 to 18)"

file open f using "${latexdir}Benefit_Variation_Counts.csv", write replace
file write f "stat,value,published" _n
file write f "pairs," (n_pairs) ",1172" _n
file write f "pairs_diff_benefits_any_quarter," (n_pairs_diff) ",1142" _n
file write f "median_quarters_diff," (med_q) ",14" _n
file write f "min_quarters_diff," (min_q) ",0" _n
file write f "max_quarters_diff," (max_q) ",18" _n
file close f
