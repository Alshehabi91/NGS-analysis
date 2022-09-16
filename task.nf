nextflow.enable.dsl = 2

params.outdir = baseDir
params.tempdir = "${baseDir}/cache"
params.gburl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id="
params.accession = "M21012"
params.gb_to_fasta = "&rettype=fasta&retmode=text"

process downloadFileGB {
    storeDir "${params.tempdir}"
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    input:
        val inurlgb
    output:
        path "${params.accession}.fasta"
    """
    wget "${inurlgb}" -O ${params.accession}.fasta
    """
}

process combined_fasta{
     publishDir "${params.outdir}", mode: 'copy', overwrite: true

    //input:
    //    path seq.fasta
    output:
        path ('*.fasta')

    """
    git clone https://gitlab.com/dabrowskiw/cq-examples.git
    cp cq-examples/data/hepatitis/seq*.fasta .
    """
}

process allData {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true

    input:
        path gbfasta 
        path genfastas
    output:
        path "allData.fasta"
    """
    cat ${gbfasta} > allData.fasta
    cat ${genfastas} > allData.fasta
    """ 
}

process mafftAlignment {
    container "https://depot.galaxyproject.org/singularity/mafft%3A7.490--hec16e2b_1"
    publishDir "${params.outdir}", mode: 'copy', overwrite: true

    input: 
        path fastafile
    output:
        path "all_align.fasta"

    """
    mafft ${fastafile} > all_align.fasta
    """
}

process trimAlignment {
    container "https://depot.galaxyproject.org/singularity/trimal%3A1.4.1--h9f5acd7_6"
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
input:
    path alignfastafile
output:
    path "trim_align.fasta"
    path "trim_align.html"

"""
trimal -in ${alignfastafile} -out trim_align.fasta -htmlout trim_align.html -automated1
"""
}

workflow{
    inurlgb = params.gburl + params.accession + params.gb_to_fasta
    gbfasta = downloadFileGB(inurlgb)
    genfastas = combined_fasta()
    alldata = allData(gbfasta, genfastas)
    align_mafft = mafftAlignment(alldata)
    trimAlignment(align_mafft)
  
}
