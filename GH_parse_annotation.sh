#/bin/bash

PREFIX=''
DIR=''
COMP=''
TMP1=$(mktemp --tmpdir=".")
TMP2=$(mktemp --tmpdir=".")
GET_ACC="gh_get_accession.py"
MERGE="gh_merge.py"
EGG_FILE="gh_all_mags_EggNOG.tab"
GO_FILE="gh_all_mags_GO.tab"
NR_FILE="gh_all_mags_NR.tab"
BINS="gh_all_mags_bin_locus.tab"
CLOUD='cloud'
SHELL='shell'
SOFT='softcore'

usage () {
	echo "######################################################################"
	echo "PARSE GET_HOMOLOGUES RESULTS TO SABIA ANNOTATIONS"
	echo "copiar todo o conteudo da pasta 'GH_scripts' antes de rodar."
	echo " "
	echo "Usage: ${0} [-f cluster list] [-p prefix]"
	echo "-c Compartimento do pangenoma: 'core', 'softcore', 'shell' ou 'cloud'"
	echo "-d Diretório contendo os genomas no formato .faa"
	echo "-p Prefixo para identificar os outputs. Ex: 'Pseudomonas_ETDI_bin8'"
	echo "-h print this help"
	echo " "
	echo "######################################################################"
		1>&2; exit 1;
}

while getopts "c:d:p:h" option; do
	case $option in
	c) COMP="${OPTARG}"
		;;
	d) DIR="${OPTARG}"
		;;
	p) PREFIX="${OPTARG}"
		;;
	h | *) usage
		exit 0
		;;
	\?) echo "Invalid option: -$OPTARG"
		exit 1
		;;
	esac
done

if [ -z "${DIR}" ] || [ -z "${PREFIX}" ] || [ -z "${COMP}" ]; then
	echo "Argumento faltando."
	echo "./GH_parse_annotation.sh -h" >&2
	exit 1
fi

mkdir ${PREFIX}_GH_output_files/intersection/${COMP}_results
mkdir ${PREFIX}_GH_output_files/only_OMCL/${COMP}_results
cd ${DIR}_homologues/intersection
cp ../../gh_* .
LIST=pangenome_matrix_t0__${COMP}_list.txt

if [[ "$COMP" == *"$CLOUD"* ]] || [[ "$COMP" == *"$SHELL"* ]] || [[ "$COMP" == *"$SOFT"* ]]; then
	grep "bin" $LIST > "${TMP1}"
	python3 gh_get_accession.py "${TMP1}"
	EGG="${LIST/_list.txt/_EggNOG.tsv}"
	GO="${LIST/_list.txt/_GO.tsv}"
	NR="${LIST/_list.txt/_NR.tsv}"
	LOCUS="${LIST/_list.txt/_locus_id.tsv}"
	REFS="${LIST/_list.txt/_references_accession.tsv}"
	grep -f "TMP_ID.tab" "${EGG_FILE}" > "${EGG}"
	grep -f "TMP_ID.tab" "${GO_FILE}" > "${GO}"
	grep -f "TMP_ID.tab" "${NR_FILE}" > "${NR}"
	mv TMP_ID.tab "${LOCUS}"
	python3 gh_merge.py "${NR}" "${EGG}" "${BINS}" "${GO}"
	grep -v "bin" $LIST > "${TMP2}"
	python3 gh_get_accession.py "${TMP2}"
	mv TMP_ID.tab "${REFS}"
	rm tmp.*
else
	python3 gh_get_accession.py "${LIST}"
        EGG="${LIST/_list.txt/_EggNOG.tsv}"
        GO="${LIST/_list.txt/_GO.tsv}"
        NR="${LIST/_list.txt/_NR.tsv}"
        LOCUS="${LIST/_list.txt/_locus_id.tsv}"
        grep -f "TMP_ID.tab" "${EGG_FILE}" > "${EGG}"
        grep -f "TMP_ID.tab" "${GO_FILE}" > "${GO}"
        grep -f "TMP_ID.tab" "${NR_FILE}" > "${NR}"
        mv TMP_ID.tab "${LOCUS}"
        python3 gh_merge.py "${NR}" "${EGG}" "${BINS}" "${GO}"
