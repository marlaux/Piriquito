#/bin/bash

MAG=$1
TMP1=$(mktemp --tmpdir=".")
EGG_FILE="gh_all_mags_EggNOG.tab"
GO_FILE="gh_all_mags_GO.tab"
NR_FILE="gh_all_mags_NR.tab"
BINS="gh_all_mags_bin_locus.tab"

mkdir ${MAG}_anno_individual

grep -w "${MAG}" $BINS | cut -f 2 > "${TMP1}"
grep -f "${TMP1}" "${EGG_FILE}" > "${MAG}_EggNOG.tab"
grep -f "${TMP1}" "${GO_FILE}" > "${MAG}_GO.tab"
grep -f "${TMP1}" "${NR_FILE}" > "${MAG}_NR.tab"
python3 Mags_anno_merge.py "${MAG}_NR.tab" "${MAG}_EggNOG.tab" "${MAG}_GO.tab"

cat "${MAG}_EggNOG.tab" | cut -f 12 | \
		sed 's/,/\n/g' | sed 's/ko://g' | sed 's/-//g' | \
		awk NF | sort | uniq | \
	       	awk '{print "gene"NR"\t"$1}' > "Knumbers_to_mapping.txt"
	find ./ -size 0c -delete
	rm tmp.*

mv merge_all.xlsx ${MAG}_merge_all.xlsx
mv merge_all.tsv ${MAG}_merge_all.tsv
mv mapping_by_product.xlsx ${MAG}_mapping_by_product.xlsx
mv mapping_by_product.tsv ${MAG}_mapping_by_product.tsv
mv mapping_by_COG.xlsx ${MAG}_mapping_by_COG.xlsx
mv mapping_by_COG.tsv ${MAG}_mapping_by_COG.tsv
mv COG_by_locus.xlsx ${MAG}_COG_by_locus.xlsx
mv COG_by_locus.tsv ${MAG}_COG_by_locus.tsv
mv KEGG_by_locus.xlsx ${MAG}_KEGG_by_locus.xlsx
mv KEGG_by_locus.tsv ${MAG}_KEGG_by_locus.tsv
mv mapping_by_KEGG.xlsx ${MAG}_mapping_by_KEGG.xlsx
mv mapping_by_KEGG.tsv ${MAG}_mapping_by_KEGG.tsv
mv GO_by_locus.xlsx ${MAG}_GO_by_locus.xlsx
mv GO_by_locus.tsv ${MAG}_GO_by_locus.tsv
mv mapping_by_GO.xlsx ${MAG}_mapping_by_GO.xlsx
mv mapping_by_GO.tsv ${MAG}_mapping_by_GO.tsv
mv Knumbers_to_mapping.txt ${MAG}_Knumbers_to_mapping.txt

mv *.tsv *.xlsx ${MAG}_Knumbers_to_mapping.txt ${MAG}_anno_individual
mv ${MAG}_EggNOG.tab ${MAG}_GO.tab ${MAG}_NR.tab ${MAG}_anno_individual
