export MANAGE_ALL_PTYS=no
export PALETTE_DIR=/etc/palettes
export PALETTE_FILE=.palette
export DEFAULT_PALETTE=dkeg-harbing-dark
paleta="$(command -v paleta)"

cwd_palette_file() {
	echo -e "$(pwd)/$PALETTE_FILE"
}

cwd_has_palette_file() {
	if [[ -f "$(pwd)/$PALETTE_FILE" ]]; then
		true
	else
		false
	fi
}

msg() {
	local dbg="pid:$$|cwd:$(pwd)"
	local msg="$@|$dbg"
	if ! ansi --yellow --italic --faint --bg-black "$msg" 2>/dev/null; then
		echo "$msg"
	fi
} >&2

lp() {
	msg "Loading Palette.."
	eval $paleta < <(echo -e "$1")
}

rp() {
	{

		if [[ -f ~/.cache/current-palette ]]; then
			#if [[ -f ~/.cache/current-palette ]]; then
			ct="$(stat ~/.cache/current-palette | grep ^Modify | cut -d ' ' -f2,3 | cut -d: -f1,2)"

			msg "Restoring cached palette from $ct"
			[[ -f ~/.cache/current-palette ]] && cat ~/.cache/current-palette

		fi

	} >&2

}

main() {
	if cwd_has_palette_file; then
		PF=$(cwd_palette_file)
	else
		PF=$PALETTE_DIR/$DEFAULT_PALETTE
	fi

	lp "$(cat $PF)"
}

ls_palettes() {
	ls $PALETTE_DIR/*-*-* | xargs -I % basename % | sort -u
}

main >&2
