

(for i in `cat ../SOFTCRAMS.txt | cut -f2`; do bash DetectBreakpoint.bash $i ; done) > ../SOFTCRAMS.report.txt


gawk -F "\t" 'BEGIN{while(getline<"../SOFTCRAMS.txt"){KNOWN[$2]="NA"};while(getline<"../known_homalt.txt"){KNOWN[$1]="1/1"};while(getline<"../known_hets.txt"){KNOWN[$1]="0/1"};while(getline<"../known_homref.txt"){KNOWN[$1]="0/0"};OFS="\t";print "SAMPLE","Deletion_spanning_reads","NotDeletion_spanning","CTRB1_inversion","Genotype","KnownGenotype","Confidence"}{geno="NA";conf="NA";if($2+$3+$4 <8){conf="LovCov_MayUnderCallHets"};if($2>0 && $3==0){geno="1/1";if($2>3 || $2+$4>7){conf="High"}};if($2>0 && $3>0){geno="0/1";conf="High"};if($2==0 && $3>0){geno="0/0";if($3+$4>12 || $3>=7){conf="High"}};if($2==0 && $3==0) {if($4>10) {conf="HighDP_yetNoCalls"}else{if($4==0){conf="LowCoverage"}}};print $0 "\t" geno "\t" KNOWN[$1] "\t" conf}' ../SOFTCRAMS.report.txt > ../SOFTCRAMS.calls.txt
