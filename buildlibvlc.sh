#!/bin/sh

rootdir=`dirname $0`

checkfail()
{
    if [ ! $? -eq 0 ];then
        echo "'$1' failed"
        exit 1
    fi
}

if [ ! -d "${rootdir}/vlc-android" ]; then
    echo "VLC Android source not found, cloning"
    git clone http://code.videolan.org/videolan/vlc-android.git
    checkfail "git clone"
fi

sh -c "cd ${rootdir}/vlc-android && ./compile.sh -l $*"
checkfail "./vlc-android/compile.sh $*"

cp "${rootdir}"/vlc-android/libvlc/build/outputs/aar/*.aar "${rootdir}"/libvlc
checkfail "libvlc*.arr not found"

VLC_SRC_DIR=`realpath "${rootdir}"/vlc-android/vlc`
LIBVLC_LIBS=`realpath "${rootdir}"/vlc-android/libvlc/jni/libs`

for project in native_sample;do
    for arch in `ls ${LIBVLC_LIBS}`;do
        $ANDROID_NDK/ndk-build -C "${rootdir}"/${project} \
            VLC_SRC_DIR="${VLC_SRC_DIR}" \
            LIBVLC_LIBS="${LIBVLC_LIBS}/${arch}" \
            APP_BUILD_SCRIPT=jni/Android.mk \
            APP_PLATFORM=android-9 \
            APP_ABI=${arch} \
            NDK_PROJECT_PATH=jni
    done
done