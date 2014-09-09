#!/bin/sh

MYABSPATH=$(readlink -f "$0")
PATCHBASE=$(dirname "$MYABSPATH")
CMBASE=$(readlink -f "$PATCHBASE/../../../../")

echo -e $CL_BLU"Cherrypicking vold patch to allow switching storages"$CL_RST
cd system/vold
git fetch http://review.cyanogenmod.org/CyanogenMod/android_system_vold refs/changes/15/56515/2
git cherry-pick FETCH_HEAD
cd ../..
echo -e $CL_BLU"Cherrypicking Art fix"$CL_RST
cd art
git fetch https://github.com/cernekee/android_art monitor-stack-v1
git cherry-pick fc2ac71d0d9e147c607bff9371fe2ef25d8470af
cd ..
echo -e $CL_BLU"Cherrypicking Low-InCall fix"$CL_RST
cd packages/services/Telephony
git fetch https://github.com/TeamCanjica/android_packages_services_Telephony cm-11.0
git cherry-pick fdf281fdabe5e7517eb96f2faf159bbcc74ae4a6
cd ../../..

for i in $(find "$PATCHBASE"/* -type d); do
	PATCHNAME=$(basename "$i")
	PATCHTARGET=$PATCHNAME
	for i in $(seq 4); do
		PATCHTARGET=$(echo $PATCHTARGET | sed 's/_/\//')
		if [ -d "$CMBASE/$PATCHTARGET" ]; then break; fi
	done
	echo applying $PATCHNAME to $PATCHTARGET
	cd "$CMBASE/$PATCHTARGET" || exit 1
	git apply "$PATCHBASE/$PATCHNAME"/* || exit 1
done
