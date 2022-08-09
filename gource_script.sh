gource \
    -s 0.1 \
    -hide filenames \
    -1280x720 \
    --auto-skip-seconds .1 \
    --multi-sampling \
    --stop-at-end \
    --highlight-users \
    --date-format "%m/%d/%y" \
    --hide mouse,filenames \
    --file-idle-time 0 \
    --max-files 0  \
    --background-colour 000000 \
    --font-size 25 \
    --output-ppm-stream - \
    | ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset ultrafast -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 ~/Desktop/gource2.mp4


    ffmpeg -i gource2.mp4 -i mactonite_-_Warp_Drive_1.mp3 -c:v copy -c:a aac Balto.mp4
