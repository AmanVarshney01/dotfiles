WALLPAPER_DIR="$HOME/wallpapers"
INTERVAL=600

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist"
    exit 1
fi

change_wallpaper() {
    WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null))

    if [ ${#WALLPAPERS[@]} -eq 0 ]; then
        echo "Error: No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi
z
    SELECTED_WALLPAPER="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"

    echo "$(date): Setting wallpaper: $SELECTED_WALLPAPER"

    hyprctl hyprpaper reload ",$SELECTED_WALLPAPER"

    echo "$(date): Wallpaper changed successfully!"
}

sleep 5
change_wallpaper

while true; do
    sleep $INTERVAL
    change_wallpaper
done
