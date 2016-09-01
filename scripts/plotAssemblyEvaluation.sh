#!/usr/bin/env bash
# Makes plots comparing the assembly realignment statistics in each region.

set -ex

# What plot filetype should we produce?
PLOT_FILETYPE="png"

# Grab the input directory to look in
INPUT_DIR=${1}

if [[ ! -d "${INPUT_DIR}" ]]
then
    echo "Specify input directory!"
    exit 1
fi

# Set to "call" or "genotype" for comparison experiment
PARAM_SET="defray"

# What evaluation are we?
EVAL="assembly_sd"

# Set up the plot parameters
# Include both versions of the 1kg SNPs graph name
PLOT_PARAMS=(
    --categories
    snp1kg
    snp1000g
    sbg
    cactus
    camel
    curoverse
    debruijn-k31
    debruijn-k63
    level1
    level2
    level3
    prg
    refonly
    simons
    trivial
    vglr
    haplo1kg30
    haplo1kg50
    shifted1kg
    freebayes
    empty
    --category_labels 
    1KG
    1KG
    7BG
    Cactus
    Camel
    Curoverse
    "De Bruijn 31"
    "De Bruijn 63"
    Level1
    Level2
    Level3
    PRG
    Primary
    SGDP
    Unmerged
    VGLR
    "1KG Haplo 30"
    "1KG Haplo 50"
    Scrambled
    Freebayes
    Empty
    --colors
    "#fb9a99"
    "#fb9a99"
    "#b15928"
    "#1f78b4"
    "#33a02c"
    "#a6cee3"
    "#e31a1c"
    "#ff7f00"
    "#FF0000"
    "#00FF00"
    "#0000FF"
    "#6a3d9a"
    "#000000"
    "#b2df8a"
    "#b1b300"
    "#cab2d6"
    "#00FF00"
    "#0000FF"
    "#FF0000"
    "#FF00FF"
    "#FFFF00"
    --dpi 90 --font_size 14 --no_n
)

for REGION in brca1 brca2 sma lrc_kir mhc; do
      
    mkdir -p "${INPUT_DIR}/evals/${EVAL}/plots/bp"  
    mkdir -p "${INPUT_DIR}/evals/${EVAL}/plots/count"
    
    # Keep stats files in their own directories
    mkdir -p "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats"  
    mkdir -p "${INPUT_DIR}/evals/${EVAL}/plots/count/stats"
    
    
    # Clear out old stats
    true > "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-insertions-${PARAM_SET}.tsv"
    true > "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-deletions-${PARAM_SET}.tsv"
    true > "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-substitutions-${PARAM_SET}.tsv"
    true > "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-unvisited-${PARAM_SET}.tsv"
    
    true > "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-insertions-${PARAM_SET}.tsv"
    true > "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-deletions-${PARAM_SET}.tsv"
    true > "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-substitutions-${PARAM_SET}.tsv"
    true > "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-unvisited-${PARAM_SET}.tsv"


    for GRAPH in snp1kg refonly shifted1kg freebayes empty; do
    
        # Parse all the counts from the stats files
        
        GRAPH_STATS="${INPUT_DIR}/evals/${EVAL}/stats/${REGION}/${GRAPH}-${PARAM_SET}.txt"
    
        # Do plot input files by base count
        INSERT_BASES=$(cat "${GRAPH_STATS}" | grep "Insertions" | sed -E 's/.* ([0-9]+) bp.*/\1/g')
        DELETE_BASES=$(cat "${GRAPH_STATS}" | grep "Deletions" | sed -E 's/.* ([0-9]+) bp.*/\1/g')
        SUBSTITUTE_BASES=$(cat "${GRAPH_STATS}" | grep "Substitutions" | sed -E 's/.* ([0-9]+) bp.*/\1/g')
        UNVISITED_BASES=$(cat "${GRAPH_STATS}" | grep "Unvisited" | sed -E 's/.* \(([0-9]+) bp\).*/\1/g')
        
        printf "${GRAPH}\t${INSERT_BASES}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-insertions-${PARAM_SET}.tsv"
        printf "${GRAPH}\t${DELETE_BASES}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-deletions-${PARAM_SET}.tsv"
        printf "${GRAPH}\t${SUBSTITUTE_BASES}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-substitutions-${PARAM_SET}.tsv"
        printf "${GRAPH}\t${UNVISITED_BASES}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-unvisited-${PARAM_SET}.tsv"
        
        # Now do by event count
        INSERT_COUNT=$(cat "${GRAPH_STATS}" | grep "Insertions" | sed -E 's/.* ([0-9]+) read events.*/\1/g')
        DELETE_COUNT=$(cat "${GRAPH_STATS}" | grep "Deletions" | sed -E 's/.* ([0-9]+) read events.*/\1/g')
        SUBSTITUTE_COUNT=$(cat "${GRAPH_STATS}" | grep "Substitutions" | sed -E 's/.* ([0-9]+) read events.*/\1/g')
        UNVISITED_COUNT=$(cat "${GRAPH_STATS}" | grep "Unvisited" | sed -E 's/.* ([0-9]+)\/.*/\1/g')
        
        printf "${GRAPH}\t${INSERT_COUNT}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-insertions-${PARAM_SET}.tsv"
        printf "${GRAPH}\t${DELETE_COUNT}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-deletions-${PARAM_SET}.tsv"
        printf "${GRAPH}\t${SUBSTITUTE_COUNT}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-substitutions-${PARAM_SET}.tsv"
        printf "${GRAPH}\t${UNVISITED_COUNT}\n" \
            >> "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-unvisited-${PARAM_SET}.tsv"
        
    done
    
    # Plot by bp
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-insertions-${PARAM_SET}.tsv" \
        --title "Inserted bases relative to sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Inserted bases in assembly re-alignment" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/bp/${REGION}-insertions-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-deletions-${PARAM_SET}.tsv" \
        --title "Deleted bases relative to sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Deleted bases in assembly re-alignment" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/bp/${REGION}-deletions-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-substitutions-${PARAM_SET}.tsv" \
        --title "Substituted bases relative to sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Substituted bases in assembly re-alignment" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/bp/${REGION}-substitutions-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/bp/stats/${REGION}-unvisited-${PARAM_SET}.tsv" \
        --title "Unvisited node length in sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Length of unvisited called nodes" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/bp/${REGION}-unvisited-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
        
    # Plot by event count
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-insertions-${PARAM_SET}.tsv" \
        --title "Insertion events relative to sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Insertions in assembly re-alignment" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/count/${REGION}-insertions-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-deletions-${PARAM_SET}.tsv" \
        --title "Deletion events relative to sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Deletions in assembly re-alignment" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/count/${REGION}-deletions-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-substitutions-${PARAM_SET}.tsv" \
        --title "Substitution events relative to sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Substitutions in assembly re-alignment" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/count/${REGION}-substitutions-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/barchart.py "${INPUT_DIR}/evals/${EVAL}/plots/count/stats/${REGION}-unvisited-${PARAM_SET}.tsv" \
        --title "Unvisited nodes in sample ${REGION^^} (${PARAM_SET})" \
        --x_label "Graph type" \
        --y_label "Number of unvisited called nodes" \
        --save "${INPUT_DIR}/evals/${EVAL}/plots/count/${REGION}-unvisited-${PARAM_SET}.${PLOT_FILETYPE}" \
        "${PLOT_PARAMS[@]}"
    
done
        
        
