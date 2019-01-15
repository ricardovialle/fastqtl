# FastQTL

* Modified version of FastQTL (Ongen, H. et al., 2016) that handles structural variants. Developed for the GTEx SVs paper [Chiang C. et al. The impact of structural variation on human gene expression. Nature Genetics (2017)](https://www.nature.com/articles/ng.3834). This repository was forked from [https://github.com/hall-lab/fastqtl](https://github.com/hall-lab/fastqtl)

* Original documentation for FastQTL can be found here: [http://fastqtl.sourceforge.net](http://fastqtl.sourceforge.net)

* Original reference: [Ongen, H. et al. Fast and efficient QTL mapper for thousands of molecular phenotypes. Bioinformatics (2016).](http://bioinformatics.oxfordjournals.org/content/32/10/1479)

### Description from Ira Hall lab forked repository

A structural variant (SV) lies within the cis window if any part of the spanned region is within the cis window *except* inversions, for which one (or both) of the breakpoints must fall are within the cis window

The spanned region for deletions, duplications, and inversions is inferred from the END field in the 8th column of the VCF. If the END field is absent for a variant, it assumes that the END is the same as the POS field (identical to standard FastQTL behavior).

The variant type is inferred from the SVTYPE field of the 8th column of the VCF. Inversions must be designated as SVTYPE=INV for proper behavior

### Running test for SVs and expression data

Before running remember to add the fastQTL binary in your PATH

~~~
module load boost/1.55.0-gcc
module load gsl/2.2.1
cd /path/to/fastqtl/example
fastQTL --vcf genotypes.vcf.gz --bed phenotypes.bed.gz --region 22:17000000-18000000 --out test.txt.gz
~~~

### Example using covariates as phenotypes

#### Inputs

For this example 3 input files are required:

1. The SV vcf file (`--vcf` parameter)
2. A covariates file (`--cov`) <-- opitional
3. A bed file with phenotypes which in this case are also covariates (`--bed`)

The **VCF** file must contain the tags SVTYPE and END in the INFO column. The file must be compressed and indexed:

~~~
bgzip genotypes.vcf && tabix -p vcf genotypes.vcf.gz
~~~

The **covariates** file contains the covariate data in simple txt format. 

* The file is TAB delimited
* First row gives the sample ID and each additional one corresponds to a single covariate
* First column gives the covariate ID and each additional one corresponds to a sample
* The file should have S+1 rows and C+1 columns where S and C are the numbers of samples and covariates, respectively.
* Both quantitative and qualitative covariates are supported. Quantitative covariates are assumed when only numeric values are provided. Qualitative covariates are assumed when only non-numeric values are provided. In practice, qualitative covariates with F factors are converted in F-1 binary quantitative covariates.

See an example:

~~~
id      SM-CJFK8        SM-CTDUU        SM-CTDSC        SM-CJIYB        SM-CTEMS        SM-CJFLR
study   MAP     MAP     MAP     MAP     MAP     MAP
msex    0       0       0       1       0       0
educ    16      16      12      15      12      15
race    1       1       1       1       1       1
apoe_genotype   33      34      23      33      33      33
age_death       90      80.65708        83.69062        90      90      90
~~~

The **phenotype** file contains the phenotypic data in a UCSC BED derived format. It is basically a BED file with one additional column per sample. 

**Important:** Phenotype quantifications are encoded with **floating numbers**. Any non numeric *covariate/phenotype* must be removed before running. 

This file is TAB delimited. Each line corresponds to a single molecular *covariate/phenotype*. The first 4 columns are:

1. Chromosome ID [string]
2. Start genomic position of the phenotype (e.g. TSS) [integer]
3. End genomic position of the phenotype (e.g. TSS) [integer]
4. Phenotype ID [string]

**Important:** Since here we are using *covariates/phenotypes* instead of transcripts, we must set the positions ranging across the entire chromosomes. And each *covariate/phenotype* must be repeated for each chromosome.

See the following example. We have 4 *covariates/phenotypes* and 3 samples showed for chromosomes 1 and 2. Note that TargedID must be unique, so we added to each *covariate/phenotype* a *chunk* label that can be removed after the analysis.

~~~
#Chr    start   end     TargetID        SM-CJFK8        SM-CTDUU        SM-CTDSC
1       0       249250621       chunk1|cts_mmse30_lv    29      13      30
1       0       249250621       chunk1|braaksc  3       5       4
1       0       249250621       chunk1|ceradsc  2       1       4
1       0       249250621       chunk1|cogdx    1       4       1
2       0       243199373       chunk2|cts_mmse30_lv    29      13      30
2       0       243199373       chunk2|braaksc  3       5       4
2       0       243199373       chunk2|ceradsc  2       1       4
2       0       243199373       chunk2|cogdx    1       4       1
~~~

This file must also be compressed and indexed

~~~
bgzip phenotypes.bed && tabix -p bed phenotypes.bed.gz
~~~

#### Running a nominal pass

**Note:** `--window 1e9` is the maximum value allowed and permits to correlate any SV within a chromossome with any covariate in the same chromosome. 

~~~
module load boost/1.55.0-gcc
module load gsl/2.2.1
cd /path/to/your/files
# Loop over the 22 chromosomes
for i in $(seq 1 22); do
  fastQTL --vcf genotypes.vcf.gz --bed phenotypes.bed.gz --cov covariates.txt --out fastQTL_chunk_${i} --chunk ${i} 22 --window 1e9
done
~~~
