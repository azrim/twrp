# A Function to Send Posts to Telegram
telegram_message() {
	curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
	-d chat_id="${TG_CHAT_ID}" \
	-d parse_mode="HTML" \
	-d text="$1"
}

echo -e \
"
Team Win Recovery Project CI
- Initializing....
" > tg.html

TG_TEXT=$(< tg.html)

telegram_message "${TG_TEXT}"

# init
mkdir -p ~/.ssh

# ssh connection
echo 'eval "$(ssh-agent -s)"' >> ~/.bashrc
echo 'ssh-add ~/.ssh/az' >> ~/.bashrc
echo 'ssh -T git@github.com' >> ~/.bashrc
echo 'ssh -T git@gitlab.com' >> ~/.bashrc

# alias
echo 'alias gcp="git cherry-pick -s"' >> ~/.bashrc
echo 'alias gcps="git cherry-pick --skip"' >> ~/.bashrc
echo 'alias gcpa="git cherry-pick --abort"' >> ~/.bashrc
echo 'alias gcpc="git cherry-pick --continue"' >> ~/.bashrc
echo 'alias grm="git remote remove"' >> ~/.bashrc
echo 'alias gra="git remote add"' >> ~/.bashrc
echo 'alias grh="git reset --hard"' >> ~/.bashrc
echo 'alias grb="git rebase"' >> ~/.bashrc
echo 'alias sync="repo sync --no-tags --no-clone-bundle --current-branch --force-sync --optimized-fetch --prune"' >> ~/.bashrc

# github
git config --global user.name "azrim"
git config --global user.email "mirzaspc@gmail.com"
git config --global merge.log 3000
git config --global user.signingkey 497F8FB059B45D1C
git config --global commit.gpgsign true

# SSH key
echo $PK >> ~/.ssh/az

chmod 400 ~/.ssh/az
# ssh connect
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/az
# source
. ~/.bashrc

# clone this repo
git clone git@github.com:azrim/ssh.git ~/secret && cd ~/secret && gpg --import gpgpriv.key && chmod +x wtclient-linux-386 && sudo cp wtclient-linux-386 /usr/local/bin/wtransfer

echo -e \
"
- Syncing....
" > tg.html

TG_TEXT=$(< tg.html)

telegram_message "${TG_TEXT}"

mkdir twrp && cd twrp
repo init --depth=1 -u git@github.com:minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
sync -j20

cd system/vold && git fetch https://gerrit.twrp.me/android_system_vold refs/changes/40/5540/6 && git cherry-pick FETCH_HEAD
cd ../../bootable/recovery && git fetch https://gerrit.twrp.me/android_bootable_recovery refs/changes/05/5405/24 && git cherry-pick FETCH_HEAD
cd ../..

git clone git@github.com:azrim/device_xiaomi_surya-twrp.git -b master device/xiaomi/surya --depth=1 --single-branch

echo -e \
"
- Building....
" > tg.html

TG_TEXT=$(< tg.html)

telegram_message "${TG_TEXT}"

TANGGAL=$(date +'%d%m%Y-%H%M')

rm -rf *img *zip *txt

export USE_CCACHE=0
export CCACHE_DISABLE=1
unset CCACHE_EXEC
unset CCACHE_DIR

export TW_INCLUDE_FASTBOOTD

source b*/e*
lunch twrp_surya-eng
mka recoveryimage -j30 | tee log.txt

cp out/target/product/surya/recovery.img twrp-$TANGGAL.img
zip -r9 twrp-$TANGGAL.zip twrp-$TANGGAL.img

echo -e \
"
- Uploading....
" > tg.html

TG_TEXT=$(< tg.html)

telegram_message "${TG_TEXT}"

wtransfer upload twrp-$TANGGAL.zip  2>&1 | tee wt-up.txt
WLINK=$(cat wt-up.txt | grep 'we.tl' | awk '{ print $1 }')

transfer wet twrp-$TANGGAL.zip > link.txt
MLINK=$(cat link.txt | grep Download | cut -d\  -f3)

echo -e \
"
✅ Build Completed Successfully!

⬇️ Download Link: <a href=\"${WLINK}\">WeTransfer</a>
⬇️ Mirror: <a href=\"${MLINK}\">Mirror</a>
📅 Date: "$TANGGAL"
" > tg.html

TG_TEXT=$(< tg.html)

telegram_message "$TG_TEXT"