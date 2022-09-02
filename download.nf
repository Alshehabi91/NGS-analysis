nextflow.enable.dsl = 2

params.outdir = "${baseDir}/out"
params.storedir = "${baseDir}/cache"
params.with_stats = null
params.with_fastqc = null
params.with_fastp = null

process prefetch {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
    storeDir params.storedir
    input:
        val accession
    output:
        path "${accession}.sra"
"""
prefetch ${accession}
mv ${accession}/${accession}.sra .
"""
}

process dump {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
    storeDir params.storedir
    input:
        path accession_sra
    output:
        path "${accession_sra.getSimpleName()}*.fastq"
    """
    fastq-dump --split-3 ${accession_sra}
    """
}

process makeFastqStats {
    container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
    publishDir "${params.outdir}", mode: 'copy', overwrite: true

    input:
        path fastqfile
    output:
        path "${fastqfile.getSimpleName()}.stats"

    """
    fastqutils stats ${fastqfile} > ${fastqfile.getSimpleName()}.stats
    """
}

process fastQC {
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    container "https://depot.galaxyproject.org/singularity/fastqc%3A0.11.9--hdfd78af_1"
    input:
        path fastq
    output:
        path "${fastq.getSimpleName()}_fastqc.html", emit: html
        path "${fastq.getSimpleName()}_fastqc.zip", emit: zip
    """
    fastqc ${fastq} > ${fastq.getSimpleName()}.fastqc
    """
}

process runFastp{
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    container "https://depot.galaxyproject.org/singularity/fastp%3A0.23.2--hb7a2d85_2"
    input:
        path fastqfile
    output:
        path "${fastqfile.getSimpleName()}trimmed.fastq", emit: fastq
        path "${fastqfile.getSimpleName()}_fastp.html", emit: report_html
        path "${fastqfile.getSimpleName()}_fastp.json", emit: report_json
    """
    fastp -i ${fastqfile} -o ${fastqfile.getSimpleName()}trimmed.fastq
    mv fastp.html ${fastqfile.getSimpleName()}_fastp.html
    mv fastp.json ${fastqfile.getSimpleName()}_fastp.json
    """
}

process multiQC{
    publishDir "${params.outdir}", mode: 'copy', overwrite: true
    container "https://depot.galaxyproject.org/singularity/multiqc%3A1.13a--pyhdfd78af_1"
    input:
        path fastp_json
    output:
         path "multiqc_report.html"
         path "multiqc_data" 
    """
    multiqc .
    """
}

workflow {
    srachannel = prefetch(params.accession)
    fastqchannel = dump(srachannel).flatten()
    if(params.with_stats != null) {
        makeFastqStats(fastqchannel)
    }
    if(params.with_fastp != null) {
        trimmedfastqchannel = runFastp(fastqchannel)
        allfastqchannel = fastqchannel.concat(trimmedfastqchannel.fastq)
    } 
    else {
        allfastqchannel = fastqchannel
    }
    if(params.with_fastqc != null) {
        fastqcoutchannel = fastQC(allfastqchannel)
    }
    multiQC(trimmedfastqchannel.report_json.collect())
}