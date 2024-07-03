# CTRB2del
Projects to call a 584 bp deletion in exon2 of CTRB2
from a cram file (or a bam).

The script DetectBreakpoint takes a sample name as a parameter.. and
computes paired reads supporting the deletion and paired reads spanning the deletion site without showing evidence of deletion.
You should edit the script to set the location of the script and the path to the BAMS/CRAM and the expression that converts the sample name to a cram.
You probably want to edit the code to set cutoffs appropriate for your data (depends on read size (76bp in this version).

License is MIT licence
Copyright Mayo Clinic
