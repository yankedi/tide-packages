TERMUX_PKG_HOMEPAGE=https://github.com/yankedi
TERMUX_PKG_DESCRIPTION="GPG public keys for the official Tide repositories"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@yankedi"
TERMUX_PKG_VERSION=0.1.0
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_ESSENTIAL=true

termux_step_make_install() {
	local GPG_SHARE_DIR="$TERMUX_PREFIX/share/tide-keyring"

	# Delete all existing termux-keyring keys
	rm -rf "$GPG_SHARE_DIR"
	mkdir -p "$GPG_SHARE_DIR"

	# Maintainer-specific keys.
	install -Dm600 "$TERMUX_PKG_BUILDER_DIR/yanmain.asc" "$GPG_SHARE_DIR"

	# Key for automatic builds (via CI).
	#install -Dm600 "$TERMUX_PKG_BUILDER_DIR/termux-autobuilds.gpg" "$GPG_SHARE_DIR"

	# Key for pacman package manager.
	#install -Dm600 "$TERMUX_PKG_BUILDER_DIR/termux-pacman.gpg" "$GPG_SHARE_DIR"

	# Create symlinks under apt GPG_DIR to key files under GPG_SHARE_DIR
	# pacman keyring path is intentionally disabled.
	for GPG_DIR in "$TERMUX_PREFIX/etc/apt/trusted.gpg.d"; do
		mkdir -p "$GPG_DIR"
		# Delete keys which have been removed in newer version and their symlink target does not exist
		find "$GPG_DIR" -xtype l -printf 'Deleting removed key: %p\n' -delete
		local -a GPG_FILES=()
		local nullglob_was_set=0
		shopt -q nullglob && nullglob_was_set=1
		shopt -s nullglob
		GPG_FILES=("$GPG_SHARE_DIR"/*.gpg "$GPG_SHARE_DIR"/*.asc)
		[[ "$nullglob_was_set" -eq 0 ]] && shopt -u nullglob
		for GPG_FILE in "${GPG_FILES[@]}"; do
			# if [[ "$GPG_DIR" == *"/apt/"* && "$GPG_FILE" == *"termux-pacman.gpg" ]]; then
			# 	continue
			# fi
			# Create or overwrite key symlink
			ln -sf "$GPG_FILE" "$GPG_DIR/$(basename "$GPG_FILE")"
		done
		# Creation of trusted files
		#if [[ "$GPG_DIR" == *"/pacman/"* ]]; then
		#	echo "998DE27318E867EA976BA877389CEED64573DFCA:4:" > "$GPG_DIR/termux-pacman-trusted"
		#fi
	done
}

termux_step_create_debscripts() {
	# pacman setup is intentionally disabled.
	:
	# if [ "$TERMUX_PACKAGE_FORMAT" = "pacman" ]; then
	# 	echo "if [ ! -d $TERMUX_PREFIX/etc/pacman.d/gnupg/ ]; then" > postupg
	# 	echo "  pacman-key --init" >> postupg
	# 	echo "fi" >> postupg
	# 	echo "pacman-key --populate" >> postupg
	# 	echo "post_upgrade" > postinst
	# fi
}
