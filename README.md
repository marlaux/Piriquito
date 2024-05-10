# Piriquito
Pipeline automatizada de análise de pangenoma de MAGs e metagenomas processados, montados e anotados pelo workflow Sabiá, LNCC

WORKFLOW

./GH_pipeline.sh -h
###############################################
Run GET_HOMOLOGUES pipeline.
Se estiver instalado via Docker, ativar a imagem primeiro.

Usage: ./GH_pipeline.sh [-d directory] [-r reference genome] [-p prefix]
-d Diretório contendo os genomas no formato .faa
-r Genoma de referência. Escolher a nossa bin, uma vez que a anotação
depende do banco de dados do Sabiá.
-p Prefixo para identificar os outputs. Ex: 'Pseudomonas_ETDI_bin8'
-h print this help
Ex: ./GH_pipeline.sh -d desulfo_refs3 -r ETDI_bin60.faa -p Desulfo_ETDI_bin60
###############################################

./GH_parse_annotation.sh -h
###############################################
PARSE GET_HOMOLOGUES RESULTS TO SABIA ANNOTATIONS
copiar todo o conteudo da pasta 'GH_scripts' antes de rodar.

Usage: ./GH_parse_annotation.sh [-f cluster list] [-p prefix]
-c Compartimento do pangenoma: 'core', 'softcore', 'shell' ou 'cloud'
-d Diretório contendo os genomas no formato .faa
-p Prefixo para identificar os outputs. Ex: 'Pseudomonas_ETDI_bin8'
-h print this help
Ex: ./GH_parse_annotation.sh -c core -d desulfo_refs3 -p Desulfo_ETDI_bin60
###############################################

DESCRIÇÃO DO WORKFLOW:
1. copiar a pasta GH_scripts para o seu work directory
a pasta contém os seguintes arquivos/scripts:
GH_pipeline.sh --> roda a pipeline do GET_HOMOLOGUES. Instruções: ./GH_pipeline.sh -h
GH_parse_annotation.sh --> faz o parseamento dos compartimentos do pangenoma e a anotação funcional. Precisa dos scripts gh_get_accession.py e gh_merge.py, e dos arquivos
gh_all_mags_GO.tab, gh_Kegg_levels.tab, gh_all_mags_EggNOG.tab, gh_all_mags_bin_locus.tab e gh_all_mags_NR.tab (arquivos com a anotação completa de todo o workflow do Sabiá desse dataset, para serem usados com qualquer bin).
Instruções: ./GH_parse_annotation.sh -h
O script GH_parse_annotation.sh também mapeia o conjunto mínimo de genes core utilizando os arquivos gh_get_core_set.sh, gh_min_core_gene_set.txt

Mags individuais
Os arquivos Mags_parse_annotation.sh e Mags_anno_merge.py rodam o parseamento para as MAGs individuais, utilizando os mesmos arquivos de anotação listados acima.
Para rodar: observar o nome das bins dentro do arquivo gh_all_mags_bin_locus.tab
então
Mags_parse_annotation.sh ETDI_bin60
Gerando o diretório de outputs ETDI_bin60_anno_individual

O script rename.py serve para renomear as sequências de proteínas dos genomas de referência baixados, de acordo com o próximo item.


