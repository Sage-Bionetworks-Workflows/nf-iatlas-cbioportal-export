#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Sage-Bionetworks-Workflows/nf-iatlas-cbioportal-export
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/Sage-Bionetworks-Workflows/nf-iatlas-cbioportal-export
----------------------------------------------------------------------------------------
*/
nextflow.enable.dsl=2

// allow override: --yaml /path/to/other.yml (can be local, s3://..., etc.)
params.yaml = params.yaml ?: "${projectDir}/pipeline.yml"

// set variables and config
def cfg = readYaml( file(params.yaml) )
def DEFAULTS = (cfg.defaults ?: [:]) as Map
def DATASETS = (cfg.datasets ?: [:]) as Map

Channel
  .from( DATASETS.collect { name, attrs -> tuple(name, DEFAULTS + (attrs ?: [:])) } )
  .set { dataset_ch }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { run_maf_processing } from './modules/run_maf_processing'
include { run_clinical_processing } from './modules/run_clinical_processing'
include { run_validation } from './modules/run_validation'
include { load_to_synapse } from './modules/load_to_synapse'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    run_maf_processing(dataset_ch)
    run_clinical_processing(dataset_ch)
    run_validation(dataset_ch)
    load_to_synapse(dataset_ch)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
