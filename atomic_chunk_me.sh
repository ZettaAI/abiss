#!/bin/bash
INIT_PATH="$(dirname "$0")"
. ${INIT_PATH}/init.sh

output=`basename $1 .json`
echo $output

try mkdir remap
for d in $META; do
    echo "create $d"
    just_in_case rm -rf $d
    try mkdir $d
done

try python3 $SCRIPT_PATH/generate_siblings.py $1|tee filelist.txt
try cat filelist.txt|$PARALLEL_CMD "$DOWNLOAD_CMD $FILE_PATH/remap/chunkmap_{}.data.${COMPRESSED_EXT} - | $COMPRESS_CMD -d -o chunkmap_{}.data"
cp chunkmap_${output}.data localmap.data

try python3 $SCRIPT_PATH/merge_chunkmap.py $1

try python3 $SCRIPT_PATH/cut_chunk_agg.py $1
try $BIN_PATH/acme param.txt $output
try cp edges_"$output".data input_rg.data

for i in {0..5}
do
    try cat boundary_"$i"_"$output".data >> frozen.data
done

try touch ns.data

try $BIN_PATH/agg $AGG_THRESHOLD input_rg.data frozen.data ns.data

try cat remap.data >> localmap.data
try $BIN_PATH/split_remap $output
try $BIN_PATH/assort $output $META

try mv meta.data meta_"$output".data
try mv residual_rg.data residual_rg_"$output".data
try mv final_rg.data final_rg_"$output".data
try mv mst.data mst_"$output".data
try mv remap.data remap_"$output".data
try mv done_segments.data info_"$output".data
try mv ongoing_segments.data ongoing_supervoxel_counts_"$output".data
try mv rejected_edges.log rejected_edges_"$output".log

try $COMPRESS_CMD mst_"${output}".data
try $COMPRESS_CMD remap_"${output}".data
try $COMPRESS_CMD edges_"${output}".data
try $COMPRESS_CMD final_rg_"${output}".data
try $COMPRESS_CMD -r remap

for d in $META; do
    if [ "$(ls -A $d)"  ]; then
        try $UPLOAD_CMD -r $d $FILE_PATH/
    fi
done

try $UPLOAD_CMD info_"${output}".data $FILE_PATH/info/info_"${output}".data
try $UPLOAD_CMD rejected_edges_"${output}".log $FILE_PATH/info/rejected_edges_"${output}".log
try $UPLOAD_CMD -r remap $FILE_PATH/
try $UPLOAD_CMD meta_"${output}".data $FILE_PATH/meta/meta_"${output}".data
try $UPLOAD_CMD mst_"${output}".data."${COMPRESSED_EXT}" $FILE_PATH/chunked_mst/mst_"${output}".data."${COMPRESSED_EXT}"
try $UPLOAD_CMD remap_"${output}".data."${COMPRESSED_EXT}" $FILE_PATH/remap/remap_"${output}".data."${COMPRESSED_EXT}"
try $UPLOAD_CMD edges_"${output}".data."${COMPRESSED_EXT}" $FILE_PATH/region_graph/edges_"${output}".data."${COMPRESSED_EXT}"
try $UPLOAD_CMD final_rg_"${output}".data."${COMPRESSED_EXT}" $FILE_PATH/region_graph/final_rg_"${output}".data."${COMPRESSED_EXT}"

try tar -cvf - *_"${output}".data | $COMPRESS_CMD > "${output}".tar."${COMPRESSED_EXT}"
try $UPLOAD_CMD "${output}".tar."${COMPRESSED_EXT}" $FILE_PATH/scratch/"${output}".tar."${COMPRESSED_EXT}"

try rm -rf remap
for d in $META; do
    try rm -rf $d
done