2. Para fazer o download automático dos arquivos de proteínas dos genomas de referência, instalar o pacote 'Datasets" do NCBI:
https://www.ncbi.nlm.nih.gov/datasets
datasets download genome accession --inputfile my_refs.txt --annotated --include protein
unzip ncbi_dataset.zip
cd /ncbi_dataset
cp ../GH_scripts/rename.py .
python3 rename.py /data
cp data/*.faa .
cd ..
mv ncbi_dataset my_refs

3. criar o diretório de análise, que deve conter as sequências de proteínas dos genomas de referência baixados, mais a(s) bin(s). 
mkdir Desulfobacterales_ETDI_bin60
cp my_refs/*.faa Desulfobacterales_ETDI_bin60
cp annotated_bins/XX_bin.faa Desulfobacterales_ETDI_bin60
As sequências de proteínas anotadas pelo sabiá se encontram na pasta /disk10/vinicius/Metapetro/files_faa
Atenção: usar pelo menos 5 taxa para a análise, ou seja, 1 bin + 4 referências, 2 bins + 3 referências, pois é necessário pelo menos 5 taxa para a pipeline gerar os compartimentos do pangenoma.
copiar o conteúdo da pasta GH_scripts para o diretório onde está a pasta com os genomas a serem analisados.
ls
/Desulfobacterales_ETDI_bin60
GH_parse_annotation.sh
GH_pipeline.sh
gh_all_mags_bin_locus.tab
gh_all_mags_EggNOG.tab
gh_all_mags_GO.tab
gh_all_mags_NR.tab
gh_get_accession.py
gh_get_core_set.sh
gh_Kegg_levels.tab
gh_merge.py
gh_min_core_gene_set.txt
Mags_anno_merge.py
Mags_parse_annotation.sh
rename.py

4. Instalar o GET_HOMOLOHUES na sua máquina:
via docker: https://hub.docker.com/r/csicunam/get_homologues
ativar o docker:
sudo service docker start
definir a pasta de trabalho para fazer a sincronização de arquivos entre o docker e o computador, no meu caso é a pasta "/home/marlaux/MAGs_METAPETRO", só substituir pela sua.
docker run --rm -v /home/marlaux/MAGs_METAPETRO:/home/you/MAGs_METAPETRO -it csicunam/get_homologues:latest /bin/bash

5. Rodar a pipeline --> ATENÇÃO!!! Usar o mesmo prefixo do início ao fim!!!
./GH_pipeline.sh -d desulfo_refs3 -r ETDI_bin60.faa -p Desulfo_ETDI_bin60
Quando terminar serão criados os seguintes diretórios outputs da pipeline do GET_HOMOLOGUES
/desulfo_refs3_homologues (output default do GH)
	Nesse diretório estão os arquivos blast da análise de ortologia, os subdiretórios da clusterização via COG e OMCL e as matrizes do pangenoma e as
	imagens das estimativas do core e do pangenoma (compartments/occupancy).
/desulfo_refs3_homologues/intersection (output default do GH)
	Nesse diretório estão os clusteres que foram identificados por ambos COG e OMCL e os outputs da análise de composição do pangenoma (core, softcore, shell e cloud).

/Desulfo_ETDI_bin60_GH_output_files (diretório de outputs customizado, descrição abaixo)

6. Rodar o parseamento e anotação dos resultados:
no work directory da análise:
ls
/desulfo_refs3	/desulfo_refs3_homologues	/Desulfo_ETDI_bin60_GH_output_files
./GH_parse_annotation.sh -h
./GH_parse_annotation.sh -c core -d desulfo_refs3 -p Desulfo_ETDI_bin60
./GH_parse_annotation.sh -c softcore -d desulfo_refs3 -p Desulfo_ETDI_bin60
./GH_parse_annotation.sh -c shell -d desulfo_refs3 -p Desulfo_ETDI_bin60
./GH_parse_annotation.sh -c cloud -d desulfo_refs3 -p Desulfo_ETDI_bin60

Dentro do diretório de outputs customizado 'Desulfo_ETDI_bin60_GH_output_files' serão criados os seguintes outputs: (o sufixo de alguns é o genoma de referência definido -r )
Desulfo_ETDI_bin60_GH_pipe.log --> log completo da pipeline do GH
core_genome_algCOG.tab_core_both.png --> core genome estimates according to Tettelin in 2005 (PubMed=16172379) e Willenbrock and collaborators (PubMed=18088402)
ETDIbin60_f0_0taxa_algCOG_e0_Avg_identity.tab --> AAI identity matrix
ETDIbin60_f0_0taxa_algCOG_e0_Avg_identity_BioNJ.ph --> dendrogram from squared tab-separated similarity/identity AAI matrices drive a neighbor joining tree.
ETDIbin60_f0_0taxa_algCOG_e0_Avg_identity_heatmap.svg
ETDIbin60_f0_0taxa_algCOG_e0_POCP.tab --> percentage of conserved proteins (blastp)
ETDIbin60_f0_0taxa_algOMCL_e0_Avg_identity.tab
ETDIbin60_f0_0taxa_algOMCL_e0_Avg_identity_BioNJ.ph
ETDIbin60_f0_0taxa_algOMCL_e0_Avg_identity_heatmap.svg
ETDIbin60_f0_0taxa_algOMCL_e0_POCP.tab
GH_pipeline_results_metrics.txt --> log com as métricas da análise de composição do pangenoma,
	incluindo a razão core/pangenoma necessária para definir se o número e quais referências utilizadas foi adequado (+- core/pan >6% e <20%)
/cloud_results --> diretório com a anotação dos outputs do compartimento cloud (clusteres de genes strain-specific PubMed=25483351)
core_genome_algCOG.tab_core_both.png
core_genome_algCOG.tab_core_both.svg
core_genome_algOMCL.tab_core_both.png
core_genome_algOMCL.tab_core_both.svg
/core_results --> diretório com a anotação dos outputs do compartimento core (presentes em todos os taxa analisados)
input_order.txt
pan_genome_algCOG.tab_pan.png
pan_genome_algCOG.tab_pan.svg
pan_genome_algOMCL.tab_pan.png
pan_genome_algOMCL.tab_pan.svg
pangenome_matrix_t0.fasta --> pangenome_FASTA file
	arquivo usado para reconstrução filogenética (compute bootstrap and aLRT support) no IQ_TREE (http://iqtree.cibiv.univie.ac.at/)
pangenome_matrix_t0.phylip --> pangenome_phylip file
pangenome_matrix_t0.phylip.log --> pangenome_phylip log
pangenome_matrix_t0.phylip.ph --> pangenome_phylip tree
	one or more alternative parsimony trees that capture the phylogeny implied in this matrix, open with FigTREE (Newick format)
pangenome_matrix_t0__cloud_list.txt --> clusteres de genes strain-specific (PubMed=25483351)	
pangenome_matrix_t0__core_list.txt --> clusteres de genes compartilhados por todos os taxa.
pangenome_matrix_t0__shell.pdf
pangenome_matrix_t0__shell.png
pangenome_matrix_t0__shell.svg
pangenome_matrix_t0__shell_circle.pdf
pangenome_matrix_t0__shell_circle.png --> circle plot ilustrando as proporções entre os compartimentos do pangenoma.
pangenome_matrix_t0__shell_circle.svg
pangenome_matrix_t0__shell_estimates.tab
pangenome_matrix_t0__shell_input.txt
pangenome_matrix_t0__shell_list.txt --> clusteres de genes compartilhados por 75% dos taxa analisados.
pangenome_matrix_t0__softcore_list.txt --> clusteres de genes compartilhados por 95% dos taxa analisados.
	 Alguns autores preferem usar o softcore para análises de populações.
/shell_results --> diretório com a anotação dos outputs do compartimento shell.
/softcore_results --> diretório com a anotação dos outputs do compartimento softcore.
venn_t0.svg --> venn mostrando a intersecção entre a clusterização via COG e OMCL.

Diretórios de cada compartimento:
intersect/core_results
only_OMCL/core_results
		/cloud_results
		/shell_results
		/softcore_results
Desulfo_refs2_core_COG_by_locus.tsv --> categoria COG por locus_id das bins.
Desulfo_refs2_core_COG_by_locus.xlsx
Desulfo_refs2_core_GO_by_locus.tsv --> GO id por locus_id das bins (identificador das proteínas anotadas pelo Sabiá)
Desulfo_refs2_core_GO_by_locus.xlsx
Desulfo_refs2_core_KEGG_by_locus.tsv --> Knumber por locus_id das bins.
Desulfo_refs2_core_KEGG_by_locus.xlsx
Desulfo_refs2_core_mapping_by_COG.tsv --> contagem de locus_id por categoria COG (Ex: top categorias, pizza plot...)
Desulfo_refs2_core_mapping_by_COG.xlsx
Desulfo_refs2_core_mapping_by_GO.tsv --> contagem de locus_id por GO id (Ex: top funções, pizza plot...)
Desulfo_refs2_core_mapping_by_GO.xlsx
Desulfo_refs2_core_mapping_by_KEGG.tsv --> contagem de locus_id por Knumber
Desulfo_refs2_core_mapping_by_KEGG.xlsx
Desulfo_refs2_core_mapping_by_product.tsv --> contagem de locus_id por NCBI gene product
Desulfo_refs2_core_mapping_by_product.xlsx
Desulfo_refs2_core_merge_all.tsv --> Tabela mesclada do EggNOG, NR e GO, com colunas selecionadas.
Desulfo_refs2_core_merge_all.xlsx
pangenome_matrix_t0__core_EggNOG.tsv --> Tabela completa com a a anotação do EggNOG.
pangenome_matrix_t0__core_GO.tsv --> Tabela completa com a a anotação do GO.
pangenome_matrix_t0__core_NR.tsv --> Tabela completa com a a anotação do NCBI-NR.
pangenome_matrix_t0__core_locus_id.tsv --> lista de locus_id da bin

Nos compartimentos não-core tem o output adicional:
	Desulfo_ETDI_bin60_matrix_t0__shell_references_accession_list --> mapear a anotação das referências no Uniprot:

https://www.uniprot.org/id-mapping
load from a text file: Desulfo_ETDI_bin60_matrix_t0__cloud_references_accession_list.txt
From database: Sequence databases --> EMBL/GenBank/DDBJ CDS
map -> if completed: select columns and download in tsv format.
PS: Nem todos os accesions são mapeados, devido à presença ou ausência de anotação do respectivo genoma no banco de dados, mas a maioria é mapeada.

Descrição completa dos outputs:
http://eead-csic-compbio.github.io/get_homologues/manual/
https://github.com/eead-csic-compbio/get_homologues
https://doi.org/10.1016/j.mib.2014.11.016
https://doi.org/10.1016/j.gde.2005.09.006
https://doi.org/10.1128/AEM.02411-13
https://link.springer.com/protocol/10.1007/978-1-4939-1720-4_14

WORKFLOW ABERTO:
get_homologues.pl -d desulfo_refs1 -A -P -t 0 -M -c -r ETDI_bin60.faa -n 6 --> gera o diretório ETDIbin60_f0_0taxa_algCOG_e0_ com os clusteres do algoritmo COG
get_homologues.pl -d desulfo_refs1 -A -P -t 0 -G -c -r ETDI_bin60.faa -n 6 --> gera o diretório ETDIbin60_f0_0taxa_algOMCL_e0_ com os clusteres do algoritmo OMCL
cd desulfo_refs1_homologues
plot_matrix_heatmap.sh -N -i *_algCOG_e0_Avg_identity.tab
plot_matrix_heatmap.sh -N -i *_algOMCL_e0_Avg_identity.tab
plot_matrix_heatmap.sh -d 1 -i *_algCOG_e0_Avg_identity.tab
plot_matrix_heatmap.sh -d 1 -i *_algOMCL_e0_Avg_identity.tab
plot_pancore_matrix.pl -i core_genome_algCOG.tab -f core_both
plot_pancore_matrix.pl -i core_genome_algOMCL.tab -f core_both
plot_pancore_matrix.pl -i pan_genome_algCOG.tab -f pan
plot_pancore_matrix.pl -i pan_genome_algOMCL.tab -f pan
compare_clusters.pl -o intersection -m -T -d ./ETDIbin60_f0_0taxa_algCOG_e0_,./ETDIbin60_f0_0taxa_algOMCL_e0_ --> intersecção COG/OMCL + pangenome matrix + Neighbour joining tree
cd intersection/
parse_pangenome_matrix.pl -m pangenome_matrix_t0.tab -s --> calcula os compartimentos do pangenoma
	Nesse diretório que o script GH_parse_annotation.sh roda, mas ele é disparado no work directory, onde estão todos os scripts.
	./GH_parse_annotation.sh -c pangenome_matrix_t0__core_list.txt -d Desulfo_bin60 -p Desulfo_ETDI_bin60
	./GH_parse_annotation.sh -c pangenome_matrix_t0__softcore_list.txt -d Desulfo_bin60 -p Desulfo_ETDI_bin60
	./GH_parse_annotation.sh -c pangenome_matrix_t0__shell_list.txt -d Desulfo_bin60 -p Desulfo_ETDI_bin60
	./GH_parse_annotation.sh -c pangenome_matrix_t0__cloud_list.txt -d Desulfo_bin60 -p Desulfo_ETDI_bin60

compare_clusters.pl -o only_OMCL -m -T -d ./ETDIbin60_f0_0taxa_algOMCL_e0_ --> algoritmo OMCL + pangenome matrix + Neighbour joining tree
cd only_OMCL/
parse_pangenome_matrix.pl -m pangenome_matrix_t0.tab -s
