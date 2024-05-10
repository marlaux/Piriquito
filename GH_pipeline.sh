#/bin/bash


DIR=''
REF=''
PREFIX=''

usage () {
	echo "######################################################################"
	echo "Run GET_HOMOLOGUES pipeline."
	echo "Se estiver instalado via Docker, ativar a imagem primeiro."
	echo " "
	echo "Usage: ${0} [-d directory] [-r reference genome] [-p prefix]"
	echo "-d Diretório contendo os genomas no formato .faa"
	echo "-r Genoma de referência. Escolher a nossa bin, uma vez que a anotação"
	echo "depende do banco de dados do Sabiá."
	echo "-p Prefixo para identificar os outputs. Ex: 'Pseudomonas_ETDI_bin8'"
	echo "-h print this help"
	echo " "
	echo "######################################################################"
		1>&2; exit 1;
}

while getopts "d:r:p:h" option; do
	case $option in
		d) DIR="${OPTARG}"
			;;
		r) REF="${OPTARG}"
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

if [ -z "${DIR}" ] || [ -z "${PREFIX}" ] || [ -z "${REF}" ]; then
	echo "Argumento faltando."
	echo "./GH_pipeline.sh -h" >&2
	exit 1
fi


mkdir ${PREFIX}_GH_output_files
mkdir ${PREFIX}_GH_output_files/intersection
mkdir ${PREFIX}_GH_output_files/only_OMCL

get_homologues.pl -d "${DIR}" -A -P -t 0 -M -c -z -r "${REF}" -n 6 &>"${PREFIX}_GH_pipe.log"
get_homologues.pl -d "${DIR}" -A -P -t 0 -G -c -z -r "${REF}" -n 6 &>>"${PREFIX}_GH_pipe.log"
mv "${PREFIX}_GH_pipe.log" ${DIR}_homologues
cd ${DIR}_homologues

plot_matrix_heatmap.sh -N -i *_algCOG_e0_Avg_identity.tab &>>"${PREFIX}_GH_pipe.log"
plot_matrix_heatmap.sh -N -i *_algOMCL_e0_Avg_identity.tab &>>"${PREFIX}_GH_pipe.log"
plot_matrix_heatmap.sh -d 1 -i *_algCOG_e0_Avg_identity.tab &>>"${PREFIX}_GH_pipe.log"
plot_matrix_heatmap.sh -d 1 -i *_algOMCL_e0_Avg_identity.tab &>>"${PREFIX}_GH_pipe.log"
plot_pancore_matrix.pl -i core_genome_algCOG.tab -f core_both &>>"${PREFIX}_GH_pipe.log"
plot_pancore_matrix.pl -i core_genome_algOMCL.tab -f core_both &>>"${PREFIX}_GH_pipe.log"
plot_pancore_matrix.pl -i pan_genome_algCOG.tab -f pan &>>"${PREFIX}_GH_pipe.log"
plot_pancore_matrix.pl -i pan_genome_algOMCL.tab -f pan &>>"${PREFIX}_GH_pipe.log"
cp *.png *.svg *Avg_identity.tab *POCP.tab input_order.txt ../${PREFIX}_GH_output_files/

COG=$(find -name "*COG*" -type d)
OMCL=$(find -name "*OMCL*" -type d)

cp "${PREFIX}_GH_pipe.log" "${PREFIX}_GH_pipe_only_OMCL.log"
compare_clusters.pl -o intersection -m -T -d $COG,$OMCL &>>"${PREFIX}_GH_pipe.log"
mv "${PREFIX}_GH_pipe.log" intersection
compare_clusters.pl -o only_OMCL -m -T -d $OMCL &>>"${PREFIX}_GH_pipe_only_OMCL.log"
mv "${PREFIX}_GH_pipe_only_OMCL.log" only_OMCL

cd intersection
parse_pangenome_matrix.pl -m pangenome_matrix_t0.tab -s &>>"${PREFIX}_GH_pipe.log"
cp *_list.txt *.png *.svg pangenome_matrix_t0.fasta pangenome_matrix_t0.phyli* ../../${PREFIX}_GH_output_files/intersection
mv "${PREFIX}_GH_pipe.log" ../../${PREFIX}_GH_output_files/intersection

cd ../only_OMCL
parse_pangenome_matrix.pl -m pangenome_matrix_t0.tab -s &>>"${PREFIX}_GH_pipe_only_OMCL.log"
cp *_list.txt *.png *.svg pangenome_matrix_t0.fasta pangenome_matrix_t0.phyli* ../../${PREFIX}_GH_output_files/only_OMCL
mv "${PREFIX}_GH_pipe_only_OMCL.log" ../../${PREFIX}_GH_output_files/only_OMCL
cd ../..