fi

./gh_get_core_set.sh "gh_min_core_gene_set.txt" "merge_all.tsv"
mv min_core_found.txt ${PREFIX}_${COMP}_min_gene_set_found.txt
mv min_core_missing.txt ${PREFIX}_${COMP}_min_gene_set_missing.txt
mv ${PREFIX}_${COMP}_min_gene_set* ../../${PREFIX}_GH_output_files/intersection
mv merge_all.xlsx ${PREFIX}_${COMP}_merge_all.xlsx
mv merge_all.tsv ${PREFIX}_${COMP}_merge_all.tsv
mv mapping_by_product.xlsx ${PREFIX}_${COMP}_mapping_by_product.xlsx
mv mapping_by_product.tsv ${PREFIX}_${COMP}_mapping_by_product.tsv
mv mapping_by_COG.xlsx ${PREFIX}_${COMP}_mapping_by_COG.xlsx
mv mapping_by_COG.tsv ${PREFIX}_${COMP}_mapping_by_COG.tsv
mv COG_by_locus.xlsx ${PREFIX}_${COMP}_COG_by_locus.xlsx
mv COG_by_locus.tsv ${PREFIX}_${COMP}_COG_by_locus.tsv
mv KEGG_by_locus.xlsx ${PREFIX}_${COMP}_KEGG_by_locus.xlsx
mv KEGG_by_locus.tsv ${PREFIX}_${COMP}_KEGG_by_locus.tsv
mv mapping_by_KEGG.xlsx ${PREFIX}_${COMP}_mapping_by_KEGG.xlsx
mv mapping_by_KEGG.tsv ${PREFIX}_${COMP}_mapping_by_KEGG.tsv
mv GO_by_locus.xlsx ${PREFIX}_${COMP}_GO_by_locus.xlsx
mv GO_by_locus.tsv ${PREFIX}_${COMP}_GO_by_locus.tsv
mv mapping_by_GO.xlsx ${PREFIX}_${COMP}_mapping_by_GO.xlsx
mv mapping_by_GO.tsv ${PREFIX}_${COMP}_mapping_by_GO.tsv
mv *.tsv *.xlsx ../../${PREFIX}_GH_output_files/intersection/${COMP}_results
rm gh_*
cd ../../${PREFIX}_GH_output_files/intersection/

log_file="GH_pipeline_results_metrics.txt"
LOG="${PREFIX}_GH_pipe.log"
CORE='pangenome_matrix_t0__core_list.txt'
SOFTCORE='pangenome_matrix_t0__softcore_list.txt'
SHELL='pangenome_matrix_t0__shell_list.txt'
CLOUD='pangenome_matrix_t0__cloud_list.txt'

CORE_c=$(wc -l < $CORE)
SOFTCORE_c=$(wc -l < $SOFTCORE)
SOFT_bin=$(grep -c "bin" $SOFTCORE)
SOFT_bin_p=$(awk -v t1="$SOFT_bin" -v t2="$SOFTCORE_c" 'BEGIN{print t1/t2 * 100}')
SOFT_ref=$(grep -c -v "bin" $SOFTCORE)
SOFT_ref_p=$(awk -v t1="$SOFT_ref" -v t2="$SOFTCORE_c" 'BEGIN{print t1/t2 * 100}')
SHELL_c=$(wc -l < $SHELL)
SHELL_bin=$(grep -c "bin" $SHELL)
SHELL_bin_p=$(awk -v t1="$SHELL_bin" -v t2="$SHELL_c" 'BEGIN{print t1/t2 * 100}')
SHELL_ref=$(grep -c -v "bin" $SHELL)
SHELL_ref_p=$(awk -v t1="$SHELL_ref" -v t2="$SHELL_c" 'BEGIN{print t1/t2 * 100}')
CLOUD_c=$(wc -l < $CLOUD)
CLOUD_bin=$(grep -c "bin" $CLOUD)
CLOUD_bin_p=$(awk -v t1="$CLOUD_bin" -v t2="$CLOUD_c" 'BEGIN{print t1/t2 * 100}')
CLOUD_ref=$(grep -c -v "bin" $CLOUD)
CLOUD_ref_p=$(awk -v t1="$CLOUD_ref" -v t2="$CLOUD_c" 'BEGIN{print t1/t2 * 100}')
PAN_c=$(($SOFTCORE_c + $SHELL_c + $CLOUD_c))
RATIO=$(awk -v t1="$CORE_c" -v t2="$PAN_c" 'BEGIN{print t1/t2 * 100}')
RATIOs=$(awk -v t1="$SOFTCORE_c" -v t2="$PAN_c" 'BEGIN{print t1/t2 * 100}')


