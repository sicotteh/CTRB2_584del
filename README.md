# CTRB2del
Projects to call a 584 bp deletion in exon2 of CTRB2
from a cram file (or a bam).

The script DetectBreakpoint takes a sample name as a parameter.. and
computes paired reads supporting the deletion and paired reads spanning the deletion site without showing evidence of deletion.
You should edit the script to set the location of the script and the path to the BAMS/CRAM and the expression that converts the sample name to a cram.
You probably want to edit the code to set cutoffs appropriate for your data (depends on read size (76bp in this version).

## Method
Using SAMtools, we counted reads spanning a 584 bp deletion encompassing exon5 34559995 (reads mapping to chr16:75204400-75205700 on GRCh38), counting read with anomalously large insert size (supporting the deletion) and reads with normal insert size (not supporting the deletion). The total coverage also includes reads with anomalous mapping (appear to be large insertion but caused by a germline CTRB1 inversion) as an additional indicator of total coverage.

The program’s cutoffs were calibrated with 605 samples from a cohort of 605 samples which were assayed for the deletion using PCR, 9 of which were homozygous deletion and 106 of which were heterozygous for the deletion.

Genotype were assigned as follows. If only reads supporting the deletion are found (and none supporting the exon 6 sequence), genotype is called 1/1. If no reads supporting the deletion were found, genotypes were 0/0, otherwise genotype was 0/1.
We further annotate the variants with a confidence indicator
	LowCov_MayUnderCallHets
If the genotype is 0/0 or 1/1 and If the total coverage is 7 or less
	High:
		If the genotype is 0/1 and there are at least one kind of reads supporting normal and large insertions.
		OR
		If the genotype is 1/1 and there are 4 or more large insertions and the total coverage is 8 or more
		OR
		If the genotype is 0/0 and the total coverage is 12 or more, with 7 or more normal reads (95 percent confidence interval)
	LowCoverage
		Genotype == NA If the total coverage is 0
	HighDP_yetNoCalls
		Genotype == NA If the total coverage is 10 or more, but there are no reads supporting normal or large


License is MIT licence
Copyright Mayo Clinic
