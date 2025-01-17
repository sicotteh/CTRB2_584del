#!/bin/bash
#set -x
SAMPLE=$1
BEDDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# EDIT this next line
cramrel="..//manta_gitrepo/cramtest/${SAMPLE}.oqfe.cram"
cram=`readlink -m $cramrel`

# EDIT the next set of parameters for your data
#MININSERT = 2 times read-size
MINFRAG=150
# MINLARGE = 584+2*readlength=584+2*76=736
MINLARGE=700
# MAXFRAG=584+ max_tolerable_fragment_size
MAXFRAG=1584
FG=$(mktemp -p . )


################################################
#  Do not edit below this line.
################################################

LEFTB=$(mktemp -p . )
RIGHTB=$(mktemp -p . )
LEFTANDRIGHT=$(mktemp -p . )
BREAKPOINT=$(mktemp -p . )

#
# check for paired reads spanning the junction and with large insert-size.. with 1 read on each side of the junction.
#
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_spandel.bed -f 1 -F 0x70C $cram | gawk -F "\t" -v MINFRAG=${MINLARGE} -v MAXFRAG=${MAXFRAG} '((($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9> -MAXFRAG))){print $0}' | cut -f1,5 | sort | uniq | gawk -F "\t" '{if($1 in N){N[$1]+=1}else{N[$1]=1}}{if($1 in HAVE) {if(HAVE[$1]<$2){HAVE[$1]=$2} else{HAVE[$1]=$2}} else{HAVE[$1]=$2}}END{for(i in HAVE){if(HAVE[i]>30 && N[i]>=2){print i}}}' > $BREAKPOINT

RIGHTEDGE=`head -n1 ${BEDDIR}/CTRB2_leftdel.bed | cut -f 3`
# To account for softclip, take the mapped read length to be defined by "M" in the CIGAR
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_leftdel.bed -f 0 -F 0x70C $cram | gawk -F "\t" -v EDGE=${RIGHTEDGE} -v MINFRAG=${MINLARGE} -v MAXFRAG=${MAXFRAG} '{CIGAR=$6;L=0;while(match(CIGAR,/([0-9]+)M/,a)){L+=substr(CIGAR,RSTART,RLENGTH);CIGAR=substr(CIGAR,RSTART+RLENGTH+1);}}((($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9>-MAXFRAG)) && $4+L<EDGE ){print $0}' | cut -f1 | sort | uniq -u > $LEFTB
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_rightdel.bed -f 0 -F 0x70C $cram | gawk -F "\t" -v EDGE=${RIGHTEDGE} -v MINFRAG=${MINLARGE} -v MAXFRAG=${MAXFRAG} '((($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9> -MAXFRAG)) && $4>EDGE){print $0}' | cut -f1 | sort | uniq -u > $RIGHTB
cat ${LEFTB} ${RIGHTB} | sort | uniq -d > ${LEFTANDRIGHT}
NDEL=`cat ${LEFTANDRIGHT} ${BREAKPOINT} | sort | uniq -d | wc -l`

#echo "584bp BREAKPOINT"
#cat ${BREAKPOINT}
#echo "--------------------"
#echo "LEFTB"
#cat ${LEFTB}
#echo "--------------------"
#echo "RIGHTB"
#cat ${RIGHTB}

#
# Check for SMALL paired reads spanning the junction, with 1 read on each side of the junction
# Allow alternate alignment because of soft-clipping at the junction.
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_spandel.bed -f 3 -F 0xF0C $cram | gawk -F "\t" -v MINFRAG=${MINFRAG} -v MAXFRAG=${MINLARGE}  '((($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9> -MAXFRAG))){print $0}' | cut -f1,5 | sort | uniq | gawk -F "\t" '{if($1 in N){N[$1]+=1}else{N[$1]=1}}{if($1 in HAVE) {if(HAVE[$1]<$2){HAVE[$1]=$2} else{HAVE[$1]=$2}} else{HAVE[$1]=$2}}END{for(i in HAVE){if(HAVE[i]>30 && N[i]>=2){print i}}}' > $BREAKPOINT

samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_leftdel.bed -f 0 -F 0xF0C $cram | gawk -F "\t" -v EDGE=${RIGHTEDGE} -v MINFRAG=${MINFRAG} -v MAXFRAG=${MINLARGE} '{CIGAR=$6;L=0;while(match(CIGAR,/([0-9]+)M/,a)){L+=substr(CIGAR,RSTART,RLENGTH);CIGAR=substr(CIGAR,RSTART+RLENGTH+1);}}($4+L<EDGE && (($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9> -MAXFRAG))){print $0}' | cut -f1 | sort | uniq -u > $LEFTB
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_rightdel.bed -f 0 -F 0xF0C $cram | gawk -F "\t" -v EDGE=${RIGHTEDGE} -v MINFRAG=${MINFRAG} -v MAXFRAG=${MINLARGE} '($4>EDGE && (($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9> -MAXFRAG))){print $0}' | cut -f1 | sort | uniq -u > $RIGHTB
cat ${LEFTB} ${RIGHTB} | sort | uniq -d > ${LEFTANDRIGHT}
NNORMAL=`cat ${LEFTANDRIGHT} ${BREAKPOINT} | sort | uniq -d | wc -l`

#echo "SMALL BREAKPOINT"
#cat ${BREAKPOINT}
#echo "--------------------"
#echo "LEFTB"
#cat ${LEFTB}
#echo "--------------------"
#echo "RIGHTB"
#cat ${RIGHTB}

# Count weird large inserts.
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_region.bed -f 1 -F 0xF0C $cram | gawk -F "\t" -v MINFRAG="18500" -v MAXFRAG="19200"  '((($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9>-MAXFRAG))){print $0}' | cut -f1 | sort | uniq -d > $BREAKPOINT
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_breakpoint_left.bed -f 0 -F 0xF0C $cram | gawk -F "\t" -v MINFRAG=18500 -v MAXFRAG=19200 '((($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9>-MAXFRAG))){print $0}' | cut -f1 | sort | uniq -u > ${LEFTB}
samtools view  --no-header --use-index -L ${BEDDIR}/CTRB2_breakpoint_right.bed -f 0 -F 0xF0C $cram | gawk -F "\t" -v MINFRAG=18500 -v MAXFRAG=19200 '((($9>MINFRAG && $9<MAXFRAG) || ($9< -MINFRAG && $9>-MAXFRAG))){print $0}' | cut -f1 | sort | uniq -u > ${RIGHTB}
cat ${LEFTB} ${RIGHTB} | sort | uniq -d > ${LEFTANDRIGHT}

NLARGE=`cat ${LEFTANDRIGHT} ${BREAKPOINT} | sort | uniq -d | wc -l`

#echo "LARGE BREAKPOINT"
#cat ${BREAKPOINT}
#echo "--------------------"
#echo "LEFTB"
#cat ${LEFTB}
#echo "--------------------"
#echo "RIGHTB"
#cat ${RIGHTB}

rm ${LEFTB}
rm ${RIGHTB}
rm ${LEFTANDRIGHT}
rm ${BREAKPOINT}

echo "${SAMPLE} $NDEL $NNORMAL $NLARGE" | sed -e 's/ /\t/g'
