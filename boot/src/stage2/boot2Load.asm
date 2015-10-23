;;FAT Subroutines start ---------------------------------------------
fat_loadCluster EQU 0x7D86

;;Variables start ---------------------------------------------------
;;Current Cluster data
var_cluster_current EQU 0x7DF3
var_cluster_next EQU 0x7DF7
;;Variables end -----------------------------------------------------

;;Constants start ---------------------------------------------------
ENTRIES_PER_FAT_SECTOR EQU 128  ;128 4byte entries per sector
CURRENT_FAT_LOCATION EQU 0x0500
CURRENT_CLUSTER_LOCATION EQU 0x0700

FAT_BYTES_PER_SECTOR EQU 0x7c00 + 11
FAT_SECTORS_PER_CLUSTER EQU 0x7c00 + 13
FAT_NUM_RESERVED_SECTORS EQU 0x7c00 + 14
FAT_NUM_TABLES EQU 0x7c00 + 16
FAT_NUM_DIR_ENTRIES EQU 0x7c00 + 17
FAT_NUM_SECTORS_SMALL EQU 0x7c00 + 19
FAT_MEDIA_DECRIPTOR_TYPE EQU 0x7c00 + 21
FAT_SECTORS_PER_TRACK EQU 0x7c00 + 24
FAT_NUM_SIDES EQU 0x7c00 + 26
FAT_NUM_HIDDEN_SECTORS EQU 0x7c00 + 28
FAT_NUM_SECTORS_LARGE EQU 0x7c00 + 32

FAT_SECTORS_PER_FAT EQU 0x7c00 + 36
FAT_FLAGS EQU 0x7c00 + 40
FAT_ROOT_CLUSTER EQU 0x7c00 + 44
FAT_DRIVE_NUM EQU 0x7c00 + 64
;;Constants end -----------------------------------------------------
