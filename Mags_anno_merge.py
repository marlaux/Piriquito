import sys
import pandas as pd
from itertools import chain
import numpy as np

file1 = sys.argv[1]
file2 = sys.argv[2]
file3 = sys.argv[3]

kegg_levels = pd.read_csv('gh_Kegg_levels.tab', sep="\t")
kegg_levels.columns = ['level1', 'level2', 'level3', 'KEGG_ko', 'ko_description']
GOs_locus = pd.read_csv(file3, keep_default_na=False, na_values=[""], sep="\t", low_memory=False)
GOs_locus.columns = ['index','locus_id','GOs','GO_function','GO_type']
NR_tab = pd.read_csv(file1, keep_default_na=False, na_values=[""], sep="\t", low_memory=False)
NR_tab.columns = ['locus_id','score','expect','coverage_query','coverage_subject','accession_reference','identities','positives','product']
Egg_tab = pd.read_csv(file2, keep_default_na=False, na_values=[""], sep="\t", low_memory=False)
Egg_tab.columns = ['locus_id','seed_ortholog','evalue','score','eggNOG_OGs','max_annot_lvl','COG_category','Description','Preferred_name','GOs','EC','KEGG_ko','KEGG_Pathway','KEGG_Module','KEGG_Reaction','KEGG_rclass','BRITE','KEGG_TC','CAZy','BiGG_Reaction','PFAMs']

merge = pd.merge(NR_tab[["locus_id","accession_reference","product","identities","coverage_query","coverage_subject"]], Egg_tab[["COG_category","Description","Preferred_name","GOs","KEGG_ko","KEGG_Pathway","CAZy","locus_id"]], on='locus_id', how='outer').drop_duplicates()
filename1 = 'merge_all.xlsx'
merge.to_excel(filename1)
filename1b = 'merge_all.tsv'
merge.to_csv(filename1b, sep="\t")

prod_ko = merge[['product', 'Preferred_name', 'COG_category', 'KEGG_ko', 'locus_id']].copy()
prod_ko_gr = prod_ko.assign(count=1).groupby(prod_ko['product'].str.lower()).agg({'count':'sum', 'Preferred_name': lambda x: ';'.join(map(str, x)),
                                             'COG_category': lambda x: ';'.join(map(str, x)),
                                             'KEGG_ko': lambda x: ';'.join(map(str, x)),
                                             'locus_id': lambda x: ';'.join(map(str, x))}).reset_index()
filename2 = 'mapping_by_product.xlsx'
prod_ko_gr.to_excel(filename2)
filename2b = 'mapping_by_product.tsv'
prod_ko_gr.to_csv(filename2b, sep="\t")


cog_gr = prod_ko.assign(count=1).groupby(prod_ko['COG_category']).agg({'count':'sum', 'Preferred_name': lambda x: ';'.join(map(str, x)),
                                             'product': lambda x: ';'.join(map(str, x)),
                                             'KEGG_ko': lambda x: ';'.join(map(str, x)),
                                             'locus_id': lambda x: ';'.join(map(str, x))}).reset_index()
filename3 = 'mapping_by_COG.xlsx'
cog_gr.to_excel(filename3)
filename3b = 'mapping_by_COG.tsv'
cog_gr.to_csv(filename3b, sep="\t")

cog_kegg_prod_locus = pd.merge(merge[['locus_id','COG_category', 'product','KEGG_ko']],kegg_levels[['KEGG_ko','level1', 'level2', 'level3', 'ko_description']], on='KEGG_ko', how='left').drop_duplicates()
filename3b = 'COG_by_locus.xlsx'
cog_kegg_prod_locus.to_excel(filename3b)
filename3c = 'COG_by_locus.tsv'
cog_kegg_prod_locus.to_csv(filename3c, sep="\t")

KEGG = Egg_tab[['locus_id','KEGG_ko']]
KEGG = KEGG[(KEGG.KEGG_ko != '-') & (KEGG.KEGG_ko.notnull())]
Knumbers = KEGG.set_index(['locus_id']).apply(lambda x: x.str.split(',').explode()).reset_index()
ko_locus_lvl = pd.merge(Knumbers[['locus_id','KEGG_ko']],kegg_levels[['KEGG_ko','level1', 'level2', 'level3', 'ko_description']], on='KEGG_ko', how='left').drop_duplicates()

ko_cog_prod_locus = pd.merge(ko_locus_lvl[['locus_id','KEGG_ko','level1', 'level2', 'level3', 'ko_description']],merge[['locus_id','COG_category','product']], on='locus_id', how='left').drop_duplicates()
filename5 = 'KEGG_by_locus.xlsx'
ko_cog_prod_locus.to_excel(filename5)
filename5b = 'KEGG_by_locus.tsv'
ko_cog_prod_locus.to_csv(filename5b, sep="\t")

kegg = ko_cog_prod_locus[['KEGG_ko', 'COG_category', 'product', 'locus_id']].drop_duplicates().copy()
kegg_gr = kegg.assign(count=1).groupby(kegg['KEGG_ko']).agg({'count':'sum', 'COG_category': lambda x: ';'.join(map(str, x)),
                                                'product': lambda x: ';'.join(map(str, x)),
                                                'locus_id': lambda x: ';'.join(map(str, x))}).reset_index()
kegg_gr_lvl = pd.merge(kegg_gr[['KEGG_ko','count','COG_category','product','locus_id']],kegg_levels[['KEGG_ko','level1', 'level2', 'level3', 'ko_description']], on='KEGG_ko', how='left').drop_duplicates()
filename6 = 'mapping_by_KEGG.xlsx'
kegg_gr_lvl.to_excel(filename6)
filename6b = 'mapping_by_KEGG.tsv'
kegg_gr_lvl.to_csv(filename6b, sep="\t")

go_cog_kegg_prod_locus = pd.merge(merge[['locus_id','product','COG_category','KEGG_ko']],GOs_locus[['locus_id','GOs','GO_function','GO_type']], on='locus_id', how='right').drop_duplicates()
filename7 = 'GO_by_locus.xlsx'
go_cog_kegg_prod_locus.to_excel(filename7)
filename7b = 'GO_by_locus.tsv'
go_cog_kegg_prod_locus.to_csv(filename7b, sep="\t")

go = go_cog_kegg_prod_locus[['GOs', 'COG_category', 'KEGG_ko', 'product', 'locus_id']].drop_duplicates().copy()
GO_gr = go.assign(count=1).groupby(go['GOs']).agg({'count':'sum', 'COG_category': lambda x: ';'.join(map(str, x)),
                                                'KEGG_ko': lambda x: ';'.join(map(str, x)),
                                                'product': lambda x: ';'.join(map(str, x)),
                                                'locus_id': lambda x: ';'.join(map(str, x))}).reset_index()
GO_gr_desc = pd.merge(GO_gr[['GOs','count','COG_category','KEGG_ko','product','locus_id']],GOs_locus[['GOs','GO_function','GO_type']], on='GOs', how='left').drop_duplicates()
filename8 = 'mapping_by_GO.xlsx'
GO_gr_desc.to_excel(filename8)
filename8b = 'mapping_by_GO.tsv'
GO_gr_desc.to_csv(filename8b, sep="\t")