echo "####GET_Homologues comandos 'COG' e 'OMCL' completos:###\n" > "${log_file}"
grep "# /get_homologues/get_homologues.pl" "${LOG}" >> "${log_file}"
echo " " >> "${log_file}"
grep -A 2 "# number_of_clusters =" "${LOG}" >> "${log_file}"
echo " " >> "${log_file}"
grep "# intersection size =" "${LOG}" >> "${log_file}"
echo " " >> "${log_file}"
grep "# pangenome_phylip file =" "${LOG}" >> "${log_file}"
grep "# pangenome_FASTA file =" "${LOG}" >> "${log_file}"
echo " " >> "${log_file}"
grep "# matrix contains" "${LOG}" >> "${log_file}"
grep "# cloud size:" "${LOG}" >> "${log_file}"
echo "Local bin clusters compose $CLOUD_bin_p% from Cloud compartment" >> "${log_file}"
echo "References clusters compose $CLOUD_ref_p% from Cloud compartment" >> "${log_file}"
echo " " >> "${log_file}"
grep "# shell size:" "${LOG}" >> "${log_file}"
echo "Local bin clusters compose $SHELL_bin_p% from Shell compartment" >> "${log_file}"
echo "References clusters compose $SHELL_ref_p% from Shell compartment" >> "${log_file}"
echo " " >> "${log_file}"
grep "# soft core size:" "${LOG}" >> "${log_file}"
echo "Local bin clusters compose $SOFT_bin_p% from Sooftcore compartment" >> "${log_file}"
echo "References clusters compose $SOFT_ref_p% from Softcore compartment" >> "${log_file}"
echo " " >> "${log_file}"
grep "# core size:" "${LOG}" >> "${log_file}"
echo "Core/Pangenome ratio: $RATIO%" >> "${log_file}"
echo "Softcore/Pangenome ratio: $RATIOs%" >> "${log_file}"
echo "######################################################################################" >> "${log_file}"
echo "ATTENTION!" >> "${log_file}"
echo "If Core/Pangenome ratio < 6% is recommended to check AAI and POCP tables and remove" >> "${log_file}"
echo "the reference genomes with the lowest similarities." >> "${log_file}"
echo "######################################################################################" >> "${log_file}"


cd ../../${DIR}_homologues/only_OMCL
cp ../../gh_* .
LIST=pangenome_matrix_t0__${COMP}_list.txt

if [[ "$COMP" == *"$CLOUD"* ]] || [[ "$COMP" == *"$SHELL"* ]] || [[ "$COMP" == *"$SOFT"* ]]; then
        grep "bin" $LIST > "${TMP1}"
        python3 gh_get_accession.py "${TMP1}"
        EGG="${LIST/_list.txt/_EggNOG.tsv}"
        GO="${LIST/_list.txt/_GO.tsv}"
        NR="${LIST/_list.txt/_NR.tsv}"
        LOCUS="${LIST/_list.txt/_locus_id.tsv}"
        REFS="${LIST/_list.txt/_references_accession.tsv}"
        grep -f "TMP_ID.tab" "${EGG_FILE}" > "${EGG}"
        grep -f "TMP_ID.tab" "${GO_FILE}" > "${GO}"
        grep -f "TMP_ID.tab" "${NR_FILE}" > "${NR}"
        mv TMP_ID.tab "${LOCUS}"
        python3 gh_merge.py "${NR}" "${EGG}" "${BINS}" "${GO}"
        grep -v "bin" $LIST > "${TMP2}"
        python3 gh_get_accession.py "${TMP2}"
        mv TMP_ID.tab "${REFS}"
        rm tmp.*
