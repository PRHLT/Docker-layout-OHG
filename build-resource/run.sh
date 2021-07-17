#!/bin/bash

software_path="/pidocs-soft/projects/DLA"

mkdir /experiment

ls /data/*.tif > /experiment/files.lst

#---- create prod annotations

mkdir /experiment/annotations

echo "Generating annotations [START]"

python3 $software_path/utils/gen_prod_annotations.py --img_list /experiment/files.lst --categories 'TextRegion:$pag' 'TextRegion:$pac' 'TextRegion:$tip' 'TextRegion:$par' 'TextRegion:$nop' 'TextRegion:$not' 'TextLine:textline' --output /experiment/annotations/prod_annotations.json

echo "Generating annotations   [END]"

#--- Gen hyps

echo "Evaluating samples      [START]"

export CUDA_VISIBLE_DEVICES=""; python3 $software_path/train_net.py --num-gpus 0 --eval-only --config-file $software_path/configs/OHG_prod.yaml SOLVER.IMS_PER_BATCH 4 MODEL.DEVICE cpu

echo "Evaluating samples        [END]"

mkdir /experiment/page;

mkdir /experiment/page_baselines;

mkdir /experiment/inference;

echo "Proccessing pages       [START]"

python3 $software_path/utils/detectronCoco2page.py --results_json /experiment/inference/coco_instances_results.json --dataset_json /experiment/annotations/prod_annotations.json --output /experiment/page

cp /data/*.tif /experiment/page/

python3 $software_path/utils/baselines/baselines.py --img_dir /experiment/page --page_dir /experiment/page --out_dir /experiment/page_baselines --must_line 'TextRegion'

mkdir -p /payload/page;

for page_in in `ls /experiment/page_baselines/*`; 
do
	python3 $software_path/utils/add_line/add_line.py 50 $page_in /payload/page/`basename $page_in`
done

echo "Proccessing pages         [END]"
