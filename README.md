# CTRB2del
Projects to call a 584 bp deletion in exon2 of CTRB2
from a cram file (or a bam). From (1), the position of that deletion was determined to be on chromosome 16 from
	75,238,615 to 75,239,199 (hg19) +/- 5 bp
	75,204,717 to 75,205,301 (GRCh38

Detecting that deletion is a little complicated for exome because the deleted region is part of a segmental duplication+inversion.
	CTRB2(+ strand): chr16	75204717`75205301
 	
 	CTRB1(- strand): chr16	*75222761	75224283 



The script DetectBreakpoint takes a sample name as a parameter.. and
computes paired reads supporting the deletion and paired reads spanning the deletion site without showing evidence of deletion.
You should edit the script to set the location of the script and the path to the BAMS/CRAM and the expression that converts the sample name to a cram.
You probably want to edit the code to set cutoffs appropriate for your data (depends on read size (76bp in this version).

## Method
Using SAMtools, we counted read pairs spanning a 584 bp deletion of the CTRB2 gene (1) encompassing exon5 (reads mapping to chr16:75204400-75205700 on GRCh38), counting read pairs with anomalously large insert size (supporting the deletion) and read pairs with normal insert size (not supporting the deletion). The total coverage also includes read pairs with anomalous mapping (appear to be large insertion but caused by a germline CTRB1 inversion) as an additional indicator of total coverage.

The program’s cutoffs were calibrated from a subset of 605 samples which were also assayed for the deletion using PCR, 9 of which were homozygous deletion and 106 of which were heterozygous for the deletion.

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

# Citations
1. Jermusyk A, Zhong J, Connelly KE, Gordon N, Perera S, Abdolalizadeh E, Zhang T, O'Brien A, Hoskins JW, Collins I, Eiser D, Yuan C; PanScan Consortium; PanC4 Consortium; Risch HA, Jacobs EJ, Li D, Du M, Stolzenberg-Solomon RZ, Klein AP, Smith JP, Wolpin BM, Chanock SJ, Shi J, Petersen GM, Westlake CJ, Amundadottir LT. A 584 bp deletion in CTRB2 inhibits chymotrypsin B2 activity and secretion and confers risk of pancreatic cancer. Am J Hum Genet. 2021 Oct 7;108(10):1852-1865. doi: 10.1016/j.ajhg.2021.09.002. Epub 2021 Sep 23. PMID: 34559995; PMCID: PMC8546220

License is MIT licence
Copyright Mayo Clinic
