##make the list of file names to be merged for bcftools
echo "/afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/data/phase2/ag1000g.phase2.ar1.pass.2R.vcf.gz" > /afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/metadata/2R_phase2_VObs_merge_file_names.txt
echo "/afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/data/VObs/VObs_2R_QD_pass_sites_good_samples.vcf.gz" >> /afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/metadata/2R_phase2_VObs_merge_file_names.txt

echo "/afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/data/phase2/ag1000g.phase2.ar1.pass.2L.vcf.gz" > /afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/metadata/2L_phase2_VObs_merge_file_names.txt
echo "/afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/data/VObs/VObs_2L_QD_pass_sites_good_samples.vcf.gz" >> /afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/metadata/2L_phase2_VObs_merge_file_names.txt

##merge with bcftools
for chrom in "2L" "2R";

do

~/local/bin/bcftools/bcftools merge \
-l /afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/metadata/${chrom}_phase2_VObs_merge_file_names.txt \
-r ${chrom} \
-o /scratch365/rlove1/merged_p2_and_VObs_${chrom}.vcf.gz \
-O z

tabix -p vcf /scratch365/rlove1/merged_p2_and_VObs_${chrom}.vcf.gz

done

##convert with vcf2npy

for chrom in "2L" "2R";

do

~/.local/bin/vcf2npy \
--vcf /afs/crc.nd.edu/group/BesanskyNGS2/inversion_genotyping/merged_p2_and_VObs_${chrom}.vcf.gz \
--fasta /afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/reference/Anopheles-gambiae-PEST_CHROMOSOMES_AgamP4.fa \
--array-type variants \
--chromosome ${chrom} \
--exclude-field ID ;

~/.local/bin/vcf2npy \
--vcf /afs/crc.nd.edu/group/BesanskyNGS2/inversion_genotyping/merged_p2_and_VObs_${chrom}.vcf.gz \
--fasta /afs/crc.nd.edu/group/BesanskyNGS/data05/comp_karyo/reference/Anopheles-gambiae-PEST_CHROMOSOMES_AgamP4.fa \
--array-type calldata_2d \
--chromosome ${chrom} \
--exclude-field is_phased \
--exclude-field GT \
--exclude-field AB \
--exclude-field MQ0 \
--exclude-field PL ;

cd /afs/crc.nd.edu/group/BesanskyNGS2/inversion_genotyping

~/.local/bin/vcfnpy2hdf5 \
--vcf merged_p2_and_VObs_${chrom}.vcf.gz \
--input-dir /afs/crc.nd.edu/group/BesanskyNGS2/inversion_genotyping/merged_p2_and_VObs_${chrom}.vcf.gz.vcfnp_cache \
--input-filename-template {array_type}.${chrom}.npy \
--output merged_p2_and_VObs_${chrom}.h5 \
--group ${chrom} \
--chunk-size 131072 \
--chunk-width 10 \
--compression gzip \
--compression-opts 3 ;

done