else
        python3 gh_get_accession.py "${LIST}"
        EGG="${LIST/_list.txt/_EggNOG.tsv}"
        GO="${LIST/_list.txt/_GO.tsv}"
        NR="${LIST/_list.txt/_NR.tsv}"
        LOCUS="${LIST/_list.txt/_locus_id.tsv}"
        grep -f "TMP_ID.tab" "${EGG_FILE}" > "${EGG}"
        grep -f "TMP_ID.tab" "${GO_FILE}" > "${GO}"
        grep -f "TMP_ID.tab" "${NR_FILE}" > "${NR}"
        mv TMP_ID.tab "${LOCUS}"
        python3 gh_merge.py "${NR}" "${EGG}" "${BINS}" "${GO}"
fi

./gh_get_core_set.sh "gh_min_core_gene_set.txt" "merge_all.tsv"
mv min_core_found.txt ${PREFIX}_${COMP}_min_gene_set_found.txt
mv min_core_missing.txt ${PREFIX}_${COMP}_min_gene_set_missing.txt
mv *min_gene_set* ../../${PREFIX}_GH_output_files/only_OMCL
mv merge_all.xlsx ${PREFIX}_${COMP}_merge_all.xlsx
mv merge_all.tsv ${PREFIX}_${COMP}_merge_all.tsv
mv mapping_by_product.xlsx ${PREFIX}_${COMP}_mapping_by_product.xlsx
mv mapping_by_product.tsv ${PREFIX}_${COMP}_mapping_by_product.tsv
mv mapping_by_COG.xlsx ${PREFIX}_${COMP}_mapping_by_COG.xlsx
mv mapping_by_COG.tsv ${PREFIX}_${COMP}_mapping_by_COG.tsv
mv COG_by_locus.xlsx ${PREFIX}_${COMP}_COG_by_locus.xlsx
mv COG_by_locus.tsv ${PREFIX}_${COMP}_COG_by_locus.tsv
mv KEGG_by_locus.xlsx ${PREFIX}_${COMP}_KEGG_by_locus.xlsx
mv KEGG_by_locus.tsv ${PREFIX}_${COMP}_KEGG_by_locus.tsv
mv mapping_by_KEGG.xlsx ${PREFIX}_${COMP}_mapping_by_KEGG.xlsx
mv mapping_by_KEGG.tsv ${PREFIX}_${COMP}_mapping_by_KEGG.tsv
mv GO_by_locus.xlsx ${PREFIX}_${COMP}_GO_by_locus.xlsx
mv GO_by_locus.tsv ${PREFIX}_${COMP}_GO_by_locus.tsv
mv mapping_by_GO.xlsx ${PREFIX}_${COMP}_mapping_by_GO.xlsx
mv mapping_by_GO.tsv ${PREFIX}_${COMP}_mapping_by_GO.tsv
mv *.tsv *.xlsx ../../${PREFIX}_GH_output_files/only_OMCL/${COMP}_results
rm gh_*
cd ../../${PREFIX}_GH_output_files/only_OMCL

log_file2="GH_pipeline_results_metrics_only_OMCL.txt"
LOG2="${PREFIX}_GH_pipe_only_OMCL.log"
CORE='pangenome_matrix_t0__core_list.txt'
SOFTCORE='pangenome_matrix_t0__softcore_list.txt'
SHELL='pangenome_matrix_t0__shell_list.txt'
CLOUD='pangenome_matrix_t0__cloud_list.txt'

