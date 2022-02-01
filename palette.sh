export MANAGE_ALL_PTYS=no
export PALETTE_DIR=/etc/palettes
export PALETTE_FILE=.palette
#export DEFAULT_PALETTE=dkeg-harbing-dark
export DEFAULT_PALETTE=dkeg-blend-dark
paleta="$(command -v paleta)"
export PALETTE_LOADER_ENABLED=1
LOADING_DEFAULT=

cat_palette(){
  echo -e "cat $(pwd)/$PALETTE_FILE 2>/dev/null || cat $PALETTE_DIR/$DEFAULT_PALETTE"
}

cmd(){
  sh -c "test '$PALETTE_LOADER_ENABLED' == '1'" && echo "eval $paleta < <($(cat_palette))"
}

main(){
  eval "$(cmd)"
}

if [[ "$PALETTE_LOADER_ENABLED" == "1" ]]; then
  main >&2
fi
return

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
	local dbg="pid:$$|cwd:$(pwd)|default:$LOADING_DEFAULT|"
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
		if [[ -f ~/.cache/current-palette ]]; then
			#if [[ -f ~/.cache/current-palette ]]; then
			ct="$(stat ~/.cache/current-palette | grep ^Modify | cut -d ' ' -f2,3 | cut -d: -f1,2)"
			msg "Restoring cached palette from $ct"
			[[ -f ~/.cache/current-palette ]] && cat ~/.cache/current-palette
		fi
} >&2

main() {
	if cwd_has_palette_file; then
    LOADING_DEFAULT=1
		PF=$(cwd_palette_file)
	else
    LOADING_DEFAULT=0
		PF=$PALETTE_DIR/$DEFAULT_PALETTE
	fi
	lp "$(cat $PF)"
} >&2

ls_palettes() {
	ls $PALETTE_DIR/*-* | xargs -I % basename % | sort -u
}

main
