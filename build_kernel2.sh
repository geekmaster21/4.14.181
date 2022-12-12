#!/bin/bash 
 set -e 
  
 BUILD_COMMAND=$1 
 PRODUCT_OUT=$2 
 PRODUCT_NAME=$3 
  
 MODEL=a71
 TEMP=${BUILD_COMMAND#*_} 
 REGION=eur
 CARRIER=open
          
 echo PRODUCT_NAME=$PRODUCT_NAME 
 echo MODEL=$MODEL 
 echo REGION=$REGION 
 echo CARRIER=$CARRIER 
 echo VARIANT=${CARRIER} 
  
  
 #*** TARGET CONFIG START ***# 
 export PROJECT_NAME=${MODEL} 
 [ -z ${PLATFORM_VERSION} ] && export PLATFORM_VERSION=10 
  
 BUILD_WHERE=$(pwd) 
 BUILD_KERNEL_DIR=$BUILD_WHERE 
 BUILD_ROOT_DIR=$BUILD_KERNEL_DIR/../../.. 
 BUILD_KERNEL_OUT_DIR=$PRODUCT_OUT/obj/KERNEL_OBJ 
  
 CHIPSET_NAME=sm7150 
 KERNEL_ARCH=arm64 
 BUILD_CROSS_COMPILE=$BUILD_ROOT_DIR/gcc/bin/aarch64-linux-android- 
 KERNEL_LLVM_BIN=$BUILD_ROOT_DIR/llvm-sdclang/compiler/bin/clang 
 CLANG_TRIPLE=aarch64-linux-gnu- 
 KERNEL_IMG=$BUILD_KERNEL_OUT_DIR/arch/arm64/boot/Image 
 DTB_IMG=$BUILD_KERNEL_OUT_DIR/arch/arm64/boot/dtb.img 
 BOARD_KERNEL_PAGESIZE=4096 
 BOARD_KERNEL_CMDLINE="console=null androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=30 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048 androidboot.usbcontroller=a600000.dwc3 firmware_class.path=/vendor/firmware_mnt/image" 
 MKBOOTIMG_AFLAG="--cmdline \"${BOARD_KERNEL_CMDLINE}\" \ 
                                 --base 0x00000000 --pagesize ${BOARD_KERNEL_PAGESIZE} \ 
                                 --os_version ${PLATFORM_VERSION} --os_patch_level ${PLATFORM_SECURITY_PATCH} \ 
                                 --ramdisk_offset 0x02000000 --tags_offset 0x01E00000 \ 
                                 --dtb dtb.img --header_version 2 \ 
                                 --board SRPSH29C000" 
 #*** TARGET CONFIG END ***# 
  
 KERNEL_DEFCONFIG=${CHIPSET_NAME}_sec_defconfig 
  
 if [ "${SEC_BUILD_OPTION_TYPE}" != "userdebug" ]; then 
         DEBUG_DEFCONFIG=${CHIPSET_NAME}_sec_${SEC_BUILD_OPTION_TYPE}_defconfig 
 fi 
  
 if [ "${REGION}" == "${CARRIER}" ]; then 
         VARIANT_DEFCONFIG=${CHIPSET_NAME}_sec_${MODEL}_${CARRIER}_defconfig 
 else 
         VARIANT_DEFCONFIG=${CHIPSET_NAME}_sec_${MODEL}_${REGION}_${CARRIER}_defconfig 
 fi 
  
 KERNEL_MAKE_ENV="DTC_EXT=/home/ubuntu/kernel/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y" 
 KERNEL_MAKE_ENV+=" DTC_OVERLAY_TEST_EXT=$BUILD_KERNEL_DIR/tools/ufdt_apply_overlay" 
 KERNEL_MAKE_ENV+=" CONFIG_BUILD_ARM64_DT_OVERLAY=y"
 BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l` 
  
 mkdir -p $BUILD_KERNEL_OUT_DIR 
  
 FUNC_BUILD_KERNEL() 
 { 
         echo "" 
         echo "==============================================" 
         echo "START : FUNC_BUILD_KERNEL" 
         echo "==============================================" 
         echo "" 
         echo "build project="$PROJECT_NAME"" 
         echo "build common config="$KERNEL_DEFCONFIG "" 
         echo "build variant config="$VARIANT_DEFCONFIG "" 
         echo "build secure option="$SECURE_OPTION "" 
         echo "build SEANDROID option="$SEANDROID_OPTION "" 
         echo "build PRODUCT_OUT="$PRODUCT_OUT "" 
  
         if [ "$BUILD_COMMAND" == "" ]; then 
                 SECFUNC_PRINT_HELP; 
                 exit -1; 
         fi 
  
     chmod u+w $PRODUCT_OUT/mkbootimg_ver_args.txt 
     echo $MKBOOTIMG_AFLAG  >  $PRODUCT_OUT/mkbootimg_ver_args.txt 
     touch $PRODUCT_OUT/vbmeta.img 
  
     echo ---------------------------------------------- 
     echo info $PRODUCT_OUT/mkbootimg_ver_args.txt 
     echo ---------------------------------------------- 
     cat  $PRODUCT_OUT/mkbootimg_ver_args.txt 
     echo ---------------------------------------------- 
      
         make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR $KERNEL_MAKE_ENV ARCH=${KERNEL_ARCH} \ 
                         CROSS_COMPILE=$BUILD_CROSS_COMPILE \ 
                         REAL_CC=$KERNEL_LLVM_BIN \ 
                         CLANG_TRIPLE=$CLANG_TRIPLE \ 
                         $KERNEL_DEFCONFIG \ 
                         DEBUG_DEFCONFIG=$DEBUG_DEFCONFIG \ 
                         VARIANT_DEFCONFIG=$VARIANT_DEFCONFIG 
  
         make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER $KERNEL_MAKE_ENV ARCH=${KERNEL_ARCH} \ 
                         CROSS_COMPILE=$BUILD_CROSS_COMPILE \ 
                         REAL_CC=$KERNEL_LLVM_BIN \ 
                         CLANG_TRIPLE=$CLANG_TRIPLE 
              
     cat ${BUILD_KERNEL_OUT_DIR}/arch/${KERNEL_ARCH}/boot/dts/qcom/*.dtb > $PRODUCT_OUT/dtb.img 
  
     #enable this section when necessary until then using static name convention 
     if [ "${MODEL}" == "a71" ] ; then 
                 DTBO_NAME=${CHIPSET_NAME}-sec-${MODEL}-overlay*.dtbo 
         else 
                 if [ "${REGION}" == "usa" ]; then 
                         DTBO_NAME=${CHIPSET_NAME}-sec-${MODEL}-overlay*.dtbo 
                 else 
                         DTBO_NAME=${CHIPSET_NAME}-sec-${MODEL}-${REGION}-overlay*.dtbo 
                 fi 
         fi 
     DTBO_NAME=${CHIPSET_NAME}-sec-${MODEL}-${REGION}-overlay*.dtbo 
      
     $BUILD_KERNEL_DIR/tools/mkdtimg create $PRODUCT_OUT/dtbo.img --page_size=${BOARD_KERNEL_PAGESIZE} $BUILD_KERNEL_OUT_DIR/arch/${KERNEL_ARCH}/boot/dts/samsung/${DTBO_NAME} 
          
     rsync -cv $KERNEL_IMG $PRODUCT_OUT/kernel 
      
     ls -al $PRODUCT_OUT/kernel 
      
         echo "" 
         echo "=================================" 
         echo "END   : FUNC_BUILD_KERNEL" 
         echo "=================================" 
         echo "" 
 }
  
 ( 
         FUNC_BUILD_KERNEL 
 )