CORE_c=$(wc -l < $CORE)
SOFTCORE_c=$(wc -l < $SOFTCORE)
SOFT_bin=$(grep -c "bin" $SOFTCORE)
SOFT_bin_p=$(awk -v t1="$SOFT_bin" -v t2="$SOFTCORE_c" 'BEGIN{print t1/t2 * 100}')
SOFT_ref=$(grep -c -v "bin" $SOFTCORE)
SOFT_ref_p=$(awk -v t1="$SOFT_ref" -v t2="$SOFTCORE_c" 'BEGIN{print t1/t2 * 100}')
SHELL_c=$(wc -l < $SHELL)
SHELL_bin=$(grep -c "bin" $SHELL)
SHELL_bin_p=$(awk -v t1="$SHELL_bin" -v t2="$SHELL_c" 'BEGIN{print t1/t2 * 100}')
SHELL_ref=$(grep -c -v "bin" $SHELL)
SHELL_ref_p=$(awk -v t1="$SHELL_ref" -v t2="$SHELL_c" 'BEGIN{print t1/t2 * 100}')
CLOUD_c=$(wc -l < $CLOUD)
CLOUD_bin=$(grep -c "bin" $CLOUD)
CLOUD_bin_p=$(awk -v t1="$CLOUD_bin" -v t2="$CLOUD_c" 'BEGIN{print t1/t2 * 100}')
CLOUD_ref=$(grep -c -v "bin" $CLOUD)
CLOUD_ref_p=$(awk -v t1="$CLOUD_ref" -v t2="$CLOUD_c" 'BEGIN{print t1/t2 * 100}')
PAN_c=$(($SOFTCORE_c + $SHELL_c + $CLOUD_c))
RATIO=$(awk -v t1="$CORE_c" -v t2="$PAN_c" 'BEGIN{print t1/t2 * 100}')
RATIOs=$(awk -v t1="$SOFTCORE_c" -v t2="$PAN_c" 'BEGIN{print t1/t2 * 100}')


echo "####GET_Homologues apenas algoritmo 'OMCL':###\n" > "${log_file2}"
grep "# /get_homologues/get_homologues.pl" "${LOG2}" >> "${log_file2}"
echo " " >> "${log_file2}"
grep -A 2 "# number_of_clusters =" "${LOG2}" >> "${log_file2}"
echo " " >> "${log_file2}"
grep "# pangenome_phylip file =" "${LOG2}" >> "${log_file2}"
grep "# pangenome_FASTA file =" "${LOG2}" >> "${log_file2}"
echo " " >> "${log_file2}"
grep "# matrix contains" "${LOG2}" >> "${log_file2}"
grep "# cloud size:" "${LOG2}" >> "${log_file2}"
echo "Local bin clusters compose $CLOUD_bin_p% from Cloud compartment" >> "${log_file2}"
echo "References clusters compose $CLOUD_ref_p% from Cloud compartment" >> "${log_file2}"
echo " " >> "${log_file2}"
grep "# shell size:" "${LOG2}" >> "${log_file2}"
echo "Local bin clusters compose $SHELL_bin_p% from Shell compartment" >> "${log_file2}"
echo "References clusters compose $SHELL_ref_p% from Shell compartment" >> "${log_file2}"
echo " " >> "${log_file2}"
grep "# soft core size:" "${LOG2}" >> "${log_file2}"
echo "Local bin clusters compose $SOFT_bin_p% from Sooftcore compartment" >> "${log_file2}"
echo "References clusters compose $SOFT_ref_p% from Softcore compartment" >> "${log_file2}"
echo " " >> "${log_file2}"
grep "# core size:" "${LOG2}" >> "${log_file2}"
echo "Core/Pangenome ratio: $RATIO%" >> "${log_file2}"
echo "Softcore/Pangenome ratio: $RATIOs%" >> "${log_file2}"
echo "######################################################################################" >> "${log_file2}"
echo "ATTENTION!" >> "${log_file2}"
echo "If Core/Pangenome ratio < 6% is recommended to check AAI and POCP tables and remove" >> "${log_file2}"
echo "the reference genomes with the lowest similarities." >> "${log_file2}"
echo "######################################################################################" >> "${log_file2}"

cd ../..
rm tmp.*
