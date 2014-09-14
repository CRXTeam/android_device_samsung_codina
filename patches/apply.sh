#!/bin/sh

MYABSPATH=$(readlink -f "$0")
PATCHBASE=$(dirname "$MYABSPATH")
CMBASE=$(readlink -f "$PATCHBASE/../../../../")

echo -e $CL_BLU"Cherrypicking vold patch to allow switching storages"$CL_RST
cd system/vold
git fetch http://review.cyanogenmod.org/CyanogenMod/android_system_vold refs/changes/15/56515/2
git cherry-pick FETCH_HEAD
cd ../..
echo -e $CL_BLU"Cherrypicking ART compatibility fix with GCC 4.8"$CL_RST
cd art
git fetch https://github.com/JustArchi/android_art cm-11.0
git cherry-pick 71a0ca3057cc3865bd8e41dcb94443998d028407
cd ..

for i in $(find "$PATCHBASE"/* -type d); do
	PATCHNAME=$(basename "$i")
	PATCHTARGET=$PATCHNAME
	for i in $(seq 4); do
		PATCHTARGET=$(echo $PATCHTARGET | sed 's/_/\//')
		if [ -d "$CMBASE/$PATCHTARGET" ]; then break; fi
	done
	echo applying $PATCHNAME to $PATCHTARGET
	cd "$CMBASE/$PATCHTARGET" || exit 1
	git am -3 "$PATCHBASE/$PATCHNAME"/* || exit 1
done
