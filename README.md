### NAME
impage - image browser using html

### USAGE
       impage [OPTIONS] [CSV]... [DIRECTORIES/FILES]...

### DESCRIPTION
Impage creates webpage interlinked to in-place images to allow
browsing them together.  Input is either the CSV file, or
directories with images.

CSV file expects fields: path, cluster, dist, pdist and bad
form the imclust tool.

For relative paths, the output location is current directory,
for absolute paths it is the /tmp/impage... directory.  If at
least one path is absolute, the rest is converted to absolute.

### OPTIONS
         -h  This help.
         -v  More verbose.
    -r ROOT  Root directory, needed if relative path in CSV requires it.
      -s/-m  Singlepage/multipage output.
         -t  Use thumbnails (to speedup remote access).
        -tt  Also reference thumbnails when clicking on image (not orig).
      -tpng  Make png thumbnails.
      -topq  Make opaque thumbnails, ignore alpha channel.
       -tcp  Copy orig images as a thumbnails.
     -q=NUM  Quality for jpeg compression of thumbnails (dflt. 75).
    -g=GEOM  Geometry of thumbnails (aka 128, x196, 640x480).
      -gmax  Don't limit the size of images displayed.
    -rl/-rr  Rotate images left/right, when making thumbnails.

### EXAMPLES
       To browse two directories (of any depth) of images:
           impage directory1 directory2
           firefox /tmp/impage/index.html
   
       To browse clustered images:
           imclust -csv -c 20 directory1 directory2 
           impage clust.csv
           firefox /tmp/impage/clust/index.html
   
       To browse remotely use impage -t to speedup the transfer.
       On the local site, if ssh tunel is necessary, create it:
           ssh -L 9000:localhost:9000 REMOTE_IP -p REMOTE_SSH_PORT
       Where the REMOTE_IP is IP of remote host (aka 192.168.0.10)
       accesible through ssh using the REMOTE_SSH_PORT port.
       Then, on the remote site:
           imclust -csv -c 20 directory1 directory2 
           impage -t clust.csv
           twistd -n web -l /dev/null -p tcp:9000 --path /
       This setup exposes everything on disk visible to you, to
       allow you to see images located anywhere on disk.  If you
       don't want this, use only relative paths in the impage and
       expose only a selected directory (example below).  Then use
       the browser on the local site:
           firefox localhost:9000/tmp/impage/clust
   
       To browse remotely from self-contained directory: on the
       remote site, copy images to the target directory:
           cp -a /absolutepath/directory1 /tmp/impage/img
       Then cluster it and impage using only relative paths:
           cd /tmp/impage
           imclust -csv -c 20 img
           impage -t clust.csv
       Then expose only the target directory:
           twistd -n web -l /dev/null -p tcp:9000 --path /tmp/impage
        or busybox httpd -f -p 9000 -h /tmp/impage
       And browse:
           firefox localhost:9000/clust

### REQUIRES
       parallel and ImageMagick to create thumbnails (with -t)

### VERSION
impage-0.3 R.Jaksa 2021 GPLv3

