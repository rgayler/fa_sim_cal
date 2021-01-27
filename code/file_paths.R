# Paths for file locations
# I suspect most of these would be unneeded if I used the targets package to cache objects

f_entity_raw_tsv <- here::here("data", "VR_20051125.txt.xz") # entity input file
f_entity_raw_fst <- here::here("output", "ent_raw.fst") # subset of entities and columns to use
f_entity_cln_fst <- here::here("output", "ent_cln.fst") # cleaned subset of entities and columns to use
f_entity_blk_fst <- here::here("output", "ent_blk.fst") # blocking variables for cleaned subset of entities to use
f_blk_char.fst   <- here::here("output", "blk_char.fst") # characterisation of each block for each blocking variable
